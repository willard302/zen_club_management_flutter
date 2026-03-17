# Supabase 集成工作指南

## 快速开始

此项目已集成 **Supabase** 作为后端服务。以下是项目结构和配置步骤。

## 📁 项目结构

```
lib/
├── config/
│   └── supabase_config.dart      # Supabase 配置（需填入凭证）
├── models/
│   ├── user.dart                 # 用户模型
│   └── transaction.dart          # 交易模型
├── services/
│   ├── supabase_service.dart     # Supabase 服务类
│   └── supabase_schema.sql       # 数据库架构 SQL 脚本
├── providers/
│   ├── user_provider.dart        # 用户 Provider（已更新）
│   └── ledger_provider.dart      # 账本 Provider（已更新）
└── main.dart                     # 主入口（已更新初始化）
```

## 🚀 配置步骤

### 1. 创建 Supabase 项目

1. 访问 [supabase.com](https://supabase.com)
2. 登录或注册账户
3. 创建新项目：
   - 项目名称：任意
   - 数据库密码：设置强密码
   - 地区：选择最近的地理位置
4. 等待项目初始化完成

### 2. 获取 API 凭证

1. 进入项目仪表板
2. 点击 **Settings** → **API**
3. 找到以下信息：
   - **Project URL**: 复制 `https://[project-id].supabase.co`
   - **API Keys**：找到 `anon` (public) 密钥

### 3. 配置本地开发环境

编辑 [lib/config/supabase_config.dart](lib/config/supabase_config.dart)：

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY';
}
```

替换为你的实际值。

### 4. 创建数据库表

1. 在 Supabase 仪表板中进入 **SQL Editor**
2. 点击 **New Query**
3. 将 [lib/services/supabase_schema.sql](lib/services/supabase_schema.sql) 的内容复制到编辑器
4. 点击 **Run** 执行脚本

### 5. 配置身份验证

在 Supabase 仪表板：

1. 进入 **Authentication** → **Providers**
2. 启用 **Email** 提供程序
3. 配置电子邮件模板（可选）

### 6. 可选：启用行级安全 (RLS)

对于生产环境，建议启用 RLS：

```sql
-- 在 SQL Editor 中运行
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

-- 创建策略示例
CREATE POLICY "Users can view their own data" 
ON public.users FOR SELECT 
USING (auth.uid() = id);

CREATE POLICY "Users can view related transactions"
ON public.transactions FOR SELECT
USING (auth.uid() = requester_id OR auth.uid() = finance_id);
```

## 📚 API 参考

### SupabaseService 类

#### 认证方法

```dart
// 获取 Supabase 客户端
final client = SupabaseService().client;

// 用户注册
await SupabaseService().signUp(
  email: 'user@example.com',
  password: 'password',
  name: '用户名',
  role: '会員'
);

// 用户登录
await SupabaseService().signIn(
  email: 'user@example.com',
  password: 'password'
);

// 用户登出
await SupabaseService().signOut();

// 检查认证状态
bool isAuth = SupabaseService().isAuthenticated;
```

#### 用户方法

```dart
// 获取用户信息
User user = await SupabaseService().getUser(userId);

// 更新用户信息
User updated = await SupabaseService().updateUser(
  userId: userId,
  name: '新名字',
  role: '管理員'
);
```

#### 交易方法

```dart
// 获取所有交易
List<Transaction> all = await SupabaseService().getTransactions();

// 根据用户获取交易
List<Transaction> userTx = await SupabaseService()
  .getUserTransactions(userId);

// 创建交易
Transaction tx = await SupabaseService().createTransaction(
  title: '交易标题',
  requesterId: 'requester-uuid',
  financeId: 'finance-uuid',
  category: '分类',
  amount: 100.0,
  date: DateTime.now(),
  type: 'income',
  status: '待处理',
  iconCode: '61632', // Material Icons 代码
);

// 更新交易
await SupabaseService().updateTransaction(
  id: txId,
  status: '已批准',
  isApproved: true,
);

// 删除交易
await SupabaseService().deleteTransaction(txId);
```

### Provider 集成

#### UserProvider

```dart
context.read<UserProvider>().signIn(
  email: email,
  password: password,
);

// 访问当前用户信息
String name = context.read<UserProvider>().name;
String role = context.read<UserProvider>().role;

// 处理错误
String? error = context.read<UserProvider>().errorMessage;
bool loading = context.read<UserProvider>().isLoading;
```

#### LedgerProvider

```dart
// 加载交易
await context.read<LedgerProvider>().loadTransactions();

// 添加交易（需要管理员权限）
await context.read<LedgerProvider>().addTransaction(
  title: '标题',
  requesterId: userId,
  financeId: financeId,
  category: '分类',
  amount: 100.0,
  date: DateTime.now(),
  type: 'income',
  status: '待处理',
  iconCode: '61632',
);

// 访问交易数据
List<Transaction> tx = context.read<LedgerProvider>().transactions;
double balance = context.read<LedgerProvider>().availableBalance;
```

## 🔐 环境变量最佳实践

对于生产环境，使用环境变量而不是硬编码凭证：

1. 创建 `.env` 文件（不提交到 Git）：
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

2. 使用 `flutter_dotenv` 包加载：
```dart
// 在 pubspec.yaml 中添加
dependencies:
  flutter_dotenv: ^5.0.0
```

```dart
// 在 main.dart 中
await dotenv.load(fileName: ".env");

// 在 supabase_config.dart 中
class SupabaseConfig {
  static final String supabaseUrl = dotenv.env['SUPABASE_URL']!;
  static final String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;
}
```

## 🧪 测试

建议在实现后进行的测试：

- [ ] 用户注册功能
- [ ] 用户登录/登出功能  
- [ ] 创建交易记录
- [ ] 更新交易记录
- [ ] 删除交易记录
- [ ] 实时同步（如果启用了訂閱）
- [ ] 权限检查

## 📖 相关资源

- [Supabase 官方文档](https://supabase.com/docs)
- [Supabase Flutter 库](https://pub.dev/packages/supabase_flutter)
- [PostgreSQL 文档](https://www.postgresql.org/docs/)

## 🐛 常见问题

### Q: 如何处理 CORS 错误？
A: Supabase 默认允许所有 CORS 请求。如果遇到问题，检查：
- API 凭证是否正确
- 网络连接是否正常
- Supabase 项目状态

### Q: 如何实现自定义身份验证？
A: 可以创建自定义认证流程。参考 Supabase 文档中的"自定义声明"部分。

### Q: 交易数据同步是实时的吗？
A: 是的，如果启用了实时订阅。参考 `SupabaseService.subscribeToTransactions()` 方法。

## 📞 支持

如有问题，请：
1. 查看 Supabase 官方文档
2. 检查 Flutter 插件文档
3. 查看项目中的 TODO 注释

---

**项目现已准备好与 Supabase 集成！完成上述步骤后，应用应能正常运行。**
