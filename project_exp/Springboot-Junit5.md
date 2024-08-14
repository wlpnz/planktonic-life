# Junit5应用

```xml
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-test</artifactId>
  <scope>test</scope>
</dependency>
```
**测试类**
```java
@ExtendWith(SpringExtension.class)
@SpringBootTest(classes = MpTenantApplication.class)
class UserMapperTest {

    @Autowired
    private UserMapper userMapper;

    @Test
    void myCount() {
        Integer count = userMapper.myCount();
        System.out.println(count);
    }
    // other test methods
}
```
