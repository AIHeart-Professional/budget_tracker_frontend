import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as Path;

class BackendService {
  static final BackendService _instance = BackendService._internal();
  factory BackendService() => _instance;
  BackendService._internal();

  Process? _backendProcess;
  bool _isRunning = false;
  String? _backendPath;

  bool get isRunning => _isRunning;

  Future<bool> startBackend() async {
    if (_isRunning) {
      print('Backend is already running');
      return true;
    }

    try {
      // Find the backend directory
      _backendPath = await _findBackendPath();
      if (_backendPath == null) {
        print('Backend directory not found');
        return false;
      }

      print('Starting Python backend from: $_backendPath');

      // Install Python dependencies first
      await _installDependencies();

      // Start the backend server using Process directly
      _backendProcess = await Process.start(
        'python',
        [
          '-m',
          'uvicorn',
          'main:app',
          '--host',
          '127.0.0.1',
          '--port',
          '8000',
          '--reload'
        ],
        workingDirectory: _backendPath,
      );

      if (_backendProcess != null) {
        _isRunning = true;
        print('Python backend started successfully');
        
        // Listen for process termination
        _backendProcess!.exitCode.then((exitCode) {
          print('Backend process exited with code: $exitCode');
          _isRunning = false;
          _backendProcess = null;
        });

        // Give the server time to start up
        await Future.delayed(const Duration(seconds: 3));
        
        return true;
      }
    } catch (e) {
      print('❌ Failed to start backend: $e');
      _isRunning = false;
    }

    return false;
  }

  Future<void> stopBackend() async {
    if (_backendProcess != null) {
      print('Stopping Python backend...');
      
      try {
        // Try graceful termination first
        _backendProcess!.kill(ProcessSignal.sigterm);
        
        // Wait for process to exit gracefully
        await _backendProcess!.exitCode.timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            // Force kill if not terminated gracefully
            _backendProcess!.kill(ProcessSignal.sigkill);
            return -1;
          },
        );
        
        print('Backend stopped successfully');
      } catch (e) {
        print('Error stopping backend: $e');
      }
      
      _backendProcess = null;
      _isRunning = false;
    }
  }

  Future<String?> _findBackendPath() async {
    try {
      // Get the executable directory (where the .exe is located)
      final executable = Platform.resolvedExecutable;
      final executableDir = Directory(Path.dirname(executable));
      
      // Try to find backend directory relative to the executable
      final possiblePaths = [
        // When running from dist package
        '${executableDir.parent.path}/backend',
        // When running in development
        '${Directory.current.path}/backend',
        // Alternative relative paths
        '${executableDir.path}/backend',
        '${executableDir.path}/../backend',
        '${executableDir.path}/../../backend',
        // Current directory relative
        './backend',
        '../backend',
      ];

      for (final path in possiblePaths) {
        final dir = Directory(path);
        if (await dir.exists()) {
          final mainPy = File('${dir.path}/main.py');
          if (await mainPy.exists()) {
            print('Found backend at: ${dir.absolute.path}');
            return dir.absolute.path;
          }
        }
      }
      
      print('Backend directory not found in any of the expected locations');
      print('Searched paths:');
      for (final path in possiblePaths) {
        print('  - $path');
      }
      
    } catch (e) {
      print('Error finding backend path: $e');
    }

    return null;
  }

  Future<void> _installDependencies() async {
    if (_backendPath == null) return;

    try {
      final requirementsFile = File('$_backendPath/requirements.txt');
      if (await requirementsFile.exists()) {
        print('Installing Python dependencies...');
        
        await Process.run(
          'python',
          [
            '-m',
            'pip',
            'install',
            '-r',
            'requirements.txt',
          ],
          workingDirectory: _backendPath,
        );
        
        print('Dependencies installed successfully');
      }
    } catch (e) {
      print('Warning: Could not install dependencies: $e');
      // Continue anyway, dependencies might already be installed
    }
  }

  Future<bool> checkBackendHealth() async {
    try {
      // This would normally use HTTP to check health endpoint
      // For now, just check if process is running
      return _isRunning && _backendProcess != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> restartBackend() async {
    await stopBackend();
    await Future.delayed(const Duration(seconds: 2));
    await startBackend();
  }

  void dispose() {
    stopBackend();
  }
}
