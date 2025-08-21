### Linux

```txt
docker install env
--restart=always : 总是开机启动
-d：后台启动
--name：指定容器名字
--privileged=true：赋予权限
-v：指定容器卷
-p：端口映射
```


#### install mysql
```
docker pull mysql:8.0.33
docker run -d -p 3306:3306 --privileged=true --restart=always \
-v /develop_env/mysql/log:/var/log/mysql \
-v /develop_env/mysql/data:/var/lib/mysql \
-v /develop_env/mysql/conf:/etc/mysql/conf.d \
-e MYSQL_ROOT_PASSWORD=abc123 --name mysql8 mysql:8.0.33 --lower-case-table-names=1
```
如果要设置表明小写，需要先在conf下创建文件夹，my.cnf写入

```
[mysqld]
lower_case_table_names=1 # 设置表名小写
```

#### install redis
```
docker pull redis:7.0.12
docker run \
-p 6379:6379 --restart=always  --name redis7 --privileged=true \
-v /develop_env/redis/redis.conf:/etc/redis/redis.conf \
-v /develop_env/redis/data:/data \
-d redis:7.0.12 redis-server /etc/redis/redis.conf
```

#### install nacos
任意启动一容器，将容器内的配置文件复制到宿主机
```
docker run -p 8848:8848 --name nacos -d nacos/nacos-server:1.4.1

docker cp nacos:/home/nacos/logs/ /mydata/nacos/
docker cp nacos:/home/nacos/conf/ /mydata/nacos/

docker run -d \
-e MODE=standalone \
-p 8848:8848 \
-v /develop_env/nacos/conf:/home/nacos/conf \
-v /develop_env/nacos/logs:/home/nacos/logs \
-v /develop_env/nacos/data:/home/nacos/data \
--name nacos \
--restart=always \
nacos/nacos-server:1.4.1
```
访问地址：192.168.10.190:8848
#### install minio
```
docker pull minio/minio:RELEASE.2022-09-07T22-25-02Z
mkdir -p /develop_env/minio/config
mkdir -p /develop_env/minio/data

docker run -d \
--name minio -p 9000:9000 -p 9001:9001 \
--restart=always --privileged=true \
-e "MINIO_ROOT_USER=admin" -e "MINIO_ROOT_PASSWORD=admin123" \
-v /develop_env/minio/data:/data \
-v /develop_env/minio/config:/root/.minio \
minio/minio:RELEASE.2022-09-07T22-25-02Z server \
--console-address ":9001" \
--address ":9000" /data
```
访问地址：192.168.10.190:9001 账号密码：admin/admin123

API使用端口是9000

#### install rabbitMQ
```
mkdir -p /develop_env/rabbitMQ

docker run --name rabbit -d rabbitmq:3.8.34
docker cp rabbit:/plugins/ /develop_env/rabbitMQ/
docker rm  -f rabbit
```
先将默认的插件复制到宿主机，然后正式启动容器
```
docker run -d --restart=always \
--hostname  my-rabbit --name rabbit \
-v /develop_env/rabbitMQ/plugins:/plugins \
-p 15672:15672 -p 5672:5672 rabbitmq:3.8.34

docker exec -it rabbit /bin/bash
```
管理界面配置：[RabbitMQ](/backend/A4-中间件/RabbitMQ.md#rabbitmq的安装)

管理界面账号密码：pnz/abc123

访问路径：http://192.168.10.190:15672/

#### install xxl-job-admin
```
install pull xuxueli/xxl-job-admin:2.3.1
sql地址：https://github.com/xuxueli/xxl-job/blob/master/doc/db/tables_xxl_job.sql
docker run -e PARAMS="--spring.datasource.url=jdbc:mysql://192.168.10.190:3308/xxl_job?useUnicode=true&characterEncoding=UTF-8&autoReconnect=true&serverTimezone=Asia/Shanghai \
--spring.datasource.username=root \
--spring.datasource.password=abc123" \
-p 8080:8080 -v /tmp:/data/applogs --restart=always --name xxl-job-admin -d xuxueli/xxl-job-admin:2.3.1
```
访问路径：http://192.168.10.190:8080/xxl-job-admin/

账号密码：admin/123456 wulan/abc123

#### install elasticsearch
```
docker run -d --name elasticsearch --restart=always -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" elasticsearch:7.12.1
```
#### install kibana
--like : 建立两个容器之间的关联, kibana 关联到 es
汉化的kibana

```
docker run -d --name kibana --restart=always --link elasticsearch:elasticsearch -e "I18N_LOCALE=zh-CN" -p 5601:5601 kibana:7.12.1
```
非汉化
```
docker run -d --name kibana --restart=always --link elasticsearch:elasticsearch -p 5601:5601 kibana:7.12.1
```
访问路径：192.168.10.190:5601

#### install nginx
#创建挂载目录
```
mkdir -p /develop_env/nginx/conf
mkdir -p /develop_env/nginx/log
mkdir -p /develop_env/nginx/html
```
#启动容器获取配置文件
```
docker run --name nginx -p 8899:80 -d nginx:1.12.2
docker cp nginx:/etc/nginx/nginx.conf /develop_env/nginx/conf
docker cp nginx:/etc/nginx/conf.d /develop_env/nginx/conf
docker cp nginx:/usr/share/nginx/html /develop_env/nginx
docker rm -f nginx
```
#创建容器

```
docker run \
-p 8899:80 \
--name nginx --restart=always \
-v /develop_env/nginx/conf/nginx.conf:/etc/nginx/nginx.conf \
-v /develop_env/nginx/conf/conf.d:/etc/nginx/conf.d \
-v /develop_env/nginx/log:/var/log/nginx \
-v /develop_env/nginx/html:/usr/share/nginx/html \
-d nginx:1.12.2
```
