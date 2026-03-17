import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/providers/user_provider.dart';
import 'package:app/constants/app_routes.dart';
import 'dart:math';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 底部導覽列當前選擇索引 (個人: 3)
  int _currentIndex = 3;

  Future<void> _handleSignOut(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      await userProvider.signOut();
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已成功登出')),
      );

      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('登出失敗: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FC), // 畫面整體淡藍灰底色
      body: Stack(
        children: [
          // 上半部天空藍漸層背景
          Container(
            height: 280,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF65B6FF), Color(0xFF4FA5FF)],
              ),
            ),
          ),
          
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                children: [
                  _buildAppBar(),
                  const SizedBox(height: 20),
                  _buildProfileSection(context),
                  const SizedBox(height: 16),
                  _buildStatsSection(),
                  const SizedBox(height: 24),
                  _buildSettingsSection(context),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // 頂部導覽列
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.menu, color: Colors.white, size: 28),
          const Text(
            '個人資料',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          // 右側圓形裝飾 Icon (模擬圖中的紅白圈)
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
            ),
            child: Center(
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF5252),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 個人資料卡片區塊
  Widget _buildProfileSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // 白色卡片本體
          Container(
            margin: const EdgeInsets.only(top: 55),
            padding: const EdgeInsets.only(top: 70, bottom: 24, left: 24, right: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Consumer<UserProvider>(
              builder: (context, user, child) {
                return Column(
                  children: [
                    Text(
                      user.name.isNotEmpty ? user.name : '陳大文',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 標籤區
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildBadge('核心成員', const Color(0xFFE3F2FD), const Color(0xFF1976D2)),
                        const SizedBox(width: 8),
                        _buildBadge('財務長', const Color(0xFFFFF8E1), const Color(0xFFF57F17)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // 虛線分隔線 (簡單用實線或極淡灰線代替)
                    Divider(color: Colors.grey.shade200, thickness: 1),
                    const SizedBox(height: 16),
                    // 學系與學號
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoColumn('學系', '資訊工程學系'),
                        _buildInfoColumn('學號', '410012345', crossAxisAlignment: CrossAxisAlignment.end),
                      ],
                    )
                  ],
                );
              },
            ),
          ),
          
          // 大頭貼與虛線外框
          Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 畫虛線圓框
                SizedBox(
                  width: 104,
                  height: 104,
                  child: CustomPaint(
                    painter: DashedCirclePainter(),
                  ),
                ),
                // 大頭貼圖片
                const CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.grey,
                  backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?img=11'), // 替換為您的圖片資產或 UserImage
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, {CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start}) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // 統計數據雙卡片區塊
  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.timer_outlined,
              title: '總禪定時數',
              value: '42.5h',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              icon: Icons.calendar_today_outlined,
              title: '本月打卡',
              value: '12次',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF5C93CC), size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF3898E5), // 亮藍色
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 帳戶設定列表區塊
  Widget _buildSettingsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              '帳戶設定',
              style: TextStyle(
                color: Color(0xFF5F7285),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              children: [
                _buildSettingItem(
                  icon: Icons.person_outline,
                  title: '編輯個人資料',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                ),
                _buildSettingItem(
                  icon: Icons.history,
                  title: '修改密碼',
                  onTap: () {},
                ),
                _buildSettingItem(
                  icon: Icons.shield_outlined,
                  title: '隱私權設定',
                  onTap: () {},
                ),
                _buildSettingItem(
                  icon: Icons.logout_outlined,
                  title: '登出',
                  isDestructive: true,
                  showChevron: false,
                  onTap: () => _handleSignOut(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    bool isDestructive = false,
    bool showChevron = true,
    required VoidCallback onTap,
  }) {
    final color = isDestructive ? const Color(0xFFE57373) : const Color(0xFF6B7B8C);
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (showChevron)
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  // 底部導覽列
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF4FA5FF),
        unselectedItemColor: Colors.grey.shade400,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: '首頁',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: '帳簿',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: '行事曆',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: '個人',
          ),
        ],
      ),
    );
  }
}

// 繪製大頭貼虛線外框的 CustomPainter
class DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 3.5;
    double radius = (size.width - strokeWidth) / 2;
    Offset center = Offset(size.width / 2, size.height / 2);
    
    Paint paint = Paint()
      ..color = const Color(0xFF81C1FB) // 淺藍色虛線
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double dashWidth = 8.0;
    double dashSpace = 6.0;
    double circumference = 2 * pi * radius;
    int dashCount = (circumference / (dashWidth + dashSpace)).floor();

    double anglePerDash = (dashWidth + dashSpace) / radius;
    
    for (int i = 0; i < dashCount; i++) {
      double startAngle = i * anglePerDash;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashWidth / radius,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}