# Dockerテンプレート

## よく使うコマンド

Volume一覧

```shell
docker volume ls
```

Volume削除

```shell
docker volume rm <volume name>
```

Image 一括削除

```shell
docker compose down --rmi all --volumes --remove-orphans
```

コンテナのIPを調べる

```shell
docker container exec -it <<container name>> hostname -i
```
