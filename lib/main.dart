import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/screens/login_screen.dart';
import 'package:app/screens/signup_screen.dart';
import 'package:app/screens/main_screen.dart';
import 'package:app/screens/home_screen.dart';
import 'package:app/screens/ledger_screen.dart';
import 'package:app/screens/calendar_screen.dart';
import 'package:app/screens/settings_screen.dart';
import 'package:app/screens/statistics_screen.dart';
import 'package:app/screens/club_ledger_edit_screen.dart';
import 'package:app/providers/timer_provider.dart';
import 'package:app/providers/ledger_provider.dart';
import 'package:app/providers/calendar_provider.dart';
import 'package:app/providers/user_provider.dart';
import 'package:app/services/supabase_service.dart';
import 'package:app/constants/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 加载 .env 文件
  try {
    await dotenv.load();
  } catch (e) {
    print('.env 加载失败: $e');
  }

  // 初始化 Supabase
  try {
    await SupabaseService().initialize();
  } catch (e) {
    print('Supabase 初始化失败: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<SupabaseService>(create: (_) => SupabaseService()),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(
          create: (_) => LedgerProvider(SupabaseService()),
        ),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
        ChangeNotifierProvider(
          create: (_) => UserProvider(SupabaseService()),
        ),
      ],
      child: const ClubLedgerApp(),
    ),
  );
}

class ClubLedgerApp extends StatelessWidget {
  const ClubLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sky Club Ledger',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
      // 定義所有命名路由
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.signup: (context) => const SignupScreen(),
        AppRoutes.main: (context) => const MainScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.ledger: (context) => const LedgerScreen(),
        AppRoutes.calendar: (context) => const CalendarScreen(),
        AppRoutes.statistics: (context) => const StatisticsScreen(),
        AppRoutes.settings: (context) => const SettingsScreen(),
        AppRoutes.clubLedgerEdit: (context) => const ClubLedgerEditScreen(),
      },
    );
  }
}
