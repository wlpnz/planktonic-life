# SpringBoot整合validator

### 介绍

validator用于请求参数校验

**maven坐标**

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-validation</artifactId>
</dependency>
```

### 常用注解

| 注解                      | 说明                                                         |
| ------------------------- | ------------------------------------------------------------ |
| @AssertTrue               | 用于boolean字段，该字段只能为true                            |
| @AssertFalse              | 用于boolean字段，该字段只能为false                           |
| @CreditCardNumber         | 对信用卡号进行一个大致的验证                                 |
| @DecimalMax               | 只能小于或等于该值                                           |
| @DecimalMin               | 只能大于或等于该值                                           |
| @Email                    | 检查是否是一个有效的email地址                                |
| @Future                   | 检查该字段的日期是否是属于将来的日期                         |
| @Length(min=,max=)        | 检查所属的字段的长度是否在min和max之间,只能用于字符串        |
| @Max                      | 该字段的值只能小于或等于该值                                 |
| @Min                      | 该字段的值只能大于或等于该值                                 |
| @NotNull                  | 不能为null                                                   |
| @NotBlank                 | 不能为空，检查时会将空格忽略                                 |
| @NotEmpty                 | 不能为空，这里的空是指空字符串                               |
| @Pattern(regex=)          | 被注释的元素必须符合指定的正则表达式                         |
| @URL(protocol=,host,port) | 检查是否是一个有效的URL，如果提供了protocol，host等，则该URL还需满足提供的条件 |

### 简单示例

**实体类**

```java
@Data
public class UserVO implements Serializable {
    private static final long serialVersionUID = 1L;
    @NotNull(message = "id不能为空", groups = Update.class)
    private String userId;
    @NotNull(message = "昵称不能为空")
    @Size(min = 2, max = 30, message = "昵称最少{min}位，最长{max}位")
    private String username;
}
```

**分组接口**

```java
import javax.validation.groups.Default;
public interface Update extends Default {}
```

**使用**

```java
@PostMapping("/test")
@ApiOperation("不分组的validated验证")
public String test(@RequestBody @Validated UserVO user) {
    // 没有设置分组时，只会校验 没有分组设置的字段
    return user.toString();
}

@PostMapping("/test_update")
@ApiOperation("测试update分组的validated")
public String testUpdate(@RequestBody @Validated({Update.class})UserVO user) {
    // 当有设置分组时，会校验 自己分组的字段 和 没有分组设置的字段
    return user.toString();
}
```

