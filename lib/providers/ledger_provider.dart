import 'package:flutter/material.dart';

enum TransactionType { income, expense }

class Transaction {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String status;
  final IconData icon;

  Transaction({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.type,
    required this.status,
    required this.icon,
  });
}

class LedgerProvider with ChangeNotifier {
  double _initialLimit = 0.0;
  double _monthlyBudget = 5000.0;
  final bool _isAdmin = true; // Simple permission control mock

  final List<Transaction> _transactions = [
    Transaction(
      id: "1",
      title: "禪修工作坊費用",
      category: "禪修 • 上午 10:45",
      amount: 450.00,
      date: DateTime.now(),
      type: TransactionType.income,
      status: "已確認",
      icon: Icons.spa,
    ),
    Transaction(
      id: "2",
      title: "園藝用品",
      category: "維護 • 昨天",
      amount: 120.50,
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: TransactionType.expense,
      status: "已結算",
      icon: Icons.eco,
    ),
    Transaction(
      id: "3",
      title: "每月會費",
      category: "會員 • 10月24日",
      amount: 1200.00,
      date: DateTime.now().subtract(const Duration(days: 3)),
      type: TransactionType.income,
      status: "已確認",
      icon: Icons.diversity_3,
    ),
    Transaction(
      id: "4",
      title: "水電費",
      category: "設施 • 10月22日",
      amount: 340.00,
      date: DateTime.now().subtract(const Duration(days: 5)),
      type: TransactionType.expense,
      status: "處理中",
      icon: Icons.lightbulb,
    ),
  ];

  List<Transaction> get transactions => _transactions;
  bool get isAdmin => _isAdmin;
  double get monthlyBudget => _monthlyBudget;

  double get totalIncome {
    return _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0, (sum, item) => sum + item.amount);
  }

  double get totalExpense {
    return _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (sum, item) => sum + item.amount);
  }

  double get availableBalance {
    return _initialLimit + totalIncome - totalExpense;
  }

  void addTransaction(Transaction transaction) {
    if (!_isAdmin) return; // Permission check
    _transactions.insert(0, transaction);
    notifyListeners();
  }

  void setInitialLimit(double limit) {
    if (!_isAdmin) return;
    _initialLimit = limit;
    notifyListeners();
  }

  void setMonthlyBudget(double budget) {
    if (!_isAdmin) return;
    _monthlyBudget = budget;
    notifyListeners();
  }
}
