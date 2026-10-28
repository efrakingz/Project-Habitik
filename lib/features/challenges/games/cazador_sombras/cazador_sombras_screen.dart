import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/inspeccion_service.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/feedback/feedback.dart';
import '../../../../shared/widgets/icons/game_icons.dart';
import '../../../../shared/widgets/layout/layout.dart';

/// Pantalla del Reto HU 2.2 — Cazador de Sombras (Inspección Fotográfica del Hogar).
class CazadorSombrasScreen extends StatefulWidget {
  final VoidCallback? onChallengeCompleted;

  const CazadorSombrasScreen({
    super.key,
    this.onChallengeCompleted,
  });

  @override
  State<CazadorSombrasScreen> createState() => _CazadorSombrasScreenState();
}

class _CazadorSombrasScreenState extends State<CazadorSombrasScreen> {
  final InspeccionService _inspeccionService = InspeccionService();
  final TextEditingController _titleController = TextEditingController(
    text: 'Inspección de luces y enchufes',
  );

  File? _compressedFile;
  int? _compressedSizeBytes;
  bool _isCompressing = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickAndCompressImage(ImageSource source) async {
    AudioService.playSFX('click.mp3');
    final file = await _inspeccionService.capturarFoto(source);
    if (file == null) return;

    setState(() {
      _compressedFile = null;
      _compressedSizeBytes = null;
      _isCompressing = true;
    });

    try {
      final compressed = await _inspeccionService.comprimirImagen(file);
      final bytes = compressed != null ? await compressed.length() : null;

      if (mounted) {
        setState(() {
          _compressedFile = compressed;
          _compressedSizeBytes = bytes;
          _isCompressing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _compressedFile = file;
          _isCompressing = false;
        });
      }
    }
  }

  void _clearImage() {
    AudioService.playSFX('click.mp3');
    setState(() {
      _compressedFile = null;
      _compressedSizeBytes = null;
    });
  }

  Future<void> _enviarEvidencia() async {
    final title = _titleController.text.trim();
    if (_compressedFile == null || title.isEmpty || _isUploading) return;

    AudioService.playSFX('click.mp3');
    setState(() => _isUploading = true);

    try {
      final evidencia = await _inspeccionService.enviarEvidencia(
        tituloMision: title,
        foto: _compressedFile!,
      );

      if (mounted) {
        _mostrarModalExito(evidencia.tituloMision);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        HabitikFeedback.showError(
          context,
          e.toString().replaceAll('Exception:', '').trim(),
        );
      }
    }
  }

  void _mostrarModalExito(String tituloMision) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('📸', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '¡Evidencia Enviada!',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tu inspección para "$tituloMision" fue subida con éxito.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.hourglass_top_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'El Jefe de Hogar revisará tu foto. Al aprobarla recibirás +80 XP y +4 Monedas.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: HabitikColors.green600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              widget.onChallengeCompleted?.call();
              Navigator.pop(context);
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool canSubmit = _compressedFile != null &&
        !_isCompressing &&
        !_isUploading &&
        _titleController.text.trim().isNotEmpty;

    return ScreenShell(
      titulo: 'Cazador de Sombras',
      subtitulo: '🔍 Misión fotográfica de inspección del hogar',
      useDefaultBackground: false,
      headerActions: [
        IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      body: Material(
        color: Colors.transparent,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner de Recompensas
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF2C2411), const Color(0xFF1E1C14)]
                      : [const Color(0xFFFFF8E1), const Color(0xFFFFECB3)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFFF57C00) : const Color(0xFFFFB74D),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF57C00).withAlpha(40),
                      shape: BoxShape.circle,
                    ),
                    child: const Text('🔍', style: TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Misión del Día',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? Colors.amber.shade200 : const Color(0xFFE65100),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Inspecciona y toma una foto de un hábito sostenible en casa.',
                          style: TextStyle(fontSize: 12, height: 1.2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          GameStarIcon(size: 14),
                          SizedBox(width: 4),
                          Text('+80 XP', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.amber)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          GameCoinIcon(size: 14),
                          SizedBox(width: 4),
                          Text('+4 🪙', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.orange)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Campo de Texto de la Misión
            Text(
              '¿Qué estás inspeccionando?',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? Colors.white : HabitikColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Ej. Inspección de luces apagadas...',
                prefixIcon: const Icon(Icons.edit_note_rounded),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E2820) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 24),

            // Sección de Captura de Fotografía
            Text(
              'Foto de Evidencia',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? Colors.white : HabitikColors.textDark,
              ),
            ),
            const SizedBox(height: 8),

            if (_compressedFile != null) ...[
              // Preview de la foto capturada y comprimida
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 240,
                      width: double.infinity,
                      color: isDark ? Colors.black26 : Colors.grey.shade100,
                      child: Image.file(
                        _compressedFile!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: InkWell(
                      onTap: _clearImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.black87,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                  if (_compressedSizeBytes != null)
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${(_compressedSizeBytes! / 1024).toStringAsFixed(1)} KB (Optimizada <500 KB)',
                          style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _pickAndCompressImage(ImageSource.camera),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Tomar otra foto'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ] else if (_isCompressing) ...[
              // Spinner de compresión
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2820) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withAlpha(50)),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text(
                        'Optimizando evidencia (<500 KB)...',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Opciones para capturar foto
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B241C) : const Color(0xFFF9FBF9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.grey.shade300,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      size: 48,
                      color: isDark ? Colors.white54 : HabitikColors.green600,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Sube una foto clara de tu inspección',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'La foto se comprimirá automáticamente en tu dispositivo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            key: const Key('btn_tomar_foto_camara'),
                            onPressed: () => _pickAndCompressImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt_rounded),
                            label: const Text('Cámara'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: HabitikColors.green600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            key: const Key('btn_seleccionar_galeria'),
                            onPressed: () => _pickAndCompressImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library_rounded),
                            label: const Text('Galería'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // CA-2.2-1: Botón "Enviar Evidencia" deshabilitado al 50% de opacidad si no hay foto lista
            Opacity(
              opacity: canSubmit ? 1.0 : 0.5,
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  key: const Key('btn_enviar_evidencia'),
                  onPressed: canSubmit ? _enviarEvidencia : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF57C00),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: canSubmit ? 3 : 0,
                  ),
                  child: _isUploading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            ),
                            SizedBox(width: 12),
                            Text('Enviando evidencia...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.send_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Enviar Evidencia',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
}
}
