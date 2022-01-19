#!/usr/bin/env bash

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
ls /etc/pgbackrest/*.conf |
    while read toplevel
    do
        echo "toplevel: $toplevel" >&2
        pgbackrest info --output json --config "$toplevel"
    done |
    jq -n '[inputs|.[]]' | # add all arrays from the info commands
  jq 'map(.archive[] + .backup[] + {name}) 
    | group_by([.name, .type]) 
    | map(max_by(.timestamp.stop))
' | jq --arg NOW "$NOW" -r 'map(.timestamp.age = ($NOW|tonumber) - .timestamp.stop)
' |
        tr "\n" " " |                      # key and value, the value being 1 line
        sed "s/^/- pgbackrest.json /" |    #### add hostname + itemkey. hostname - is taken from config
        if [ "$DEBUG" ]
        then
            cat
        else
            zabbix_sender -c /etc/zabbix/zabbix_agentd.conf -i -
        fi
