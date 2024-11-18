# SpringBoot整合Dozer

### dozer

dozer通过配置两个对象属性字段的映射以及Mapper类完成对象转换

### 封装示例

**依赖**

```xml
<dependency>
    <groupId>com.github.dozermapper</groupId>
    <artifactId>dozer-spring-boot-starter</artifactId>
    <version>6.5.0</version>
</dependency>
```

**配置**

在resources/dozer下新建下面两个xml文件

**blobal.dozer.xml**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<mappings xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xmlns="http://dozermapper.github.io/schema/bean-mapping"
          xsi:schemaLocation="http://dozermapper.github.io/schema/bean-mapping
                              http://dozermapper.github.io/schema/bean-mapping.xsd">
    <!--
    全局配置:
    <date-format>表示日期格式
     -->
    <configuration>
        <date-format>yyyy-MM-dd</date-format>
    </configuration>
</mappings>
```

**biz.dozer.xml**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<mappings xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xmlns="http://dozermapper.github.io/schema/bean-mapping"
          xsi:schemaLocation="http://dozermapper.github.io/schema/bean-mapping
                             http://dozermapper.github.io/schema/bean-mapping.xsd">
    <!--描述两个类中属性的对应关系，对于两个类中同名的属性可以不映射-->
    <mapping date-format="yyyy-MM-dd HH:mm:ss">
        <class-a>com.example.server.entity.UserEntity</class-a>
        <class-b>com.example.server.entity.UserDTO</class-b>
        <field>
            <a>id</a>
            <b>userId</b>
        </field>
        <field>
            <a>name</a>
            <b>userName</b>
        </field>
        <field>
            <a>age</a>
            <b>userAge</b>
        </field>
    </mapping>
    <!--
    	指定map-id, 可以在程序中使用；
		这里不指定date-format，会自动使用全局配置
    -->
    <mapping map-id="user">
        <class-a>com.example.server.entity.UserEntity</class-a>
        <class-b>com.example.server.entity.UserDTO</class-b>
        <field>
            <a>id</a>
            <b>userId</b>
        </field>
        <field>
            <a>name</a>
            <b>userName</b>
        </field>
        <field>
            <a>age</a>
            <b>userAge</b>
        </field>
    </mapping>
</mappings>
```

**application.yml**

```yaml
# dozer配置
dozer:
  mappingFiles:
    - classpath:dozer/global.dozer.xml
    - classpath:dozer/biz.dozer.xml
```

**两个实体类**

```java
@Data
public class UserEntity {
    private String id;
    private String name;
    private int age;
    private String address;
    private Date birthday;
}

@Data
public class UserDTO {
    private String userId;
    private String userName;
    private int userAge;
    private String address;
    private String birthday;
}
```

**使用**

```java
@Autowired
private Mapper mapper;

// 默认情况  userDTO 实例对象 ==> UserEntity
UserEntity user = mapper.map(userDTO, UserEntity.class);
System.out.println(user);

// 指定map-id    userDTO 实例对象 ==> UserEntity 通过map-id
UserEntity user = mapper.map(userDTO, UserEntity.class, "user");
System.out.println(user);

// 两个实例对象   userDTO 实例对象 ==> userEntity 实例对象  
// userEntity的内容会被覆盖
mapper.map(userDTO,userEntity, "user");
```

