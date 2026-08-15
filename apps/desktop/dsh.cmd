@echo off
setlocal
set "NODE=%~dp0node\node.exe"
if not exist "%NODE%" set "NODE=node"
"%NODE%" "%~dp0lib\bin.js" %*
