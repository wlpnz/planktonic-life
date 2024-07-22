编写bat文件运行exe

### 第一种方式

```plain
@echo off
cd /d %~dp0
redis-server.exe redis.conf
pause
```

在批处理文件（.bat文件）中，`cd /d %~dp0`的作用是将当前目录切换到批处理文件所在的目录。具体来说：

- `/d` 选项使得 `cd` 命令不仅更改目录，还更改驱动器。

- `%0` 代表批处理文件的完整路径（包括文件名）。
- `%~dp0` 提取该路径的驱动器号和目录路径（不包括文件名）。

因此，`cd %~dp0` 将当前工作目录更改为批处理文件所在的目录。这在批处理文件中非常有用，特别是当你希望脚本能够在任何位置运行，但需要访问与批处理文件相对路径的资源时。

例如，如果你有一个批处理文件 `script.bat` 放在 `C:\MyScripts\` 目录下，并在文件中包含 `cd %~dp0`，那么无论你从哪个目录运行 `script.bat`，脚本都会将当前工作目录切换到 `C:\MyScripts\`。



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

