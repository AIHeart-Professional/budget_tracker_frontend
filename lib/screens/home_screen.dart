import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Monthly Budget Overview Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Monthly Budget',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          'September 2024',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Budget Progress Indicator
                    LinearProgressIndicator(
                      value: 0.65, // 65% of budget used
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Spent',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const Text(
                              '\$1,950.00',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Remaining',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              '\$1,050.00',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Quick Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Income',
                    '\$3,500.00',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Expenses',
                    '\$1,950.00',
                    Icons.trending_down,
                    Colors.red,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Recent Transactions Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to transactions screen
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Recent Transactions List
            ...List.generate(5, (index) => _buildTransactionItem(context, index)),
            
            const SizedBox(height: 24),
            
            // Categories Overview
            Text(
              'Categories Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            
            const SizedBox(height: 16),
            
            // Category Progress Bars
            ...List.generate(4, (index) => _buildCategoryProgress(context, index)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatCard(BuildContext context, String title, String amount, 
                       IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTransactionItem(BuildContext context, int index) {
    final transactions = [
      {'title': 'Grocery Shopping', 'amount': '-\$85.50', 'category': 'Food', 'date': 'Today'},
      {'title': 'Salary Deposit', 'amount': '+\$3,500.00', 'category': 'Income', 'date': 'Yesterday'},
      {'title': 'Gas Station', 'amount': '-\$45.00', 'category': 'Transport', 'date': 'Yesterday'},
      {'title': 'Restaurant', 'amount': '-\$32.75', 'category': 'Food', 'date': '2 days ago'},
      {'title': 'Online Shopping', 'amount': '-\$129.99', 'category': 'Shopping', 'date': '3 days ago'},
    ];
    
    final transaction = transactions[index];
    final isIncome = transaction['amount']!.startsWith('+');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isIncome ? Colors.green[100] : Colors.red[100],
          child: Icon(
            isIncome ? Icons.arrow_upward : Icons.arrow_downward,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
        title: Text(transaction['title']!),
        subtitle: Text('${transaction['category']} • ${transaction['date']}'),
        trailing: Text(
          transaction['amount']!,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isIncome ? Colors.green : Colors.red,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
  
  Widget _buildCategoryProgress(BuildContext context, int index) {
    final categories = [
      {'name': 'Food & Dining', 'spent': 450, 'budget': 600, 'color': Colors.orange},
      {'name': 'Transportation', 'spent': 320, 'budget': 400, 'color': Colors.blue},
      {'name': 'Shopping', 'spent': 280, 'budget': 350, 'color': Colors.purple},
      {'name': 'Entertainment', 'spent': 150, 'budget': 200, 'color': Colors.teal},
    ];
    
    final category = categories[index];
    final progress = (category['spent']! as int) / (category['budget']! as int);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category['name'] as String,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '\$${category['spent']} / \$${category['budget']}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(category['color'] as Color),
          ),
        ],
      ),
    );
  }
}
