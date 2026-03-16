import 'package:flutter/material.dart';
import 'package:app/models/transaction.dart';
import 'package:app/services/supabase_service.dart';

class LedgerProvider with ChangeNotifier {
  final SupabaseService _supabaseService;

  double _initialLimit = 0.0;
  double _monthlyBudget = 5000.0;
  bool _isAdmin = false;
  bool _isLoading = false;
  String? _errorMessage;

  final List<Transaction> _transactions = [];

  LedgerProvider(this._supabaseService) {
    loadTransactions();
  }

  // Getters
  List<Transaction> get transactions => _transactions;
  bool get isAdmin => _isAdmin;
  double get monthlyBudget => _monthlyBudget;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  /// 加载交易记录
  Future<void> loadTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final transactions = await _supabaseService.getTransactions();
      _transactions.clear();
      _transactions.addAll(transactions);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = '加载交易记录失败: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 根据用户加载交易记录
  Future<void> loadUserTransactions(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final transactions = await _supabaseService.getUserTransactions(userId);
      _transactions.clear();
      _transactions.addAll(transactions);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = '加载用户交易记录失败: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 添加交易记录
  Future<bool> addTransaction({
    required String title,
    required String requesterId,
    required String financeId,
    required String category,
    required double amount,
    required DateTime date,
    required String type,
    required String status,
    required String iconCode,
    String? receiptPath,
    bool isApproved = false,
  }) async {
    if (!_isAdmin) {
      _errorMessage = '权限不足';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final transaction = await _supabaseService.createTransaction(
        title: title,
        requesterId: requesterId,
        financeId: financeId,
        category: category,
        amount: amount,
        date: date,
        type: type,
        status: status,
        iconCode: iconCode,
        receiptPath: receiptPath,
        isApproved: isApproved,
      );
      _transactions.insert(0, transaction);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '添加交易记录失败: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 更新交易记录
  Future<bool> updateTransaction({
    required String id,
    String? title,
    String? category,
    double? amount,
    String? status,
    bool? isApproved,
  }) async {
    if (!_isAdmin) {
      _errorMessage = '权限不足';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedTx = await _supabaseService.updateTransaction(
        id: id,
        title: title,
        category: category,
        amount: amount,
        status: status,
        isApproved: isApproved,
      );
      final index = _transactions.indexWhere((t) => t.id == id);
      if (index != -1) {
        _transactions[index] = updatedTx;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '更新交易记录失败: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 删除交易记录
  Future<bool> deleteTransaction(String id) async {
    if (!_isAdmin) {
      _errorMessage = '权限不足';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabaseService.deleteTransaction(id);
      _transactions.removeWhere((t) => t.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '删除交易记录失败: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 设置初始限额
  Future<void> setInitialLimit(double limit) async {
    if (!_isAdmin) return;
    _initialLimit = limit;
    notifyListeners();
  }

  /// 设置每月预算
  Future<void> setMonthlyBudget(double budget) async {
    if (!_isAdmin) return;
    _monthlyBudget = budget;
    notifyListeners();
  }

  /// 设置管理员状态
  void setIsAdmin(bool value) {
    _isAdmin = value;
    notifyListeners();
  }

  /// 清除错误消息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
