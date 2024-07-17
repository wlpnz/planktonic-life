### 依赖
```java
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
    <!-- 无需在parent的配置文件中添加 -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-amqp</artifactId>
    </dependency>

</dependencies>
```
### 配置文件
**注意：**每一队列同时只能绑定一个交换机
```java
@Configuration
public class RabbitMQConfig {
    //声明交换机
    //fanout
    public static final String FANOUT_EXCHANGE_NAME = "fanout.exchange";
    public static final String QUEUE_1 = "queue.1";
    public static final String QUEUE_2 = "queue.2";

    //direct
    public static final String DIRECT_EXCHANGE_NAME = "direct.exchange";
    public static final String DIRECT_QUEUE1_ROUTING_KEY = "direct.queue.1.routingkey";
    public static final String DIRECT_QUEUE2_ROUTING_KEY = "direct.queue.2.routingkey";
    //topic
    public static final String TOPIC_EXCHANGE_NAME = "topic.exchange";
    public static final String TOPIC_QUEUE1_ROUTING_KEY = "*.rabbit.*"; //* 代表一个单词
    public static final String TOPIC_QUEUE2_ROUTING_KEY = "#.rabbit"; //# 代表零个或多个单词
    /*
    队列声明
     */
    @Bean
    public Queue queue1(){
        return QueueBuilder.durable(QUEUE_1).build();
    }
    @Bean
    public Queue queue2(){
        return QueueBuilder.durable(QUEUE_2).build();
    }
    /*
    fanout交换机模式的声明
     */
    @Bean
    public FanoutExchange fanoutExchange(){
        return new FanoutExchange(FANOUT_EXCHANGE_NAME);
    }
//    @Bean
//    public Binding queue1BindingFanoutExchange1(@Qualifier("fanoutExchange") FanoutExchange fanoutExchange,
//                                         @Qualifier("queue1") Queue queue){
//        return BindingBuilder.bind(queue).to(fanoutExchange);
//    }
//    @Bean
//    public Binding queue2BindingFanoutExchange(@Qualifier("fanoutExchange") FanoutExchange fanoutExchange,
//                                         @Qualifier("queue2") Queue queue){
//        return BindingBuilder.bind(queue).to(fanoutExchange);
//    }

    /*
    direct交换机模式的声明
     */
    @Bean
    public DirectExchange directExchange(){
        return new DirectExchange(DIRECT_EXCHANGE_NAME);
    }
//    @Bean
//    public Binding queue1BindingDirectExchange(@Qualifier("directExchange") DirectExchange directExchange,
//                                         @Qualifier("queue1") Queue queue1){
//        return BindingBuilder.bind(queue1).to(directExchange).with(DIRECT_QUEUE1_ROUTING_KEY);
//    }
//    @Bean
//    public Binding queue2BindingDirectExchange(@Qualifier("directExchange") DirectExchange directExchange,
//                                         @Qualifier("queue2") Queue queue2){
//        return BindingBuilder.bind(queue2).to(directExchange).with(DIRECT_QUEUE2_ROUTING_KEY);
//    }
    /*
    topic交换机模式的声明
     */
    @Bean
    public TopicExchange topicExchange(){
        return new TopicExchange(TOPIC_EXCHANGE_NAME);
    }
    @Bean
    public Binding queue1BindingDirectExchange(@Qualifier("topicExchange") TopicExchange topicExchange,
                                         @Qualifier("queue1") Queue queue1){
        return BindingBuilder.bind(queue1).to(topicExchange).with(TOPIC_QUEUE1_ROUTING_KEY);
    }
    @Bean
    public Binding queue2BindingDirectExchange(@Qualifier("topicExchange") TopicExchange topicExchange,
                                         @Qualifier("queue2") Queue queue2){
        return BindingBuilder.bind(queue2).to(topicExchange).with(TOPIC_QUEUE2_ROUTING_KEY);
    }
}
```
### 生产者
```java
@RestController
@Slf4j
public class ProducerController {
    @Resource
    private RabbitTemplate rabbitTemplate;


    @GetMapping("/fanout/{msg}")
    public String fanoutSendMsg(@PathVariable String msg){
        log.info("fanout交换机发送消息：{}",msg);
        rabbitTemplate.convertAndSend(RabbitMQConfig.FANOUT_EXCHANGE_NAME,"",msg);
        return "fanout交换机发送消息:"+msg;
    }
    @GetMapping("/direct/{msg}")
    public String directSendMsg(@PathVariable String msg){
        log.info("fanout交换机发送消息：{}",msg);
        rabbitTemplate.convertAndSend(RabbitMQConfig.DIRECT_EXCHANGE_NAME,RabbitMQConfig.DIRECT_QUEUE1_ROUTING_KEY,msg + RabbitMQConfig.DIRECT_QUEUE1_ROUTING_KEY);
        rabbitTemplate.convertAndSend(RabbitMQConfig.DIRECT_EXCHANGE_NAME,RabbitMQConfig.DIRECT_QUEUE2_ROUTING_KEY,msg + RabbitMQConfig.DIRECT_QUEUE2_ROUTING_KEY);
        return "direct交换机发送消息:"+msg;
    }
    @GetMapping("/topic/{msg}/{routingKey}")
    public String topicSendMsg(@PathVariable String msg,@PathVariable String routingKey){
        log.info("topic交换机发送消息：{}",msg);
        CorrelationData correlationData = new CorrelationData();
        rabbitTemplate.convertAndSend(RabbitMQConfig.TOPIC_EXCHANGE_NAME,routingKey,msg);
        return "topic交换机发送消息:"+msg;
    }
}
```
### 消费者
```java
@Component
@Slf4j
public class QueueConsumer {
    @RabbitListener(queues = RabbitMQConfig.QUEUE_1)
    public void received1(Message message){
        String msg = new String(message.getBody());
        log.info("{}队列收到消息，routingKey：{}，内容：{}",RabbitMQConfig.QUEUE_1,message.getMessageProperties().getReceivedRoutingKey(),msg);
    }
    @RabbitListener(queues = RabbitMQConfig.QUEUE_2)
    public void received2(Message message){
        String msg = new String(message.getBody());
        log.info("{}队列收到消息，routingKey：{}，内容：{}",RabbitMQConfig.QUEUE_2,message.getMessageProperties().getReceivedRoutingKey(),msg);
    }
}
```
