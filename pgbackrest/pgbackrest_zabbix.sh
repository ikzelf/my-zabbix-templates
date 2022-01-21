#!/usr/bin/env bash
# read all configs from /etc/pgbackrest/*.conf where each tenant has an own file
# filename convention: pgbackrest.conf -> default -> tenant ""
#                      pgbackrest_xxx.conf        -> tenant "xxx"
# data is sent per tenant to the same key
# in zabbix 5.0.16 this gives weird behaviour for the character items
# the items like wal, version and status - that all come from character data
# become invalid after accepting their data. This is already annoying by itself
# for zabbix now disrespects the disregard unchanged setting in the items
# sounds like a zabbix bug to me.
# since the zabbix_sender limits are not very clear the files are saved
# in /tmp/pgbackrest_zabbix.data.$tenant.$USER so it can be checked for sizing when
# problems arrize with a big list of database per config.
# a database + 1 standby gives about 1500 bytes in the data json.

function missing_tool()
{
    {
    echo "$1" not in PATH
    echo is "$1" installed, if not, first install "$1"
    } >&2
    exit 1
}

# type pgbackrest >/dev/null 2>&1    || missing_tool pgbackrest
type jq >/dev/null 2>&1            || missing_tool jq
type zabbix_sender >/dev/null 2>&1 || missing_tool zabbix_sender

DEBUG=""
if [ "$1" = "-d" ]
then
    DEBUG="echo"
fi

date
NOW=$(date +%s)
export NOW
echo
echo sending discovery structure
echo
ls /etc/pgbackrest/*.conf |
   while read toplevel
   do
        tenant=$( (basename "$toplevel")|sed "s/.conf//"|sed "s/.*_//"|sed "s/pgbackrest//")
        echo "toplevel: $toplevel tenant: $tenant" >&2
        pgbackrest info --output json --config "$toplevel" |
        jq --arg tenant "$tenant" 'map([ .backup[] + {name} ])
        | .[]
        | [{ tenant: $tenant, name: .[].name, type: .[].type }]
        | sort
        | unique
           '
   done  |
    jq -n '[inputs|.[]]' |                 #### all in one big array
        tee "/tmp/pgbackrest_zabbix.json.$USER" |    # for debugging issues
        tr "\n" " " |                      # one line
        sed "s/^/- pgbackrest.json /" |    #### add hostname + itemkey. hostname - is taken from config
        if [ "$DEBUG" ]
        then
            cat
        else
            zabbix_sender -c /etc/zabbix/zabbix_agentd.conf -i -
        fi


echo
echo sending data only latest backup per name per type per tenant
echo
ls /etc/pgbackrest/*.conf |
    while read toplevel
    do
        tenant=$( (basename "$toplevel")|sed "s/.conf//"|sed "s/.*_//"|sed "s/pgbackrest//")
        echo "toplevel: $toplevel tenant: $tenant" >&2
        pgbackrest info --output json --config "$toplevel"  |
           jq 'map(.archive[] + .backup[] + {name}) | group_by([.name, .type]) | map(max_by(.timestamp.stop))
'        | jq --arg tenant "$tenant" --arg NOW "$NOW" -r 'map(.timestamp.age = ($NOW|tonumber) - .timestamp.stop)
                                                      | map(.tenant = $tenant)
'        |
        tee "/tmp/pgbackrest_zabbix.data.$tenant.$USER" |
        tr "\n" " " |
        sed "s/^/- pgbackrest.data /" |    #### add hostname + itemkey. hostname - is taken from config
        if [ "$DEBUG" ]
        then
            cat
        else
            zabbix_sender -c /etc/zabbix/zabbix_agentd.conf -i -
        fi
    done
