#!/usr/bin/env python3
"""
Budget Tracker Desktop App Launcher
Starts both Python backend and Flutter frontend
"""

import subprocess
import sys
import os
import time
import threading
import signal
from pathlib import Path

class AppLauncher:
    def __init__(self):
        self.backend_process = None
        self.flutter_process = None
        self.running = True
        
        # Setup signal handlers for clean shutdown
        signal.signal(signal.SIGINT, self.signal_handler)
        signal.signal(signal.SIGTERM, self.signal_handler)
    
    def signal_handler(self, signum, frame):
        """Handle shutdown signals"""
        print("\n🛑 Shutting down Budget Tracker...")
        self.stop_all()
        sys.exit(0)
    
    def install_python_dependencies(self):
        """Install Python backend dependencies"""
        backend_dir = Path(__file__).parent / "backend"
        requirements_file = backend_dir / "requirements.txt"
        
        if requirements_file.exists():
            print("📦 Installing Python dependencies...")
            try:
                subprocess.check_call([
                    sys.executable, "-m", "pip", "install", "-r", str(requirements_file)
                ])
                print("✅ Python dependencies installed")
                return True
            except subprocess.CalledProcessError as e:
                print(f"❌ Failed to install Python dependencies: {e}")
                return False
        return True
    
    def install_flutter_dependencies(self):
        """Install Flutter dependencies"""
        print("📦 Installing Flutter dependencies...")
        try:
            subprocess.check_call(["flutter", "pub", "get"])
            print("✅ Flutter dependencies installed")
            return True
        except subprocess.CalledProcessError as e:
            print(f"❌ Failed to install Flutter dependencies: {e}")
            return False
    
    def start_backend(self):
        """Start the Python backend server"""
        backend_dir = Path(__file__).parent / "backend"
        
        if not backend_dir.exists():
            print("❌ Backend directory not found")
            return False
        
        try:
            print("🐍 Starting Python backend server...")
            self.backend_process = subprocess.Popen([
                sys.executable, "-m", "uvicorn", 
                "main:app",
                "--host", "127.0.0.1",
                "--port", "8000",
                "--reload"
            ], cwd=str(backend_dir))
            
            # Wait a moment to see if process starts successfully
            time.sleep(2)
            
            if self.backend_process.poll() is None:
                print("✅ Backend server started on http://127.0.0.1:8000")
                print("📚 API Documentation: http://127.0.0.1:8000/docs")
                return True
            else:
                print("❌ Backend server failed to start")
                return False
                
        except Exception as e:
            print(f"❌ Error starting backend: {e}")
            return False
    
    def start_flutter(self):
        """Start the Flutter desktop app"""
        try:
            print("📱 Starting Flutter desktop app...")
            
            # Start Flutter in a separate thread so it doesn't block
            def run_flutter():
                self.flutter_process = subprocess.Popen([
                    "flutter", "run", "-d", "windows", "--release"
                ])
                self.flutter_process.wait()
            
            flutter_thread = threading.Thread(target=run_flutter, daemon=True)
            flutter_thread.start()
            
            print("✅ Flutter app starting...")
            return True
            
        except Exception as e:
            print(f"❌ Error starting Flutter app: {e}")
            return False
    
    def stop_all(self):
        """Stop all processes"""
        self.running = False
        
        if self.backend_process:
            print("🛑 Stopping backend server...")
            self.backend_process.terminate()
            try:
                self.backend_process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                self.backend_process.kill()
        
        if self.flutter_process:
            print("🛑 Stopping Flutter app...")
            self.flutter_process.terminate()
            try:
                self.flutter_process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                self.flutter_process.kill()
        
        print("✅ All processes stopped")
    
    def run(self):
        """Main run method"""
        print("🚀 Budget Tracker Desktop App Launcher")
        print("=" * 50)
        
        # Install dependencies
        if not self.install_python_dependencies():
            return False
        
        if not self.install_flutter_dependencies():
            return False
        
        print("\n🎯 Starting services...")
        
        # Start backend
        if not self.start_backend():
            return False
        
        # Wait a bit for backend to fully start
        time.sleep(3)
        
        # Start Flutter app
        if not self.start_flutter():
            self.stop_all()
            return False
        
        print("\n✅ Budget Tracker is now running!")
        print("💡 Press Ctrl+C to stop the application")
        
        # Keep the launcher running
        try:
            while self.running:
                # Check if backend is still running
                if self.backend_process and self.backend_process.poll() is not None:
                    print("❌ Backend process died, restarting...")
                    if not self.start_backend():
                        break
                
                time.sleep(1)
        
        except KeyboardInterrupt:
            pass
        
        self.stop_all()
        return True

if __name__ == "__main__":
    launcher = AppLauncher()
    success = launcher.run()
    sys.exit(0 if success else 1)
