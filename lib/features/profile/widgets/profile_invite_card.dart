import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/user.dart';

/// Tarjeta compacta para Invitar a la Familia en el Perfil de Usuario (Jefe/Admin).
/// Rediseñada en formato horizontal ultra-compacto y armónico con [ProfileBadgesCard].
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

    final cardBg = isDark ? HabitikColors.darkCardBg : Colors.white;
    final cardBorder = isDark 
        ? const Color(0xFF523B17) 
        : const Color(0xFFFDE68A);
    final iconBg = isDark ? const Color(0xFF38260F) : const Color(0xFFFEF3C7);
    final iconBorder = isDark ? const Color(0xFF5A3D18) : const Color(0xFFFCD34D);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: onInvite,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: cardBorder, width: 1.2),
            boxShadow: isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : HabitikShadows.card,
          ),
          child: Row(
            children: [
              // ── Contenedor compacto del ícono de invitación ──
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: iconBorder, width: 1.2),
                ),
                alignment: Alignment.center,
                child: const Text('🎟️', style: TextStyle(fontSize: 22)),
              ),

              const SizedBox(width: 14),

              // ── Título y subtítulo conciso ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Invitar a mi Familia',
                      style: GoogleFonts.outfit(
                        color: isDark ? HabitikColors.amber100 : const Color(0xFF92400E),
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Comparte código o enlace QR',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : HabitikColors.textMid,
                        fontSize: 12,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // ── Botón de acción compacto estilo pill ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [HabitikColors.amber400, HabitikColors.orange400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: HabitikColors.orange400.withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isGenerating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: HabitikColors.textDark,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.qr_code_2_rounded,
                            size: 16,
                            color: HabitikColors.textDark,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Invitar',
                            style: GoogleFonts.outfit(
                              color: HabitikColors.textDark,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, curve: Curves.easeOutQuad);
  }
}
