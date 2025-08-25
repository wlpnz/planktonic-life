## PostgreSQL

### docker安装

```shell
docker pull postgres:14.19

docker run -d `
 --name postgres `
 -e POSTGRES_PASSWORD=postgres `
 -v E:\develop_tool\docker\postgres\data:/var/lib/postgresql/data `
 -p 5432:5432 `
 postgres:14.19
```

### 权限管理

命令行操作

PostgreSQL安装后会默认创建一个**postgres**账号，登录需要先切换到**postgres**账号

```shell
su postgres
```

输入**psql**,进入命令行交互界面

```shell
psql
可以直接进入到命令行的原因，是psql默认情况下，就是以postgres用户去连接本地的pgsql，所以可以直接进入

可以通过 psql --help 查看更多的参数
下面是建立连接的相关参数 

Connection options:
  -h, --host=HOSTNAME      database server host or socket directory (default: "local socket")
  -p, --port=PORT          database server port (default: "5432")
  -U, --username=USERNAME  database user name (default: "postgres")
  -w, --no-password        never prompt for password
  -W, --password           force password prompt (should happen automatically)
```

```shell
\help 查看数据库级别的命令
\help create user 可以查看命令的具体详情
\? 查看PostgreSQL服务级别的命令,q：退出
```



#### 用户操作

```sql
# 区别： create user默认有连接权限，create role没有，不过可以基于选项去设置
CREATE USER name [ [ WITH ] option [ ... ] ]
CREATE ROLE name [ [ WITH ] option [ ... ] ]

# 构建一个超级管理员用户
create user root with SUPERUSER PASSWORD 'root';

# root用户登录
psql -U root -W
```

光有用户并不能登录，还需要创建数据库

```sql
create database root;
```

在创建完数据库后，可以在不退出psql的情况下直接切换到另一个数据库

```sql
# 语法
\c[onnect] {[DBNAME|- USER|- HOST|- PORT|-] | conninfo}

# 切换到数据库 dbname， 使用的用户是当前登录用户
\c dbname;

# 切换到数据库 root，使用用户是root
\c root root;
```

如果要修改用户可以用`ALTER USER`

如果要删除用户可以用`DROP USER`

列出数据库的用户列表`\du`

#### 权限操作

**PGSQL的逻辑结构**

 ![image-20250825154423132](images/PostgreSQL/image-20250825154423132.png)

PGSQL一个数据库中有多个schema，在每个schema下都有自己的相应的库表信息，权限粒度会MySQL更细一些。

在PGSQL，权限管理可以分很多层

> server、cluster、tablespace级别：这个级别一般基于pg_hba.conf去配置
>
> database级别：通过命令级别操作，grant
>
> namespace、schema级别：玩的不多...不去多了解这个～~
>
> 对象级别：通过grant命令去设置

```sql
\help grant 查看命令详情
```

```sql
# 用有权限的用户在相应库中执行
# 把当前库下dbschema下的所以表的增改查权限赋予给dbuser
grant select,insert,update on all tables in schema dbschema to dbuser; 
```

对于拥有者来说，拥有对象相应所有的操作权限。

### 数据类型

数据类型，中文社区：http://www.postgres.cn/docs/12/datatype.html

| 名称     | 说明                                                         | 对比MySQL                                                    |
| -------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 布尔类型 | boolean，标准的布尔类型，只能存储true，false                 | MySQL中虽然没有对应的boolean，但是有替换的类型，数值的tinyint类型，和PGSQL的boolean都是占1个字节。 |
| 整型     | smallint（2字节），integer（4字节），bigint（8字节）         | 跟MySQL没啥区别。                                            |
| 浮点型   | decimal，numeric（和decimal一样一样的，精准浮点型），real（float），double precision（double），money（货币类型） | 和MySQL基本也没区别，MySQL支持float，double，decimal。MySQL没有这个货币类型。 |
| 字符串型 | varchar(n) (character varying), char(n)(character), text     | 和MySQL没啥区别。<br />PGSQL的varchar类型，可以存储一个G，MySQL只能存储64KB |
| 日期类型 | date(年月日), time(时分秒), timestamp(年月日时分秒)          | 区别不大，MySQL有个datetime                                  |
| 二进制类型 | bytea-存储二进制类型                                | MySQL也支持，MySQL中是blob                      |
| 位图类型   | bit(n)（定长位图），bit varying(n)（可变长度位图）  | 就是存储0，1。MySQL也有，只是这个类型用的不多。 |
| 枚举类型   | enum，跟Java的enum一样                              | MySQL也支持。                                   |
| 几何类型   | 点，直线，线段，圆......                            | MySQL没有，但是一般开发也用不到                 |
| 数组类型   | 在类型后，追加，代表存储数组                        | MySQL没有~~                                     |
| JSON类型   | json（存储JSON数据的文本），jsonb（存储JSON二进制） | 可以存储JSON，MySQL8.x也支持                    |
| ip类型     | cidr（存储ip地址）                                  | MySQL也不支持~                                  |

### 基本操作

#### 单引号&双引号

在PGSQL中，写SQL语句时，单引号用来标识实际的值。双引号用来标识一个关键字，比如表名，字段名。

```sql
--单引号写具体的值，双引号类似MySQL的标记，用来填充关键字
--下面的葡萄牙会报错，因为葡萄牙不是关键字
select 1.414, '卡塔尔', "葡萄牙";
```

#### 类型转换

第一种方式：只需要在值的前面添加上具体的数据类型

```sql
select bit '101010101001'; -- 所见所得，类型转换成bit
```

第二种方式：在具体值的后面，添加上`::类型`，来指定类型

```sql
select '2011-11-11'::date;
select '101010101001'::bit(20); -- 类型转成bit，长度不足20,后面自动补0
select '13'::int;
```

第三种方式：使用CAST函数

```sql
select CAST(varchar '100' as int);
```

#### 布尔类型

布尔类型可以存储三个值，`true`，`false`，`null`

```sql
-- 布尔类型的约束没有那么强，true，faLse大小写随意，他会给你转，同时yes，no这种他也认识，但是需要转换
select true,false,'yes'::boolean,boolean 'no',True,FaLse,NULL::boolean
```

| 字段A | 字段B | a and b | a or b |
| ----- | ----- | ------- | ------ |
| true  | true  | true    | true   |
| true  | false | false   | true   |
| false | false | false   | false  |
| true  | NULL  | NULL    | true   |
| false | NULL  | false   | NULL   |
| NULL  | true  | NULL    | true   |
| NULL  | false | false   | NULL   |
| NULL  | NULL  | NULL    | NULL   |

#### 数值类型

##### 整形

整型比较简单，主要就是三个：

- smallint、int2：2字节
- integer、int、int4：4字节
- bigint、int8：8字节

##### 浮点型

浮点类型就关注2个 (其实是一个）

- decimal(n,m)：本质就是numeric，PGSQL会帮你转换
- numeric(n,m)：PGSQL本质的浮点类型

针对浮点类型的数据，就使用**numeric**

##### 序列

MySQL中的主键自增，是基于auto_increment去实现，MySQL里没有序列的对象。

PGSQL和Oracle十分相似，支持序列：sequence。

PGSQL可没有auto_increment。

序列的操作：

```sql
-- 删除序列
drop sequence testschema.table_id_seq;
-- 创建序列
create sequence testschema.table_id_seq;
--查询下一个值
select nextval('testschema.table_id_seq');
-- 查询当前值
select currval('testschema.table_id_seq');
```

默认情况下，sequence的起始值是0，每次nextval递增1，最大值9223372036854775807

在sequenece的值为初始值0时，调用currval会报错。

高速缓存，插入的数据比较多，可以指定高速缓存，比如一次性计算出20个后续的值，nextval时，就不可以不去计算，直接去高速缓存拿值，效率会有一内内的提升。

序列大多数的应用，是用作表的主键自增效果

使用序列实现主键自增

方式一：使用自定义序列

```sql
create table testschema.xxx(
	id bigint default nextval('testschema.table_id_seq'),
	name varchar(20)
);
insert into testschema.xxx(name) values('xxx');
select * from testschema.xxx;
```

方式二： 序列类型

PGSQL提供了序列的数据类型，可以在声明表结构时，直接指定序列的类型即可。

bigserial相当于给bigint类型设置了序列实现自增。

- smallserial
- serial
- bigserial

```sql
create table testschema.yyy(
	id bigserial,
	name varchar(20)
)
insert into testschema.yyy(name) values('222')
select * from testschema.yyy;
```

上面这种方式会自动创建一个序列，命名为：tableName_columnName_seq，例如上面sql会创建序列：yyy_id_seq

在drop表之后，序列也会被删除，因为序列在使用serial去构建时，会绑定到指定表的指定列上。

#### 数值的常见操作

针对数值有加减乘除取余这5个操作

还有其他的操作方式

| 操作符 | 描述   | 示例     | 结果 |
| ------ | ------ | -------- | ---- |
| ^      | 幂     | 2 ^ 3    | 8    |
| \|/    | 平方根 | \|/ 36   | 6    |
| @      | 绝对值 | @ -5     | 5    |
| &      | 与     | 31 & 16  | 16   |
| \|     | 或     | 31 \| 32 | 63   |
| <<     | 左移   | 1 << 1   | 2    |
| >>     | 右移   | 16 >> 1  | 8    |

数值操作也提供了一些函数，比如pi()，round(数值，位数)，floor()，ceil()

#### 字符串操作

