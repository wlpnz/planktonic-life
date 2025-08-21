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
### Windows

> **行续行符**：在 PowerShell 中使用 **`** (反引号)，在 CMD 中使用 **^** (脱字符号)。

#### install redis

配置文件可以从别的包中获取

redis下载列表：https://download.redis.io/releases/

> 配置文件修改：
>
> - 开启密码校验： requirepass your_password
> - 允许redis外地连接 将 bind 127.0.0.1 注释
> - 取消保护模式 将protected-mode设置为no

```
docker pull redis:7.4.5

docker run -d `
  --name redis7 `
  -p 6379:6379 `
  --privileged=true `
  -v E:/develop_tool/docker/redis/redis.conf:/redis.conf `
  -v E:/develop_tool/docker/redis/data:/data `
  redis:7.4.5 `
  redis-server /redis.conf
```

> 这里将数据目录设置成/data是因为redis配置的数据目录是 `dir ./`，而redis容器的工作目录是/data，因此默认的数据目录就是/data

#### install nacos

```
docker pull nacos/nacos-server:v2.5.1
```

任意启动一容器，将容器内的配置文件复制到宿主机

```
docker run --name nacos -d nacos/nacos-server:v2.5.1
docker cp -a nacos:/home/nacos/conf E:\develop_tool\docker\nacos\
```

[配置持久化：MySQL-SQL表](https://github.com/alibaba/nacos/blob/master/distribution/conf/mysql-schema.sql?spm=5238cd80.2ef5001f.0.0.3f613b7cibtZjT&file=mysql-schema.sql)

> 本地MySQL需要将root的host修改成host，允许任何人连接。
>
> 位置：mysql数据库 -> user表
>
> 修改完，需要刷新，使配置立马生效。
>
> ```
> use mysql; 
> update user set host = '%' where user ='root';
> select Host,User from user;
> 
> flush privileges;
> ```

```
# 修改数据源配置
spring.sql.init.platform=mysql

db.num=1
db.url.0=jdbc:mysql://${mysql_host}:${mysql_port}/${nacos_database}?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true
db.user=${mysql_user}
db.password=${mysql_password}
```

```
docker run -d `
  --name nacos `
  -e MODE=standalone `
  -p 8848:8848 `
  -p 9848:9848 `
  -v E:/develop_tool/docker/nacos/conf:/home/nacos/conf `
  -v E:/develop_tool/docker/nacos/logs:/home/nacos/logs `
  -v E:/develop_tool/docker/nacos/data:/home/nacos/data `
  nacos/nacos-server:v2.5.1
```

访问地址：localhost:8848

nacos容器端口开放说明：

- **`8848`**：对所有需要访问控制台和API的**客户端**和**用户**开放。
- **`9848`**：对所有使用 Nacos 2.x 客户端的**应用程序**开放。
- **`9849`**：对**集群内的其他 Nacos 节点**开放（内网通信）。
- **`7848`**：对**集群内的其他 Nacos 节点**开放（内网通信，通常只在容器网络内部）。

确保 Nacos v2.5.1 能够正常工作，**请至少开放 `8848` 和 `9848` 端口**。如果部署集群，还必须开放 `9849` 端口。

#### install minio

> --console-address 指定Web管理页面端口
>
> --address 指定API端口

```
docker pull minio/minio:RELEASE.2024-11-07T00-52-20Z

docker run -d --name minio -p 9000:9000 -p 9001:9001 --privileged=true -e "MINIO_ROOT_USER=minioadmin" -e "MINIO_ROOT_PASSWORD=minioadmin" -v E:\develop_tool\docker\minio\data:/data -v E:\develop_tool\docker\minio\config:/root/.minio minio/minio:RELEASE.2024-11-07T00-52-20Z server --console-address ":9001" --address ":9000" /data

docker run -d `
  --name minio `
  -p 9000:9000 `
  -p 9001:9001 `
  --privileged=true `
  -e "MINIO_ROOT_USER=minioadmin" `
  -e "MINIO_ROOT_PASSWORD=minioadmin" `
  -v E:/develop_tool/docker/minio/data:/data `
  -v E:/develop_tool/docker/minio/config:/root/.minio `
  minio/minio:RELEASE.2024-11-07T00-52-20Z `
  server --console-address ":9001" --address ":9000" /data
```

访问地址：localhost:9001

账号密码：minioadmin/minioadmin

#### install rabbitMQ

```
docker pull rabbitmq:3.13.7-management

docker run -d `
  --name rabbit `
  -p 15672:15672 `
  -p 5672:5672 `
  -e RABBITMQ_DEFAULT_USER=rabbitadmin `
  -e RABBITMQ_DEFAULT_PASS=rabbitadmin `
  rabbitmq:3.13.7-management

容器内插件文件夹：/opt/rabbitmq/plugins
```




#### install xxl-job-admin

sql地址：[https://github.com/xuxueli/xxl-job/blob/master/doc/db/tables_xxl_job.sql](https://github.com/xuxueli/xxl-job/blob/master/doc/db/tables_xxl_job.sql)

```
docker pull xuxueli/xxl-job-admin:2.5.0

docker run -d `
  --name xxl-job `
  -p 8090:8080 `
  -v E:/develop_tool/docker/xxl-job-admin:/data/applogs `
  -e PARAMS="--spring.datasource.url=jdbc:mysql://192.168.104.142:3306/docker_xxl_job?useUnicode=true&characterEncoding=UTF-8&autoReconnect=true&serverTimezone=Asia/Shanghai --spring.datasource.username=root --spring.datasource.password=abc123" `
  xuxueli/xxl-job-admin:2.5.0
```

访问路径：http://localhost:8090/xxl-job-admin

账号密码：admin/123456 

#### install nginx

```
docker pull nginx:1.29.1

先启动将配置文件复制到本地
docker run --name nginx -d nginx:1.29.1
docker cp -a nginx:/etc/nginx/conf.d E:\develop_tool\docker\nginx\
docker cp -a nginx:/etc/nginx/nginx.conf E:\develop_tool\docker\nginx\
docker cp -a nginx:/usr/share/nginx/html E:\develop_tool\docker\nginx\

docker run -d `
  --name nginx `
  -p 80:80 `
  -v E:\develop_tool\docker\nginx\nginx.conf:/etc/nginx/nginx.conf:ro `
  -v E:\develop_tool\docker\nginx\conf.d:/etc/nginx/conf.d:ro `
  -v E:\develop_tool\docker\nginx\html:/usr/share/nginx/html:ro `
  -v E:\develop_tool\docker\nginx\logs:/var/log/nginx `
  nginx:1.29.1
  
# 如果需要开放新的端口，需要删除容器重新创建容器
```

#### install elasticsearch

```
docker pull elasticsearch:8.11.0 

# 先启动容器，将配置文件复制到宿主机
docker run -d --name elasticsearch -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" elasticsearch:8.11.0
docker cp -a elasticsearch:/usr/share/elasticsearch/config/ E:\develop_tool\docker\es\

# 删除上面创建的临时容器，重新创建容器
docker run -d `
  --name elasticsearch `
  -p 9200:9200 `
  -p 9300:9300 `
  -e "discovery.type=single-node" `
  -v E:/develop_tool/docker/es/data:/usr/share/elasticsearch/data `
  -v E:/develop_tool/docker/es/config:/usr/share/elasticsearch/config `
  -v E:/develop_tool/docker/es/plugins:/usr/share/elasticsearch/plugins `
  elasticsearch:8.11.0
```

