"""
Backend Server Manager
Handles starting/stopping the FastAPI server
"""

import subprocess
import sys
import os
import time
import signal
import threading
from pathlib import Path

class BackendServer:
    def __init__(self, host="127.0.0.1", port=8000):
        self.host = host
        self.port = port
        self.process = None
        self.backend_dir = Path(__file__).parent
        
    def install_dependencies(self):
        """Install Python dependencies"""
        requirements_file = self.backend_dir / "requirements.txt"
        if requirements_file.exists():
            print("Installing Python dependencies...")
            subprocess.check_call([
                sys.executable, "-m", "pip", "install", "-r", str(requirements_file)
            ])
        
    def start_server(self):
        """Start the FastAPI server"""
        if self.process and self.process.poll() is None:
            print(f"Server is already running on {self.host}:{self.port}")
            return True
            
        try:
            # Install dependencies first
            self.install_dependencies()
            
            # Start the server
            print(f"Starting backend server on {self.host}:{self.port}")
            
            main_py = self.backend_dir / "main.py"
            self.process = subprocess.Popen([
                sys.executable, "-m", "uvicorn", 
                "main:app",
                "--host", self.host,
                "--port", str(self.port),
                "--reload"
            ], cwd=str(self.backend_dir))
            
            # Wait a moment to check if server started successfully
            time.sleep(2)
            
            if self.process.poll() is None:
                print(f"✅ Backend server started successfully!")
                print(f"🌐 API Documentation: http://{self.host}:{self.port}/docs")
                return True
            else:
                print("❌ Failed to start backend server")
                return False
                
        except Exception as e:
            print(f"❌ Error starting server: {e}")
            return False
    
    def stop_server(self):
        """Stop the FastAPI server"""
        if self.process:
            print("Stopping backend server...")
            self.process.terminate()
            try:
                self.process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                self.process.kill()
            self.process = None
            print("✅ Backend server stopped")
    
    def is_running(self):
        """Check if server is running"""
        return self.process and self.process.poll() is None
    
    def restart_server(self):
        """Restart the server"""
        self.stop_server()
        return self.start_server()

def signal_handler(signum, frame):
    """Handle shutdown signals"""
    print("\nShutting down backend server...")
    if hasattr(signal_handler, 'server'):
        signal_handler.server.stop_server()
    sys.exit(0)

if __name__ == "__main__":
    # Setup signal handlers
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    # Create and start server
    server = BackendServer()
    signal_handler.server = server  # Store reference for signal handler
    
    if server.start_server():
        try:
            # Keep the script running
            while server.is_running():
                time.sleep(1)
        except KeyboardInterrupt:
            server.stop_server()
    else:
        print("Failed to start server")
        sys.exit(1)
