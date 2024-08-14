# Maven问题

### SystemPath应用

> 当使用SystemPath引用本地依赖，且Scope的值为System时，打包没有将该依赖加入jar包
> 解决：

```xml
<plugin>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-maven-plugin</artifactId>
  <configuration>
    <includeSystemScope>true</includeSystemScope>
  </configuration>
</plugin>
```



### Scope值设置
在Apache Maven中，依赖的scope（范围）用于控制依赖的可见性和生命周期。这些scope值在项目构建中扮演着重要角色，帮助开发者管理依赖关系。以下是Maven中常见的scope及其讲究：
**compile：**
默认范围：如果没有明确指定scope，默认值是compile。
用途：这些依赖在编译、测试、运行和打包时都可用。
适用场景：需要在整个项目生命周期中使用的依赖，例如大多数的应用库。
**provided：**
用途：这些依赖在编译和测试时可用，但在运行和打包时不会被包含。
适用场景：适用于容器或运行时环境会提供的库，如Servlet API、JDBC驱动等。
**runtime：**
用途：这些依赖在编译时不可用，但在运行和测试时可用。
适用场景：需要在运行时才会用到的库，如JDBC驱动。
**test：**
用途：这些依赖仅在测试编译和运行时可用。
适用场景：仅用于测试的库，如JUnit、Mockito等。
**system：**
用途：类似于provided，但需要显式指定依赖的路径，通常用于依赖特定的本地系统库。
适用场景：用于依赖本地系统上的特定库时，例如系统特有的驱动。
**import（仅限于dependencyManagement）**：
用途：该scope用于导入依赖的POM文件，该POM文件定义了一组依赖管理策略。
适用场景：用于管理大型项目中的依赖版本，例如使用BOM（Bill of Materials）。

**具体应用讲究：**

- 选择合适的scope：根据依赖的实际用途选择合适的scope，可以减少不必要的依赖传递和冲突。
- 避免scope混乱：明确区分编译时依赖、测试时依赖和运行时依赖，确保项目构建过程的稳定性。
- 使用provided避免冲突：对于由应用服务器或容器提供的依赖，使用provided可以避免重复打包和冲突。
- 管理依赖版本：使用dependencyManagement结合import scope，可以在多模块项目中统一管理依赖版本，避免版本冲突。

通过合理地使用和管理Maven依赖的scope，可以更好地控制项目依赖的生命周期，提高构建的可靠性和可维护性。



### RelativePath标签

##### 描述

在POM的父子依赖关系中，一般会出现<relativePath></relativePath>的标签
在Maven项目的pom.xml文件中，relativePath标签用于指定与当前pom.xml文件所在位置的相对路径，以便Maven可以定位到父级POM文件。通常情况下，relativePath标签用于多模块项目，其中子模块的pom.xml文件需要引用父模块的POM文件。
具体的说是告诉**Maven去哪里查找父模块的POM文件**，通常是用**相对路径**来表示的

##### 示例

```xml
my-parent-project/
    ├── pom.xml
    ├── module-1/
    │    └── pom.xml
    └── module-2/
         └── pom.xml
在module-1和module-2的pom.xml中，
可以使用relativePath标签来指定相对路径以引用父模块的POM文件，如下所示：
<parent>
    <groupId>com.example</groupId>
    <artifactId>my-parent-project</artifactId>
    <version>1.0</version>
    <relativePath>../pom.xml</relativePath>
</parent>
```

