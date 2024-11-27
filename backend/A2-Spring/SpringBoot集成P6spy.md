# SpringBoot集成P6spy

### 概述

P6Spy 是一个开源的 JDBC 中间件，可以拦截 JDBC 调用并记录 SQL 查询日志。它通过代理 JDBC 驱动来实现日志记录和 SQL 性能分析。
官网地址：[p6spy官网](https://p6spy.readthedocs.io/en/latest/install.html)

**代理流程**

- 应用程序调用 JDBC API（例如 `Connection.createStatement`）。

- P6Spy 代理类拦截调用，将 SQL 和参数记录下来。

- 实际驱动执行数据库操作。

- P6Spy 收集执行结果和耗时，并通过日志系统记录或输出。

### 使用

使用步骤：

- 导入依赖
- 修改配置文件
- 编写spy.properties配置文件

**依赖**

```xml
<dependency>
    <groupId>p6spy</groupId>
    <artifactId>p6spy</artifactId>
    <version>3.9.1</version>
</dependency>
```

**配置文件信息**

```yaml
spring:
  datasource:
    driver-class-name: com.p6spy.engine.spy.P6SpyDriver
    url: jdbc:p6spy:mysql://ip:port/database_name?useUnicode=true&characterEncoding=UTF-8&useSSL=false&useTimezone=true&serverTimezone=Asia/Shanghai&allowMultiQueries=true&autoReconnect=true&allowPublicKeyRetrieval=true
    username: root
    password: password
```

**spy.propertes**

```properties
module.log=com.p6spy.engine.logging.P6LogFactory,com.p6spy.engine.outage.P6OutageFactory
# 内置日志打印
#logMessageFormat=com.p6spy.engine.spy.appender.SingleLineFormat
#logMessageFormat=com.p6spy.engine.spy.appender.CustomLineFormat
#customLogMessageFormat=%(currentTime) | SQL耗时： %(executionTime) ms | 连接信息： %(category)-%(connectionId) | 执行语句： %(sql)
# 自定义日志打印
logMessageFormat=com.example.server.common.util.CustomP6spyLogger
# 使用控制台记录sql
appender=com.p6spy.engine.spy.appender.StdoutLogger
## 配置记录Log例外
excludecategories=info,debug,result,batc,resultset
# 设置使用p6spy driver来做代理
deregisterdrivers=true
# 日期格式
dateformat=yyyy-MM-dd HH:mm:ss
# 实际驱动
driverlist=com.mysql.cj.jdbc.Driver
# 是否开启慢SQL记录
outagedetection=true
# 慢SQL记录标准 秒
outagedetectioninterval=2
```

**自定义日志打印Logger**

```java
public class CustomP6spyLogger implements MessageFormattingStrategy {

    /**
     * 重写日志格式方法
     * now:当前时间
     * elapsed:执行耗时
     * category：执行分组
     * prepared：预编译sql语句
     * sql:执行的真实SQL语句，已替换占位
     */
    @Override
    public String formatMessage(int connectionId, String now, long elapsed, String category, String prepared, String sql, String url) {
        String msg = "消耗时间：{} ms, 执行时间 {}\n数据源: {}\n执行的SQL：{}\n";
        return StringUtils.isNotBlank(sql) ? StrUtil.format(msg, elapsed, now, url, sql.replaceAll("\\s+", " ")) : "";
    }

}
```

