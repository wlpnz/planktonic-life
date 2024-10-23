# SpringBoot集成WebSocket

## 服务端实现

### 依赖

```
<dependencies>
    <!-- Spring Web -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <!-- Spring WebSocket -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-websocket</artifactId>
    </dependency>
</dependencies>
```

### 配置WebSocket

因为要使用 `@ServerEndpoint` 注解，我们需要配置 `ServerEndpointExporter`。

```java
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.server.standard.ServerEndpointExporter;

/**
 * WebSocket 配置类
 */
@Configuration
public class WebSocketConfig {

    /**
     * 自动注册使用了 @ServerEndpoint 注解声明的 WebSocket endpoint
     */
    @Bean
    public ServerEndpointExporter serverEndpointExporter() {
        return new ServerEndpointExporter();
    }
}
```

> **注意**：如果使用了外部的独立 Servlet 容器（如 Tomcat、Jetty 等），而不是 Spring Boot 内置的容器，则不需要 `ServerEndpointExporter`，否则会报错

### 配置WebSocketConfigurator

```java
import org.springframework.stereotype.Component;
import javax.websocket.HandshakeResponse;
import javax.websocket.server.HandshakeRequest;
import javax.websocket.server.ServerEndpointConfig;
import java.util.List;
import java.util.Map;

@Component
public class WebSocketConfigurator extends ServerEndpointConfig.Configurator {

    @Override
    public void modifyHandshake(ServerEndpointConfig sec, HandshakeRequest request, HandshakeResponse response) {
        //parameterMap中会有路径参数和查询字符串
        Map<String, List<String>> params = request.getParameterMap(); 
        String key = params.get("key").get(0); // 获取 key 的值
        sec.getUserProperties().put("key", key); // 存储 key 到 session 的 user properties 中
    }
}
```

### 创建 WebSocket 端点

使用 `@ServerEndpoint` 注解定义 WebSocket 服务器端点。

```java
import javax.websocket.*;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;
import org.springframework.stereotype.Component;
import java.io.IOException;
import java.util.concurrent.ConcurrentHashMap;

/**
 * WebSocket 服务器端点
 */
@ServerEndpoint(value = "/websocket/{sid}", configurator = WebSocketConfigurator.class)
@Component
public class WebSocketServer {
    
    // 注入bean需要通过set注入的方式，bean变量需要被static修饰
    private static UserMapper userMapper;

    @Autowired
    public void setUserMapper(UserMapper userMapper) {
        WebSocketServer.userMapper = userMapper;
    }

    // 静态变量，用于记录当前在线连接数
    private static int onlineCount = 0;

    // 线程安全的 Map，用于存放每个客户端对应的 WebSocket 对象
    private static ConcurrentHashMap<String, WebSocketServer> webSocketMap = new ConcurrentHashMap<>();

    // 与某个客户端的连接会话
    private Session session;

    // 客户端的标识（sid）
    private String sid = "";

    /**
     * 连接建立成功调用的方法
     * 
     * 通过@PathParam注解获取连接url中的路径参数
     * QueryString需要在configurator中获取，并放置在Session的userProperties中
     */
    @OnOpen
    public void onOpen(Session session, @PathParam("sid") String sid) {
        this.session = session;
        String key = (String) session.getUserProperties().get("key");
        this.sid = sid;
        if (webSocketMap.containsKey(sid)) {
            webSocketMap.remove(sid);
            webSocketMap.put(sid, this);
        } else {
            webSocketMap.put(sid, this);
            addOnlineCount();
        }
        System.out.println("有新窗口开始监听：" + sid + "，当前在线人数为：" + getOnlineCount() + 
                           "，key为：" + key);
        try {
            sendMessage("连接成功");
        } catch (IOException e) {
            System.out.println("WebSocket IO 异常");
        }
    }

    /**
     * 连接关闭调用的方法
     */
    @OnClose
    public void onClose() {
        if (webSocketMap.containsKey(sid)) {
            webSocketMap.remove(sid);
            subOnlineCount();
        }
        System.out.println("有一连接关闭！当前在线人数为：" + getOnlineCount());
    }

    /**
     * 收到客户端消息后调用的方法
     *
     * @param message 客户端发送的消息
     * @param session 会话
     */
    @OnMessage
    public void onMessage(String message, Session session) {
        System.out.println("收到来自窗口 " + sid + " 的信息：" + message);
        // 群发消息
        for (WebSocketServer item : webSocketMap.values()) {
            try {
                item.sendMessage("用户 " + sid + " 说：" + message);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * 发生错误时调用
     *
     * @param session 会话
     * @param error   错误信息
     */
    @OnError
    public void onError(Session session, Throwable error) {
        System.out.println("发生错误");
        error.printStackTrace();
    }

    /**
     * 服务器主动推送消息
     */
    public void sendMessage(String message) throws IOException {
        this.session.getBasicRemote().sendText(message);
    }

    /**
     * 群发自定义消息
     */
    public static void sendInfo(String message, @PathParam("sid") String sid) throws IOException {
        System.out.println("推送消息到窗口 " + sid + "，推送内容：" + message);
        if (sid != null && webSocketMap.containsKey(sid)) {
            webSocketMap.get(sid).sendMessage(message);
        } else {
            System.out.println("用户 " + sid + " 不在线！");
        }
    }

    public static synchronized int getOnlineCount() {
        return onlineCount;
    }

    public static synchronized void addOnlineCount() {
        WebSocketServer.onlineCount++;
    }

    public static synchronized void subOnlineCount() {
        WebSocketServer.onlineCount--;
    }
}
```

> `@ServerEndpoint(value = "/websocket/{sid}", configurator = WebSocketConfigurator.class)`：`value = "/websocket/{sid}"`：定义 WebSocket 连接的 URL，其中 `{sid}` 是路径参数，用于区分不同的客户端;`configurator = WebSocketConfigurator.class`：配置自定义configurator，用于获取请求参数
>
> `@OnOpen`：当 WebSocket 连接成功建立时调用。
>
> `@OnClose`：当 WebSocket 连接关闭时调用。
>
> `@OnMessage`：当收到客户端消息时调用。
>
> `@OnError`：当发生错误时调用。
>
> `sendMessage`：服务器主动向客户端发送消息的方法。

## 客户端实现

创建Vue组件`WebSocketDemo.vue`

```vue
<template>
  <div>
    <h1>WebSocket Demo</h1>
    <div v-if="!connected">
      <input v-model="sid" placeholder="请输入你的 SID" />
      <button @click="connectWebSocket">连接</button>
    </div>
    <div v-else>
      <p>已连接，SID：{{ sid }}</p>
      <input v-model="message" placeholder="请输入消息" />
      <button @click="sendMessage">发送</button>
      <button @click="disconnectWebSocket">断开连接</button>
      <div>
        <h2>收到的消息：</h2>
        <ul>
          <li v-for="(msg, index) in receivedMessages" :key="index">{{ msg }}</li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      websocket: null,
      message: '',
      receivedMessages: [],
      sid: '',
      connected: false,
    };
  },
  methods: {
    connectWebSocket() {
      if (!this.sid) {
        alert('请先输入 SID');
        return;
      }
      this.websocket = new WebSocket(`ws://localhost:8080/websocket/${this.sid}?key=value`);

      this.websocket.onopen = () => {
        console.log('WebSocket 连接已打开');
        this.connected = true;
      };

      this.websocket.onmessage = (event) => {
        console.log('收到消息：' + event.data);
        this.receivedMessages.push(event.data);
      };

      this.websocket.onclose = () => {
        console.log('WebSocket 连接已关闭');
        this.connected = false;
      };

      this.websocket.onerror = (error) => {
        console.log('WebSocket 发生错误：', error);
      };
    },
    sendMessage() {
      if (this.websocket && this.connected) {
        this.websocket.send(this.message);
        this.message = '';
      } else {
        alert('WebSocket 尚未连接');
      }
    },
    disconnectWebSocket() {
      if (this.websocket) {
        this.websocket.close();
      }
    },
  },
  beforeUnmount() {
    if (this.websocket) {
      this.websocket.close();
    }
  },
};
</script>

<style scoped>
/* 样式 */
</style>
```

> 用户需要先输入 `SID` 并点击连接按钮，建立 WebSocket 连接。
>
> 连接成功后，可以输入消息并发送，收到的消息会显示在下方列表中。

> 注意点：
>
> 针对客户端websocket断开服务端没有触发断开连接的事件，需要添加心跳请求                 
