@echo off

setlocal EnableExtensions EnableDelayedExpansion

title Telegram Bot Builder Installer

echo.
echo ==========================================
echo   Installing Telegram Bot Builder
echo ==========================================
echo.


REM ==========================================
REM Resolve Source Directory
REM ==========================================

set "SOURCE_DIR=%~dp0"

if "%SOURCE_DIR:~-1%"=="\" set "SOURCE_DIR=%SOURCE_DIR:~0,-1%"


REM ==========================================
REM Installation Paths
REM ==========================================

set "APP_NAME=Telegram-Bot-Builder"

set "INSTALL_DIR=%LOCALAPPDATA%\%APP_NAME%"
set "COMMAND_DIR=%LOCALAPPDATA%\Microsoft\WindowsApps"
set "COMMAND_PATH=%COMMAND_DIR%\%APP_NAME%.bat"

set "VENV_DIR=%INSTALL_DIR%\.venv"
set "PYTHON_BIN=%VENV_DIR%\Scripts\python.exe"


REM ==========================================
REM Check Required Files
REM ==========================================

if not exist "%SOURCE_DIR%\requirements.txt" (
    echo [ERROR] requirements.txt not found.
    echo Source directory:
    echo %SOURCE_DIR%
    pause
    exit /b 1
)

if not exist "%SOURCE_DIR%\app\streamlit_app.py" (
    echo [ERROR] app\streamlit_app.py not found.
    pause
    exit /b 1
)

if not exist "%SOURCE_DIR%\main.py" (
    echo [ERROR] main.py not found.
    pause
    exit /b 1
)


REM ==========================================
REM Check Python
REM ==========================================

where python >nul 2>nul

if errorlevel 1 (
    echo [ERROR] Python was not found in PATH.
    echo Install Python and enable:
    echo Add Python to PATH
    pause
    exit /b 1
)


REM ==========================================
REM Create Installation Directory
REM ==========================================

echo [INFO] Creating installation directory:

if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%"
)

if not exist "%INSTALL_DIR%\app" (
    mkdir "%INSTALL_DIR%\app"
)

if not exist "%INSTALL_DIR%\src" (
    mkdir "%INSTALL_DIR%\src"
)

if not exist "%INSTALL_DIR%\assets" (
    mkdir "%INSTALL_DIR%\assets"
)

if not exist "%INSTALL_DIR%\bots" (
    mkdir "%INSTALL_DIR%\bots"
)

if not exist "%INSTALL_DIR%\generated" (
    mkdir "%INSTALL_DIR%\generated"
)


REM ==========================================
REM Copy Source Code
REM ==========================================

echo.
echo [INFO] Copying source code...

xcopy "%SOURCE_DIR%\app" "%INSTALL_DIR%\app" /E /I /Y >nul
xcopy "%SOURCE_DIR%\src" "%INSTALL_DIR%\src" /E /I /Y >nul

if exist "%SOURCE_DIR%\assets" (
    xcopy "%SOURCE_DIR%\assets" "%INSTALL_DIR%\assets" /E /I /Y >nul
)

copy /Y "%SOURCE_DIR%\main.py" "%INSTALL_DIR%\main.py" >nul
copy /Y "%SOURCE_DIR%\requirements.txt" "%INSTALL_DIR%\requirements.txt" >nul

if exist "%SOURCE_DIR%\pyproject.toml" (
    copy /Y "%SOURCE_DIR%\pyproject.toml" "%INSTALL_DIR%\pyproject.toml" >nul
)

echo [OK] Source code copied.


REM ==========================================
REM Create Virtual Environment
REM ==========================================

if not exist "%VENV_DIR%" (

    echo.
    echo [INFO] Creating virtual environment...

    python -m venv "%VENV_DIR%"

    if errorlevel 1 (
        echo [ERROR] Failed to create virtual environment.
        pause
        exit /b 1
    )

    echo [OK] Virtual environment created.

) else (

    echo [INFO] Virtual environment already exists.

)


REM ==========================================
REM Install Dependencies
REM ==========================================

echo.
echo [INFO] Installing Python dependencies...

"%PYTHON_BIN%" -m pip install --upgrade pip

if errorlevel 1 (
    echo [ERROR] Failed to upgrade pip.
    pause
    exit /b 1
)

"%PYTHON_BIN%" -m pip install -r "%INSTALL_DIR%\requirements.txt"

if errorlevel 1 (
    echo [ERROR] Failed to install requirements.
    pause
    exit /b 1
)

echo [OK] Python dependencies installed.


REM ==========================================
REM Create Global Command
REM ==========================================

echo.
echo [INFO] Creating global command...

if not exist "%COMMAND_DIR%" (
    mkdir "%COMMAND_DIR%"
)

(
    echo @echo off
    echo set "INSTALL_DIR=%INSTALL_DIR%"
    echo set "PYTHON_BIN=%%INSTALL_DIR%%\.venv\Scripts\python.exe"
    echo set "STREAMLIT_APP=%%INSTALL_DIR%%\app\streamlit_app.py"
    echo cd /d "%%INSTALL_DIR%%"
    echo "%%PYTHON_BIN%%" -m streamlit run "%%STREAMLIT_APP%%"
) > "%COMMAND_PATH%"

echo [OK] Global command created:
echo %COMMAND_PATH%


REM ==========================================
REM Finish
REM ==========================================

echo.
echo ==========================================
echo   Installation completed successfully
echo ==========================================
echo.
echo Installed source:
echo %INSTALL_DIR%
echo.
echo Run the application with:
echo %APP_NAME%
echo.
echo If the command is not recognized, restart
echo your terminal or add this directory to PATH:
echo %COMMAND_DIR%
echo.

endlocal
pause