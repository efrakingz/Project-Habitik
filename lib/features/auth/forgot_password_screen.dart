import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:habitik/core/services/api_client.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/shared/widgets/buttons/buttons.dart';
import 'package:habitik/shared/widgets/feedback/habitik_feedback.dart';
import 'package:habitik/shared/widgets/layout/loading_overlay.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String? initialEmail;
  const ForgotPasswordScreen({super.key, this.initialEmail});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _currentStep = 0; // 0: Email, 1: Código, 2: Nueva Contraseña, 3: Éxito
  bool _loading = false;
  String _loadingMessage = '';

  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _newPwdCtrl = TextEditingController();
  final _confirmPwdCtrl = TextEditingController();

  bool _obscureNewPwd = true;
  bool _obscureConfirmPwd = true;

  Timer? _resendTimer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      _emailCtrl.text = widget.initialEmail!;
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _newPwdCtrl.dispose();
    _confirmPwdCtrl.dispose();
    super.dispose();
  }

  void _startResendCountdown() {
    _secondsRemaining = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Paso 1: Enviar Código
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _handleSendCode() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      HabitikFeedback.showError(context, 'Por favor ingresa un correo electrónico válido.');
      return;
    }

    setState(() {
      _loading = true;
      _loadingMessage = 'Enviando código de verificación...';
    });

    try {
      final response = await ApiClient().post('/auth/forgot-password', {
        'email': email,
      });

      final data = jsonDecode(response.body);
      if (!mounted) return;

      debugPrint('✅ [ForgotPasswordScreen] Código solicitado para: $email');
      HabitikFeedback.showSuccess(
        context,
        data['message'] ?? 'Código enviado. Revisa tu correo.',
      );

      _startResendCountdown();
      setState(() {
        _currentStep = 1;
      });
    } catch (e) {
      if (!mounted) return;
      debugPrint('⚠️ [ForgotPasswordScreen] Error al enviar código: $e');
      HabitikFeedback.showError(context, e.toString().replaceAll('Exception:', '').trim());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Paso 2: Verificar Código
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _handleVerifyCode() async {
    final email = _emailCtrl.text.trim();
    final code = _codeCtrl.text.trim();

    if (code.length < 6) {
      HabitikFeedback.showError(context, 'Ingresa el código de 6 dígitos que enviamos a tu correo.');
      return;
    }

    setState(() {
      _loading = true;
      _loadingMessage = 'Verificando código...';
    });

    try {
      final response = await ApiClient().post('/auth/verify-reset-code', {
        'email': email,
        'code': code,
      });

      final data = jsonDecode(response.body);
      if (!mounted) return;

      debugPrint('✅ [ForgotPasswordScreen] Código verificado exitosamente');
      HabitikFeedback.showSuccess(context, data['message'] ?? 'Código verificado con éxito.');

      setState(() {
        _currentStep = 2;
      });
    } catch (e) {
      if (!mounted) return;
      debugPrint('⚠️ [ForgotPasswordScreen] Código inválido: $e');
      HabitikFeedback.showError(context, e.toString().replaceAll('Exception:', '').trim());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Paso 3: Restablecer Contraseña
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _handleResetPassword() async {
    final email = _emailCtrl.text.trim();
    final code = _codeCtrl.text.trim();
    final newPwd = _newPwdCtrl.text;
    final confirmPwd = _confirmPwdCtrl.text;

    if (newPwd.length < 6) {
      HabitikFeedback.showError(context, 'La contraseña debe tener al menos 6 caracteres.');
      return;
    }
    if (newPwd != confirmPwd) {
      HabitikFeedback.showError(context, 'Las contraseñas no coinciden. Verifica e intenta de nuevo.');
      return;
    }

    setState(() {
      _loading = true;
      _loadingMessage = 'Actualizando contraseña...';
    });

    try {
      final response = await ApiClient().post('/auth/reset-password', {
        'email': email,
        'code': code,
        'newPassword': newPwd,
      });

      final data = jsonDecode(response.body);
      if (!mounted) return;

      debugPrint('✅ [ForgotPasswordScreen] Contraseña actualizada exitosamente');
      HabitikFeedback.showSuccess(
        context,
        data['message'] ?? '¡Contraseña restablecida exitosamente!',
      );

      setState(() {
        _currentStep = 3;
      });
    } catch (e) {
      if (!mounted) return;
      debugPrint('⚠️ [ForgotPasswordScreen] Error restableciendo contraseña: $e');
      HabitikFeedback.showError(context, e.toString().replaceAll('Exception:', '').trim());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, _) {
        final cardBg = isDark ? const Color(0xFF16251B) : Colors.white;
        final headerGradient = isDark ? HabitikColors.heroGreenDark : HabitikColors.heroGreen;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F1A12) : const Color(0xFFF4F8F4),
          body: Stack(
            children: [
              Column(
                children: [
                  // Cabecera con botón de retroceso
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 16,
                      bottom: 24,
                      left: 20,
                      right: 20,
                    ),
                    decoration: BoxDecoration(gradient: headerGradient),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                          onPressed: () {
                            if (_currentStep > 0 && _currentStep < 3) {
                              setState(() => _currentStep--);
                            } else {
                              Navigator.pop(context);
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recuperar Cuenta',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (_currentStep < 3)
                                Text(
                                  'Paso ${_currentStep + 1} de 3',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white70,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Contenido según el paso activo
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: HabitikShadows.card,
                          border: Border.all(
                            color: isDark ? const Color(0xFF28402D) : const Color(0xFFE8F0E9),
                            width: 1.2,
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: switch (_currentStep) {
                            0 => _StepEmail(
                                emailCtrl: _emailCtrl,
                                isDark: isDark,
                                onSendCode: _handleSendCode,
                              ),
                            1 => _StepCode(
                                email: _emailCtrl.text.trim(),
                                codeCtrl: _codeCtrl,
                                isDark: isDark,
                                secondsRemaining: _secondsRemaining,
                                onVerifyCode: _handleVerifyCode,
                                onResendCode: _handleSendCode,
                              ),
                            2 => _StepPassword(
                                newPwdCtrl: _newPwdCtrl,
                                confirmPwdCtrl: _confirmPwdCtrl,
                                obscureNew: _obscureNewPwd,
                                obscureConfirm: _obscureConfirmPwd,
                                isDark: isDark,
                                onToggleObscureNew: () => setState(() => _obscureNewPwd = !_obscureNewPwd),
                                onToggleObscureConfirm: () => setState(() => _obscureConfirmPwd = !_obscureConfirmPwd),
                                onResetPassword: _handleResetPassword,
                              ),
                            _ => _StepSuccess(
                                isDark: isDark,
                                onGoToLogin: () => Navigator.pop(context, _emailCtrl.text.trim()),
                              ),
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Overlay de Carga
              LoadingOverlay(
                isLoading: _loading,
                message: _loadingMessage,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Paso 1: Formulario de Correo
// ─────────────────────────────────────────────────────────────────────────────
class _StepEmail extends StatelessWidget {
  final TextEditingController emailCtrl;
  final bool isDark;
  final VoidCallback onSendCode;

  const _StepEmail({
    required this.emailCtrl,
    required this.isDark,
    required this.onSendCode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('step_email'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: HabitikColors.green100,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.mail_outline_rounded, color: HabitikColors.green700, size: 28),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '¿Olvidaste tu contraseña?',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : HabitikColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ingresa el correo electrónico asociado a tu cuenta. Te enviaremos un código de verificación de 6 dígitos.',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white70 : HabitikColors.textMid,
            fontSize: 13.5,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : HabitikColors.textDark,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            labelText: 'Correo Electrónico',
            hintText: 'ejemplo@correo.com',
            prefixIcon: const Icon(Icons.alternate_email_rounded, color: HabitikColors.green600, size: 20),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E2E22) : const Color(0xFFF7FAF7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: isDark ? const Color(0xFF2C4332) : const Color(0xFFD4E3D5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: isDark ? const Color(0xFF2C4332) : const Color(0xFFD4E3D5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: HabitikColors.green600, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Enviar código',
          icon: Icons.send_rounded,
          onTap: onSendCode,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Paso 2: Formulario de Código Verificador
// ─────────────────────────────────────────────────────────────────────────────
class _StepCode extends StatelessWidget {
  final String email;
  final TextEditingController codeCtrl;
  final bool isDark;
  final int secondsRemaining;
  final VoidCallback onVerifyCode;
  final VoidCallback onResendCode;

  const _StepCode({
    required this.email,
    required this.codeCtrl,
    required this.isDark,
    required this.secondsRemaining,
    required this.onVerifyCode,
    required this.onResendCode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('step_code'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: HabitikColors.green100,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.pin_outlined, color: HabitikColors.green700, size: 28),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Código de Verificación',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : HabitikColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Hemos enviado un código de 6 dígitos a:\n$email',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white70 : HabitikColors.textMid,
            fontSize: 13.5,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: codeCtrl,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : HabitikColors.textDark,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 10,
          ),
          decoration: InputDecoration(
            hintText: '000000',
            counterText: '',
            filled: true,
            fillColor: isDark ? const Color(0xFF1E2E22) : const Color(0xFFF7FAF7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: isDark ? const Color(0xFF2C4332) : const Color(0xFFD4E3D5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: isDark ? const Color(0xFF2C4332) : const Color(0xFFD4E3D5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: HabitikColors.green600, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¿No recibiste el código? ',
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white60 : HabitikColors.textLight,
                fontSize: 13,
              ),
            ),
            if (secondsRemaining > 0)
              Text(
                'Reenviar en ${secondsRemaining}s',
                style: GoogleFonts.outfit(
                  color: HabitikColors.green600,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              )
            else
              TextButton(
                onPressed: onResendCode,
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: Text(
                  'Reenviar código',
                  style: GoogleFonts.outfit(
                    color: HabitikColors.green600,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: 'Verificar código',
          icon: Icons.check_circle_outline_rounded,
          onTap: onVerifyCode,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Paso 3: Formulario de Nueva Contraseña
// ─────────────────────────────────────────────────────────────────────────────
class _StepPassword extends StatelessWidget {
  final TextEditingController newPwdCtrl;
  final TextEditingController confirmPwdCtrl;
  final bool obscureNew;
  final bool obscureConfirm;
  final bool isDark;
  final VoidCallback onToggleObscureNew;
  final VoidCallback onToggleObscureConfirm;
  final VoidCallback onResetPassword;

  const _StepPassword({
    required this.newPwdCtrl,
    required this.confirmPwdCtrl,
    required this.obscureNew,
    required this.obscureConfirm,
    required this.isDark,
    required this.onToggleObscureNew,
    required this.onToggleObscureConfirm,
    required this.onResetPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('step_password'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: HabitikColors.green100,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.lock_reset_rounded, color: HabitikColors.green700, size: 28),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Nueva Contraseña',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : HabitikColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Crea una contraseña segura de al menos 6 caracteres para proteger tu hogar.',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white70 : HabitikColors.textMid,
            fontSize: 13.5,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: newPwdCtrl,
          obscureText: obscureNew,
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : HabitikColors.textDark,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            labelText: 'Nueva Contraseña',
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: HabitikColors.green600, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: isDark ? HabitikColors.green300 : HabitikColors.textLight,
                size: 20,
              ),
              onPressed: onToggleObscureNew,
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E2E22) : const Color(0xFFF7FAF7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: isDark ? const Color(0xFF2C4332) : const Color(0xFFD4E3D5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: isDark ? const Color(0xFF2C4332) : const Color(0xFFD4E3D5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: HabitikColors.green600, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: confirmPwdCtrl,
          obscureText: obscureConfirm,
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : HabitikColors.textDark,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            labelText: 'Confirmar Contraseña',
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: HabitikColors.green600, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: isDark ? HabitikColors.green300 : HabitikColors.textLight,
                size: 20,
              ),
              onPressed: onToggleObscureConfirm,
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E2E22) : const Color(0xFFF7FAF7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: isDark ? const Color(0xFF2C4332) : const Color(0xFFD4E3D5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: isDark ? const Color(0xFF2C4332) : const Color(0xFFD4E3D5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: HabitikColors.green600, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Guardar nueva contraseña',
          icon: Icons.check_circle_rounded,
          onTap: onResetPassword,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Paso 4: Confirmación de Éxito
// ─────────────────────────────────────────────────────────────────────────────
class _StepSuccess extends StatelessWidget {
  final bool isDark;
  final VoidCallback onGoToLogin;

  const _StepSuccess({
    required this.isDark,
    required this.onGoToLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('step_success'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: HabitikColors.green100,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.check_circle_rounded, color: HabitikColors.green700, size: 44),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '¡Contraseña Actualizada!',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : HabitikColors.textDark,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Tu contraseña ha sido restablecida con éxito. Ya puedes iniciar sesión con tus nuevas credenciales.',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white70 : HabitikColors.textMid,
            fontSize: 14,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 28),
        PrimaryButton(
          label: 'Iniciar sesión ahora',
          icon: Icons.login_rounded,
          onTap: onGoToLogin,
        ),
      ],
    );
  }
}

