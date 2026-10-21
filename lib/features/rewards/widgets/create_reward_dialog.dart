import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/reward.dart';
import 'coin_value_guide.dart';

enum RewardDialogMode { admin, memberProposal }

Future<void> showCreateRewardDialog(
  BuildContext context, {
  required Function(RewardItem) onCreate,
  RewardDialogMode mode = RewardDialogMode.admin,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 30),
      child: CreateRewardDialog(
        onCreate: onCreate,
        mode: mode,
      ),
    ),
  );
}

class CreateRewardDialog extends StatefulWidget {
  final Function(RewardItem) onCreate;
  final RewardDialogMode mode;

  const CreateRewardDialog({
    super.key,
    required this.onCreate,
    this.mode = RewardDialogMode.admin,
  });

  @override
  State<CreateRewardDialog> createState() => _CreateRewardDialogState();
}

class _CreateRewardDialogState extends State<CreateRewardDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  int _costo = 10;
  bool _esFamiliar = false; // Por defecto personal
  String _frecuencia = 'semanal';
  String _emoji = '🎁';

  static const _frecuencias = {
    'diario': '1x día',
    'semanal': '1x semana',
    'mensual': '1x mes',
    'unico': 'Único',
  };

  static const _emojis = [
    '🎁', '🛒', '🎥', '🍕', '🍔', '🍜', '🥩',
    '🏆', '⭐', '💫', '💰', '🪙',
    '🏠', '🌴', '🎮', '📱', '💻',
    '🎤', '🎵', '🐶', '🦄', '🌸', '🌿',
    '☕', '🛋️', '😴', '📚', '🎨', '⚽', '🚴', '🌟',
  ];

  @override
  void initState() {
    super.initState();
    // Si es modo admin, permitir familiar por defecto si se desea
    if (widget.mode == RewardDialogMode.admin) {
      _esFamiliar = true;
    } else {
      _esFamiliar = false;
    }
  }

  bool get _isValid => _tituloCtrl.text.trim().isNotEmpty;

  void _submit() {
    if (_formKey.currentState!.validate() && _isValid) {
      widget.onCreate(RewardItem(
        id: DateTime.now().millisecondsSinceEpoch,
        titulo: _tituloCtrl.text.trim(),
        descripcion: _descCtrl.text.trim(),
        costo: widget.mode == RewardDialogMode.admin ? _costo : 0,
        emoji: _emoji,
        esFamiliar: widget.mode == RewardDialogMode.admin ? _esFamiliar : false,
        estado: widget.mode == RewardDialogMode.admin ? 'activo' : 'propuesto',
        metadata: _esFamiliar ? {'frecuencia': _frecuencia} : {},
      ));
      Navigator.pop(context);
    }
  }

  void _mostrarEmojiPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (_, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1C3D28),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Elige un emoji',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _emojis.map((e) {
                  final selected = e == _emoji;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _emoji = e);
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: selected
                            ? HabitikColors.green500.withValues(alpha: 0.35)
                            : Colors.white.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? HabitikColors.green400
                              : Colors.white.withValues(alpha: 0.1),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(e, style: const TextStyle(fontSize: 24)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.mode == RewardDialogMode.admin;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C3D28), Color(0xFF172F1F)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Form(
          key: _formKey,
          onChanged: () => setState(() {}),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DialogHeader(isAdmin: isAdmin),
                const SizedBox(height: 14),
                _EmojiRow(
                  emoji: _emoji,
                  onTap: _mostrarEmojiPicker,
                ),
                const SizedBox(height: 14),
                if (isAdmin) ...[
                  const _SectionLabel('Tipo de premio'),
                  const SizedBox(height: 8),
                  _TypePills(
                    esFamiliar: _esFamiliar,
                    onSelect: (val) => setState(() => _esFamiliar = val),
                  ),
                  const SizedBox(height: 14),
                ],
                const _SectionLabel('Nombre del premio'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _tituloCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  validator: (v) => v == null || v.trim().isEmpty ? 'El nombre es requerido' : null,
                  decoration: InputDecoration(
                    hintText: isAdmin 
                        ? (_esFamiliar ? 'ej: Pizza Familiar, Noche de Cine…' : 'ej: 1 hora de videojuegos, Elegir postre…')
                        : 'ej: Salir a andar en bicicleta, 1 hora de TV…',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 13),
                    prefixIcon: const Icon(Icons.edit_outlined, color: Colors.white38, size: 18),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.07),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(13),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13),
                        borderSide: BorderSide(color: HabitikColors.green400, width: 1.5)),
                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13),
                        borderSide: const BorderSide(color: Colors.redAccent)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                const _SectionLabel('Descripción (opcional)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Agrega un detalle o regla del premio…',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 13),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(top: 0),
                      child: Icon(Icons.notes_outlined, color: Colors.white38, size: 18),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.07),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(13),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13),
                        borderSide: BorderSide(color: HabitikColors.green400, width: 1.5)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),
                if (isAdmin) ...[
                  _CostSlider(
                    costo: _costo,
                    onChanged: (newCosto) => setState(() => _costo = newCosto),
                  ),
                  const SizedBox(height: 12),
                  const CoinValueGuide(),
                  if (_esFamiliar) ...[
                    const SizedBox(height: 14),
                    const _SectionLabel('Frecuencia disponible'),
                    const SizedBox(height: 8),
                    _FrequencyChips(
                      frecuencias: _frecuencias,
                      frecuenciaSeleccionada: _frecuencia,
                      onSelect: (val) => setState(() => _frecuencia = val),
                    ),
                  ],
                ] else ...[
                  // Explicación para el miembro
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_rounded, size: 20, color: HabitikColors.amber400),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Esta propuesta le llegará directamente al Jefe de Hogar. Él le asignará el valor en monedas y la aprobará para que esté disponible en tu tienda.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                _DialogActionButtons(
                  isValid: _isValid,
                  isAdmin: isAdmin,
                  onSubmit: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets independientes (Clean Code Habitik)
// ─────────────────────────────────────────────────────────────────────────────

class _DialogHeader extends StatelessWidget {
  final bool isAdmin;
  const _DialogHeader({required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [HabitikColors.green500, HabitikColors.green600],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: HabitikColors.green500.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(isAdmin ? Icons.card_giftcard : Icons.lightbulb_outline_rounded, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAdmin ? 'Crear Premio' : 'Proponer Premio',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
            ),
            Text(
              isAdmin ? 'Define el costo y tipo de recompensa' : 'Propón un premio personal para tu hogar',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.close, color: Colors.white.withValues(alpha: 0.5), size: 18),
          ),
        ),
      ],
    );
  }
}

class _EmojiRow extends StatelessWidget {
  final String emoji;
  final VoidCallback onTap;

  const _EmojiRow({required this.emoji, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emoji del premio',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                  Text(
                    'Toca para cambiar',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.3),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _TypePills extends StatelessWidget {
  final bool esFamiliar;
  final ValueChanged<bool> onSelect;

  const _TypePills({required this.esFamiliar, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _TypeOption(
            emoji: '👨‍👩‍👧',
            label: 'Familiar',
            subtitle: 'Colaborativo',
            selected: esFamiliar,
            onTap: () => onSelect(true),
          ),
          _TypeOption(
            emoji: '👤',
            label: 'Personal',
            subtitle: 'Individual',
            selected: !esFamiliar,
            onTap: () => onSelect(false),
          ),
        ],
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  final String emoji;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _TypeOption({
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(
                    colors: [HabitikColors.green500, HabitikColors.green600],
                    begin: Alignment.topLeft, end: Alignment.bottomRight)
                : null,
            color: selected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: selected
                ? [BoxShadow(color: HabitikColors.green500.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 2))]
                : [],
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                    fontSize: 13,
                  )),
              Text(subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: selected ? 0.8 : 0.4),
                    fontSize: 10,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _CostSlider extends StatelessWidget {
  final int costo;
  final ValueChanged<int> onChanged;

  const _CostSlider({required this.costo, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Costo en monedas',
                  style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.4)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: HabitikColors.green500.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: HabitikColors.green400.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 5),
                    Text('$costo',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(width: 3),
                    const Text('monedas', style: TextStyle(color: Colors.white60, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: HabitikColors.green400,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.12),
              thumbColor: Colors.white,
              overlayColor: HabitikColors.green500.withValues(alpha: 0.15),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
            ),
            child: Slider(
              value: costo.toDouble(),
              min: 5, max: 200, divisions: 39,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                onChanged(v.round());
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('5 🪙', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 10)),
              Text('200 🪙', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FrequencyChips extends StatelessWidget {
  final Map<String, String> frecuencias;
  final String frecuenciaSeleccionada;
  final ValueChanged<String> onSelect;

  const _FrequencyChips({
    required this.frecuencias,
    required this.frecuenciaSeleccionada,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7, runSpacing: 7,
      children: frecuencias.entries.map((e) {
        final sel = frecuenciaSeleccionada == e.key;
        return GestureDetector(
          onTap: () => onSelect(e.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: sel ? HabitikColors.green500 : Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: sel ? Colors.white.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.15)),
              boxShadow: sel ? [BoxShadow(color: HabitikColors.green500.withValues(alpha: 0.35), blurRadius: 8)] : [],
            ),
            child: Text(e.value,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                  fontSize: 12,
                )),
          ),
        );
      }).toList(),
    );
  }
}

class _DialogActionButtons extends StatelessWidget {
  final bool isValid;
  final bool isAdmin;
  final VoidCallback onSubmit;

  const _DialogActionButtons({
    required this.isValid,
    required this.isAdmin,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
            child: const Text('Cancelar', style: TextStyle(fontSize: 13)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: AnimatedOpacity(
            opacity: isValid ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: ElevatedButton(
              onPressed: isValid ? onSubmit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: HabitikColors.green500,
                foregroundColor: Colors.white,
                disabledBackgroundColor: HabitikColors.green500.withValues(alpha: 0.3),
                disabledForegroundColor: Colors.white38,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 13),
                elevation: isValid ? 4 : 0,
                shadowColor: HabitikColors.green500.withValues(alpha: 0.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isAdmin ? Icons.add_circle : Icons.send_rounded, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    isAdmin ? 'Crear Premio' : 'Enviar Propuesta',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: Colors.white60,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
    ),
  );
}
