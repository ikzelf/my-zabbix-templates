#!/usr/bin/env bash

type zabbix_sender >/dev/null 2>&1
if [ $? -ne 0 ]
then
    echo "zabbix_sender not in PATH"
    echo "is zabbix_sender installed?"
    exit 1
fi >&2

date
NOW=$(date +%s)
export NOW
pgbackrest info --output json |
   jq -r 'map([ .backup[] + {name} ]
         | max_by(.timestamp.stop))
' | jq --arg NOW "$NOW" -r 'map(.timestamp.age = ($NOW|tonumber) - .timestamp.stop)
' |
        tr "\n" " " |
        sed "s/^/- pgbackrest.json /" |    #### add hostname + itemkey. hostname - is taken from config
        zabbix_sender -c /etc/zabbix/zabbix_agentd.conf -i -

