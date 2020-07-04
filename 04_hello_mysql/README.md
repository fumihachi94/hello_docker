## Data Volume Container によるデータ保持

MySQLのデータをData Volumeコンテナに保持するデモ。
※ ただし、Data Volumeコンテナは同一Docker Host内でのみ有効

### 1. Build Docker image

```
$ docker image build -t sample/mysql-data:latest .
```

### 2. Run Data Volume Container

```
$ docker container run -d --name mysql-data sample/mysql-data:latest
```

This is run the only busybox's sh commmand, so finish immediately after execution.

### 3. Run MySQL Container

```
$ docker container run -d --rm --name mysql \
-e "MYSQL_ALLOW_EMPTY_PASSWORD=yes" \
-e "MYSQL_DATABASE=volume_test" \
-e "MYSQL_USER=hoge" \
-e "MYSQL_PASSWORD=hoge" \
--volumes-from mysql-data mysql:5.7

$ docker container exec -it mysql mysql -u root -p volume_test
※password is empty.
```


```sh
# Create table
mysql> CREATE TABLE user(
    id int PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255)
)   ENGINE=InnoDB DEFAULT CHARSET = utf8mb4 COLLATE utf8mb4_unicode_ci; 

# Add new data to table
mysql> insert into user (name) values ('nogizaka'), ('keyakizaka'), ('hinatazaka');

# Show all table list
mysql> show tables;
+-----------------------+
| Tables_in_volume_test |
+-----------------------+
| user                  |
+-----------------------+
1 row in set (0.00 sec)

# Show contents of table
mysql> select * from user;
+----+------------+
| id | name       |
+----+------------+
|  1 | nogizaka   |
|  2 | keyakizaka |
|  3 | hinatazaka |
+----+------------+
3 rows in set (0.00 sec)
```

### 4. Stop MySQL Container

```sh
$ docker container stop mysql
```

### 5. Run MySQL Container again

```sh
$ docker container run -d --rm --name mysql \
-e "MYSQL_ALLOW_EMPTY_PASSWORD=yes" \
-e "MYSQL_DATABASE=volume_test" \
-e "MYSQL_USER=hoge" \
-e "MYSQL_PASSWORD=hoge" \
--volumes-from mysql-data mysql:5.7

$ docker container exec -it mysql mysql -u root -p volume_test
※password is empty.
```

```sh
# Show contents of table
mysql> select * from user;
+----+------------+
| id | name       |
+----+------------+
|  1 | nogizaka   |
|  2 | keyakizaka |
|  3 | hinatazaka |
+----+------------+
3 rows in set (0.00 sec)

# Delete table
mysql> drop table user;
Query OK, 0 rows affected (0.14 sec)

```

一度コンテナを停止/破棄してもデータが残っていることが確認できました。