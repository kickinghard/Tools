@echo off
::启用了延迟变量扩展，因此密码中！前要加^^ 否则不能正常显示
setlocal enabledelayedexpansion

::连接远程目录
set USER_NAME=BJWL
set PASSWORD=123^^!@#
::共享文件目录路径 
set SHARE_PATH=\\192.168.0.100\share\教培
:: Map network drive with credentials
echo %SHARE_PATH% /user:%USER_NAME% 123^^!@#
net use %SHARE_PATH% /user:%USER_NAME% 123^^!@#
if errorlevel 1 (
    echo Mapping failed!
    pause
    exit /b 1
)




:: 禁止的app
set "APP_LIST_FILE=%SHARE_PATH%\ban_apps.txt"

:: 必须启动的app
set "REQUIRED_APPS_FILE=%SHARE_PATH%\required_apps.txt"

echo ===============================================
echo %APP_LIST_FILE%
echo %REQUIRED_APPS_FILE%
echo ===============================================
echo.
echo =====================

:: Check if both files exist; exit if both are missing
if not exist "%APP_LIST_FILE%" if not exist "%REQUIRED_APPS_FILE%" (
    echo ERROR: Both ban_apps.txt and required_apps.txt files are missing in the script's directory.
    timeout /t 10 /nobreak >nul
    exit /b 1
)

if not exist "%APP_LIST_FILE%" (
    echo WARNING: ban_apps.txt is missing, but required_apps.txt is present. Continuing with required processes check only.
) else if not exist "%REQUIRED_APPS_FILE%" (
    echo WARNING: required_apps.txt is missing, but ban_apps.txt is present. Continuing with target processes check only.
)



:check_apps
:: 巡查必要进程
for /f "usebackq delims=" %%i in ("%REQUIRED_APPS_FILE%") do (
    set "required_app=%%i"
    echo "!required_app!"

    tasklist | find /i "!required_app!" >nul 2>&1
    if !errorlevel! neq 0 (
        echo Required process !required_app! is not running. Restarting the system...
		rundll32.exe user32.dll,LockWorkStation
        rem shutdown /r /t 0
        rem goto :eof  结束并退出脚本
    )
)

echo --------------------

:: 巡查禁止进程
for /f "usebackq delims=" %%i in ("%APP_LIST_FILE%") do (
    set "app=%%i"
	echo "!app!"

    tasklist | find /i "!app!" >nul 2>&1
    if !errorlevel! equ 0 (
        echo Process !app! is running.

        rundll32.exe user32.dll,LockWorkStation

		rem shutdown   /r:重启  /s:关机  /t:延时   这个命令必须administrator管理员才能执行
		rem shutdown /r /t 0
        rem goto :eof  结束并退出脚本 
    )
)
echo =====================

::再次巡检
timeout /t 5 /nobreak >nul
goto :check_apps
:end
endlocal