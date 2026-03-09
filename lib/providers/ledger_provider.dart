import 'package:flutter/material.dart';

enum TransactionType { income, expense }

class Transaction {
  final String id;
  final String title;
  final String requester;
  final String finance;
  final String category;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String status;
  final IconData icon;
  final String? receiptPath;
  final bool isApproved;

  Transaction({
    required this.id,
    required this.title,
    required this.requester,
    required this.finance,
    required this.category,
    required this.amount,
    required this.date,
    required this.type,
    required this.status,
    required this.icon,
    this.receiptPath,
    this.isApproved = false,
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
      requester: "王大明",
      finance: "李小華",
      category: "禪修 • 上午 10:45",
      amount: 450.00,
      date: DateTime.now(),
      type: TransactionType.income,
      status: "已確認",
      icon: Icons.spa,
      isApproved: true,
    ),
    Transaction(
      id: "2",
      title: "園藝用品",
      requester: "陳建國",
      finance: "李小華",
      category: "維護 • 昨天",
      amount: 120.50,
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: TransactionType.expense,
      status: "已結算",
      icon: Icons.eco,
      isApproved: true,
    ),
    Transaction(
      id: "3",
      title: "每月會費",
      requester: "林美玲",
      finance: "李小華",
      category: "會員 • 10月24日",
      amount: 1200.00,
      date: DateTime.now().subtract(const Duration(days: 3)),
      type: TransactionType.income,
      status: "已確認",
      icon: Icons.diversity_3,
      isApproved: true,
    ),
    Transaction(
      id: "4",
      title: "水電費",
      requester: "張小芬",
      finance: "李小華",
      category: "設施 • 10月22日",
      amount: 340.00,
      date: DateTime.now().subtract(const Duration(days: 5)),
      type: TransactionType.expense,
      status: "處理中",
      icon: Icons.lightbulb,
      isApproved: false,
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

  void updateTransaction(Transaction updatedTx) {
    if (!_isAdmin) return;
    final index = _transactions.indexWhere((t) => t.id == updatedTx.id);
    if (index != -1) {
      _transactions[index] = updatedTx;
      notifyListeners();
    }
  }

  void deleteTransaction(String id) {
    if (!_isAdmin) return;
    _transactions.removeWhere((t) => t.id == id);
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
