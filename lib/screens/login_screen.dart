import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/screens/signup_screen.dart';
import 'package:app/screens/main_screen.dart';
import 'package:app/providers/user_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog('請輸入電子郵件和密碼');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userProvider = context.read<UserProvider>();
      final success = await userProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        if (success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        } else {
          _showErrorDialog(userProvider.errorMessage ?? '登入失敗，請重試');
        }
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('登入錯誤: ${e.toString()}');
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('錯誤'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAKLqnX9ZXB6k4S_M2OiUzo28rwbVbB4qgtt-CuoJnz7esDmG4EipwCVb159pJxmBEUzY0SIMcJffb8sBWx7x0cCktLUUeogL4l_7CKhM4tw-WrZapPYOiXOJ_wFK0XCHI8tjk2PkDynPSxN-hiE_8DwZJ0-k355BY8O0Jn4yeAvRUuQ6juPcePLPZzromKaH4sAy7R06qG24jk8u4mJDZr3UbyPmicNP-tofDjENIMKDtGvnRYe5SgAVTeEDieQCXIlvpG11VqryQ',
              fit: BoxFit.cover,
            ),
          ),
          // Primary color slight overlay
          Positioned.fill(
            child: Container(
              color: AppTheme.skyDeep.withValues(alpha: 0.1),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCenterContent(context),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterContent(BuildContext context) {
    return Column(
      children: [
        _buildLogo(),
        const SizedBox(height: 24),
        _buildTitles(),
        const SizedBox(height: 32),
        _buildForm(context),
      ],
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      width: 128,
      height: 128,
      child: Stack(
        alignment: Alignment.center,
        children: [
           // Fake conic gradient with sweep gradient for pulse effect
           Container(
             width: 128,
             height: 128,
             decoration: BoxDecoration(
               shape: BoxShape.circle,
               gradient: SweepGradient(
                 colors: [
                   AppTheme.skyDeep,
                   Colors.white,
                   AppTheme.skyLight,
                   AppTheme.skyDeep,
                 ],
               ),
               boxShadow: [
                 BoxShadow(color: AppTheme.skyLight.withValues(alpha: 0.5), blurRadius: 40)
               ]
             ),
           ),
           Container(
             width: 112,
             height: 112,
             decoration: BoxDecoration(
               color: Colors.white.withValues(alpha: 0.2),
               shape: BoxShape.circle,
               border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 4),
             ),
             child: Center(
               child: Container(
                 width: 80,
                 height: 80,
                 decoration: BoxDecoration(
                   shape: BoxShape.circle,
                   border: Border.all(color: AppTheme.skyDeep.withValues(alpha: 0.8), width: 6),
                 ),
                 child: Center(
                   child: Container(
                     width: 48,
                     height: 48,
                     decoration: BoxDecoration(
                       shape: BoxShape.circle,
                       border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 4),
                     ),
                   )
                 ),
               )
             ),
           )
        ],
      ),
    );
  }

  Widget _buildTitles() {
    return const Column(
      children: [
        Text(
          '淡江大學禪學社',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
            shadows: [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
          ),
        ),
        SizedBox(height: 8),
        Text(
          'TKU ZEN CLUB',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            letterSpacing: 4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Column(
        children: [
          _buildGlassField(
            hint: '輸入電子郵件',
            controller: _emailController,
            isPassword: false,
          ),
          const SizedBox(height: 16),
          _buildGlassField(
            hint: '輸入密碼',
            controller: _passwordController,
            isPassword: true,
          ),
          const SizedBox(height: 24),
          _buildLoginButton(context),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '忘記密碼？',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen()));
                },
                child: Container(
                  padding: const EdgeInsets.only(bottom: 2),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.3))),
                  ),
                  child: const Text(
                    '註冊',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildGlassField({required String hint, required TextEditingController controller, required bool isPassword}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      obscureText: isPassword && _obscurePassword,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 16),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        isDense: true,
                      ),
                    ),
                  ),
                  if (isPassword)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      child: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 20,
                      ),
                    )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return GestureDetector(
      onTap: _isLoading ? null : _handleLogin,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _isLoading ? AppTheme.skyDeep.withValues(alpha: 0.5) : AppTheme.skyDeep,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.skyDeep.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  '登入',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.2))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '或以此方式繼續',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.2))),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(FontAwesomeIcons.google, Colors.white, _handleLogin),
            const SizedBox(width: 24),
            _buildSocialButton(FontAwesomeIcons.facebookF, Colors.white, _handleLogin),
            const SizedBox(width: 24),
            _buildSocialButton(FontAwesomeIcons.line, Colors.white, _handleLogin),
          ],
        )
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
           filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
           child: Container(
             width: 56,
             height: 56,
             decoration: BoxDecoration(
               color: Colors.white.withValues(alpha: 0.1),
               shape: BoxShape.circle,
               border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
             ),
             child: Icon(icon, color: iconColor, size: 24),
           ),
        ),
      ),
    );
  }
}
