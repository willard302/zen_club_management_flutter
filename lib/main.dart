import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/screens/login_screen.dart';
import 'package:app/providers/timer_provider.dart';
import 'package:app/providers/ledger_provider.dart';
import 'package:app/providers/calendar_provider.dart';
import 'package:app/providers/user_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => LedgerProvider()),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
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
    );
  }
}
