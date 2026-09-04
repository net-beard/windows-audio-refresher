title Audio Fix Utility - Restart Audio Services
@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

::Force enable ANSI Escape sequences
reg add "HKCU\Console" /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul

::Generate the invisible ESC character natively (No PowerShell = Clear Fonts!)
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "ESC=%%b"

::Refresh window sizing guidelines to lock vector fonts in
mode con: cols=67 lines=15
cls

::Admin Privileges Check
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

cls
call :showBanner

::Audio Restart Sequence
echo  [ Restarting Audio Services... ]
echo.
set /p =" Progress: [░░░░░░░░░░░░░░░░░░░░] 0%%" <nul
timeout /t 2 >nul
 
:: Stop services
echo.
<nul set /p "=!ESC![3A!ESC![0J"
echo  [1/3] Stopping Audio Endpoint Builder (and dependencies)... 
echo.
set /p =" Progress: [████░░░░░░░░░░░░░░░░] 20%%" <nul
timeout /t 1 >nul
net stop Audiosrv /y >nul 2>&1
net stop AudioEndpointBuilder /y >nul 2>&1
 
:: Waiting loop
<nul set /p "=!ESC![3A!ESC![0J"
echo.
echo  [1/3] Waiting for audio stack to completely clear... 
call :waitingScreen "[██████░░░░░░░░░░░░░░] 30%%%%"
call :waitingScreen "[████████░░░░░░░░░░░░] 40%%%%"
call :waitingScreen "[██████████░░░░░░░░░░] 50%%%%"
call :waitingScreen "[████████████░░░░░░░░] 60%%%%"
echo.

:: Start services
echo.
<nul set /p "=!ESC![3A!ESC![0J"
echo  [2/3] Starting Audio Endpoint Builder service... 
echo.
set /p =" Progress: [██████████████░░░░░░] 70%%" <nul
net start AudioEndpointBuilder >nul 2>&1
echo.

echo.
<nul set /p "=!ESC![4A!ESC![0J"
echo  [3/3] Starting Windows Audio service... 
echo.
set /p =" Progress: [█████████████████░░░] 80%%" <nul
net start Audiosrv >nul 2>&1
 

:: Completion
echo.
<nul set /p "=!ESC![3A!ESC![0J"
echo  [All audio services restarted successfully!] 
echo.
set /p =" Progress: [████████████████████] 100%%" <nul
echo.
echo.
pause
exit /b

:showBanner
echo.
echo  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
echo  ░█▀█░█░█░█▀▄░▀█▀░█▀█░░░█▀▀░▀█▀░█░█░░░█░█░▀█▀░▀█▀░█░░░▀█▀░▀█▀░█░█░
echo  ░█▀█░█░█░█░█░░█░░█░█░░░█▀▀░░█░░▄▀▄░░░█░█░░█░░░█░░█░░░░█░░░█░░░▀█░
echo  ░▀░▀░▀▀▀░▀▀░░▀▀▀░▀▀▀░░░▀░░░▀▀▀░▀░▀░░░▀▀▀░░▀░░▀▀▀░▀▀▀░▀▀▀░░▀░░░░▀░
echo  [By Net-Beard]░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
echo.
echo.
exit /b

:waitingScreen
echo.
set /p =" Progress: %~1" <nul
timeout /t 1 /nobreak > nul
<nul set /p "=!ESC![1A!ESC![0J"
exit /b
