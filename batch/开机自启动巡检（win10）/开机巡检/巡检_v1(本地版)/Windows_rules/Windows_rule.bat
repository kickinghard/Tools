@echo off
setlocal enabledelayedexpansion

set "APP_LIST_FILE=%~dp0ban_apps.txt"
set "REQUIRED_APPS_FILE=%~dp0required_apps.txt"

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
		rundll32.exe user32.dll,LockWorkStation
        rem shutdown /r /t 0
    )
)

for /f "usebackq delims=" %%i in ("%APP_LIST_FILE%") do (
    set "app=%%i"
    tasklist | find /i "!app!" >nul 2>&1
    if !errorlevel! equ 0 (
        rundll32.exe user32.dll,LockWorkStation
		rem shutdown /r /t 0
    )
)

timeout /t 5 /nobreak >nul
goto :check_apps
:end
endlocal