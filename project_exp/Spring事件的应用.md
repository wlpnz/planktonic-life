# Spring Event的应用

### 自定义事件

#### 自定义事件

```java
//自定义事件 继承 ApplicationEvent
public class CustomEvent extends ApplicationEvent {

    public CustomEvent(MQMsg source) {
        super(source);
    }
}
```

#### 事件监听一

```java
@Component
public class CustomEventEventListener1 {

    @Async
    @EventListener
    public void onCustomEventEvent(CustomEvent event) {
        MQMsg source = (MQMsg) event.getSource();
        System.out.println("onCustomEventEvent: MQMsg >>" + source + " current thread:" + Thread.currentThread().getName());
    }
}
```

#### 发布事件

```
@Autowired
ApplicationEventPublisher publisher;

@RequestMapping("/publish")
public String test(String msg) {
    MQMsg event = new MQMsg(12, msg);
    // 发布事件
    publisher.publishEvent(new CustomEvent(event));
    return "event";
}
```

#### 事件监听的其他方式

```java
@AllArgsConstructor
public class CustomEventEventListener {

    private final Consumer<MQMsg> consumer;

    @Async
    @EventListener
    public void onCustomEventEvent(CustomEvent event) {
        MQMsg source = (MQMsg) event.getSource();
        consumer.accept(source);
    }
}

// 在配置类注册
@Bean
@ConditionalOnExpression("\"peng\".equals('${custom.listener}')")
public CustomEventEventListener customEventEventListener4() {
    return new CustomEventEventListener(data -> {
        System.out.println("peng -- 自定义事件监听器：" + data);
    });
}

@Bean
@ConditionalOnExpression("\"zhang\".equals('${custom.listener}')")
public CustomEventEventListener customEventEventListener4() {
    return new CustomEventEventListener(data -> {
        System.out.println("zhang -- 自定义事件监听器：" + data);
    });
}
```

