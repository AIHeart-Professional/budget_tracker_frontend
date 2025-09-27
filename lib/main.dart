import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/categories_screen.dart';
import 'services/backend_service.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Start the Python backend automatically
  final backendService = BackendService();
  print('🚀 Starting Budget Tracker...');
  
  final backendStarted = await backendService.startBackend();
  if (!backendStarted) {
    print('⚠️ Warning: Could not start backend automatically');
  }
  
  // Wait a moment for backend to fully initialize
  await Future.delayed(const Duration(seconds: 2));
  
  runApp(const BudgetTrackerApp());
}

class BudgetTrackerApp extends StatelessWidget {
  const BudgetTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final BackendService _backendService = BackendService();
  final ApiService _apiService = ApiService();

  static const List<Widget> _screens = [
    HomeScreen(),
    TransactionsScreen(),
    CategoriesScreen(),
  ];

  @override
  void dispose() {
    // Clean shutdown of backend when app closes
    _backendService.dispose();
    _apiService.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
