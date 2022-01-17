import the template, linkt to the pgbackrest server


put pgbackrest_zabbix.sh in ~pgbackrest/bin/

Use crontab to schedule pgbackrest_zabbix.sh


01 * * * * $HOME/bin/pgbackrest_zabbix.sh >/var/log/pgbackrest/pgbackrest_zabbix.sh.log 2>&1
