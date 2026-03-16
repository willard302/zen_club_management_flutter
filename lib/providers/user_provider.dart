import 'package:flutter/material.dart';
import 'package:app/models/user.dart' as app_models;
import 'package:app/services/supabase_service.dart';

class UserProvider with ChangeNotifier {
  final SupabaseService _supabaseService;
  
  app_models.User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserProvider(this._supabaseService) {
    _initializeUser();
  }

  // Getters
  app_models.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  String get name => _currentUser?.name ?? "用户";
  String get role => _currentUser?.role ?? "会員";
  String get email => _currentUser?.email ?? "";
  String get userId => _currentUser?.id ?? "";

  /// 初始化用户信息
  void _initializeUser() {
    try {
      if (_supabaseService.isAuthenticated) {
        _currentUser = _supabaseService.currentUser;
      }
    } catch (e) {
      _errorMessage = '初始化用户失败: $e';
    }
    notifyListeners();
  }

  /// 更新用户配置文件
  Future<bool> updateProfile(String name, String role) async {
    if (_currentUser == null) {
      _errorMessage = '未登录';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await _supabaseService.updateUser(
        userId: _currentUser!.id,
        name: name,
        role: role,
      );
      _currentUser = updatedUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 用户注册
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String studentId,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _supabaseService.signUp(
        email: email,
        password: password,
        name: name,
        studentId: studentId,
        role: role,
      );
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 用户登录
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _supabaseService.signIn(
        email: email,
        password: password,
      );
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 用户登出
  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
      _currentUser = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// 清除错误消息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

