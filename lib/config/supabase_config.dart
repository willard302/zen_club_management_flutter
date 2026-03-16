import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase 配置常量
/// 从 .env 文件中加载真实的值
class SupabaseConfig {
  /// 从 .env 获取 Supabase 项目 URL
  /// 格式: https://[project-id].supabase.co
  static String get supabaseUrl {
    final url = dotenv.env['SUPABASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('SUPABASE_URL 未在 .env 中设置');
    }
    return url;
  }

  /// 从 .env 获取 Supabase 项目 anon key
  static String get supabaseAnonKey {
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY 未在 .env 中设置');
    }
    return key;
  }
}
