@echo off
setlocal
set "PORT=%DSH_DESKTOP_PORT%"
if "%PORT%"=="" set "PORT=3080"
set "LOG_FILE=%TEMP%\dsh-desktop.log"
node "%~dp0lib\bin.js" web --port %PORT% >> "%LOG_FILE%" 2>&1
