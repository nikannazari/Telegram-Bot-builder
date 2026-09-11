@echo off

setlocal EnableExtensions EnableDelayedExpansion

title Telegram Bot Builder Uninstaller

echo.
echo ==========================================
echo   Uninstalling Telegram Bot Builder
echo ==========================================
echo.


REM ==========================================
REM Installation Paths
REM ==========================================

set "APP_NAME=Telegram-Bot-Builder"

set "INSTALL_DIR=%LOCALAPPDATA%\%APP_NAME%"
set "COMMAND_PATH=%LOCALAPPDATA%\Microsoft\WindowsApps\%APP_NAME%.bat"


REM ==========================================
REM Confirmation
REM ==========================================

echo The following items will be removed:
echo.
echo Source:
echo %INSTALL_DIR%
echo.
echo Command:
echo %COMMAND_PATH%
echo.

set /p "ANSWER=Are you sure? [y/N]: "

if /I not "%ANSWER%"=="y" (
    echo.
    echo [INFO] Uninstallation cancelled.
    pause
    exit /b 0
)


REM ==========================================
REM Remove Global Command
REM ==========================================

if exist "%COMMAND_PATH%" (

    echo.
    echo [INFO] Removing global command...

    del /F /Q "%COMMAND_PATH%"

    echo [OK] Global command removed.

) else (

    echo [INFO] Global command was not found.

)


REM ==========================================
REM Remove Source Code
REM ==========================================

if exist "%INSTALL_DIR%" (

    echo.
    echo [INFO] Removing installed source code...

    rmdir /S /Q "%INSTALL_DIR%"

    echo [OK] Installed source code removed.

) else (

    echo [INFO] Installation directory was not found.

)


REM ==========================================
REM Finish
REM ==========================================

echo.
echo ==========================================
echo   Uninstallation completed successfully
echo ==========================================
echo.

endlocal
pause