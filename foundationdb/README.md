
# foundationdb使い方メモ

## コマンドラインで動作確認

docker-compose exec fdb-coordinator bash

```shell
[root@7a9d04bbc067 /]# fdbcli
Using cluster file `/var/fdb/fdb.cluster'.

The database is available.

Welcome to the fdbcli. For help, type `help'.
fdb>
```

クラスターの状態を確認

```shell
fdb> status

Using cluster file `/var/fdb/fdb.cluster'.

Configuration:
  Redundancy mode        - single
  Storage engine         - memory-2
  Coordinators           - 1
  Usable Regions         - 1

Cluster:
  FoundationDB processes - 4
  Zones                  - 4
  Machines               - 4
  Memory availability    - 6.4 GB per process on machine with least available
  Fault Tolerance        - 0 machines
  Server time            - 07/14/23 12:37:59

Data:
  Replication health     - Healthy
  Moving data            - 0.000 GB
  Sum of key-value sizes - 0 MB
  Disk space used        - 315 MB

Operating space:
  Storage server         - 1.0 GB free on most full server
  Log server             - 45.6 GB free on most full server

Workload:
  Read rate              - 7 Hz
  Write rate             - 0 Hz
  Transactions started   - 3 Hz
  Transactions committed - 0 Hz
  Conflict rate          - 0 Hz

Backup and DR:
  Running backups        - 0
  Running DRs            - 0

Client time: 07/14/23 12:37:59
```

登録

```shell
configure new triple ssd
writemode on
set shop_name "seven-eleven"


```

取得
```shell
```

削除
```shell
```
