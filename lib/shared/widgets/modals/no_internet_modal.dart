import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/services/network_service.dart';

class NoInternetModal extends StatefulWidget {
  final VoidCallback? onConnected;

  const NoInternetModal({super.key, this.onConnected});

  /// Muestra el modal bloqueante directamente en el contexto
  static Future<void> show(BuildContext context, {VoidCallback? onConnected}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (ctx) => NoInternetModal(onConnected: onConnected),
    );
  }

  @override
  State<NoInternetModal> createState() => _NoInternetModalState();
}

class _NoInternetModalState extends State<NoInternetModal> {
  bool _isChecking = false;
  String? _statusFeedback;

  Future<void> _retryConnection() async {
    if (_isChecking) return;

    setState(() {
      _isChecking = true;
      _statusFeedback = 'Comprobando conexión...';
    });

    final hasInternet = await NetworkService().checkInternet();

    if (!mounted) return;

    if (hasInternet) {
      setState(() {
        _isChecking = false;
        _statusFeedback = '¡Conexión restaurada!';
      });
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      widget.onConnected?.call();
    } else {
      setState(() {
        _isChecking = false;
        _statusFeedback = 'Aún sin señal de internet. Revisa tu Wi-Fi o datos.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF142217) : Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: isDark ? const Color(0x354ADE80) : const Color(0x3010B981),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.6)
                    : const Color(0xFF10B981).withValues(alpha: 0.15),
                blurRadius: 36,
                spreadRadius: 4,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono animado con halo luminoso
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF1E3324) : const Color(0xFFE8F5E9),
                  border: Border.all(
                    color: isDark ? const Color(0xFF4ADE80) : HabitikColors.green500,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? const Color(0xFF4ADE80) : HabitikColors.green500)
                          .withValues(alpha: 0.35),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: const Text('📡', style: TextStyle(fontSize: 44))
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(0.92, 0.92),
                        end: const Offset(1.06, 1.06),
                        duration: 1200.ms,
                        curve: Curves.easeInOut,
                      ),
                ),
              ),

              const SizedBox(height: 24),

              // Título
              Text(
                'Sin Conexión a Internet',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : HabitikColors.textDark,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 12),

              // Descripción
              Text(
                'Habitik necesita una conexión activa a internet para registrar tus hábitos sostenibles y sincronizar el progreso de tu hogar.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  height: 1.45,
                  color: isDark ? const Color(0xFFB0C5B5) : HabitikColors.textMid,
                ),
              ),

              const SizedBox(height: 18),

              // Badge indicador
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF26382B)
                      : HabitikColors.green50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? const Color(0x354ADE80)
                        : HabitikColors.green200,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      size: 16,
                      color: isDark ? const Color(0xFF4ADE80) : HabitikColors.green700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Conéctate a Wi-Fi o Datos Móviles',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFF4ADE80) : HabitikColors.green700,
                      ),
                    ),
                  ],
                ),
              ),

              if (_statusFeedback != null) ...[
                const SizedBox(height: 14),
                Text(
                  _statusFeedback!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _statusFeedback!.contains('restaurada')
                        ? (isDark ? const Color(0xFF4ADE80) : HabitikColors.green600)
                        : const Color(0xFFE53935),
                  ),
                ).animate().fadeIn(duration: 200.ms),
              ],

              const SizedBox(height: 26),

              // Botón de Reintentar
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isChecking ? null : _retryConnection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HabitikColors.green600,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: HabitikColors.green700.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isChecking
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
                            const Icon(Icons.refresh_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Reintentar Conexión',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ).animate().scale(begin: const Offset(0.9, 0.9), duration: 300.ms, curve: Curves.easeOutBack).fadeIn(duration: 250.ms),
    );
  }
}

/// Envoltorio global que bloquea completamente cualquier pantalla si se pierde la conexión a internet
class NoInternetBarrier extends StatelessWidget {
  final Widget child;

  const NoInternetBarrier({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: NetworkService().isConnectedNotifier,
      builder: (context, isConnected, _) {
        return Stack(
          children: [
            child,
            if (!isConnected)
              Positioned.fill(
                child: AbsorbPointer(
                  absorbing: false,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.75),
                    alignment: Alignment.center,
                    child: const NoInternetModal(),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
