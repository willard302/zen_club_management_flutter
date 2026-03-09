import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/providers/timer_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.skyLight, // match main app background
      appBar: AppBar(
        title: const Text('統計總覽', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildTotalTimeCard(context),
              const SizedBox(height: 32),
              const Text(
                '最近禪修紀錄',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
              const SizedBox(height: 20),
              _buildRecentSessions(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildTotalTimeCard(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timerData, child) {
        final totalDuration = timerData.getTotalMeditationTime();
        final hours = totalDuration.inHours;
        final minutes = totalDuration.inMinutes.remainder(60);
        String displayTime = hours > 0 
            ? '${hours}h ${minutes}m'
            : '${minutes}m';
        if (totalDuration.inMinutes == 0 && totalDuration.inSeconds > 0) {
           displayTime = '< 1m';
        } else if (totalDuration.inSeconds == 0) {
           displayTime = '12.5 hrs'; // Default mock data if empty matching Stitch
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.skyBlue, AppTheme.skyDeep],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppTheme.skyBlue.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '總禪修時間',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                displayTime,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentSessions(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timerData, child) {
        final history = timerData.history.reversed.toList();
        
        if (history.isEmpty) {
          // Show mock data if history is empty to match the design's intention
          return Column(
            children: [
              _buildSessionItem(
                title: '晨間靜心',
                note: '今天感覺非常平靜與專注...',
                durationString: '45m',
                icon: Icons.wb_sunny_outlined,
              ),
              const SizedBox(height: 16),
              _buildSessionItem(
                title: '晚間反思',
                note: '釋放了考試的壓力。',
                durationString: '30m',
                icon: Icons.nights_stay_outlined,
              ),
              const SizedBox(height: 16),
              _buildSessionItem(
                title: '午間呼吸練習',
                note: '課間的快速重置。',
                durationString: '15m',
                icon: Icons.restaurant_menu_outlined,
              ),
            ],
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: history.length > 5 ? 5 : history.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final session = history[index];
            final mins = session.duration.inMinutes;
            final secs = session.duration.inSeconds.remainder(60);
            String timeStr = mins > 0 ? '${mins}m' : '${secs}s';
            return _buildSessionItem(
              title: '禪修紀錄',
              note: '${session.date.month}/${session.date.day} ${session.date.hour}:${session.date.minute.toString().padLeft(2, '0')}',
              durationString: timeStr,
              icon: Icons.self_improvement,
            );
          },
        );
      },
    );
  }

  Widget _buildSessionItem({
    required String title,
    required String note,
    required String durationString,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.skyLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: AppTheme.skyDeep, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  note,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            durationString,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.skyDeep,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.home_filled, '首頁', false, () {
                Navigator.pop(context); // Go back home
              }),
              _buildNavItem(context, Icons.bar_chart, '統計', true, () {}),
              _buildNavItem(context, Icons.timer, '禪修', false, () {}),
              _buildNavItem(context, Icons.person, '個人', false, () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppTheme.skyDeep : AppTheme.textLight.withValues(alpha: 0.5),
            size: 28,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.skyDeep : AppTheme.textLight.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
