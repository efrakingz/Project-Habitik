import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/services/audio_service.dart';
import 'package:habitik/data/models/models.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';
import 'package:habitik/shared/widgets/cards/cards.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  final _user = UserProfile.mock;
  late List<RewardItem> _rewards;
  late int _userMonedas;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _rewards = List.from(RewardItem.mockList);
    _userMonedas = _user.monedas;
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _canjear(RewardItem r) {
    if (!r.disponible || _userMonedas < r.costo) {
      AudioService.playSFX('error.mp3');
      return;
    }
    AudioService.playSFX('redeem.mp3');
    _confettiController.play();
    setState(() {
      _userMonedas -= r.costo;
      final index = _rewards.indexWhere((item) => item.id == r.id);
      if (index != -1) {
        _rewards[index] = RewardItem(
          id: r.id,
          titulo: r.titulo,
          costo: r.costo,
          descripcion: r.descripcion,
          emoji: r.emoji,
          disponible: false,
        );
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [const Icon(Icons.access_time, color: Colors.white), const SizedBox(width: 10), Expanded(child: Text('Canje de "${r.titulo}" enviado. Esperando al Jefe.'))]),
      backgroundColor: HabitikColors.amber400,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: HabitikRadius.md_),
    ));
  }

  void _showCreateRewardDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final costController = TextEditingController();
    String selectedEmoji = '🎁';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: isDark ? HabitikColors.darkBgAlert : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(
                  color: isDark ? HabitikColors.whiteOverlay20 : Colors.white,
                  width: 3,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '✨ Crear Nueva Recompensa',
                    style: TextStyle(
                      color: isDark ? Colors.white : HabitikColors.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Campo Título
                  Text(
                    'Título del Canje',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : HabitikColors.textLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleController,
                    style: TextStyle(color: isDark ? Colors.white : HabitikColors.textDark, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Ej. Salida familiar',
                      hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey.shade400),
                      filled: true,
                      fillColor: isDark ? HabitikColors.darkInputFill : Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: HabitikColors.green500, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Campo Descripción
                  Text(
                    'Descripción',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : HabitikColors.textLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descController,
                    maxLines: 2,
                    style: TextStyle(color: isDark ? Colors.white : HabitikColors.textDark, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Ej. Una tarde en los juegos mecánicos',
                      hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey.shade400),
                      filled: true,
                      fillColor: isDark ? HabitikColors.darkInputFill : Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: HabitikColors.green500, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      // Costo
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Costo (Monedas 🪙)',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : HabitikColors.textLight,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: costController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: isDark ? Colors.white : HabitikColors.textDark, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Ej. 25',
                                hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey.shade400),
                                filled: true,
                                fillColor: isDark ? HabitikColors.darkInputFill : Colors.grey.shade50,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: HabitikColors.green500, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Emoji seleccionado
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Emoji',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : HabitikColors.textLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isDark ? HabitikColors.darkInputFill : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? Colors.white24 : Colors.grey.shade300,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(selectedEmoji, style: const TextStyle(fontSize: 24)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Selección rápida de emojis
                  Text(
                    'Selección rápida de Emojis',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : HabitikColors.textLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: ['🍕', '🎬', '🛌', '🍦', '🎮', '🏖️', '🧸', '🚲', '📚', '🍭', '⚽', '🍿', '🎁']
                          .map((emoji) {
                        final isSelected = selectedEmoji == emoji;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedEmoji = emoji;
                            });
                          },
                          child: AnimatedContainer(
                            duration: 150.ms,
                            margin: const EdgeInsets.only(right: 8),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? HabitikColors.darkSelectedIcon : HabitikColors.amber100)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? HabitikColors.amber500
                                    : (isDark ? Colors.white12 : Colors.grey.shade200),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(emoji, style: const TextStyle(fontSize: 20)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón Guardar
                  GestureDetector(
                    onTap: () {
                      final title = titleController.text.trim();
                      final desc = descController.text.trim();
                      final cost = int.tryParse(costController.text.trim()) ?? 0;

                      if (title.isEmpty || desc.isEmpty || cost <= 0) {
                        AudioService.playSFX('error.mp3');
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text('Por favor completa todos los campos correctamente.'),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: HabitikRadius.md_),
                        ));
                        return;
                      }

                      AudioService.playSFX('redeem.mp3');
                      setState(() {
                        _rewards.add(RewardItem(
                          id: _rewards.length + 1,
                          titulo: title,
                          costo: cost,
                          descripcion: desc,
                          emoji: selectedEmoji,
                          disponible: true,
                        ));
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Row(children: [const Icon(Icons.check_circle, color: Colors.white), const SizedBox(width: 10), Expanded(child: Text('¡Recompensa "$title" creada con éxito!'))]),
                        backgroundColor: HabitikColors.green600,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: HabitikRadius.md_),
                      ));
                    },
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: HabitikColors.heroGreen,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: HabitikShadows.colored(HabitikColors.green600),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Añadir Canje',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(gradient: HabitikColors.heroGreen),
          child: SafeArea(
            bottom: false,
            child: ScreenShell(
              titulo: 'Canjes',
              subtitulo: '🪙 Tienda de Recompensas',
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Stats bar
                  Row(children: [
                    Expanded(child: _StatCard(gradient: HabitikColors.heroGreen, icon: '⭐', label: 'Nivel actual', value: 'Nv. ${_user.nivel}')),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard(gradient: HabitikColors.xpGold, icon: '🪙', label: 'Disponible', value: '$_userMonedas')),
                  ]).animate().fadeIn().slideY(begin: 0.05, duration: 300.ms),

                  const SizedBox(height: 20),

                  // Catalog Title and Action Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: GameSectionTitle(emoji: '🎁', title: 'Catálogo de Canjes'),
                      ),
                      GestureDetector(
                        onTap: _showCreateRewardDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: HabitikColors.heroGreen,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: HabitikShadows.colored(HabitikColors.green600.withAlpha(80)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_circle_outline, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Crear Canje',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_rewards.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          'El jefe aún no ha creado canjes',
                          style: TextStyle(
                            color: Colors.white.withAlpha(220),
                            fontWeight: FontWeight.w800,
                            shadows: const [
                              Shadow(color: Colors.black26, offset: Offset(0, 1), blurRadius: 2),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: _rewards.asMap().entries.map((e) => RewardCard(
                        reward: e.value,
                        userMonedas: _userMonedas,
                        isJefe: _user.rol == 'jefe' || _user.rol == 'jefa',
                        onCanjear: () => _canjear(e.value),
                      ).animate().fadeIn(delay: (e.key * 80).ms)).toList(),
                    ),
                  
                  // Padding space for floating nav
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
              Colors.amber,
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final Gradient gradient;
  final String icon;
  final String label;
  final String value;
  const _StatCard({required this.gradient, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: HabitikRadius.lg_,
        border: Border.all(color: Colors.white, width: 3.0),
        boxShadow: HabitikShadows.card,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
      ]),
    );
  }
}
