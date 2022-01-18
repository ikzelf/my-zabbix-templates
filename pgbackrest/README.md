import the template, link to the pgbackrest server
template "pgbackrest server-v5.xml" is meant for zabbix-v5


put pgbackrest_zabbix.sh in ~pgbackrest/bin/
pgbackrest_zabbix.sh is tested with
  . jq-1.5
  . pgbackrest-2.36

Use crontab to schedule pgbackrest_zabbix.sh


01 * * * * $HOME/bin/pgbackrest_zabbix.sh >/var/log/pgbackrest/pgbackrest_zabbix.sh.log 2>&1
