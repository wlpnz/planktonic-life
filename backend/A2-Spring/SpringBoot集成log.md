# SpringBoot集成log

#### 概述

SpringBoot默认带Logback

Logback继承自log4j。Logback的架构非常的通用，适用于不同的使用场景。

Logback 构建在三个主要的类上：Logger，Appender 和 Layout。这三个不同类型的组件一起作用能够让开发者根据消息的类型以及日志的级别来打印日志。 

**Logger**作为日志的记录器，把它关联到应用的对应的context后，主要用于存放日志对象，也可以定义日志类型、级别。各个logger 都被关联到一个 LoggerContext，LoggerContext负责制造logger，也负责以树结构排列各 logger。

**Appender**主要用于指定日志输出的目的地，目的地可以是控制台、文件、 数据库等。

**Layout** 负责把事件转换成字符串，输出格式化的日志信息。



#### logback日志输出等级

logback的日志输出等级分为：TRACE, DEBUG, INFO, WARN, ERROR。

如果一个给定的logger没有指定一个日志输出等级，那么它就会继承离它最近的一个祖先的层级。

为了确保所有的logger都有一个日志输出等级，root logger会有一个默认输出等级 --- DEBUG。



#### 日志格式

```xml
logging.pattern.console=%d{yyyy/MM/dd-HH:mm:ss} [%thread] %-5level %logger- %msg%n
logging.pattern.file=%d{yyyy/MM/dd-HH:mm} [%thread] %-5level %logger- %msg%n
```

> 解释
>
> %d{HH:mm:ss.SSS}——日志输出时间
>
> %thread——输出日志的进程名字，这在Web应用以及异步任务处理中很有用
>
> %-5level——日志级别，并且使用5个字符靠左对齐
>
> %logger- ——日志输出者的名字
>
> %msg——日志消息
>
> %n——平台的换行符

#### 自定义日志配置

Spring Boot官方文档指出，根据不同的日志系统，可以按照如下的日志配置文件名就能够被正确加载，如下：

1. **`Logback`**：logback-spring.xml, logback-spring.groovy, logback.xml, logback.groovy
2. **`Log4j`**：log4j-spring.properties, log4j-spring.xml, log4j.properties, log4j.xml
3. **`Log4j2`**：log4j2-spring.xml, log4j2.xml
4. **`JDK (Java Util Logging)`**：logging.properties

如果是其他名字（比如：logging-config.xml）需要通过配置指定：

```properties
logging.config=classpath:logging-config.xm
```

#### 示例

**resources/logback-base.xml**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<included>
    <contextName>logback</contextName>
    <!--
		name的值是变量的名称，value的值时变量定义的值
		定义变量后，可以使“${}”来使用变量
	-->
    <property name="log.path" value="d:\\logs" />
    <property name="log.filename" value="apiserver" />

    <!--输出到控制台-->
    <appender name="LOG_CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] [%-5level] [%logger{50}] - %msg%n</pattern>
            <!-- 设置字符集 -->
            <charset>UTF-8</charset>
        </encoder>
    </appender>

    <!--输出到文件-->
    <appender name="LOG_FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <!-- 正在记录的日志文件的路径及文件名 -->
        <file>${log.path}/${log.filename}/logback.log</file>
        <!--日志文件输出格式-->
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] [%-5level] [%logger{50}] - %msg%n</pattern>
            <charset>UTF-8</charset>
        </encoder>
        <!-- 日志记录器的滚动策略，按日期，按大小记录 -->
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <!-- 每天日志归档路径以及格式 -->
            <fileNamePattern>${log.path}/${log.filename}/info/log-info-%d{yyyy-MM-dd}.%i.log</fileNamePattern>
            <timeBasedFileNamingAndTriggeringPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">
                <maxFileSize>100MB</maxFileSize>
            </timeBasedFileNamingAndTriggeringPolicy>
            <!--日志文件保留天数-->
            <maxHistory>15</maxHistory>
        </rollingPolicy>
    </appender>
</included>
```

**resources/logback-spring.xml**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <!--引入其他配置文件-->
    <include resource="logback-base.xml" />
    <!--
        <logger>用来设置某一个包或者具体的某一个类的日志打印级别、
        以及指定<appender>。<logger>仅有一个name属性，一个可选的level和一个可选的addtivity属性。
        name:用来指定受此logger约束的某一个包或者具体的某一个类。
        level:用来设置打印级别，大小写无关：TRACE, DEBUG, INFO, WARN, ERROR, ALL 和 OFF，
              如果未设置此属性，那么当前logger将会继承上级的级别。
        addtivity:是否向上级logger传递打印信息。默认是true。
     -->

    <!--开发环境-->
    <springProfile name="dev">
        <logger name="com.example.server.controller" additivity="false" level="debug">
            <appender-ref ref="LOG_CONSOLE"/>
        </logger>
    </springProfile>
    <!--生产环境-->
    <springProfile name="prod">
        <logger name="com.example.server.controller" additivity="false" level="info">
            <!--<appender-ref ref="LOG_CONSOLE"/>-->
            <appender-ref ref="LOG_FILE"/>
        </logger>
    </springProfile>

    <!--
        root节点是必选节点，用来指定最基础的日志输出级别，只有一个level属性
        level:设置打印级别，大小写无关：TRACE, DEBUG, INFO, WARN, ERROR, ALL 和 OFF 默认是DEBUG
        可以包含零个或多个元素，标识这个appender将会添加到这个logger。
    -->
    <root level="info">
        <appender-ref ref="LOG_CONSOLE" />
        <appender-ref ref="LOG_FILE" />
    </root>
</configuration>
```

```yaml
# application.yaml
spring:
  profiles:
    active: dev
```

**使用**

正常情况：

```java
private final Logger logger= LoggerFactory.getLogger(DemoApplicationTests.class);

// method in 
logger.log("message");
```

简化情况：

可以引入`lombok`依赖，然后通过@Slf4f注解，使用Logger对象

```java
@Slf4j
public class AuthController {
 	@GetMapping("/success")
    public void success() {
    	log.info("success");
    }
}    
```

