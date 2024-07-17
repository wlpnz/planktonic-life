### 五种失效和解决方案
#### 1.类没有被Spring管理
> 解决方案：在类上添加注解，将类注入容器

#### 2.方法不是public修饰
声明式事务是基于AOP实现的，AOP是通过代理模式实现的，即为目标对象生成一个代理对象，当调用代理对象的方法时，会自动添加事务的控制代码。
在这种情况下，如果事务注释所在的方法不是public的，则无法生成代理对象，因此事务代码将无法添加到方法执行前后，导致事务失效。
> 解决方案：使用public修饰方法

#### 3.异常被捕获了
```java
@Service
public class OrderService {
    
    @Transactional(rollbackFor = Exception.class)
    public void saveData(OrderAddForm addForm) {
        try {
            orderDao.insert(addForm);
        } catch (Exception e) {
            // 处理异常
            log.error("save order error", e);
        }
    }
}
```
如上代码所示，方法中的异常被try-catch捕获，事务检测不到异常，不能及时回滚
> 解决方案：捕获的异常处理完成之后，仍然抛出去：throw e;

#### 4.方法内部调用同一类中的事务方法
```java
@Service
public class OrderService{

    public void createOrder(OrderAddForm addForm){
        this.saveData(addForm);
    }

    @Transactional(rollbackFor = Exception.class)
    public void saveData(OrderAddForm addForm){
        orderDao.insert(addForm);
    }
}
```
如上所示，在方法内部调用同一类中其他事务方法，事务失效
> 解决方案：
1.在类中通过autowired注入当前对象，然后通过当前对象调用此事务方法
2.启动类添加[@EnableAspectJAutoProxy(exposeProxy ](/EnableAspectJAutoProxy(exposeProxy ) = true)，方法内使用AopContext.currentProxy()获得代理类，使用事务。 
代码示例：

```java
//解决方案一
@Service
public class OrderService{
	
	@Autowired
	private OrderService orderService;

    public void createOrder(OrderAddForm addForm){
        orderService.saveData(addForm);
    }
	//...
}
```
```java
//解决方案二
SpringBootApplication.java ::>

@EnableAspectJAutoProxy(exposeProxy = true)
@SpringBootApplication
public class SpringBootApplication {}

OrderService.java ::>

public void createOrder(OrderCreateDTO createDTO){
    OrderService orderService = (OrderService)AopContext.currentProxy();
    orderService.saveData(createDTO);
}
```
#### MySQL存储引警不支持事务
MyISAM 存储引擎是 MySQL 的一种存储引擎，它是 MySQL 5.1 版本之前的默认存储引擎，它是不支持事务的。从 MySQL 5.5 版本开始，InnoDB 成为了 MySQL 的默认存储引擎。我们想使用也可以切换到MyISAM引擎。
> 解决方案：将存储引擎修改为支持事务的存储引擎，例如InnoDB

