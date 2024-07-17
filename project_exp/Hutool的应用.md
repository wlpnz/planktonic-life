### 用户密码设计
数据库表设计：
有字段：salt(密码盐)，password(密码)
添加用户时，先随机生成20位的**密码盐**
然后通过sha256将默认密码和密码盐加密
```
//工具类来自 Hutool
user.setSalt(RandomUtil.randomString(20));
//明文密码 + 密码盐
user.setPassword(SecureUtil.sha256(user.getPassword() + user.getSalt()));
```

### 初始化参数
添加记录时，设置初始值时，可以通过Convert.toXXX(Object value, Object defaultValue)来设置
第一个参数为初始值，如果初始值为空，则设置为默认值


