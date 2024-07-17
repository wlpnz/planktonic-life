@echo off

REM 使用PowerShell获取当前日期和时间
FOR /F "usebackq tokens=*" %%i IN (`powershell -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd HH:mm:ss'"`) DO SET currentDateTime=%%i

REM 输出中文信息
ECHO 当前日期和时间是: %currentDateTime%

REM 
REM cd E:\planktonic-life\

cd E:
cd %~dp0

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