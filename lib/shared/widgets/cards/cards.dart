import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/models.dart';
import 'package:habitik/shared/widgets/avatar/avatar.dart';
import 'package:habitik/shared/widgets/badges/badges.dart';
import 'package:habitik/shared/widgets/icons/game_icons.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ChallengeCard – tarjeta de reto en el grid de gamificación
// ─────────────────────────────────────────────────────────────────────────────
class ChallengeCard extends StatelessWidget {
  final ChallengeType challenge;
  final bool completed;
  final bool selected;
  final VoidCallback onTap;

  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.completed,
    this.selected = false,
    required this.onTap,
  });

  String get shortTitle {
    switch (challenge.id) {
      case 'ducha':      return 'Speedrun Ducha';
      case 'inspeccion': return 'Cazador Sombras';
      case 'trivia':     return 'Trivia Eco';
      case 'puzzle':     return 'Eco-Puzzle';
      case 'wordle':     return 'Eco-Wordle';
      case 'sopa':       return 'Sopa Letras';
      default:           return challenge.titulo;
    }
  }

  String get shortEmoji {
    switch (challenge.id) {
      case 'ducha':      return '🚿';
      case 'inspeccion': return '📷';
      case 'trivia':     return '🧠';
      case 'puzzle':     return '🧩';
      case 'wordle':     return '🔤';
      case 'sopa':       return '🔠';
      default:           return challenge.emoji;
    }
  }

  String get subLabel {
    switch (challenge.id) {
      case 'ducha':      return '200 XP';
      case 'inspeccion': return 'Variable';
      case 'trivia':     return 'x3 Mult.';
      case 'puzzle':     return 'Por tiempo';
      case 'wordle':     return 'Variable';
      case 'sopa':       return '100 XP';
      default:           return '${challenge.xp} XP';
    }
  }



  @override
  Widget build(BuildContext context) {
    final themeColor = completed ? const Color(0xFF2E7D32) : const Color(0xFF66BB6A);
    final themeColorLight = completed ? const Color(0xFF43A047) : const Color(0xFF9CCC65);
    final shadow = completed ? const Color(0xFF1B5E20) : const Color(0xFF388E3C);
    final clipper = _LeafClipper();

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Anillo de selección con forma de hoja
              if (selected)
                Positioned(
                  top: -6, bottom: -6, left: -6, right: -6,
                  child: ClipPath(
                    clipper: clipper,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(230),
                        boxShadow: [
                          BoxShadow(
                            color: themeColor.withAlpha(150),
                            blurRadius: 14,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Relieve / sombra 3D inferior
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ClipPath(
                  clipper: clipper,
                  child: Container(width: 78, height: 78, color: shadow),
                ),
              ),

              // Hoja principal con degradado + nervadura
              ClipPath(
                clipper: clipper,
                child: Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [themeColorLight, themeColor],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _LeafVeinPainter(Colors.white.withAlpha(60)),
                        ),
                      ),
                      Center(
                        child: completed
                            ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 38)
                            : GameChallengeIcon(
                                challengeId: challenge.id,
                                size: 34,
                                solidWhite: true,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .slideY(begin: 0, end: -0.06, duration: 1500.ms, curve: Curves.easeInOut),
          const SizedBox(height: 6),

          // Etiqueta del nombre del juego debajo de la hoja
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(120),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withAlpha(20), width: 0.5),
            ),
            child: Text(
              shortTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Forma de hoja real (punta arriba-izq y abajo-der, lados curvos) ----
class _LeafClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();
    // Punta superior-izquierda (ápice)
    path.moveTo(w * 0.05, h * 0.05);
    // Curva por el lado derecho hasta la punta inferior-derecha (tallo)
    path.quadraticBezierTo(w * 1.02, h * 0.10, w * 0.95, h * 0.95);
    // Curva de regreso por el lado izquierdo hasta el ápice
    path.quadraticBezierTo(w * -0.02, h * 0.90, w * 0.05, h * 0.05);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ---- Nervadura central de la hoja ----
class _LeafVeinPainter extends CustomPainter {
  final Color color;
  _LeafVeinPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Vena principal de punta a punta
    final main = Path()
      ..moveTo(w * 0.12, h * 0.12)
      ..quadraticBezierTo(w * 0.55, h * 0.45, w * 0.86, h * 0.86);
    canvas.drawPath(main, paint);

    // Venas laterales pequeñas
    final thin = Paint()
      ..color = color.withAlpha(140)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(w * 0.40, h * 0.32), Offset(w * 0.62, h * 0.22), thin);
    canvas.drawLine(Offset(w * 0.55, h * 0.50), Offset(w * 0.40, h * 0.70), thin);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// EvidenceCard – tarjeta de evidencia en el feed familiar
// ─────────────────────────────────────────────────────────────────────────────
class EvidenceCard extends StatelessWidget {
  final EvidenceItem evidence;
  final bool liked;
  final VoidCallback onLike;
  final int index;

  const EvidenceCard({
    super.key,
    required this.evidence,
    required this.liked,
    required this.onLike,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2E22) : const Color(0xFFEBF7EC),
        borderRadius: HabitikRadius.lg_,
        border: Border.all(color: isDark ? const Color(0x30FFFFFF) : Colors.white, width: 3.5),
        boxShadow: HabitikShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(letra: evidence.avatarLetra, colorHex: evidence.avatarColor, avatarUrl: evidence.avatarUrl, radius: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(evidence.autorNombre, style: TextStyle(color: isDark ? Colors.white : HabitikColors.textDark, fontSize: 13, fontWeight: FontWeight.w700)),
                    Text('${evidence.accion} · ${evidence.tiempo}', style: TextStyle(color: isDark ? Colors.white70 : HabitikColors.textLight, fontSize: 11), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              XpBadge(evidence.xp),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: isDark ? const Color(0xFF141F17) : Colors.white, borderRadius: HabitikRadius.md_),
            child: Row(
              children: [
                Text(evidence.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(child: Text(evidence.descripcion, style: TextStyle(color: isDark ? Colors.white70 : HabitikColors.textDark, fontSize: 12, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          if (evidence.imagenUrl != null && evidence.imagenUrl!.isNotEmpty) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: HabitikRadius.md_,
              child: Image.network(evidence.imagenUrl!, height: 100, width: 100, fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(height: 100, width: 100, color: HabitikColors.green100, child: const Icon(Icons.broken_image, color: HabitikColors.green300))),
            ),
          ],
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onLike,
            child: Row(
              children: [
                Icon(liked ? Icons.favorite : Icons.favorite_border, color: liked ? Colors.redAccent : (isDark ? Colors.white60 : HabitikColors.textLight), size: 18)
                    .animate(target: liked ? 1 : 0)
                    .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 150.ms)
                    .then()
                    .scale(begin: const Offset(1.3, 1.3), end: const Offset(1, 1), duration: 100.ms),
                const SizedBox(width: 4),
                Text('${evidence.likes}', style: TextStyle(color: liked ? Colors.redAccent : (isDark ? Colors.white60 : HabitikColors.textLight), fontSize: 12, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.05, duration: 350.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RewardCard – tarjeta de canje en la tienda
// ─────────────────────────────────────────────────────────────────────────────
class RewardCard extends StatelessWidget {
  final RewardItem reward;
  final int userMonedas;
  final bool isJefe;
  final VoidCallback onCanjear;
  final VoidCallback? onEdit;

  const RewardCard({
    super.key,
    required this.reward,
    required this.userMonedas,
    required this.isJefe,
    required this.onCanjear,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canCanjear = reward.disponible && userMonedas >= reward.costo;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: reward.disponible
            ? (isDark ? HabitikColors.darkCardBg : HabitikColors.lightCardBg)
            : (isDark ? HabitikColors.darkCardClaimedBg : HabitikColors.surface),
        borderRadius: HabitikRadius.lg_,
        border: Border.all(
          color: isDark ? HabitikColors.whiteOverlay20 : Colors.white,
          width: 3.0,
        ),
        boxShadow: reward.disponible ? HabitikShadows.card : [],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Emoji Avatar Left
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: reward.disponible
                  ? (isDark ? HabitikColors.darkSelectedIcon : HabitikColors.amber100)
                  : (isDark ? HabitikColors.darkSubSurface : HabitikColors.divider.withAlpha(100)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                reward.emoji,
                style: TextStyle(
                  fontSize: 26,
                  color: reward.disponible ? null : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title & Description Middle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  reward.titulo,
                  style: TextStyle(
                    color: reward.disponible
                        ? (isDark ? Colors.white : HabitikColors.textDark)
                        : (isDark ? Colors.white38 : HabitikColors.textLight),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reward.descripcion,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : HabitikColors.textLight,
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Cost Tag
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${reward.costo} 🪙',
                        style: TextStyle(
                          color: canCanjear ? HabitikColors.amber500 : (isDark ? Colors.white30 : HabitikColors.textLight),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Action Button Right
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isJefe && onEdit != null) ...[
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: HabitikColors.green100,
                      borderRadius: HabitikRadius.sm_,
                    ),
                    child: const Icon(Icons.edit, size: 16, color: HabitikColors.green700),
                  ),
                ),
              ],
              if (!reward.disponible)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? HabitikColors.darkSubSurface : HabitikColors.divider,
                    borderRadius: HabitikRadius.xs_,
                  ),
                  child: Text(
                    'Canjeado',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white38 : HabitikColors.textLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: canCanjear ? onCanjear : null,
                  child: AnimatedContainer(
                    duration: 200.ms,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: canCanjear
                          ? HabitikColors.xpGold
                          : LinearGradient(colors: isDark ? [HabitikColors.darkSubSurface, HabitikColors.darkSubSurface] : [HabitikColors.divider, HabitikColors.divider]),
                      borderRadius: HabitikRadius.sm_,
                      boxShadow: canCanjear ? HabitikShadows.colored(HabitikColors.amber500.withAlpha(100)) : [],
                    ),
                    child: Text(
                      canCanjear ? 'Canjear' : 'Sin fondos',
                      style: TextStyle(
                        color: canCanjear ? Colors.white : (isDark ? Colors.white30 : HabitikColors.textLight),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AchievementCard – tarjeta de logro ecológico
// ─────────────────────────────────────────────────────────────────────────────
class AchievementCard extends StatelessWidget {
  final AchievementItem achievement;
  final int index;

  const AchievementCard({super.key, required this.achievement, this.index = 0});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unlocked = achievement.desbloqueado;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unlocked
            ? (isDark ? const Color(0xFF1E2E22) : const Color(0xFFEBF7EC))
            : (isDark ? const Color(0xFF161E1A) : HabitikColors.surface),
        borderRadius: HabitikRadius.lg_,
        border: Border.all(
          color: isDark ? const Color(0x30FFFFFF) : Colors.white,
          width: 3.0,
        ),
        boxShadow: unlocked ? HabitikShadows.card : [],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji badge
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: unlocked
                  ? (isDark ? const Color(0xFF141F17) : HabitikColors.green50)
                  : (isDark ? const Color(0xFF1C2820) : Colors.grey.shade100),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(achievement.emoji,
                style: TextStyle(fontSize: 26, color: unlocked ? null : Colors.grey.shade400)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(achievement.nombre,
                        style: TextStyle(
                          color: unlocked ? (isDark ? Colors.white : HabitikColors.textDark) : Colors.grey.shade500,
                          fontWeight: FontWeight.w800, fontSize: 14,
                        )),
                    ),
                    const SizedBox(width: 6),
                    DificultadBadge(achievement.dificultad),
                  ],
                ),
                const SizedBox(height: 4),
                Text(achievement.descripcion,
                  style: TextStyle(color: unlocked ? (isDark ? Colors.white70 : HabitikColors.textLight) : Colors.grey.shade400, fontSize: 12, height: 1.3)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      XpBadge(achievement.xp),
                      const SizedBox(width: 6),
                      MonedasBadge(achievement.monedas),
                    ]),
                    if (!unlocked)
                      Row(children: [
                        Icon(Icons.lock_outline, size: 12, color: Colors.grey.shade400),
                        const SizedBox(width: 3),
                        Text('BLOQUEADO', style: TextStyle(color: Colors.grey.shade400, fontSize: 9, fontWeight: FontWeight.w800)),
                      ]),
                    if (unlocked && achievement.desbloqueadoEn != null)
                      Text('${achievement.desbloqueadoEn}', style: TextStyle(color: isDark ? Colors.white60 : HabitikColors.textLight, fontSize: 9)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 80).ms).slideX(begin: 0.05, duration: 300.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ValidationCard – tarjeta de validación pendiente (para panel jefe)
// ─────────────────────────────────────────────────────────────────────────────
class ValidationCard extends StatelessWidget {
  final PendingValidation validation;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const ValidationCard({
    super.key,
    required this.validation,
    required this.onApprove,
    required this.onReject,
  });

  bool get _isCanje => validation.evidencias.length == 1 && validation.evidencias.first == 'Canje';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2E22) : const Color(0xFFEBF7EC),
        borderRadius: HabitikRadius.lg_,
        border: Border.all(color: isDark ? const Color(0x30FFFFFF) : Colors.white, width: 3.0),
        boxShadow: HabitikShadows.card,
      ),
      child: Column(
        children: [
          Row(
            children: [
              UserAvatar(letra: validation.avatarLetra, colorHex: validation.avatarColor, radius: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(validation.usuario, style: TextStyle(color: isDark ? Colors.white : HabitikColors.textDark, fontSize: 14, fontWeight: FontWeight.w800)),
                    Text(validation.reto, style: TextStyle(color: _isCanje ? HabitikColors.amber500 : (isDark ? HabitikColors.green400 : HabitikColors.green600), fontSize: 12, fontWeight: FontWeight.w600)),
                    Text(validation.hora, style: TextStyle(color: isDark ? Colors.white38 : HabitikColors.textHint, fontSize: 11)),
                  ],
                ),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                if (!_isCanje) XpBadge(validation.xp),
                const SizedBox(height: 4),
                MonedasBadge(validation.monedas, positive: !_isCanje),
              ]),
            ],
          ),
          if (validation.evidencias.isNotEmpty && !_isCanje) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: isDark ? const Color(0xFF141F17) : Colors.white, borderRadius: HabitikRadius.md_),
              child: Row(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: HabitikColors.green600, borderRadius: HabitikRadius.xs_), child: const Text('📎 EVIDENCIA', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900))),
                const SizedBox(width: 8),
                Expanded(child: Text(validation.evidencias.join(', '), style: TextStyle(color: isDark ? Colors.white70 : HabitikColors.green700, fontSize: 11, fontWeight: FontWeight.w600))),
              ]),
            ),
          ],
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: onApprove,
                child: Container(
                  height: 38, alignment: Alignment.center,
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [HabitikColors.green500, HabitikColors.green700]), borderRadius: HabitikRadius.sm_),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.check, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text('Aprobar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                  ]),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: onReject,
                child: Container(
                  height: 38, alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3A1F1F) : Colors.red.shade50,
                    borderRadius: HabitikRadius.sm_,
                    border: Border.all(color: isDark ? const Color(0xFF6E2B2B) : Colors.red.shade300),
                  ),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.close, color: Colors.redAccent, size: 16),
                    SizedBox(width: 4),
                    Text('Rechazar', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w800, fontSize: 13)),
                  ]),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
