#### 新建自定义事件
```
//自定义事件 继承 ApplicationEvent
public class SysLogEvent extends ApplicationEvent {

    // OptLogDTO：自定义系统日志类
    public SysLogEvent(OptLogDTO source) {
        super(source);
    }
}
```
#### 新建自定义事件监听
```
@Slf4j
@AllArgsConstructor
public class SysLogListener {

    private final Consumer<OptLogDTO> consumer;

    @Async
    @Order
    @EventListener(SysLogEvent.class)  //监听 SysLogEvent事件
    public void saveSysLog(SysLogEvent event) {
        OptLogDTO sysLog = (OptLogDTO) event.getSource();
        consumer.accept(sysLog);
    }
}
```

#### 注册事件监听器
```java
/**
* lamp.log.enabled = true 并且 lamp.log.type=DB时实例该类
*/
@Bean
@ConditionalOnExpression("${lamp.log.enabled:true} && 'DB'.equals('${lamp.log.type:LOGGER}')")
public SysLogListener sysLogListener(BaseOperationLogService logApi) {
// 消费者的accept设置为 往数据库中插入一条记录  
//也就是说，在事件触发后，将操作log往数据库中存储
return new SysLogListener(data -> 
  logApi.save(BeanPlusUtil.toBean(data, BaseOperationLogSaveVO.class))); //消费者的accept
}
```

#### 发布事件
```java
//ApplicationContext applicationContext
applicationContext.publishEvent(event);
```

