# Java虚拟机

### 概述

[黑马JVM在线文档](https://lisxpq12rl7.feishu.cn/wiki/ZaKnwhhhmiDu9ekUnRNcv2iNnof)

JVM 全称是 Java Virtual Machine，中文译名 Java虚拟机。JVM 本质上是一个运行在计算机上的程序，他的职责是运行Java字节码文件。

Java源代码执行流程如下：

![image-20241106110559379](images/JVM基础/image-20241106110559379.png) 

分为三个步骤：

1、编写Java源代码文件。

2、使用Java编译器（javac命令）将源代码编译成Java字节码文件。

3、使用Java虚拟机加载并运行Java字节码文件，此时会启动一个新的进程。

**JVM架构图**

<img src="./images/JVM基础/image-20241105154930258.png" alt="image-20241105154930258" style="zoom:80%;" /> 

这个架构可以分成三层看：

- 最上层：javac编译器将编译好的字节码class文件，通过java 类装载器执行机制，把对象或class文件存放在 jvm划分内存区域。
- 中间层：称为Runtime Data Area，主要是在Java代码运行时用于存放数据的，从左至右为方法区、堆、栈、程序计数器、寄存器、本地方法栈(私有)。
- 最下层：解释器、JIT(just in time)编译器和 GC（Garbage Collection，垃圾回收器）



### 字节码文件





### 类生命周期



Loading(装载)阶段



Linking(链接)阶段



Initialization(初始化)阶段



 

### 类加载器





### 双亲委派机制

核心是解决一个类到底由谁加载的问题



### 运行时数据区



### 垃圾回收



