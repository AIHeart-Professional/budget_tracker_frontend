@echo off
echo Building Budget Tracker Desktop App...
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python is not installed or not in PATH
    echo Please install Python 3.8+ and try again
    pause
    exit /b 1
)

REM Check if Flutter is installed
flutter --version >nul 2>&1
if errorlevel 1 (
    echo Error: Flutter is not installed or not in PATH
    echo Please install Flutter and try again
    pause
    exit /b 1
)

echo Starting build process...
echo.

REM Run the build script
python build_desktop_app.py

if errorlevel 1 (
    echo.
    echo Build failed! Check the error messages above.
    pause
    exit /b 1
)

echo.
echo ========================================
echo Build completed successfully!
echo ========================================
echo.
echo Your app is ready in the 'dist' folder:
echo   - dist\BudgetTracker\ - Full app folder
echo   - dist\BudgetTracker.zip - Portable package
echo.
echo To run: Double-click 'start_budget_tracker.bat'
echo in the BudgetTracker folder
echo.
pause
