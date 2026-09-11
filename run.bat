@echo off

setlocal EnableExtensions EnableDelayedExpansion

title Telegram Bot Builder - Development Runner

echo.
echo ==========================================
echo   Telegram Bot Builder - DEV
echo ==========================================
echo.


REM ==========================================
REM Resolve Project Directory
REM ==========================================

set "PROJECT_DIR=%~dp0"

REM Remove trailing backslash
if "%PROJECT_DIR:~-1%"=="\" set "PROJECT_DIR=%PROJECT_DIR:~0,-1%"


REM ==========================================
REM Project Paths
REM ==========================================

set "VENV_DIR=%PROJECT_DIR%\.venv"
set "PYTHON_BIN=%VENV_DIR%\Scripts\python.exe"
set "PIP_BIN=%VENV_DIR%\Scripts\pip.exe"

set "REQUIREMENTS_FILE=%PROJECT_DIR%\requirements.txt"
set "STREAMLIT_APP=%PROJECT_DIR%\app\streamlit_app.py"


REM ==========================================
REM Check Required Files
REM ==========================================

if not exist "%REQUIREMENTS_FILE%" (
    echo [ERROR] requirements.txt not found:
    echo %REQUIREMENTS_FILE%
    pause
    exit /b 1
)

if not exist "%STREAMLIT_APP%" (
    echo [ERROR] Streamlit application not found:
    echo %STREAMLIT_APP%
    pause
    exit /b 1
)


REM ==========================================
REM Check Python
REM ==========================================

where python >nul 2>nul

if errorlevel 1 (
    echo [ERROR] Python was not found in PATH.
    echo Install Python and enable "Add Python to PATH".
    pause
    exit /b 1
)


REM ==========================================
REM Create Virtual Environment
REM ==========================================

if not exist "%VENV_DIR%" (

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
REM Install Requirements
REM ==========================================

echo.
echo [INFO] Upgrading pip...

"%PYTHON_BIN%" -m pip install --upgrade pip

if errorlevel 1 (
    echo [ERROR] Failed to upgrade pip.
    pause
    exit /b 1
)

echo.
echo [INFO] Installing project requirements...

"%PYTHON_BIN%" -m pip install -r "%REQUIREMENTS_FILE%"

if errorlevel 1 (
    echo [ERROR] Failed to install requirements.
    pause
    exit /b 1
)

echo.
echo [OK] Requirements installed.


REM ==========================================
REM Run Streamlit
REM ==========================================

echo.
echo ==========================================
echo   Starting Streamlit application
echo ==========================================
echo.
echo Project:
echo %PROJECT_DIR%
echo.
echo Application:
echo %STREAMLIT_APP%
echo.
echo Press Ctrl+C to stop the application.
echo.

cd /d "%PROJECT_DIR%"

"%PYTHON_BIN%" -m streamlit run "%STREAMLIT_APP%"

if errorlevel 1 (
    echo.
    echo [ERROR] Streamlit exited with an error.
    pause
    exit /b 1
)

endlocal