import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/user.dart';

class ProfileInviteCard extends StatelessWidget {
  final UserProfile user;
  final bool isDark;
  final bool isGenerating;
  final VoidCallback onInvite;

  const ProfileInviteCard({
    super.key,
    required this.user,
    required this.isDark,
    required this.isGenerating,
    required this.onInvite,
  });

  @override
  Widget build(BuildContext context) {
    if (!user.isJefe) return const SizedBox.shrink();

    return Column(
      children: [
        Stack(
          children: [
            // Ambient Glow (simulates light spilling out)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: HabitikRadius.lg_,
                  boxShadow: [
                    BoxShadow(
                      color: HabitikColors.amber400.withValues(alpha: isDark ? 0.15 : 0.3),
                      blurRadius: 30,
                      spreadRadius: -5,
                    ),
                  ],
                ),
              ),
            ),
            
            // Main VIP Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: isDark 
                    ? const LinearGradient(colors: [Color(0xFF2C2415), Color(0xFF1E1A11)], begin: Alignment.topLeft, end: Alignment.bottomRight) 
                    : const LinearGradient(
                        colors: [Color(0xFFFFF8E1), Color(0xFFFFF3E0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: HabitikRadius.lg_,
                border: Border.all(
                  color: HabitikColors.amber400.withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [HabitikColors.amber300, HabitikColors.orange400],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: HabitikShadows.colored(HabitikColors.amber500),
                        ),
                        alignment: Alignment.center,
                        child: const Text('🎟️', style: TextStyle(fontSize: 26)),
                      ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(end: 1.05, duration: 2.seconds),
                      
                      const SizedBox(width: 16),
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Invitar a mi Familia',
                              style: TextStyle(
                                color: isDark ? HabitikColors.amber100 : Colors.orange.shade800,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Conecta a tus seres queridos para compartir metas de ahorro y retos en equipo.',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : HabitikColors.textMid,
                                fontSize: 13,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Primary Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: onInvite,
                      icon: isGenerating 
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: HabitikColors.textDark)
                            )
                          : const Icon(Icons.qr_code_scanner_rounded, size: 20, color: HabitikColors.textDark),
                      label: Text(
                        isGenerating ? 'Generando...' : '✨ Mostrar QR y Enlace',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: HabitikColors.textDark),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HabitikColors.amber400,
                        elevation: 4,
                        shadowColor: HabitikColors.amber400.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, curve: Curves.easeOutQuad),
        const SizedBox(height: 24),
      ],
    );
  }
}
