@echo off
title Enable USB Drives
reg add "HKLM\SYSTEM\CurrentControlSet\Services\USBSTOR" /v Start /t REG_DWORD /d 3 /f > nul
echo USB�ӿ����óɹ�  
pause