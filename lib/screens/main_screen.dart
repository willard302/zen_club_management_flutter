import 'package:flutter/material.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/screens/home_screen.dart';
import 'package:app/screens/ledger_screen.dart';
import 'package:app/screens/calendar_screen.dart';
import 'package:app/screens/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const LedgerScreen(),
    const CalendarScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Render all pages to keep state, only display current using Offstage
          ...List.generate(_pages.length, (index) {
            return Offstage(
              offstage: _currentIndex != index,
              child: _pages[index],
            );
          }),
          // Custom Bottom Navigation Bar
          Positioned(
             bottom: 0,
             left: 0,
             right: 0,
             child: _buildBottomNavigationBar(),
          )
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 32, left: 32, right: 32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        border: Border(
           top: BorderSide(color: AppTheme.skyLight.withValues(alpha: 0.5), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(icon: Icons.timer, label: 'Timer', index: 0),
          _buildNavItem(icon: Icons.account_balance_wallet, label: 'Ledger', index: 1),
          _buildNavItem(icon: Icons.calendar_today, label: 'Calendar', index: 2),
          _buildNavItem(icon: Icons.person, label: 'Profile', index: 3),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppTheme.skyBlue : const Color(0xFFCBD5E1); // slate-300

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5, // tight tracking
            ),
          ),
        ],
      ),
    );
  }
}
