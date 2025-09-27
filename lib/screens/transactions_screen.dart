import 'package:flutter/material.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Income'),
            Tab(text: 'Expenses'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'Today', child: Text('Today')),
              const PopupMenuItem(value: 'This Week', child: Text('This Week')),
              const PopupMenuItem(value: 'This Month', child: Text('This Month')),
              const PopupMenuItem(value: 'This Year', child: Text('This Year')),
              const PopupMenuItem(value: 'All', child: Text('All Time')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Balance Overview',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSummaryItem('Income', '\$3,500.00', Colors.green),
                        _buildSummaryItem('Expenses', '\$1,950.00', Colors.red),
                        _buildSummaryItem('Balance', '\$1,550.00', Colors.blue),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Filter Info
          if (_selectedFilter != 'All')
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Chip(
                label: Text('Filtered by: $_selectedFilter'),
                onDeleted: () {
                  setState(() {
                    _selectedFilter = 'All';
                  });
                },
              ),
            ),
          
          // Transactions List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionsList('all'),
                _buildTransactionsList('income'),
                _buildTransactionsList('expense'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String amount, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList(String type) {
    final allTransactions = [
      {
        'title': 'Salary Deposit',
        'amount': 3500.00,
        'category': 'Income',
        'date': '2024-09-25',
        'time': '09:00 AM',
        'type': 'income',
        'description': 'Monthly salary from ABC Company',
      },
      {
        'title': 'Grocery Shopping',
        'amount': -85.50,
        'category': 'Food',
        'date': '2024-09-26',
        'time': '02:30 PM',
        'type': 'expense',
        'description': 'Weekly groceries at SuperMart',
      },
      {
        'title': 'Gas Station',
        'amount': -45.00,
        'category': 'Transportation',
        'date': '2024-09-25',
        'time': '08:15 AM',
        'type': 'expense',
        'description': 'Fuel for car',
      },
      {
        'title': 'Freelance Payment',
        'amount': 750.00,
        'category': 'Income',
        'date': '2024-09-24',
        'time': '03:45 PM',
        'type': 'income',
        'description': 'Web design project payment',
      },
      {
        'title': 'Restaurant Dinner',
        'amount': -32.75,
        'category': 'Food',
        'date': '2024-09-24',
        'time': '07:20 PM',
        'type': 'expense',
        'description': 'Dinner at Italian Bistro',
      },
      {
        'title': 'Online Shopping',
        'amount': -129.99,
        'category': 'Shopping',
        'date': '2024-09-23',
        'time': '11:30 AM',
        'type': 'expense',
        'description': 'Electronics from TechStore',
      },
      {
        'title': 'Coffee Shop',
        'amount': -4.50,
        'category': 'Food',
        'date': '2024-09-23',
        'time': '09:15 AM',
        'type': 'expense',
        'description': 'Morning coffee',
      },
      {
        'title': 'Uber Ride',
        'amount': -12.30,
        'category': 'Transportation',
        'date': '2024-09-22',
        'time': '06:45 PM',
        'type': 'expense',
        'description': 'Ride to downtown',
      },
    ];

    // Filter transactions based on type
    List<Map<String, dynamic>> filteredTransactions = allTransactions.where((transaction) {
      if (type == 'all') return true;
      return transaction['type'] == type;
    }).toList();

    // Group transactions by date
    Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
    for (var transaction in filteredTransactions) {
      String date = transaction['date'] as String;
      if (!groupedTransactions.containsKey(date)) {
        groupedTransactions[date] = [];
      }
      groupedTransactions[date]!.add(transaction);
    }

    // Sort dates in descending order
    List<String> sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        String date = sortedDates[index];
        List<Map<String, dynamic>> dayTransactions = groupedTransactions[date]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _formatDate(date),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
            // Transactions for this date
            ...dayTransactions.map((transaction) => 
              _buildTransactionItem(transaction)),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final isIncome = (transaction['amount'] as double) > 0;
    final amount = (transaction['amount'] as double).abs();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isIncome ? Colors.green[100] : Colors.red[100],
          child: Icon(
            _getCategoryIcon(transaction['category'] as String),
            color: isIncome ? Colors.green : Colors.red,
            size: 20,
          ),
        ),
        title: Text(
          transaction['title'] as String,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${transaction['category']} • ${transaction['time']}'),
            if (transaction['description'] != null)
              Text(
                transaction['description'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'}\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isIncome ? Colors.green : Colors.red,
            fontSize: 16,
          ),
        ),
        onTap: () {
          _showTransactionDetails(transaction);
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transportation':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'income':
        return Icons.attach_money;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.medical_services;
      case 'education':
        return Icons.school;
      default:
        return Icons.category;
    }
  }

  String _formatDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));
    DateTime transactionDate = DateTime(date.year, date.month, date.day);
    
    if (transactionDate == today) {
      return 'Today';
    } else if (transactionDate == yesterday) {
      return 'Yesterday';
    } else {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  void _showTransactionDetails(Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(transaction['title'] as String),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Amount: ${transaction['amount'] > 0 ? '+' : ''}\$${(transaction['amount'] as double).toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              Text('Category: ${transaction['category']}'),
              const SizedBox(height: 8),
              Text('Date: ${_formatDate(transaction['date'] as String)}'),
              const SizedBox(height: 8),
              Text('Time: ${transaction['time']}'),
              if (transaction['description'] != null) ...[
                const SizedBox(height: 8),
                Text('Description: ${transaction['description']}'),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Navigate to edit transaction screen
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }
}
