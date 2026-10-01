import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/reward.dart';

Future<void> showCreateRewardDialog(
  BuildContext context, {
  required Function(RewardItem) onCreate,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 40),
      child: CreateRewardDialog(onCreate: onCreate),
    ),
  );
}

class CreateRewardDialog extends StatefulWidget {
  final Function(RewardItem) onCreate;
  const CreateRewardDialog({super.key, required this.onCreate});

  @override
  State<CreateRewardDialog> createState() => _CreateRewardDialogState();
}

class _CreateRewardDialogState extends State<CreateRewardDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  int _costo = 10;
  bool _esFamiliar = true;
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
    '🏠', '🌴', '🤺', '🎮', '📱', '💻',
    '🎤', '🎵', '🐟', '🐶', '🦄',
    '🌸', '🌿', '☕', '🛋️', '😴',
    '📚', '🎨', '⚽', '🏄', '🚴', '🌟',
  ];

  bool get _isValid => _tituloCtrl.text.trim().isNotEmpty;

  void _submit() {
    if (_formKey.currentState!.validate() && _isValid) {
      widget.onCreate(RewardItem(
        id: DateTime.now().millisecondsSinceEpoch,
        titulo: _tituloCtrl.text.trim(),
        descripcion: _descCtrl.text.trim(),
        costo: _costo,
        emoji: _emoji,
        esFamiliar: _esFamiliar,
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

  Widget _buildEmojiRow() {
    return GestureDetector(
      onTap: _mostrarEmojiPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Text(_emoji, style: const TextStyle(fontSize: 26)),
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

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 40, offset: const Offset(0, 10)),
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
                _buildHeader(),
                const SizedBox(height: 14),
                // ── Selector de emoji minimalista ──
                _buildEmojiRow(),
                const SizedBox(height: 14),
                _SectionLabel('Tipo de premio'),
                const SizedBox(height: 8),
                _buildTypePills(),
                const SizedBox(height: 14),
                _SectionLabel('Nombre del premio'),
                const SizedBox(height: 8),
                _buildTitleField(),
                const SizedBox(height: 12),
                _SectionLabel('Descripción (opcional)'),
                const SizedBox(height: 8),
                _buildDescField(),
                const SizedBox(height: 14),
                _buildCostRow(),
                if (_esFamiliar) ...[
                  const SizedBox(height: 14),
                  _SectionLabel('Límite de canje'),
                  const SizedBox(height: 8),
                  _buildFrequencyChips(),
                ],
                const SizedBox(height: 20),
                _buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }


  // ── Sub-builders ──────────────────────────────────────────────────────────

  Widget _buildHeader() {
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
            boxShadow: [BoxShadow(color: HabitikColors.green500.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: const Icon(Icons.card_giftcard, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Crear Premio',
                style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)),
            Text('Define el costo y tipo de recompensa',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
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

  Widget _buildTypePills() {
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
            subtitle: 'Compartido',
            selected: _esFamiliar,
            onTap: () => setState(() => _esFamiliar = true),
          ),
          _TypeOption(
            emoji: '👤',
            label: 'Personal',
            subtitle: 'Solo para mí',
            selected: !_esFamiliar,
            onTap: () => setState(() => _esFamiliar = false),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _tituloCtrl,
      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
      validator: (v) => v == null || v.trim().isEmpty ? 'El nombre es requerido' : null,
      decoration: InputDecoration(
        hintText: 'ej: Pizza Familiar, Noche de Cine…',
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
    );
  }

  Widget _buildDescField() {
    return TextFormField(
      controller: _descCtrl,
      maxLines: 2,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: 'Agrega un detalle del premio…',
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
    );
  }

  Widget _buildCostRow() {
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
                    Text('$_costo',
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
              value: _costo.toDouble(),
              min: 5, max: 200, divisions: 39,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                setState(() => _costo = v.round());
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

  Widget _buildFrequencyChips() {
    return Wrap(
      spacing: 7, runSpacing: 7,
      children: _frecuencias.entries.map((e) {
        final sel = _frecuencia == e.key;
        return GestureDetector(
          onTap: () => setState(() => _frecuencia = e.key),
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

  Widget _buildActions() {
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
            opacity: _isValid ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: ElevatedButton(
              onPressed: _isValid ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: HabitikColors.green500,
                foregroundColor: Colors.white,
                disabledBackgroundColor: HabitikColors.green500.withValues(alpha: 0.3),
                disabledForegroundColor: Colors.white38,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 13),
                elevation: _isValid ? 4 : 0,
                shadowColor: HabitikColors.green500.withValues(alpha: 0.5),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle, size: 16),
                  SizedBox(width: 6),
                  Text('Crear Premio', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets auxiliares
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.4));
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
