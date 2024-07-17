```java
public class UserHolder {
    public static final ThreadLocal<String> tl = new ThreadLocal<>();

    public static void saveUser(String userId){
        tl.set(userId);
    }

    public static Integer getUser(){
        return Integer.valueOf(tl.get());
    }

    public static void removeUser(){
        tl.remove();
    }
}

```

