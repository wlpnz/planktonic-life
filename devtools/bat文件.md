编写bat文件运行exe

### 第一种方式

```plain
@echo off
cd /d %~dp0
redis-server.exe redis.conf
pause
```

cd /d %~dp0

表示更改当前目录为批处理文件本身的目（也就是进入当前目录）

比如你有个批处理a.bat在D:\qq文件夹下

a.bat内容为

cd /d %~dp0

在这里

cd /d 注解：（通常情况下，我们要进入其他盘符下的任意目录，需要在CMD窗口运行两次命令：第一次，进入盘符，第二次进入指定目录）

- 例如：进入D盘

- - 第一步：D:
  - 第二步 进入D盘下的test目录: cd test

通过使用CD命令，并加入参数 /d ，可以通过一个步骤，直接进入指定盘符下的任意文件夹。

- 一个步骤进入D盘下的test目录：cd /d d:\test



cd /d %~dp0的意思就是cd /d d:\qq

%0代表批处理本身 d:\qq\a.bat

~dp是变量扩充

d既是扩充到分区号 d:

p就是扩充到路径 \qq

dp就是扩充到分区号路径 d:\qq



### 第二种方式

```plain
@echo off
E:
cd E:\develop_tool\Redis-7.0.15-Windows-x64\
redis-server.exe redis.conf
pause
```

相比于第一种，先进入E盘，然后再进入redis所在目录

然后再执行命令



### 示例

### 示例1

自动推送至git仓库

```bat
@echo off

REM 使用PowerShell获取当前日期和时间
FOR /F "usebackq tokens=*" %%i IN (`powershell -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd HH:mm:ss'"`) DO SET currentDateTime=%%i

REM 输出中文信息
ECHO 当前日期和时间是: %currentDateTime%

REM 
E:
cd E:\浮游一生\

git pull origin "master"
IF %ERRORLEVEL% NEQ 0 (
    ECHO 拉取时遇到冲突或错误，请手动解决冲突后再推送。
    PAUSE
    EXIT /B 1
)

ECHO 拉取结束
ECHO 开始推送

git add .
git commit -m "%currentDateTime%"
git push -u origin "master"
IF %ERRORLEVEL% NEQ 0 (
    ECHO 推送时遇到错误，请检查。
    PAUSE
    EXIT /B 1
)
ECHO 文件已推送至远程仓库
PAUSE
```

