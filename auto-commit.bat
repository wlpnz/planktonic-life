@echo off

REM ʹ��PowerShell��ȡ��ǰ���ں�ʱ��
FOR /F "usebackq tokens=*" %%i IN (`powershell -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd HH:mm:ss'"`) DO SET currentDateTime=%%i

REM ���������Ϣ
ECHO ��ǰ���ں�ʱ����: %currentDateTime%

REM 
REM cd E:\planktonic-life\

cd /d %~dp0

git pull origin "master"
IF %ERRORLEVEL% NEQ 0 (
    ECHO ��ȡʱ������ͻ��������ֶ������ͻ�������͡�
    PAUSE
    EXIT /B 1
)
ECHO ��ȡ����
ECHO ��ʼ����

git add .
git commit -m "%currentDateTime%"
git push -u origin "master"
IF %ERRORLEVEL% NEQ 0 (
    ECHO ����ʱ�����������顣
    PAUSE
    EXIT /B 1
)
ECHO �ļ���������Զ�ֿ̲�
PAUSE