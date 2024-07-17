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
