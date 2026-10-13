import 'package:flutter/material.dart';
import 'package:habitik/core/services/api_client.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/family_member.dart';
import 'package:habitik/shared/widgets/feedback/feedback.dart';

class NotificacionPersonalizadaSheet extends StatefulWidget {
  const NotificacionPersonalizadaSheet({
    super.key,
    required this.members,
    required this.familyId,
    required this.senderName,
  });

  final List<FamilyMember> members;
  final String familyId;
  final String senderName;

  @override
  State<NotificacionPersonalizadaSheet> createState() =>
      _NotificacionPersonalizadaSheetState();
}

class _NotificacionPersonalizadaSheetState
    extends State<NotificacionPersonalizadaSheet> {
  final _tituloCtrl = TextEditingController();
  final _mensajeCtrl = TextEditingController();
  FamilyMember? _destinatarioSeleccionado; // null = todos
  bool _enviando = false;

  // Plantillas rápidas
  static const List<Map<String, String>> _plantillas = [
    {
      'emoji': '🌿',
      'titulo': '¡Hábito del día!',
      'mensaje':
          'Recuerda completar tu reto de hoy. ¡Cada acción cuenta para el hogar! 💪'
    },
    {
      'emoji': '💡',
      'titulo': 'Alerta de consumo',
      'mensaje':
          'El consumo de luz de este mes está por encima de la meta. ¡Apaguemos lo que no usamos!'
    },
    {
      'emoji': '🚿',
      'titulo': 'Reto de agua',
      'mensaje':
          '¡Hoy es el día del reto de la ducha rápida! Menos de 5 minutos y ganarás XP extra.'
    },
    {
      'emoji': '🏆',
      'titulo': '¡Bien hecho familia!',
      'mensaje':
          'Este mes vamos muy bien con nuestras metas. ¡Sigamos así para alcanzar el nivel siguiente!'
    },
  ];

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _mensajeCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final titulo = _tituloCtrl.text.trim();
    final mensaje = _mensajeCtrl.text.trim();

    if (titulo.isEmpty || mensaje.isEmpty) {
      HabitikFeedback.showError(
          context, 'Completa el título y el mensaje antes de enviar.');
      return;
    }

    setState(() => _enviando = true);

    try {
      final bodyMap = <String, dynamic>{
        'titulo': titulo,
        'mensaje': mensaje,
        'tipo': 'MANUAL',
        'family_id': widget.familyId,
        'usuario_nombre': widget.senderName,
        if (_destinatarioSeleccionado != null)
          'destinatario_id': _destinatarioSeleccionado!.id,
      };

      final response = await ApiClient().post(
        '/notificaciones/enviar-personalizada',
        bodyMap,
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context);
        HabitikFeedback.showSuccess(
          context,
          _destinatarioSeleccionado != null
              ? '✅ Notificación enviada a ${_destinatarioSeleccionado!.nombre}'
              : '✅ Notificación enviada a toda la familia',
        );
      } else {
        HabitikFeedback.showError(context, 'Error al enviar. Intenta de nuevo.');
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('❌ [ControlScreen] Error enviando notificación: $e');
      HabitikFeedback.showError(
          context, 'Error de conexión. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111B15) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Título del sheet
            Text(
              '🔔 Enviar Notificación',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : HabitikColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'El mensaje llegará aunque la app esté cerrada',
              style: TextStyle(fontSize: 12, color: HabitikColors.textMid),
            ),
            const SizedBox(height: 20),

            // Plantillas rápidas
            Text(
              'Plantillas rápidas',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : HabitikColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _plantillas.length,
                separatorBuilder: (_, x) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final p = _plantillas[i];
                  return _PlantillaChip(
                    label: '${p['emoji']} ${p['titulo']}',
                    onTap: () {
                      _tituloCtrl.text = p['titulo']!;
                      _mensajeCtrl.text = p['mensaje']!;
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 18),

            // Destinatario
            Text(
              'Destinatario',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : HabitikColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            _DestinatarioSelector(
              members: widget.members,
              selected: _destinatarioSeleccionado,
              onChanged: (m) => setState(() => _destinatarioSeleccionado = m),
              isDark: isDark,
            ),
            const SizedBox(height: 18),

            // Título
            _InputField(
              controller: _tituloCtrl,
              label: 'Título',
              hint: 'Ej: ¡Hábito del día!',
              isDark: isDark,
              maxLength: 60,
            ),
            const SizedBox(height: 12),

            // Mensaje
            _InputField(
              controller: _mensajeCtrl,
              label: 'Mensaje',
              hint: 'Escribe el mensaje que recibirá tu familia...',
              isDark: isDark,
              maxLines: 3,
              maxLength: 200,
            ),
            const SizedBox(height: 24),

            // Botón enviar
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _enviando ? null : _enviar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HabitikColors.blue500,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      HabitikColors.blue500.withValues(alpha: 0.5),
                  elevation: 0,
                  shape:
                      RoundedRectangleBorder(borderRadius: HabitikRadius.md_),
                ),
                child: _enviando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            _destinatarioSeleccionado != null
                                ? 'Enviar a ${_destinatarioSeleccionado!.nombre}'
                                : 'Enviar a toda la familia',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlantillaChip extends StatelessWidget {
  const _PlantillaChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2A3A) : const Color(0xFFE8F5FF),
          borderRadius: HabitikRadius.xl_,
          border: Border.all(
            color: HabitikColors.blue500.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: HabitikColors.blue500,
          ),
        ),
      ),
    );
  }
}

class _DestinatarioSelector extends StatelessWidget {
  const _DestinatarioSelector({
    required this.members,
    required this.selected,
    required this.onChanged,
    required this.isDark,
  });
  final List<FamilyMember> members;
  final FamilyMember? selected;
  final ValueChanged<FamilyMember?> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final todos = [null, ...members];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: todos.length,
        separatorBuilder: (_, x) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final member = todos[i];
          final isSelected = selected?.id == member?.id;
          final label = member == null ? '👨‍👩‍👧 Todos' : member.nombre;

          return GestureDetector(
            onTap: () => onChanged(member),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? HabitikColors.blue500
                    : (isDark
                        ? const Color(0xFF1C2C1E)
                        : const Color(0xFFF5F5F5)),
                borderRadius: HabitikRadius.xl_,
                border: Border.all(
                  color: isSelected
                      ? HabitikColors.blue500
                      : (isDark ? Colors.white12 : Colors.black12),
                  width: 1.5,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : HabitikColors.textDark),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.isDark,
    this.maxLines = 1,
    this.maxLength,
  });
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isDark;
  final int maxLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : HabitikColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white : HabitikColors.textDark,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(color: HabitikColors.textLight, fontSize: 13),
            counterStyle:
                const TextStyle(color: HabitikColors.textLight, fontSize: 11),
            filled: true,
            fillColor:
                isDark ? const Color(0xFF1C2C1E) : const Color(0xFFF7FAF7),
            border: OutlineInputBorder(
              borderRadius: HabitikRadius.md_,
              borderSide: BorderSide(
                color: isDark ? Colors.white12 : HabitikColors.green200,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: HabitikRadius.md_,
              borderSide: BorderSide(
                color: isDark ? Colors.white12 : HabitikColors.green200,
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: HabitikRadius.md_,
              borderSide: const BorderSide(
                color: HabitikColors.blue500,
                width: 1.8,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
