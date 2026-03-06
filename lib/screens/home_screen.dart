import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/providers/timer_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.skyLight,
      body: Stack(
        children: [
          _buildBackgroundGradient(),
          _buildClouds(),
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildTimerContent(context),
                    const SizedBox(height: 100), 
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.softSky,
            AppTheme.skyLight,
          ],
        ),
      ),
    );
  }

  Widget _buildClouds() {
    return Stack(
      children: [
        Positioned(
          top: 40,
          left: -40,
          child: _CloudBlur(size: 250, opacity: 0.8),
        ),
        Positioned(
          top: 160,
          right: -40,
          child: _CloudBlur(size: 300, opacity: 0.6),
        ),
        Positioned(
          bottom: 150,
          left: 40,
          child: _CloudBlur(size: 280, opacity: 0.7),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40), // Placeholder to maintain centered title
          const Text(
            'Sky Zen Timer',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz, color: Colors.white),
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              offset: const Offset(0, 48),
              onSelected: (value) {
                // Handle menu selection here
                if (value == 'record') {
                  // Navigate to Zen Record
                } else if (value == 'settings') {
                  // Navigate to Sound Settings
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'record',
                  child: Row(
                    children: [
                      Icon(Icons.history, color: AppTheme.skyBlue, size: 20),
                      const SizedBox(width: 12),
                      const Text('禪定紀錄', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.volume_up, color: AppTheme.skyBlue, size: 20),
                      const SizedBox(width: 12),
                      const Text('音效設定', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget _buildTimerContent(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timerData, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTimerRing(timerData.formattedTime),
            const SizedBox(height: 48),
            _buildTitles(),
            const SizedBox(height: 48),
            _buildControls(context, timerData),
          ],
        );
      },
    );
  }

  Widget _buildTimerRing(String time) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.1),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.5),
            blurRadius: 50,
          ),
          BoxShadow(
            color: AppTheme.skyBlue.withValues(alpha: 0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
           Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'REMAINING',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.7),
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            child: Transform.translate(
               offset: const Offset(0, -8),
               child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                      )
                    ]
                  ),
               ),
            )
          )
        ],
      ),
    );
  }

  Widget _buildTitles() {
    return Column(
      children: [
        const Text(
          'Morning Reflection',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0C4A6E),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Find your center in the clear blue sky',
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF075985).withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context, TimerProvider timerData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSmallControlButton(
          icon: Icons.replay_10,
          onTap: () => timerData.rewind10Seconds(),
        ),
        const SizedBox(width: 32),
        _buildPlayPauseButton(
          isRunning: timerData.isRunning,
          onTap: () => timerData.toggleTimer(),
        ),
        const SizedBox(width: 32),
        _buildSmallControlButton(
          icon: Icons.forward_10,
          onTap: () => timerData.forward10Seconds(),
        ),
      ],
    );
  }

  Widget _buildSmallControlButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF0369A1), size: 32),
      ),
    );
  }

  Widget _buildPlayPauseButton({required bool isRunning, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.skyBlue.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Icon(
          isRunning ? Icons.pause : Icons.play_arrow,
          color: const Color(0xFF0EA5E9),
          size: 40,
        ),
      ),
    );
  }
}

class _CloudBlur extends StatelessWidget {
  final double size;
  final double opacity;

  const _CloudBlur({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withValues(alpha: opacity),
            Colors.transparent,
          ],
          stops: const [0.0, 0.7],
        ),
      ),
    );
  }
}

extension InnerShadow on Widget {
   Widget innerShadow({Color shadowColor = Colors.black}) {
     return this;
   }
}
