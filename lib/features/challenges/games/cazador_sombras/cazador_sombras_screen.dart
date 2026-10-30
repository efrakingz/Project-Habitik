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

    final fileSize = await _compressedFile!.length();
    if (fileSize > 5 * 1024 * 1024) {
      if (mounted) {
        HabitikFeedback.showError(
          context,
          'La imagen supera el límite permitido de 5 MB. Intenta con otra foto.',
        );
      }
      return;
    }

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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: HabitikColors.green600.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle_rounded, color: HabitikColors.green600, size: 28),
            ),
            const SizedBox(width: 12),
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
            const SizedBox(height: 14),
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
                      'El Jefe de Hogar revisará tu foto. Al aprobarla recibirás +80 XP y +4 🪙.',
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

    final bgColor = isDark ? const Color(0xFF101712) : const Color(0xFFF6FAF6);
    final cardColor = isDark ? const Color(0xFF1B241C) : Colors.white;
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE2EBE2);
    final textColor = isDark ? Colors.white : HabitikColors.textDark;
    final subtextColor = isDark ? Colors.white60 : const Color(0xFF5A6E5D);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1511) : HabitikColors.heroGreen.colors.first,
      body: ScreenShell(
        titulo: 'Cazador de Sombras',
        subtitulo: 'Misión fotográfica de inspección del hogar',
        useDefaultBackground: false,
        headerActions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: bgColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(context).padding.bottom + 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 1. Banner de Misión Diaria ─────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isDark ? 35 : 8),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.shade400,
                              Colors.orange.shade600,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withAlpha(80),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Misión del Día',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Inspecciona y toma una foto de un hábito sostenible en casa.',
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.25,
                                color: subtextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber.withAlpha(35),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const GameStarIcon(size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '+80 XP',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                    color: Colors.amber.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const GameCoinIcon(size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '+4 🪙',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // ── 2. Campo "¿Qué estás inspeccionando?" ───────────────────
                Row(
                  children: [
                    Icon(Icons.edit_note_rounded, size: 20, color: HabitikColors.green600),
                    const SizedBox(width: 8),
                    Text(
                      '¿Qué estás inspeccionando?',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isDark ? 25 : 6),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _titleController,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ej. Cargador desconectado, luces apagadas...',
                      hintStyle: TextStyle(color: subtextColor.withAlpha(160), fontSize: 13),
                      prefixIcon: Icon(Icons.search_rounded, color: HabitikColors.green600, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── 3. Visor de Foto de Evidencia ─────────────────────────
                Row(
                  children: [
                    Icon(Icons.camera_alt_rounded, size: 20, color: HabitikColors.green600),
                    const SizedBox(width: 8),
                    Text(
                      'Foto de Evidencia',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (_compressedFile != null) ...[
                  // Preview de la foto capturada
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(isDark ? 40 : 12),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Container(
                              height: 250,
                              width: double.infinity,
                              color: Colors.black,
                              child: Image.file(
                                _compressedFile!,
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Badge de foto lista
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(180),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.greenAccent.withAlpha(100)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 14),
                                    SizedBox(width: 6),
                                    Text(
                                      'Foto Optimizada HD',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Botón para eliminar foto
                            Positioned(
                              top: 12,
                              right: 12,
                              child: InkWell(
                                onTap: _clearImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.black87,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                            // Tamaño comprimido
                            if (_compressedSizeBytes != null)
                              Positioned(
                                bottom: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(180),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${(_compressedSizeBytes! / 1024).toStringAsFixed(1)} KB (<500 KB)',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: OutlinedButton.icon(
                            onPressed: () => _pickAndCompressImage(ImageSource.camera),
                            icon: const Icon(Icons.sync_rounded, size: 18),
                            label: const Text('Tomar otra foto'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: HabitikColors.green600,
                              side: BorderSide(color: HabitikColors.green600.withAlpha(120)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (_isCompressing) ...[
                  // Spinner de compresión
                  Container(
                    height: 190,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: HabitikColors.green600,
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Optimizando evidencia fotográfica...',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Comprimiendo a menos de 500 KB sin perder calidad',
                            style: TextStyle(fontSize: 12, color: subtextColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // Dropzone de captura de foto
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? Colors.white12 : HabitikColors.green600.withAlpha(50),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(isDark ? 30 : 6),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: HabitikColors.green600.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_a_photo_rounded,
                            size: 32,
                            color: HabitikColors.green600,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Sube una foto clara de tu inspección',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'La imagen se comprimirá automáticamente en tu dispositivo.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: subtextColor),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                key: const Key('btn_tomar_foto_camara'),
                                onPressed: () => _pickAndCompressImage(ImageSource.camera),
                                icon: const Icon(Icons.photo_camera_rounded, size: 19),
                                label: const Text(
                                  'Cámara',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: HabitikColors.green600,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                key: const Key('btn_seleccionar_galeria'),
                                onPressed: () => _pickAndCompressImage(ImageSource.gallery),
                                icon: const Icon(Icons.photo_library_rounded, size: 19),
                                label: const Text(
                                  'Galería',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: HabitikColors.green600,
                                  side: BorderSide(
                                    color: HabitikColors.green600,
                                    width: 1.5,
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
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

                // ── 5. Botón de Envío Épico ────────────────────────────────
                Opacity(
                  opacity: canSubmit ? 1.0 : 0.5,
                  child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: canSubmit
                        ? const LinearGradient(
                            colors: [Color(0xFFFFA000), Color(0xFFFF6F00)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: canSubmit ? null : (isDark ? Colors.white10 : Colors.grey.shade300),
                    boxShadow: canSubmit
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFF6F00).withAlpha(100),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: ElevatedButton(
                    key: const Key('btn_enviar_evidencia'),
                    onPressed: canSubmit ? _enviarEvidencia : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.transparent,
                      disabledForegroundColor: isDark ? Colors.white30 : Colors.grey.shade600,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isUploading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Enviando evidencia...',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.send_rounded,
                                size: 20,
                                color: canSubmit
                                    ? Colors.white
                                    : (isDark ? Colors.white30 : Colors.grey.shade600),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Enviar Evidencia',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  letterSpacing: 0.3,
                                  color: canSubmit
                                      ? Colors.white
                                      : (isDark ? Colors.white30 : Colors.grey.shade600),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
