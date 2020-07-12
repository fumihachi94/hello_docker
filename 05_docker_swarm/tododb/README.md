# docker-mysql

TODOアプリで使うMySQLイメージを構築するためのリポジトリをクローンしてくる。
```bash
git clone https://github.com/gihyodocker/tododb.git
```

## Derectory components

ファイル構成は以下のようになっている。
```bash
$ tree .
.
├── Dockerfile
├── LICENSE
├── README.md
├── add-server-id.sh
├── etc
│   └── mysql
│       ├── conf.d
│       │   └── mysql.cnf
│       └── mysql.conf.d
│           └── mysqld.cnf
├── init-data.sh
├── prepare.sh
└── sql
    ├── 01_ddl.sql
    └── 02_dml.sql

5 directories, 10 files
```

## データベース・コンテナ構成

- MySQLコンテナイメージ：mysql:5.7
- Master/Slave両方の役割をする単一Dockerイメージ作成
- **環境変数`MYSQL_MASTER`の値でMaster/Slaveを制御**
- Slaveを増やす場合はreplicasを増やすことで対応
- 上記作業でMaster/Slaveの一時停止（ダウンタイム）は許容

## 認証情報

MASTER
|Paht|Description|Value|
|--|--|--|
|MYSQL_ROOT_PASSWoRD|Root user's password|gihyo|
|MYSQL_DATABASE|Database of ToDo application|tododb|
|MYSQL_USER|User of database| gihyo|
|MYSQL_PASSWORD| Password| gihyo|

SLAVE
|Paht|Description|Value|
|--|--|--|
|MYSQL_MASTER_HOST|Name of Mater host| master|
|MYSQL_ROOT_PASSWORD|Root user's password|gihyo|
|MYSQL_DATABASE|Database of ToDo application|tododb|
|MYSQL_USER|User of database| gihyo|
|MYSQL_PASSWORD| Password| gihyo|
|MYSQL_REPL_USER|Replication user who registrate to master|repi|
|MYSQL_REPL_PASSWORD|Replication user's password|gihyo|

## MYSQL Setting

- etc/mysql/mysql.conf.d/mysqld.cnf

```cnf
[mysqld]
character-set-server = utf8mb4
collation-server = utf8mb4_general_ci
pid-file	= /var/run/mysqld/mysqld.pid
socket		= /var/run/mysqld/mysqld.sock
datadir		= /var/lib/mysql
#log-error	= /var/log/mysql/error.log
# By default we only accept connections from localhost
#bind-address	= 127.0.0.1
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
relay-log=mysqld-relay-bin 
relay-log-index=mysqld-relay-bin 

log-bin=/var/log/mysql/mysql-bin.log

# server-id = 1
```

1. **mysqld**
   mysqld は、MySQL サーバーとも呼ばれ、MySQL インストールでのほとんどの作業を実行するメインプログラムです。

2. **character-set-server** / **collation-server**
サーバーの起動時に文字コードを指定。
utf8mb4 文字セットは、文字ごとに最大 4 バイトを使用し、補助文字をサポートします。
つまり、utf8mb4にするとこのような😁絵文字も利用できます。

3.  **pid-file**
 基本的に実行中のプロセスIDなどの情報が記述されるファイルを指定。このファイルはプロセスの制御（再起動や停止など）、プロセス同士の連携などに利用されます。

4. **socket**
サーバーがローカルクライアントと通信するために使用する UNIX ソケットファイルを指定。[ソケット](http://research.nii.ac.jp/~ichiro/syspro98/socket.html)とはネットワークとプログラムを繋げる役割をするものです。

5. **datadir**
保存先ディレクトリを指定します。

6. **log-error**
サーバーから出力されるエラーメッセージを記録するファイルを指定。

7. **symbolic-links**
シンボリックリンクを利用するか指定。(1: 有効, 0: 無効）

8. **log-bin**
バイナリログの出力先を指定。レプリケーション<sup>*1</sup>にはバイナリログが必要となるので必須項目です。
    > *1: <u>レプリケーションとは</u>
    > 同じネットワーク内、もしくは遠隔地にサーバーを設置し、リアルタイムにデータをコピーする技術のこと。

9. **server-id**
MySQLサーバーを一意に識別するためのIDで、Master/Slave構成のスタック内において重複しない値を設定する必要があります。そのため、MySQLコンテナを実行したタイミングで採番し追記します。この採番を自動で行ってくれるスクリプト`add-server-id.sh`を用意されています。


## Replication setting

`prepare.sh`というスクリプトで、Master/Slave間でレプリケーション準備をし、Slaveコンテナ実行時に自動的にレプリケーション設定されるようにします。

詳細は`prepare.sh`内を確認してください。

## Dockerfile

詳細は`Dockerfile`内を確認してください。

(2)でEntrykitのインストールを行っています。Entrykitは、コンテナ実行時の処理を記述するために便利なツールで、メインプロセス前にコマンド実行したい場合に利用できます(ENTRYPOINTの"prehook"部)。Entrykitの詳しい解説は「[Entrykit のすすめ - Qiita](https://qiita.com/spesnova/items/bae6406bf69d2dc6f88b)」が参考になります。

### imageの作成

```bash
# ”ch04/tododb:latest”という名前でimageをビルド
$ docker image build -t ch04/tododb:latest .
# タグ付け
$ docker image tag ch04/tododb:latest localhost:5000/ch04/tododb:latest
# 確認
$ docker image ls
REPOSITORY                   TAG                 IMAGE ID            CREATED             SIZE
ch04/tododb                  latest              3f78beaee4da        2 minutes ago       490MB
localhost:5000/ch04/tododb   latest              3f78beaee4da        2 minutes ago       490MB
# registryにpush
$ docker image push localhost:5000/ch04/tododb:latest 
The push refers to repository [localhost:5000/ch04/tododb]
29bee73b2f65: Preparing 
<--omission-->
13cb14c2acd3: Pushed 
latest: digest: sha256:b242dafbb9fa7282e81ccacedd418c15000cc0488e3204ff7683185d6bb70c72 size: 5334
```

### Swarm上でMaster/Slaveを実行

**Swarmでデプロイ**

`todo_mysql_master`と`todo_mysql_slave`という名前のServiceが作成される。

```bash
$ docker container exec -it manager docker stack deploy -c /stack/todo-mysql.yml todo_mysql
Creating service todo_mysql_master
Creating service todo_mysql_slave
```


### 初期データを投入する

`init-data.sh`で初期データを投入する。

```sh
#!/bin/bash -e

for SQL in `ls /sql/*.sql`
do
  mysql -u root -p$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE < $SQL > /dev/null 2>&1
done
```

masterコンテナのSwarm上ノード位置を確認
このとき以下のように多段でコンテナに入るコマンドとして出力しておくと便利。

```bash
$ docker container exec -it manager docker service ps todo_mysql_master --no-trunc --filter "desired-state=running" --format "docker container exec -it {{.Node}} docker container exec -it {{.Name}}.{{.ID}} bash"

docker container exec -it 04a8fc9e6776 docker container exec -it todo_mysql_master.1.i75b868kg9tj37migmbso646z bash

$ docker container exec -it 04a8fc9e6776 docker container exec -it todo_mysql_master.1.i75b868kg9tj37migmbso646z bash
Error: No such container: todo_mysql_master.1.i75b868kg9tj37migmbso646z
```
そんなコンテナはねぇと怒られた。
うーん…とりあえずservice一覧を見てみる。

```
$ doc-it manager docker stack services todo_mysql
ID                  NAME                MODE                REPLICAS            IMAGE                              PORTS
7tzolecxdc1h        todo_mysql_master   replicated          0/1                 registry:5000/ch04/tododb:latest   
91f6f1xv9qlt        todo_mysql_slave    replicated          0/2                 registry:5000/ch04/tododb:latest
```

レプリカが0じゃん。これ動いてなくね。
ってことでworker01ノードにimageをpullしてみる。

```
$ docker container exec -it worker01 docker image pull registry:5000/ch04/tododb:latest
latest: Pulling from ch04/tododb
Digest: sha256:b242dafbb9fa7282e81ccacedd418c15000cc0488e3204ff7683185d6bb70c72
Status: Downloaded newer image for registry:5000/ch04/tododb:latest
```











