# bat文件运行exe

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

例如，如果你有一个批处理文件 `script.bat` 放在 `C:\bat\` 目录下，并在文件中包含 `cd /d %~dp0`，那么无论你从哪个目录运行 `script.bat`，脚本都会将当前工作目录切换到 `C:\bat\`。

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

