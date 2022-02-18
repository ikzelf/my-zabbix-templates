import the template, link to the pgbackrest server
template "pgbackrest server-v5.xml" is meant for zabbix-v5


put pgbackrest_zabbix.sh in ~pgbackrest/bin/
pgbackrest_zabbix.sh is tested with
  . jq-1.5
  . pgbackrest-2.36

Use crontab to schedule pgbackrest_zabbix.sh


```
01 * * * * $HOME/bin/pgbackrest_zabbix.sh >>/var/log/pgbackrest/pgbackrest_zabbix.sh.log 2>&1
```



example json used for discovery:
```
[
  {
    "tenant": "",
    "name": "db1",
    "type": "full"
  },
  {
    "tenant": "",
    "name": "db1",
    "type": "incr"
  },
]
```

for the data:
```
[
  {
    "database": {
      "id": 1,
      "repo-key": 1
    },
    "id": "12-1",
    "max": "000000050000000000000021",
    "min": "000000050000000000000010",
    "archive": {
      "start": "00000005000000000000001E",
      "stop": "00000005000000000000001E"
    },
    "backrest": {
      "format": 5,
      "version": "2.36"
    },
    "error": false,
    "info": {
      "delta": 266591264,
      "repository": {
        "delta": 17323605,
        "size": 17323605
      },
      "size": 266591264
    },
    "label": "20220124-081445F",
    "prior": null,
    "reference": null,
    "timestamp": {
      "start": 1643008485,
      "stop": 1643008498,
      "age": 111603
    },
    "type": "full",
    "name": "db1",
    "tenant": ""
  },
  {
    "database": {
      "id": 1,
      "repo-key": 1
    },
    "id": "12-1",
    "max": "000000050000000000000021",
    "min": "000000050000000000000010",
    "archive": {
      "start": "000000050000000000000020",
      "stop": "000000050000000000000020"
    },
    "backrest": {
      "format": 5,
      "version": "2.36"
    },
    "error": false,
    "info": {
      "delta": 10027519,
      "repository": {
        "delta": 522400,
        "size": 17300356
      },
      "size": 266609439
    },
    "label": "20220124-081445F_20220125-081752I",
    "prior": "20220124-081445F",
    "reference": [
      "20220124-081445F"
    ],
    "timestamp": {
      "start": 1643095072,
      "stop": 1643095075,
      "age": 25026
    },
    "type": "incr",
    "name": "db1",
    "tenant": ""
  }
]
```
