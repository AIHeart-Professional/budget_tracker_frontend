#!/usr/bin/env python3
"""
Build script for Budget Tracker Desktop App
Creates a single deployable package with Flutter .exe and Python backend
"""

import os
import shutil
import subprocess
import sys
from pathlib import Path
import zipfile

def run_command(command, cwd=None):
    """Run a command and return success status"""
    try:
        print(f"Running: {' '.join(command)}")
        result = subprocess.run(command, cwd=cwd, check=True, capture_output=True, text=True)
        print(f"Success: {' '.join(command)}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"Failed: {' '.join(command)}")
        print(f"Error: {e.stderr}")
        return False

def build_flutter_release():
    """Build Flutter release executable"""
    print("Building Flutter release...")
    
    # Clean previous builds
    if not run_command(["flutter", "clean"]):
        return False
    
    # Get dependencies
    if not run_command(["flutter", "pub", "get"]):
        return False
    
    # Build Windows release
    if not run_command(["flutter", "build", "windows", "--release"]):
        return False
    
    print("Flutter build completed")
    return True

def prepare_backend():
    """Prepare Python backend for distribution"""
    print("Preparing Python backend...")
    
    backend_src = Path("backend")
    if not backend_src.exists():
        print("Backend directory not found")
        return False
    
    # Check if required files exist
    required_files = ["main.py", "requirements.txt"]
    for file in required_files:
        if not (backend_src / file).exists():
            print(f"Required file {file} not found in backend/")
            return False
    
    print("Backend files verified")
    return True

def create_distribution_package():
    """Create the final distribution package"""
    print("Creating distribution package...")
    
    # Paths
    flutter_build_path = Path("build/windows/x64/runner/Release")
    backend_path = Path("backend")
    dist_path = Path("dist")
    
    # Create dist directory
    if dist_path.exists():
        shutil.rmtree(dist_path)
    dist_path.mkdir()
    
    # Create BudgetTracker directory
    app_dist_path = dist_path / "BudgetTracker"
    app_dist_path.mkdir()
    
    # Copy Flutter executable and its files
    if flutter_build_path.exists():
        print("Copying Flutter app...")
        shutil.copytree(flutter_build_path, app_dist_path / "app")
    else:
        print("Flutter build not found. Run 'flutter build windows --release' first")
        return False
    
    # Copy backend
    print("Copying Python backend...")
    shutil.copytree(backend_path, app_dist_path / "backend")
    
    # Create launcher script
    launcher_script = app_dist_path / "start_budget_tracker.bat"
    launcher_content = """@echo off
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
cd backend
python -m pip install -r requirements.txt >nul 2>&1

echo Starting backend server...
start /B python -m uvicorn main:app --host 127.0.0.1 --port 8000

echo Waiting for backend to start...
timeout /t 3 /nobreak >nul

echo Starting Budget Tracker app...
cd ..\\app
start "" budget_tracker.exe

echo.
echo Budget Tracker is now running!
echo Close this window to stop the backend server.
echo.
pause

REM Kill backend when done
taskkill /f /im python.exe >nul 2>&1
"""
    
    with open(launcher_script, 'w') as f:
        f.write(launcher_content)
    
    # Create README
    readme_path = app_dist_path / "README.txt"
    readme_content = """Budget Tracker Desktop App
============================

Requirements:
- Python 3.8 or higher installed and added to PATH
- Internet connection for initial dependency installation

How to run:
1. Double-click "start_budget_tracker.bat"
2. Wait for the app to start (may take a few seconds on first run)
3. Enjoy your Budget Tracker!

Troubleshooting:
- If Python is not found, install it from https://python.org
- Make sure to check "Add Python to PATH" during Python installation
- On first run, Python dependencies will be downloaded automatically

Files:
- app/budget_tracker.exe - The main Flutter application
- backend/ - Python API server files
- start_budget_tracker.bat - Launch script

The backend API runs on http://127.0.0.1:8000 when active.
"""
    
    with open(readme_path, 'w') as f:
        f.write(readme_content)
    
    print(f"Distribution package created at: {app_dist_path.absolute()}")
    
    # Create ZIP for easy distribution
    zip_path = dist_path / "BudgetTracker.zip"
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(app_dist_path):
            for file in files:
                file_path = Path(root) / file
                arcname = file_path.relative_to(app_dist_path)
                zipf.write(file_path, arcname)
    
    print(f"ZIP package created: {zip_path.absolute()}")
    return True

def main():
    """Main build process"""
    print("Budget Tracker Desktop App Build Script")
    print("=" * 50)
    
    # Verify we're in the right directory
    if not Path("pubspec.yaml").exists():
        print("Please run this script from the Flutter project root directory")
        return False
    
    # Build steps
    steps = [
        ("Preparing backend", prepare_backend),
        ("Building Flutter release", build_flutter_release), 
        ("Creating distribution package", create_distribution_package),
    ]
    
    for step_name, step_func in steps:
        print(f"\n{step_name}...")
        if not step_func():
            print(f"Build failed at step: {step_name}")
            return False
    
    print("\nBuild completed successfully!")
    print("\nYour app is ready in the 'dist' folder:")
    print("   - dist/BudgetTracker/ - Full application folder")
    print("   - dist/BudgetTracker.zip - Portable ZIP package")
    print("\nTo run: Double-click 'start_budget_tracker.bat' in the BudgetTracker folder")
    
    return True

if __name__ == "__main__":
    success = main()
    if not success:
        input("\nPress Enter to exit...")
        sys.exit(1)
