# SpringMVC参数解析器

### 概述

参数解析器属于spring-web包中提供的组件，springmvc框架中对应提供了很多参数解析器。例如我们开发的Controller代码如下：

~~~java
@RestController
@RequestMapping("/user")
public class UserController{
    @PostMapping("/save")
    //此处request对象就是通过Springmvc提供的参数解析器帮我们注入的
    public String saveUser(HttpServletRequest request){
        return "success";
    }
}
~~~

在上面的saveUser方法中，我们声明了一个类型为`HttpServletRequest`的参数，这个对象就是通过springmvc提供的`ServletRequestMethodArgumentResolver`这个参数解析器帮我们注入的。同样如果我们需要使用`HttpServletResponse`对象，也可以直接在方法上加入这个参数即可，此时springmvc会通过`ServletResponseMethodArgumentResolver`这个参数解析器帮我们注入。



在项目开发中我们也可以根据需要自定义参数解析器，需要实现`HandlerMethodArgumentResolver`接口：

~~~java
public interface HandlerMethodArgumentResolver {
    boolean supportsParameter(MethodParameter var1);

    @Nullable
    Object resolveArgument(MethodParameter var1, 
                            @Nullable ModelAndViewContainer var2, 
                            NativeWebRequest var3, 
                            @Nullable WebDataBinderFactory var4) throws Exception;
}
~~~

可以看到此接口包含两个接口方法：`supportsParameter`和`resolveArgument`。

当`supportsParameter`方法返回true时，才会调用`resolveArgument`方法。

### 案例

通过在Controller方法的`User`参数前添加`@CurrentUser`注解，实现当前用户信息注入`User`参数

**实体类**

```java
@Data
public class UserEntity {
    private String id;
    private String name;

    public UserEntity() {}

    public UserEntity(String id, String name) {
        this.id = id;
        this.name = name;
    }
}
```

**注解**

```java
/**
* 绑定当前登录用户
*/
@Target({ElementType.PARAMETER})
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface CurrentUser {
}
```

**自定义参数解析**

```java
import com.example.server.annotation.CurrentUser;
import com.example.server.entity.UserEntity;
import org.springframework.core.MethodParameter;
import org.springframework.web.bind.support.WebDataBinderFactory;
import org.springframework.web.context.request.NativeWebRequest;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.method.support.ModelAndViewContainer;

/**
 * 自定义参数解析器
 */
public class CurrentUserMethodArgumentResolver implements HandlerMethodArgumentResolver {
    public CurrentUserMethodArgumentResolver() {
        System.out.println("CurrentUserMethodArgumentResolver自定义参数解析器初始化...");
    }

    @Override
    public boolean supportsParameter(MethodParameter parameter) {
        //如果Controller的方法参数类型为UserEntity同时还加入了CurrentUser注解，则返回true
        if (parameter.getParameterType().equals(UserEntity.class) &&
                parameter.hasParameterAnnotation(CurrentUser.class)) {
            return true;
        }
        return false;
    }

    //当supportsParameter方法返回true时执行此方法
    @Override
    public Object resolveArgument(MethodParameter parameter, 
                                  ModelAndViewContainer mavContainer,
                                  NativeWebRequest webRequest, 
                                  WebDataBinderFactory binderFactory) throws Exception {
        System.out.println("参数解析器...");
        //此处直接模拟了一个UserEntity对象，实际项目中可能需要从请求头中获取登录用户的令牌然后进行解析，
        //最终封装成UserEntity对象返回即可，这样在Controller的方法形参就可以直接引用到User对象了
        UserEntity user = new UserEntity("123","admin");
        
        return user;
    }
}
```

**自定义参数解析器注入容器**

```java
import org.springframework.context.annotation.Configuration;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.util.List;

@Configuration
public class ArgumentResolverConfiguration implements WebMvcConfigurer {
    public CurrentUserMethodArgumentResolver getCurrentUserMethodArgumentResolver(){
        return new CurrentUserMethodArgumentResolver();
    }

    @Override
    //注册自定义参数解析器
    public void addArgumentResolvers(List<HandlerMethodArgumentResolver> resolvers) {
        resolvers.add(getCurrentUserMethodArgumentResolver());
    }
}
```

**使用**

```java
@GetMapping("/currentUser")
public String currentUser(@CurrentUser UserEntity user) {
    log.info("当前用户：{}",user.toString());
    return user.toString();
}
```

