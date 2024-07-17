引入依赖：
```xml
<!--根据扩展名取mimetype-->
<dependency>
    <groupId>com.j256.simplemagic</groupId>
    <artifactId>simplemagic</artifactId>
    <version>1.17</version>
</dependency>
```
构建通用方法
```java
public String getMimeType(String extension) {
    if (extension == null)
        extension = "";
    //根据扩展名取出mimeType
    ContentInfo extensionMatch = ContentInfoUtil.findExtensionMatch(extension);
    //通用mimeType，字节流
    String mimeType = MediaType.APPLICATION_OCTET_STREAM_VALUE;
    if (extensionMatch != null) {
        mimeType = extensionMatch.getMimeType();
    }
    return mimeType;
}
```
