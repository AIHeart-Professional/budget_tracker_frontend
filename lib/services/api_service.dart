import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class Transaction {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final String type; // 'income' or 'expense'
  final String date;
  final String time;
  final String? description;
  final String? createdAt;

  Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
    required this.time,
    this.description,
    this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      title: json['title'],
      amount: json['amount']?.toDouble() ?? 0.0,
      category: json['category'],
      type: json['type'],
      date: json['date'],
      time: json['time'],
      description: json['description'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
      'type': type,
      'date': date,
      'time': time,
      'description': description,
    };
  }
}

class Category {
  final int? id;
  final String name;
  final String type; // 'income' or 'expense'
  final double budget;
  final String icon;
  final String color;
  final String? createdAt;

  Category({
    this.id,
    required this.name,
    required this.type,
    required this.budget,
    required this.icon,
    required this.color,
    this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      budget: json['budget']?.toDouble() ?? 0.0,
      icon: json['icon'],
      color: json['color'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'budget': budget,
      'icon': icon,
      'color': color,
    };
  }
}

class BudgetSummary {
  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final double budgetUsed;
  final double budgetRemaining;

  BudgetSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.budgetUsed,
    required this.budgetRemaining,
  });

  factory BudgetSummary.fromJson(Map<String, dynamic> json) {
    return BudgetSummary(
      totalIncome: json['total_income']?.toDouble() ?? 0.0,
      totalExpenses: json['total_expenses']?.toDouble() ?? 0.0,
      balance: json['balance']?.toDouble() ?? 0.0,
      budgetUsed: json['budget_used']?.toDouble() ?? 0.0,
      budgetRemaining: json['budget_remaining']?.toDouble() ?? 0.0,
    );
  }
}

class CategorySpending {
  final String name;
  final double budget;
  final String icon;
  final String color;
  final double spent;
  final double remaining;
  final double percentage;

  CategorySpending({
    required this.name,
    required this.budget,
    required this.icon,
    required this.color,
    required this.spent,
    required this.remaining,
    required this.percentage,
  });

  factory CategorySpending.fromJson(Map<String, dynamic> json) {
    return CategorySpending(
      name: json['name'],
      budget: json['budget']?.toDouble() ?? 0.0,
      icon: json['icon'],
      color: json['color'],
      spent: json['spent']?.toDouble() ?? 0.0,
      remaining: json['remaining']?.toDouble() ?? 0.0,
      percentage: json['percentage']?.toDouble() ?? 0.0,
    );
  }
}

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // HTTP client with timeout
  final http.Client _client = http.Client();
  final Duration _timeout = const Duration(seconds: 10);

  // Helper method for making HTTP requests
  Future<http.Response> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final defaultHeaders = {
      'Content-Type': 'application/json',
      ...?headers,
    };

    http.Response response;
    
    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _client.get(url, headers: defaultHeaders).timeout(_timeout);
          break;
        case 'POST':
          response = await _client.post(
            url, 
            headers: defaultHeaders,
            body: body != null ? json.encode(body) : null,
          ).timeout(_timeout);
          break;
        case 'PUT':
          response = await _client.put(
            url, 
            headers: defaultHeaders,
            body: body != null ? json.encode(body) : null,
          ).timeout(_timeout);
          break;
        case 'DELETE':
          response = await _client.delete(url, headers: defaultHeaders).timeout(_timeout);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }
      
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Check if backend is running
  Future<bool> isBackendRunning() async {
    try {
      final response = await _makeRequest('GET', '/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Transaction methods
  Future<List<Transaction>> getTransactions({
    String? type,
    String? category,
    int? limit,
  }) async {
    String endpoint = '/transactions';
    List<String> queryParams = [];
    
    if (type != null) queryParams.add('type=$type');
    if (category != null) queryParams.add('category=$category');
    if (limit != null) queryParams.add('limit=$limit');
    
    if (queryParams.isNotEmpty) {
      endpoint += '?${queryParams.join('&')}';
    }

    final response = await _makeRequest('GET', endpoint);
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Transaction.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch transactions: ${response.statusCode}');
    }
  }

  Future<Transaction> createTransaction(Transaction transaction) async {
    final response = await _makeRequest('POST', '/transactions', body: transaction.toJson());
    
    if (response.statusCode == 200) {
      return Transaction.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create transaction: ${response.statusCode}');
    }
  }

  Future<Transaction> getTransaction(int id) async {
    final response = await _makeRequest('GET', '/transactions/$id');
    
    if (response.statusCode == 200) {
      return Transaction.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch transaction: ${response.statusCode}');
    }
  }

  Future<void> deleteTransaction(int id) async {
    final response = await _makeRequest('DELETE', '/transactions/$id');
    
    if (response.statusCode != 200) {
      throw Exception('Failed to delete transaction: ${response.statusCode}');
    }
  }

  // Category methods
  Future<List<Category>> getCategories({String? type}) async {
    String endpoint = '/categories';
    if (type != null) {
      endpoint += '?type=$type';
    }

    final response = await _makeRequest('GET', endpoint);
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch categories: ${response.statusCode}');
    }
  }

  Future<Category> createCategory(Category category) async {
    final response = await _makeRequest('POST', '/categories', body: category.toJson());
    
    if (response.statusCode == 200) {
      return Category.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create category: ${response.statusCode}');
    }
  }

  // Budget methods
  Future<BudgetSummary> getBudgetSummary() async {
    final response = await _makeRequest('GET', '/budget/summary');
    
    if (response.statusCode == 200) {
      return BudgetSummary.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch budget summary: ${response.statusCode}');
    }
  }

  Future<List<CategorySpending>> getCategorySpending() async {
    final response = await _makeRequest('GET', '/budget/categories');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CategorySpending.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch category spending: ${response.statusCode}');
    }
  }

  // Clean up resources
  void dispose() {
    _client.close();
  }
}
