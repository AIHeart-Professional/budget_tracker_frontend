import 'package:flutter/material.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('Categories'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Expenses'),
            Tab(text: 'Income'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCategoryDialog,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryList('expense'),
          _buildCategoryList('income'),
        ],
      ),
    );
  }

  Widget _buildCategoryList(String type) {
    final expenseCategories = [
      {'name': 'Food & Dining', 'icon': Icons.restaurant, 'color': Colors.orange, 'budget': 600.0, 'spent': 450.0},
      {'name': 'Transportation', 'icon': Icons.directions_car, 'color': Colors.blue, 'budget': 400.0, 'spent': 320.0},
      {'name': 'Shopping', 'icon': Icons.shopping_bag, 'color': Colors.purple, 'budget': 350.0, 'spent': 280.0},
      {'name': 'Entertainment', 'icon': Icons.movie, 'color': Colors.teal, 'budget': 200.0, 'spent': 150.0},
      {'name': 'Health & Fitness', 'icon': Icons.medical_services, 'color': Colors.red, 'budget': 300.0, 'spent': 125.0},
      {'name': 'Education', 'icon': Icons.school, 'color': Colors.indigo, 'budget': 250.0, 'spent': 80.0},
      {'name': 'Utilities', 'icon': Icons.electrical_services, 'color': Colors.amber, 'budget': 500.0, 'spent': 480.0},
      {'name': 'Rent', 'icon': Icons.home, 'color': Colors.brown, 'budget': 1200.0, 'spent': 1200.0},
    ];

    final incomeCategories = [
      {'name': 'Salary', 'icon': Icons.work, 'color': Colors.green, 'amount': 3500.0},
      {'name': 'Freelance', 'icon': Icons.laptop, 'color': Colors.blue, 'amount': 750.0},
      {'name': 'Business', 'icon': Icons.business, 'color': Colors.purple, 'amount': 0.0},
      {'name': 'Investment', 'icon': Icons.trending_up, 'color': Colors.teal, 'amount': 0.0},
      {'name': 'Gift', 'icon': Icons.card_giftcard, 'color': Colors.pink, 'amount': 0.0},
      {'name': 'Other', 'icon': Icons.category, 'color': Colors.grey, 'amount': 0.0},
    ];

    final categories = type == 'expense' ? expenseCategories : incomeCategories;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: (category['color'] as Color).withOpacity(0.1),
              child: Icon(
                category['icon'] as IconData,
                color: category['color'] as Color,
              ),
            ),
            title: Text(
              category['name'] as String,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: type == 'expense' 
              ? _buildExpenseSubtitle(category)
              : _buildIncomeSubtitle(category),
            trailing: type == 'expense'
              ? _buildExpenseTrailing(category)
              : _buildIncomeTrailing(category),
            onTap: () => _showCategoryDetails(category, type),
          ),
        );
      },
    );
  }

  Widget _buildExpenseSubtitle(Map<String, dynamic> category) {
    final budget = category['budget'] as double;
    final spent = category['spent'] as double;
    final progress = spent / budget;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('\$${spent.toStringAsFixed(0)} spent'),
            Text('of \$${budget.toStringAsFixed(0)}'),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress > 1.0 ? 1.0 : progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            progress > 0.9 ? Colors.red : category['color'] as Color,
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeSubtitle(Map<String, dynamic> category) {
    final amount = category['amount'] as double;
    
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        amount > 0 
          ? 'This month: \$${amount.toStringAsFixed(2)}'
          : 'No income this month',
        style: TextStyle(
          color: amount > 0 ? Colors.green : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildExpenseTrailing(Map<String, dynamic> category) {
    final budget = category['budget'] as double;
    final spent = category['spent'] as double;
    final remaining = budget - spent;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          remaining >= 0 ? '\$${remaining.toStringAsFixed(0)} left' : 'Over budget',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: remaining >= 0 ? Colors.green : Colors.red,
          ),
        ),
        Text(
          '${((spent / budget) * 100).toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeTrailing(Map<String, dynamic> category) {
    final amount = category['amount'] as double;
    
    return Text(
      '\$${amount.toStringAsFixed(2)}',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: amount > 0 ? Colors.green : Colors.grey[600],
        fontSize: 16,
      ),
    );
  }

  void _showCategoryDetails(Map<String, dynamic> category, String type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                category['icon'] as IconData,
                color: category['color'] as Color,
              ),
              const SizedBox(width: 8),
              Text(category['name'] as String),
            ],
          ),
          content: type == 'expense' 
            ? _buildExpenseDetails(category)
            : _buildIncomeDetails(category),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showEditCategoryDialog(category, type);
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpenseDetails(Map<String, dynamic> category) {
    final budget = category['budget'] as double;
    final spent = category['spent'] as double;
    final remaining = budget - spent;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Budget', '\$${budget.toStringAsFixed(2)}'),
        _buildDetailRow('Spent', '\$${spent.toStringAsFixed(2)}'),
        _buildDetailRow(
          'Remaining', 
          '\$${remaining.toStringAsFixed(2)}',
          color: remaining >= 0 ? Colors.green : Colors.red,
        ),
        const SizedBox(height: 16),
        const Text('Progress:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (spent / budget) > 1.0 ? 1.0 : (spent / budget),
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            (spent / budget) > 0.9 ? Colors.red : category['color'] as Color,
          ),
        ),
        const SizedBox(height: 8),
        Text('${((spent / budget) * 100).toStringAsFixed(1)}% used'),
      ],
    );
  }

  Widget _buildIncomeDetails(Map<String, dynamic> category) {
    final amount = category['amount'] as double;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('This Month', '\$${amount.toStringAsFixed(2)}'),
        _buildDetailRow('Last Month', '\$${(amount * 0.85).toStringAsFixed(2)}'), // Mock data
        _buildDetailRow('Average', '\$${(amount * 0.92).toStringAsFixed(2)}'), // Mock data
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final budgetController = TextEditingController();
    IconData selectedIcon = Icons.category;
    Color selectedColor = Colors.blue;
    String categoryType = _tabController.index == 0 ? 'expense' : 'income';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Add ${categoryType == 'expense' ? 'Expense' : 'Income'} Category'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (categoryType == 'expense') ...[
                      TextField(
                        controller: budgetController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Monthly Budget',
                          prefixText: '\$ ',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        const Text('Icon: '),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _showIconPicker(setDialogState, (icon) {
                            selectedIcon = icon;
                          }),
                          child: CircleAvatar(
                            backgroundColor: selectedColor.withOpacity(0.1),
                            child: Icon(selectedIcon, color: selectedColor),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text('Color: '),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _showColorPicker(setDialogState, (color) {
                            selectedColor = color;
                          }),
                          child: CircleAvatar(backgroundColor: selectedColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      // TODO: Add category to data source
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Category added successfully!')),
                      );
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditCategoryDialog(Map<String, dynamic> category, String type) {
    final nameController = TextEditingController(text: category['name'] as String);
    final budgetController = TextEditingController(
      text: type == 'expense' ? (category['budget'] as double).toString() : '',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
              ),
              if (type == 'expense') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: budgetController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Monthly Budget',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Delete category
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Category deleted!')),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                // TODO: Update category
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Category updated!')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showIconPicker(StateSetter setDialogState, Function(IconData) onIconSelected) {
    final icons = [
      Icons.restaurant, Icons.directions_car, Icons.shopping_bag,
      Icons.movie, Icons.medical_services, Icons.school,
      Icons.home, Icons.electrical_services, Icons.work,
      Icons.laptop, Icons.business, Icons.trending_up,
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose Icon'),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: icons.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    onIconSelected(icons[index]);
                    Navigator.of(context).pop();
                    setDialogState(() {});
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icons[index]),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showColorPicker(StateSetter setDialogState, Function(Color) onColorSelected) {
    final colors = [
      Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
      Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
      Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
      Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose Color'),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: colors.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    onColorSelected(colors[index]);
                    Navigator.of(context).pop();
                    setDialogState(() {});
                  },
                  child: CircleAvatar(backgroundColor: colors[index]),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
