@echo off
setlocal
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%LOCALAPPDATA%\WenyouSite\release\Initialize-WenyouReleaseSsh.ps1"
set "RELEASE_EXIT=%ERRORLEVEL%"
echo.
if not "%RELEASE_EXIT%"=="0" echo SSH release setup failed.
if "%RELEASE_EXIT%"=="0" echo SSH release setup completed.
pause
exit /b %RELEASE_EXIT%
