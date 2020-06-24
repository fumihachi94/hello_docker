# cron書き方

参考サイト 
- [Cronの使い方とテクニックと詰まったところ - Qiita](https://qiita.com/UNILORN/items/a1a3f62409cdb4256219)
- [クーロン(cron)をさわってみるお - Qiita](https://qiita.com/katsukii/items/d5f90a6e4592d1414f99)


# Dockerイメージのビルド

```
# Dockerイメージのビルド 
$ docker image build -t sample/cronjob:latest .

# イメージの実行
$ docker container run -d --rm --name cronjob sample/cronjob:latest
```

# 実行結果logの確認

```
$ docker container exec -it cronjob tail -f /var/log/cron.log
```

# cron-example

10s毎に実行する場合

```
* * * * *         root  for i in `seq 0 10 59`;do (sleep ${i}; sh /usr/local/bin/task.sh ) & done;
```

1分毎に実行する場合

```
* * * * *         root  sh /usr/local/bin/task.sh 
```

# コンテナにアクセス

```
$ docker exec -it cronjob bash 
```