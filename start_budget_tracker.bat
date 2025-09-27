@echo off
title Budget Tracker
echo Starting Budget Tracker Desktop App...
echo.

REM Check if Python is available
python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python is not installed or not in PATH
    echo.
    echo Please install Python 3.8+ from https://python.org
    echo Make sure to check "Add Python to PATH" during installation
    echo.
    pause
    exit /b 1
)

echo Installing Python dependencies...
cd dist\BudgetTracker\backend
python -m pip install -r requirements.txt >nul 2>&1

echo Starting backend server...
start /B python -m uvicorn main:app --host 127.0.0.1 --port 8000

echo Waiting for backend to start...
timeout /t 3 /nobreak >nul

echo Starting Budget Tracker app...
cd ..\app
start "" budget_tracker.exe

echo.
echo Budget Tracker is now running!
echo Close this window to stop the backend server.
echo.
pause

REM Kill backend when done
taskkill /f /im python.exe >nul 2>&1
