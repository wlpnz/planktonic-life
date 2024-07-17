### &、*、<<:
**示例**
```yaml
development: &defaults
  adapter:  postgres
  host:     localhost

production:
  database: myapp_development
  <<: *defaults

//相当于
production:
  database: myapp_development
  adapter:  postgres
  host:     localhost
```
**说明**
重复的节点（对象）首先由锚（&）定义别名，然后用星号（*）引用别名。
&
&用来设置节点的别名。
development: &defaults 表示设置development的别名为defaults。
*****
*用来引用节点数据，其实就是从节点取数据。
*defaults表示引用名称为defaults的别名节点信息。
**<<:**
<<: 用来把符号后面的内容插入该节点。
production:
<<: *defaults
表示把defaults节点的所有信息插入到production节点中。

### ${key:default_value}
示例：
```yaml
spring:
  redis:
    #数据库索引
    database: ${REDIS_DB:0}
    host: ${REDIS_HOST:127.0.0.1}
    port: ${REDIS_PORT:6379}
    password: ${REDIS_PWD:''}
    #连接超时时间
    timeout: 5000
```
用法说明
${key:default_value} 这种表达方式是通过key来获取value，如果获取不到就使用后面默认值。
在一些直接通过Jar包启动的场景中，可以在启动时手动配置相关参数，如果没有配置，也会自动获取默认值进行启动，如
```yaml
java -jar -REDIS_HOST=172.16.0.36 -REDIS_DB=2  xxx.jar
```
key也可以通过配置项来获取，如：
```yaml
//application
spring:
  application:
    name: app-test
project:
  name: ${spring.application.name:project-test}
```

