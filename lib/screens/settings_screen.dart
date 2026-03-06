import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/providers/user_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              children: [
                _buildHeaderAndProfile(context),
                _buildSettingsList(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderAndProfile(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildSkyGradientHeader(context),
        Positioned(
           top: 80, 
           left: 0,
           right: 0,
           child: _buildProfileCard(context)
        )
      ],
    );
  }

  Widget _buildSkyGradientHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 90, left: 24, right: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.skyBlue, Color(0xFF38BDF8)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40), // Placeholder to maintain centered title
          const Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0C4A6E).withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ]
        ),
        child: Consumer<UserProvider>(
          builder: (context, user, child) {
            return Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 96, height: 96,
                      decoration: BoxDecoration(
                         color: AppTheme.skyLight.withValues(alpha: 0.8),
                         shape: BoxShape.circle,
                         border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 4),
                      ),
                      child: const Icon(Icons.person, color: AppTheme.skyBlue, size: 48),
                    ),
                    Positioned(
                       bottom: 0, right: 0,
                       child: Container(
                         width: 32, height: 32,
                         decoration: BoxDecoration(
                           color: AppTheme.skyBlue,
                           shape: BoxShape.circle,
                           border: Border.all(color: Colors.white, width: 2),
                         ),
                         child: const Icon(Icons.edit, color: Colors.white, size: 14),
                       )
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.role,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.skyBlue,
                  ),
                )
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 120),
      color: AppTheme.backgroundLight,
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('ACCOUNT SETTINGS'),
          _buildSettingsGroup([
            _buildSettingItem(Icons.person_outline, 'Personal Information', true, null),
            _buildSettingItem(Icons.notifications_none, 'Notifications', true, null),
            _buildSettingItem(Icons.lock_open, 'Privacy & Security', true, null),
          ]),
          const SizedBox(height: 32),
          _buildSectionTitle('APP EXPERIENCE'),
          _buildSettingsGroup([
            _buildSettingItem(Icons.palette, 'Theme Preference', false, 
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                 decoration: BoxDecoration(
                   color: AppTheme.skyLight.withValues(alpha: 0.5),
                   borderRadius: BorderRadius.circular(4),
                 ),
                 child: const Text('Blue Sky', style: TextStyle(color: Color(0xFF0284C7), fontSize: 12, fontWeight: FontWeight.w600)),
               )
            ),
            _buildSettingItem(Icons.language, 'Language', true, null),
          ]),
          const SizedBox(height: 16),
          _buildSignOutButton(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.skyBlue,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
         children: items,
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, bool hasChevron, Widget? trailing) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.skyLight.withValues(alpha: 0.5), width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.skyLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.skyBlue, size: 22),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              )
            ],
          ),
          if (trailing != null) trailing
          else if (hasChevron) Icon(Icons.chevron_right, color: Colors.grey.shade300)
        ],
      ),
    );
  }

  Widget _buildSignOutButton() {
     return Container(
       width: double.infinity,
       padding: const EdgeInsets.symmetric(vertical: 16),
       decoration: BoxDecoration(
         borderRadius: BorderRadius.circular(16),
         border: Border.all(color: Colors.red.shade100),
       ),
       child: Center(
         child: Text(
           'Sign Out',
           style: TextStyle(
             color: Colors.red.shade500,
             fontWeight: FontWeight.bold,
             fontSize: 14,
           ),
         ),
       ),
     );
  }
}
