### 创建备份用户

```mysql
CREATE USER 'dumper'@'localhost' IDENTIFIED BY 'dumper';

GRANT SELECT, PROCESS, SHOW VIEW, LOCK TABLES, EVENT ON *.* TO 'dumper'@'localhost';

FLUSH PRIVILEGES;

```



### 脚本内容

```shell
#!/bin/bash
# 备份目录
BACKUP=/opt/backup
# 当前时间
DATETIME=$(date +%Y-%m-%d_%H%M%S)
echo $DATETIME

#数据库地址
HOST=localhost

#数据库用户名
DB_USER=dumper
#数据库密码
DB_PW=dumper
#备份的数据库名
DATABASE=phi_daily

# 备份数据库
mysqldump --host=${HOST} -u${DB_USER} -p${DB_PW} --databases ${DATABASE} > ${BACKUP}/${DATABASE}/${DATABASE}_${DATETIME}.sql

# 删除10天前的备份文件
find ${BACKUP}/${DATABASE} -type f -name "*.sql" -mtime +10 -exec rm {} \;
echo "备份数据库【${DATABASE}】成功~"
```

```shell
#!/bin/bash
# 备份目录
BACKUP=/opt/backup
# 当前时间
DATETIME=$(date +%Y-%m-%d_%H%M%S)
echo $DATETIME

#数据库地址
HOST=localhost

#数据库用户名
DB_USER=dumper
#数据库密码
DB_PW=dumper
#备份的数据名 $1是第一个参数
DATABASE=$1

[ ! -d "${BACKUP}/${DATABASE}" ] && mkdir -p "${BACKUP}/${DATABASE}"

# 备份数据库
/opt/docker/bin/docker exec mysql8 /bin/bash -c "exec /bin/mysqldump --host=${HOST} -u${DB_USER} -p${DB_PW} --databases ${DATABASE}" > ${BACKUP}/${DATABASE}/${DATABASE}_${DATETIME}.sql

# 删除10天前的备份文件
find ${BACKUP}/${DATABASE} -type f -name "*.sql" -mtime +10 -exec rm {} \;
echo "备份数据库【${DATABASE}】成功~"
```
### 添加定时任务
命令：
添加定时任务：`crontab -e`
查看定时任务：`crontab -l`

```shell
# 每分钟执行一次测试脚本是否可用
* * * * * /opt/backup/mysql_dump.sh phi_daily

# 定时任务内容
# 凌晨两点备份执行数据库备份脚本
0 2 * * * /opt/backup/mysql_dump.sh phi_daily
注意：
通过定时任务执行脚本备份时，备份文件大小为0 是因为 crontab找不到命令
像 mysqldump、docker这些，都需要写全绝对路径
```
