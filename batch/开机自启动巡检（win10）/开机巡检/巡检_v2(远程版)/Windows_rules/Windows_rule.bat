@echo off
::�������ӳٱ�����չ����������У�ǰҪ��^^ ������������ʾ
setlocal enabledelayedexpansion

::����Զ��Ŀ¼
set USER_NAME=BJWL
set PASSWORD=123^^!@#
::�����ļ�Ŀ¼·�� 
set SHARE_PATH=\\192.168.0.100\share\����
:: Map network drive with credentials
echo %SHARE_PATH% /user:%USER_NAME% 123^^!@#
net use %SHARE_PATH% /user:%USER_NAME% 123^^!@#
if errorlevel 1 (
    echo Mapping failed!
    pause
    exit /b 1
)




:: ��ֹ��app
set "APP_LIST_FILE=%SHARE_PATH%\ban_apps.txt"

:: ����������app
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
:: Ѳ���Ҫ���̡�
for /f "usebackq delims=" %%i in ("%REQUIRED_APPS_FILE%") do (
    set "required_app=%%i"
    echo "!required_app!"

    tasklist | find /i "!required_app!" >nul 2>&1
    if !errorlevel! neq 0 (
        echo Required process !required_app! is not running. Restarting the system...
		rundll32.exe user32.dll,LockWorkStation
        rem shutdown /r /t 0
        rem goto :eof  �������˳��ű�
    )
)

echo --------------------

:: Ѳ���ֹ����
for /f "usebackq delims=" %%i in ("%APP_LIST_FILE%") do (
    set "app=%%i"
	echo "!app!"

    tasklist | find /i "!app!" >nul 2>&1
    if !errorlevel! equ 0 (
        echo Process !app! is running.

        rundll32.exe user32.dll,LockWorkStation

		rem shutdown   /r:����  /s:�ػ�  /t:��ʱ   ����������administrator����Ա����ִ��
		rem shutdown /r /t 0
        rem goto :eof  �������˳��ű� 
    )
)
echo =====================

::�ٴ�Ѳ��
timeout /t 5 /nobreak >nul
goto :check_apps
:end
endlocal