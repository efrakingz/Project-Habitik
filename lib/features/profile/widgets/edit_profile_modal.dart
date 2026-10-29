import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/services/profile_service.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/user.dart';
import 'package:habitik/shared/widgets/avatar/avatar.dart';
import 'package:habitik/shared/widgets/feedback/feedback.dart';

/// Modal interactivo para Editar Perfil (HU Perfil).
/// Incluye:
/// - Vista previa del avatar en tiempo real.
/// - Restricción de 1 caracter en mayúscula para la letra (TextCapitalization.characters).
/// - Selector de paleta de colores oficial.
/// - Persistencia en PUT /perfil/editar y refresco global reactivo.
class EditProfileModal extends StatefulWidget {
  final UserProfile user;

  const EditProfileModal({
    super.key,
    required this.user,
  });

  /// Muestra el modal deslizante con ajuste automático de teclado
  static Future<bool?> show(BuildContext context) {
    final currentUser = SessionService().currentUser ?? UserProfile.empty;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF142419) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: EditProfileModal(user: currentUser),
      ),
    );
  }

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  final ProfileService _profileService = ProfileService();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _letterController;

  late String _selectedColor;
  late String _activeLetter;
  bool _letterManuallyEdited = false;
  bool _isSaving = false;

  // Paleta oficial de colores vibrantes para avatar
  static const List<String> _paletteColors = [
    '#2E7D32', // Verde Primario Habitik
    '#00897B', // Verde Esmeralda
    '#1E88E5', // Azul Océano
    '#3949AB', // Índigo Profundo
    '#8E24AA', // Púrpura Real
    '#D81B60', // Rosa Fucsia
    '#E53935', // Rojo Coral
    '#FB8C00', // Naranja Fuego
    '#F59E0B', // Ámbar Oro
    '#546E7A', // Gris Azulado
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.nombre);
    _letterController = TextEditingController(text: widget.user.avatarLetra);
    _selectedColor = widget.user.avatarColor.isNotEmpty ? widget.user.avatarColor : '#2E7D32';
    _activeLetter = widget.user.avatarLetra.isNotEmpty ? widget.user.avatarLetra : 'A';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _letterController.dispose();
    super.dispose();
  }

  Color _parseHexColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '').trim();
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return HabitikColors.green600;
    }
  }

  void _onNameChanged(String val) {
    if (!_letterManuallyEdited && val.trim().isNotEmpty) {
      final firstChar = val.trim()[0].toUpperCase();
      setState(() {
        _activeLetter = firstChar;
        _letterController.text = firstChar;
      });
    }
  }

  void _onLetterChanged(String val) {
    _letterManuallyEdited = true;
    final upper = val.toUpperCase().trim();
    setState(() {
      _activeLetter = upper.isNotEmpty ? upper[0] : (widget.user.nombre.isNotEmpty ? widget.user.nombre[0].toUpperCase() : 'A');
    });
  }

  Future<void> _guardarPerfil() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    final nuevoNombre = _nameController.text.trim();
    final nuevaLetra = _activeLetter.toUpperCase().trim();

    setState(() => _isSaving = true);

    try {
      await _profileService.editarPerfil(
        nombre: nuevoNombre,
        color: _selectedColor,
        letra: nuevaLetra,
      );

      if (mounted) {
        HabitikFeedback.showSuccess(context, '¡Perfil actualizado con éxito!');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        HabitikFeedback.showError(
          context,
          e.toString().replaceAll('Exception:', '').trim(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentColor = _parseHexColor(_selectedColor);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 1. Tirador superior (drag handle) ──
            Center(
              child: Container(
                width: 40,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── 2. Cabecera del Modal ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: currentColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    color: currentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Editar Perfil',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : HabitikColors.textDark,
                        ),
                      ),
                      Text(
                        'Personaliza tu nombre y los atributos de tu avatar',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : HabitikColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── 3. Vista Previa del Avatar en Tiempo Real ──
            Center(
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: currentColor.withValues(alpha: 0.35),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: UserAvatar(
                      letra: _activeLetter,
                      colorHex: _selectedColor,
                      avatarUrl: widget.user.avatarUrl,
                      radius: 42,
                      showBorder: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1B2E22) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Vista Previa',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : HabitikColors.textMid,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ── 4. Campo Nombre Completo ──
            Text(
              'Nombre',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : HabitikColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameController,
              onChanged: _onNameChanged,
              textCapitalization: TextCapitalization.words,
              style: TextStyle(
                color: isDark ? Colors.white : HabitikColors.textDark,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Tu nombre o apodo familiar',
                prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                filled: true,
                fillColor: isDark ? const Color(0xFF1B2E22) : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: HabitikColors.green500, width: 1.8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'El nombre no puede estar vacío';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // ── 5. Campo Inicial / Letra del Avatar (Restricción maxLength: 1) ──
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Letra del Avatar',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : HabitikColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Un solo caracter en mayúscula',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white54 : HabitikColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: TextFormField(
                    controller: _letterController,
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                    ],
                    onChanged: _onLetterChanged,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : HabitikColors.textDark,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1B2E22) : const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: HabitikColors.green500, width: 1.8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Requerido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── 6. Selector de Color del Avatar ──
            Text(
              'Color del Avatar',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : HabitikColors.textDark,
              ),
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: _paletteColors.map((hex) {
                final color = _parseHexColor(hex);
                final isSelected = _selectedColor.toUpperCase() == hex.toUpperCase();

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedColor = hex);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: isSelected ? 2.5 : 0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: isSelected ? 0.6 : 0.25),
                          blurRadius: isSelected ? 8 : 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 20,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            // ── 7. Botón Guardar Cambios ──
            Container(
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [HabitikColors.green700, HabitikColors.green500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: HabitikColors.green600.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isSaving ? null : _guardarPerfil,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.save_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Guardar Cambios',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
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

