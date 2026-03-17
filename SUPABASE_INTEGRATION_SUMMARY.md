# Supabase 集成总结

## 已完成的集成

此项目已完整集成 Supabase 后端服务。以下是已实现的功能和文件更改：

### 📦 依赖更新

- ✅ 添加 `supabase_flutter: ^2.9.1` 到 `pubspec.yaml`

### 📁 新建文件结构

```
lib/
├── config/
│   └── supabase_config.dart         # Supabase 配置（需填入凭证）
├── models/
│   ├── user.dart                    # User 模型（带 JSON 序列化）
│   └── transaction.dart             # Transaction 模型（带 JSON 序列化）
├── services/
│   ├── supabase_service.dart        # Supabase 核心服务（单例模式）
│   └── supabase_schema.sql          # 数据库 SQL 架构
└── SUPABASE_SETUP.md               # 详细设置指南
```

### 🔧 更新现有文件

| 文件 | 更改内容 |
|------|---------|
| `main.dart` | 添加 Supabase 初始化，传递 SupabaseService 到 Providers |
| `providers/user_provider.dart` | 集成 Supabase 认证（注册、登录、登出、更新) |
| `providers/ledger_provider.dart` | 集成 Supabase 交易操作（CRUD操作） |
| `screens/login_screen.dart` | 实现真实登录逻辑，添加加载状态和错误处理 |

## 🚀 快速开始

### 第1步：设置 Supabase 项目

1. 访问 [supabase.com](https://supabase.com)
2. 创建新项目
3. 获取 **Project URL** 和 **API Key (anon)**

### 第2步：配置本地凭证

编辑 `lib/config/supabase_config.dart`：

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY_HERE';
}
```

### 第3步：创建数据库表

1. 在 Supabase 仪表板中打开 **SQL Editor**
2. 运行 `lib/services/supabase_schema.sql` 中的 SQL 语句

### 第4步：启用身份验证

在 Supabase 仪表板：
- 进入 **Authentication** → **Providers**
- 启用 **Email** 提供程序

### 第5步：获取依赖

```bash
flutter pub get
```

## 🔑 核心 API 文档

### SupabaseService (单例)

```dart
// 获取实例
final service = SupabaseService();

// 认证
await service.signUp(email, password, name, role);
await service.signIn(email, password);
await service.signOut();
bool isAuth = service.isAuthenticated;

// 用户操作
User user = await service.getUser(userId);
User updated = await service.updateUser(userId: id, name: 'New Name');

// 交易操作
List<Transaction> txs = await service.getTransactions();
Transaction tx = await service.createTransaction(...);
await service.updateTransaction(id: '...', status: '已批准');
await service.deleteTransaction(id);
```

### UserProvider

```dart
context.read<UserProvider>().signIn(email, password);
context.read<UserProvider>().updateProfile(name, role);
context.read<UserProvider>().signOut();

// 获取数据
String name = context.read<UserProvider>().name;
String error = context.read<UserProvider>().errorMessage;
bool loading = context.read<UserProvider>().isLoading;
```

### LedgerProvider

```dart
// 加载数据
await context.read<LedgerProvider>().loadTransactions();
await context.read<LedgerProvider>().loadUserTransactions(userId);

// CRUD 操作
bool success = await context.read<LedgerProvider>().addTransaction(...);
bool success = await context.read<LedgerProvider>().updateTransaction(...);
bool success = await context.read<LedgerProvider>().deleteTransaction(id);

// 获取数据
List<Transaction> txs = context.read<LedgerProvider>().transactions;
double balance = context.read<LedgerProvider>().availableBalance;
```

## 📝 数据模型

### User 模型

```dart
User(
  id: 'uuid',
  email: 'user@example.com',
  name: '使用者名称',
  role: '會員',
  createdAt: DateTime.now(),
)
```

### Transaction 模型

```dart
Transaction(
  id: 'uuid',
  title: '交易標題',
  requesterId: 'requester-uuid',
  financeId: 'finance-uuid',
  category: '分類',
  amount: 100.0,
  date: DateTime.now(),
  type: TransactionType.income,
  status: '已批准',
  icon: Icons.spa,
  isApproved: true,
)
```

## ⚙️ 环境变量配置（生产环境推荐）

使用 `.env` 文件管理凭证：

```bash
# .env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-key-here
```

然后使用 `flutter_dotenv` 包加载。

## 🔒 权限和安全

### 现在实现的权限控制

- ✅ 用户只能编辑自己的信息
- ✅ 管理员权限检查（在 LedgerProvider 中）
- ✅ 认证状态检查

### 推荐的生产级设置

1. **启用 RLS** （行级安全性）
2. **定义策略** 以限制数据访问
3. **使用环境变量** 而不是硬编码凭证
4. **启用审计日志** 追踪数据变化

## 🧪 测试清单

- [ ] 用户注册
- [ ] 用户登录
- [ ] 用户登出
- [ ] 创建交易记录
- [ ] 更新交易记录
- [ ] 删除交易记录
- [ ] 查看个人信息
- [ ] 修改个人信息
- [ ] 加载交易历史记录
- [ ] 错误处理和显示

## 📚 进一步优化

建议的下一步改进：

1. **添加密码重置功能**
   ```dart
   await SupabaseService().client.auth
     .resetPasswordForEmail('user@example.com');
   ```

2. **实现社交登录** (Google, GitHub 等)

3. **添加数据分页**
   ```dart
   .range(0, 10); // Limit and offset
   ```

4. **实现实时订阅**
   ```dart
   SupabaseService().subscribeToTransactions((txs) {
     // Handle real-time updates
   });
   ```

5. **添加离线支持** (可使用 `sqflite`)

6. **实现更复杂的查询和过滤**

## ⚠️ 常见问题

**Q: 为什么登录失败？**
A: 
- 检查 Supabase 凭证是否正确
- 确保用户在 Supabase 中已注册
- 检查网络连接

**Q: 如何调试？**
A: 
- 在 `SupabaseService` 中添加日志
- 使用 Flutter DevTools 检查网络请求
- Supabase 仪表板中查看日志

**Q: 如何处理长列表性能？**
A: 使用分页：
```dart
.range(page * 20, (page + 1) * 20)
```

## 📞 获取帮助

- 查看 [SUPABASE_SETUP.md](./SUPABASE_SETUP.md) 获取详细设置指南
- 访问 [Supabase 文档](https://supabase.com/docs)
- 查看 [Flutter Supabase 包](https://pub.dev/packages/supabase_flutter)

---

**项目已准备好使用 Supabase！如有任何问题，请参考上述文档。**
