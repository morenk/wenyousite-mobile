@echo off
setlocal
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%LOCALAPPDATA%\WenyouSite\release\Publish-WenyouAndroid.ps1"
set "RELEASE_EXIT=%ERRORLEVEL%"
echo.
if not "%RELEASE_EXIT%"=="0" echo Android publish failed.
if "%RELEASE_EXIT%"=="0" echo Android publish finished.
pause
exit /b %RELEASE_EXIT%
