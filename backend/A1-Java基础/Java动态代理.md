# Java动态代理

### Java自带接口实现代理

在 Java 中，动态代理（Dynamic Proxy）是通过 `java.lang.reflect.Proxy` 类和 `InvocationHandler` 接口来实现的。动态代理允许在运行时动态生成代理类，而无需手动编写代理类代码。

动态代理通常用于 AOP（面向切面编程），例如记录日志、性能监控、安全控制等场景。

基础实现：

```java
// 自定义接口
public interface DemoService {
    String hello();
}
```

```java
// 自定义接口实现
public class DemoServiceImpl implements DemoService{
    @Override
    public String hello() {
        System.out.println("Hello");
        return "Hello";
    }
}
```

```java
// 实现InvocationHandler接口
public class ServiceInvocationHandler implements InvocationHandler {

    private Object target;

    public ProxyFactory(Object target) {
        this.target = target;
    }
    
	//代理方法的实现
    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        System.out.println("method exec before");
        //原方法调用
        Object invoke = method.invoke(target, args);
        if(invoke instanceof String){
            invoke += " proxy";
        }
        System.out.println("method exec after");
        return invoke;
    }
}
```

```java
public class ProxyTest {

    public static void main(String[] args) {
        DemoService demoService = new DemoServiceImpl();
        ServiceInvocationHandler handler = new ServiceInvocationHandler(demoService);
        //通过java.lang.reflect.Proxy类的newProxyInstance方法创建代理类
        DemoService proxyInstance = (DemoService) Proxy.newProxyInstance(
            	demoService.getClass().getClassLoader(),
                demoService.getClass().getInterfaces(),
                handler);

        System.out.println(proxyInstance.hello());
    }
}
```

```java
// 输出：
method exec before
Hello
method exec after
Hello proxy
```

### cglib实现代理

CGLIB（Code Generation Library）是一个强大的字节码生成库，允许在运行时动态生成类并实现代理。与 Java 的 `java.lang.reflect.Proxy` 不同，CGLIB 可以为没有实现接口的类创建代理，因为它是通过生成子类来实现的。

首先需要引入依赖

```xml
<dependency>
    <groupId>cglib</groupId>
    <artifactId>cglib</artifactId>
    <version>3.3.0</version>
</dependency>
```

```java
//被代理的类
public class Service {
    public void performTask() {
        System.out.println("Executing task in Service");
    }
}
```

```java
// 代理方法拦截器
public class ServiceInterceptor implements MethodInterceptor {

    // 实现代理方法
    @Override
    public Object intercept(Object obj, Method method, Object[] args, MethodProxy proxy) throws Throwable {
        System.out.println("Before method: " + method.getName());
        
        // 调用目标对象的方法
        Object result = proxy.invokeSuper(obj, args);
        
        System.out.println("After method: " + method.getName());
        return result;
    }
}
```

```java
import net.sf.cglib.proxy.Enhancer;

public class CglibProxyTest {
    public static void main(String[] args) {
        // 创建 Enhancer 对象
        Enhancer enhancer = new Enhancer();
        // 设置父类
        enhancer.setSuperclass(Service.class);
        // 设置拦截器
        enhancer.setCallback(new ServiceInterceptor());
        // 创建代理对象
        Service proxyService = (Service) enhancer.create();
        
        // 调用代理对象的方法
        proxyService.performTask();
    }
}
```

```java
// 输出
Before method: performTask
Executing task in Service
After method: performTask
```

