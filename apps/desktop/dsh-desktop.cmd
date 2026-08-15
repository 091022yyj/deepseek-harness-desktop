@echo off
setlocal EnableExtensions

set "INSTALL_DIR=%~dp0"
set "PORT=%DSH_DESKTOP_PORT%"
if "%PORT%"=="" set "PORT=3080"
set "URL=http://127.0.0.1:%PORT%"
set "PROFILE_DIR=%LOCALAPPDATA%\dsh-desktop\chromium-profile"
set "LOG_FILE=%TEMP%\dsh-desktop.log"

if defined DSH_DESKTOP_URL (
  set "URL=%DSH_DESKTOP_URL%"
  goto open
)

where curl >nul 2>nul
if errorlevel 1 (
  echo [dsh-desktop] Need curl to check the service, install curl or set DSH_DESKTOP_URL to an existing service. 1>&2
  exit /b 1
)

curl -fsS --max-time 2 "%URL%" >nul 2>nul
if not errorlevel 1 goto open

if not exist "%INSTALL_DIR%lib\bin.js" (
  echo [dsh-desktop] Program not found: %INSTALL_DIR%lib\bin.js 1>&2
  exit /b 1
)

echo [dsh-desktop] Starting DeepSeek Harness local service...
start "DeepSeek Harness Service" /min "%INSTALL_DIR%run-service.cmd"

set /a TRIES=0
:wait
curl -fsS --max-time 2 "%URL%" >nul 2>nul
if not errorlevel 1 goto open
set /a TRIES+=1
if %TRIES% GEQ 60 (
  echo [dsh-desktop] Service not ready in 60s, log: %LOG_FILE% 1>&2
  if exist "%LOG_FILE%" type "%LOG_FILE%" 1>&2
  exit /b 1
)
timeout /t 1 /nobreak >nul
goto wait

:open
echo [dsh-desktop] Opening app window: %URL%
if defined DSH_DESKTOP_BROWSER (
  start "" "%DSH_DESKTOP_BROWSER%" --app="%URL%" --user-data-dir="%PROFILE_DIR%" --no-first-run --no-default-browser-check
  exit /b 0
)

for %%B in (
  "C:\Program Files\Google\Chrome\Application\chrome.exe"
  "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
  "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"
  "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
  "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
) do (
  if exist "%%~B" (
    start "" "%%~B" --app="%URL%" --user-data-dir="%PROFILE_DIR%" --no-first-run --no-default-browser-check
    exit /b 0
  )
)

echo [dsh-desktop] Chrome/Edge not found, opening in the default browser. 1>&2
start "" "%URL%"
endlocal
