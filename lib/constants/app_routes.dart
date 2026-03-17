/// 應用全站路由名稱常數
/// 統一管理所有路由，避免字符串重複定義
class AppRoutes {
  // 認證相關
  static const String login = '/login';
  static const String signup = '/signup';

  // 主應用
  static const String main = '/main';

  // 主應用標籤頁
  static const String home = '/home';
  static const String ledger = '/ledger';
  static const String calendar = '/calendar';
  static const String statistics = '/statistics';
  static const String settings = '/settings';

  // 編輯/詳情頁
  static const String clubLedgerEdit = '/club-ledger-edit';

  /// 獲取所有已註冊路由名稱（用於調試）
  static List<String> getAllRoutes() {
    return [
      login,
      signup,
      main,
      home,
      ledger,
      calendar,
      statistics,
      settings,
      clubLedgerEdit,
    ];
  }
}
