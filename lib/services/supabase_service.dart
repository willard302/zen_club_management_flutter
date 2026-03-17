import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:app/models/user.dart' as app_models;
import 'package:app/models/transaction.dart';
import 'package:app/config/supabase_config.dart';

/// Supabase 数据库服务类
/// 处理所有与 Supabase 的交互
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  late SupabaseClient _client;

  SupabaseService._internal();

  /// 单例工厂构造函数
  factory SupabaseService() {
    return _instance;
  }

  /// 获取 Supabase 客户端
  SupabaseClient get client => _client;

  /// 获取当前认证用户（从内存缓存）
  /// 注：如需最新数据，请调用 fetchCurrentUser()
  app_models.User? _cachedCurrentUser;

  /// 获取缓存的当前用户
  app_models.User? get currentUser => _cachedCurrentUser;

  /// 从 users 表获取最新的当前用户信息
  Future<app_models.User?> fetchCurrentUser() async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) return null;

      final userId = session.user.id;
      
      final userDoc = await _client
          .from('users')
          .select('*')
          .eq('id', userId)
          .single();

      _cachedCurrentUser = app_models.User.fromJson(userDoc);
      return _cachedCurrentUser;
    } catch (e) {
      print('获取当前用户信息失败: $e');
      return null;
    }
  }

  /// 初始化 Supabase
  Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      _client = Supabase.instance.client;
    } catch (e) {
      throw Exception('Failed to initialize Supabase: $e');
    }
  }

  // ==================== Auth Methods ====================

  /// 用户注册
  Future<app_models.User> signUp({
    required String email,
    required String password,
    required String name,
    required String studentId,
    required String role,
  }) async {
    try {
      // 第 1 步：创建认证用户
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'student_id': studentId,
          'role': role,
        },
      );

      if (response.user == null) {
        throw Exception('用户注册失败');
      }

      final userId = response.user!.id;
      final newUser = app_models.User(
        id: userId,
        email: response.user!.email ?? email,
        name: name,
        studentId: studentId,
        role: role,
        createdAt: DateTime.now(),
      );

      // 第 2 步：在 users 表中创建用户记录
      try {
        await _client.from('users').insert({
          'id': userId,
          'avatar_url': '',
          'email': email,
          'gender': '',
          'name': name,
          'student_id': studentId,
          'hierarchy': '',
          'club_role': role,
          'phone': '',
          'line_id': '',
          'instagram': '',
          'department': '',
          'grade': '',
          'birthday': DateTime(2000, 1, 1).toIso8601String(), // 默认生日
          'club_group': '',
          'inviter': '',
          'join_date': DateTime.now().toIso8601String(), // 默认加入时间
          'created_by': 'system',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        print('✓ 用户记录已创建到 users 表');
        _cachedCurrentUser = newUser;
      } catch (e) {
        print('⚠️ 警告：在 users 表中创建用户记录失败: $e');
        // 继续执行，因为认证用户已创建成功
      }

      return newUser;
    } catch (e) {
      throw Exception('注册错误: $e');
    }
  }

  /// 用户登录
  Future<app_models.User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('登录失败');
      }

      final userId = response.user!.id;

      // 尝试从 users 表获取用户信息
      try {
        final userDoc = await _client
            .from('users')
            .select('*')
            .eq('id', userId)
            .single();

        final user = app_models.User.fromJson(userDoc);
        _cachedCurrentUser = user;
        print('✓ 用户信息已从 users 表加载');
        return user;
      } catch (e) {
        // 如果 users 表中没有记录，从 auth 用户创建
        print('⚠️ 警告：users 表中未找到用户记录，使用 auth 数据: $e');
        
        final fallbackUser = app_models.User(
          id: userId,
          email: response.user!.email ?? email,
          name: response.user!.userMetadata?['name'] ?? email.split('@')[0],
          role: response.user!.userMetadata?['role'] ?? '会员',
          createdAt: DateTime.now(),
        );
        _cachedCurrentUser = fallbackUser;
        return fallbackUser;
      }
    } catch (e) {
      throw Exception('登录错误: $e');
    }
  }

  /// 用户登出
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      _cachedCurrentUser = null;
      print('✓ 用户已登出，缓存已清除');
    } catch (e) {
      throw Exception('登出错误: $e');
    }
  }

  /// 获取当前认证状态
  bool get isAuthenticated => _client.auth.currentSession != null;

  // ==================== User Methods ====================

  /// 获取用户信息
  Future<app_models.User> getUser(String userId) async {
    try {
      final userDoc = await _client
          .from('users')
          .select('*')
          .eq('id', userId)
          .single();

      return app_models.User.fromJson(userDoc);
    } catch (e) {
      throw Exception('获取用户信息失败: $e');
    }
  }

  /// 更新用户信息
  Future<app_models.User> updateUser({
    required String userId,
    String? name,
    String? role,
    String? email,
    String? phone,
    String? gender,
    String? department,
    String? grade,
    DateTime? birthday,
    String? avatarUrl,
    String? lineId,
    String? instagram,
    String? hierarchy,
    String? clubRole,
    String? clubGroup,
    String? inviter,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updates['name'] = name;
      if (role != null) updates['role'] = role;
      if (email != null) updates['email'] = email;
      if (phone != null) updates['phone'] = phone;
      if (gender != null) updates['gender'] = gender;
      if (department != null) updates['department'] = department;
      if (grade != null) updates['grade'] = grade;
      if (birthday != null) updates['birthday'] = birthday.toIso8601String();
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (lineId != null) updates['line_id'] = lineId;
      if (instagram != null) updates['instagram'] = instagram;
      if (hierarchy != null) updates['hierarchy'] = hierarchy;
      if (clubRole != null) updates['club_role'] = clubRole;
      if (clubGroup != null) updates['club_group'] = clubGroup;
      if (inviter != null) updates['inviter'] = inviter;

      final response = await _client
          .from('users')
          .update(updates)
          .eq('id', userId)
          .select('*')
          .single();

      return app_models.User.fromJson(response);
    } catch (e) {
      throw Exception('更新用户信息失败: $e');
    }
  }

  // ==================== Transaction Methods ====================

  /// 获取所有交易记录
  Future<List<Transaction>> getTransactions() async {
    try {
      final response = await _client
          .from('transactions')
          .select('*')
          .order('date', ascending: false);

      return (response as List)
          .map((item) => Transaction.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('获取交易记录失败: $e');
    }
  }

  /// 根据用户获取交易记录
  Future<List<Transaction>> getUserTransactions(String userId) async {
    try {
      final response = await _client
          .from('transactions')
          .select('*')
          .or('requester_id.eq.$userId,finance_id.eq.$userId')
          .order('date', ascending: false);

      return (response as List)
          .map((item) => Transaction.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('获取用户交易记录失败: $e');
    }
  }

  /// 创建交易记录
  Future<Transaction> createTransaction({
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
    try {
      final response = await _client
          .from('transactions')
          .insert({
            'title': title,
            'requester_id': requesterId,
            'finance_id': financeId,
            'category': category,
            'amount': amount,
            'date': date.toIso8601String(),
            'type': type,
            'status': status,
            'icon': iconCode,
            'receipt_path': receiptPath,
            'is_approved': isApproved,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select('*')
          .single();

      return Transaction.fromJson(response);
    } catch (e) {
      throw Exception('创建交易记录失败: $e');
    }
  }

  /// 更新交易记录
  Future<Transaction> updateTransaction({
    required String id,
    String? title,
    String? category,
    double? amount,
    String? status,
    bool? isApproved,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (title != null) updates['title'] = title;
      if (category != null) updates['category'] = category;
      if (amount != null) updates['amount'] = amount;
      if (status != null) updates['status'] = status;
      if (isApproved != null) updates['is_approved'] = isApproved;

      final response = await _client
          .from('transactions')
          .update(updates)
          .eq('id', id)
          .select('*')
          .single();

      return Transaction.fromJson(response);
    } catch (e) {
      throw Exception('更新交易记录失败: $e');
    }
  }

  /// 删除交易记录
  Future<void> deleteTransaction(String id) async {
    try {
      await _client.from('transactions').delete().eq('id', id);
    } catch (e) {
      throw Exception('删除交易记录失败: $e');
    }
  }

  // ==================== Subscription Methods ====================

  /// 订阅交易记录变化（实时更新）
  /// 注意：需要在 Supabase 中启用 REPLICA IDENTITY FULL
  /// TODO: 实现实时订阅需要使用新的 Supabase Realtime API
  /* 
  RealtimeChannel subscribeToTransactions(
    Function(List<Transaction>) onUpdate,
  ) {
    final channel = _client.channel(
      'public:transactions',
      opts: const RealtimeChannelConfig(self: true),
    );

    channel.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
        event: '*',
        schema: 'public',
        table: 'transactions',
      ),
      (payload) async {
        try {
          final transactions = await getTransactions();
          onUpdate(transactions);
        } catch (e) {
          print('Error updating transactions: $e');
        }
      },
    ).subscribe();

    return channel;
  }
  */

  /// 方便方法：订阅交易更新并刷新列表
  void setupTransactionUpdates(
    Function(List<Transaction>) onUpdate,
  ) {
    // 目前使用定时轮询的方式，后续可升级为真实时
    // 实时功能需要:
    // 1. 在 Supabase 中启用 REPLICA IDENTITY FULL
    // 2. 为表启用 RLS (行级安全)
    // 3. 配置相应的策略
  }

  /// 清理资源
  void dispose() {
    // Clean up if needed
  }
}
