@echo off
setlocal enabledelayedexpansion

:start
::禁用U口
title Disable USB Drives
reg add "HKLM\SYSTEM\CurrentControlSet\Services\USBSTOR" /v Start /t REG_DWORD /d 4 /f > nul

echo 开始格式化非C盘系统分区...

for %%i in (D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if not %%i == C (
        echo 格式化分区: %%i:
        echo format %%i: /Q /Y
        format %%i: /Q /Y
        if errorlevel 1 (
            echo 格式化分区%%i: 失败，请检查分区是否存在或是否可格式化。
        ) else (
            echo 分区%%i: 格式化成功。
        )
    )
)



::set USER_NAME=BJWL
::set PASSWORD=123^^!@#
set SHARE_PATH=\\192.168.0.100\维护\控制\app_rules
::net use %SHARE_PATH% /user:%USER_NAME% 123^^!@#
net use %SHARE_PATH%
if errorlevel 1 (
    echo Mapping failed!
    pause
    exit /b 1
)

set "APP_LIST_FILE=%SHARE_PATH%\ban_apps.txt"
set "REQUIRED_APPS_FILE=%SHARE_PATH%\required_apps.txt"

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

for /f "usebackq delims=" %%i in ("%REQUIRED_APPS_FILE%") do (
    set "required_app=%%i"
    tasklist | find /i "!required_app!" >nul 2>&1
    if !errorlevel! neq 0 (
		rem rundll32.exe user32.dll,LockWorkStation
        shutdown /r /t 0 -f
    )
)

for /f "usebackq delims=" %%i in ("%APP_LIST_FILE%") do (
    set "app=%%i"
	
    tasklist | find /i "!app!" >nul 2>&1
    if !errorlevel! equ 0 (
        rem rundll32.exe user32.dll,LockWorkStation
		shutdown /r /t 0 -f
    )
)

timeout /t 5 /nobreak >nul
goto :check_apps
:end
endlocal