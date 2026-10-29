import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/services/api_client.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/data/models/user.dart';
import 'package:habitik/shared/widgets/buttons/buttons.dart';
import 'package:habitik/shared/widgets/feedback/feedback.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';
import 'package:habitik/shared/widgets/branding/habitik_logo.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLogin;
  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  bool _loading = false;
  bool _obscurePwd = true;
  String _loadingMessage = "";
  String _selectedRole = 'jefe'; // 'jefe' o 'miembro'

  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    final email = _emailCtrl.text.trim();
    final pwd = _pwdCtrl.text.trim();
    final name = _nameCtrl.text.trim();

    if (email.isEmpty || pwd.isEmpty) {
      _showError('Por favor completa todos los campos.');
      return;
    }

    if (!_isLogin) {
      if (name.isEmpty) {
        _showError('Por favor ingresa tu nombre.');
        return;
      }
    }

    setState(() {
      _loading = true;
      _loadingMessage = _isLogin ? "Iniciando sesión..." : "Creando tu hogar...";
    });

    try {
      if (_isLogin) {
        // Iniciar Sesión
        final response = await ApiClient().post('/auth/login', {
          'email': email,
          'password': pwd,
        });

        final data = jsonDecode(response.body);
        final token = data['token_jwt'];
        final profile = UserProfile.fromJson(data['profile']);

        await SessionService().saveSession(token: token, profile: profile);
        await SessionService().saveLastEmail(email);

        if (mounted) {
          widget.onLogin();
        }
      } else {
        // Registrar Jefe/Miembro y Hogar
        final finalFamilyName = 'Hogar de $name';
        await ApiClient().post('/auth/register', {
          'email': email,
          'password': pwd,
          'nombre': name,
          'nombreFamilia': finalFamilyName,
        });

        // Login automático tras registro exitoso para obtener perfil completo
        setState(() => _loadingMessage = "Configurando tu cuenta...");

        final response = await ApiClient().post('/auth/login', {
          'email': email,
          'password': pwd,
        });

        final data = jsonDecode(response.body);
        final token = data['token_jwt'];
        final profile = UserProfile.fromJson(data['profile']);

        await SessionService().saveSession(token: token, profile: profile);
        await SessionService().saveLastEmail(email);
        await SessionService().setOnboardingRole(_selectedRole);

        if (mounted) {
          _showSuccess('¡Cuenta creada con éxito!');
          widget.onLogin();
        }
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
        setState(() => _loading = false);
      }
    }
  }

  void _showError(String msg) => HabitikFeedback.showError(context, msg);

  void _showSuccess(String msg) => HabitikFeedback.showSuccess(context, msg);

  Future<void> _navigateToForgotPassword() async {
    final returnedEmail = await Navigator.of(context).push<String>(
      FadePageRoute(
        child: ForgotPasswordScreen(
          initialEmail: _emailCtrl.text.trim(),
        ),
      ),
    );

    if (returnedEmail != null && returnedEmail.isNotEmpty && mounted) {
      setState(() {
        _isLogin = true;
        _emailCtrl.text = returnedEmail;
        _pwdCtrl.clear();
      });
      HabitikFeedback.showSuccess(
        context,
        'Contraseña restablecida. Ingresa tus nuevas credenciales.',
      );
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
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(gradient: headerGradient),
                child: SafeArea(
                  child: Column(
                    children: [
                      // ── Header Superior ────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: Column(
                          children: [
                            // Fila superior con toggle de tema
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _ThemeToggleButton(isDark: isDark),
                              ],
                            ),

                            // Logo oficial de Habitik
                            HabitikLogo(
                              size: 78,
                            )
                                .animate()
                                .scale(
                                  begin: const Offset(0.7, 0.7),
                                  duration: 500.ms,
                                  curve: Curves.elasticOut,
                                )
                                .fadeIn(duration: 350.ms),

                            const SizedBox(height: 12),

                            // Título de la App
                            Text(
                              'HABITIK',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4,
                              ),
                            ).animate().fadeIn(delay: 150.ms),

                            const SizedBox(height: 4),

                            // Subtítulo dinámico
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Text(
                                _isLogin
                                    ? '¡Bienvenido de vuelta! 👋'
                                    : 'Crea tu hogar ecológico 🌍',
                                key: ValueKey(_isLogin),
                                style: GoogleFonts.outfit(
                                  color: isDark
                                      ? HabitikColors.green300
                                      : HabitikColors.green100,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Superficie del Formulario ──────────────────────────
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(36),
                            ),
                            border: Border(
                              top: BorderSide(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.10)
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.08),
                                blurRadius: 24,
                                offset: const Offset(0, -6),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Selector de pestaña (Login ↔ Registro)
                                _AuthTabSwitcher(
                                  isLogin: _isLogin,
                                  isDark: isDark,
                                  onChanged: (isLogin) =>
                                      setState(() => _isLogin = isLogin),
                                ),

                                const SizedBox(height: 24),

                                // Campos específicos de Registro
                                if (!_isLogin) ...[
                                  Text(
                                    'Elige tu rol en el hogar',
                                    style: GoogleFonts.outfit(
                                      color: isDark ? Colors.white : HabitikColors.textDark,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Selector moderno de 2 tarjetas
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _RoleCard(
                                          title: 'Jefe de Hogar',
                                          subtitle: 'Administra y guía',
                                          icon: Icons.shield_rounded,
                                          isSelected: _selectedRole == 'jefe',
                                          isDark: isDark,
                                          onTap: () => setState(() => _selectedRole = 'jefe'),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _RoleCard(
                                          title: 'Miembro',
                                          subtitle: 'Participa y juega',
                                          icon: Icons.group_rounded,
                                          isSelected: _selectedRole == 'miembro',
                                          isDark: isDark,
                                          onTap: () => setState(() => _selectedRole = 'miembro'),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 18),

                                  // Campo Nombre
                                  _InputField(
                                    label: 'Tu nombre o apodo',
                                    hint: 'Ej: Carlos Torres',
                                    controller: _nameCtrl,
                                    icon: Icons.person_outline_rounded,
                                    isDark: isDark,
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // Campo Correo
                                _InputField(
                                  label: 'Correo electrónico',
                                  hint: 'tu.correo@ejemplo.com',
                                  controller: _emailCtrl,
                                  icon: Icons.alternate_email_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  isDark: isDark,
                                ),

                                const SizedBox(height: 16),

                                // Campo Contraseña
                                _InputField(
                                  label: 'Contraseña',
                                  hint: '••••••••',
                                  controller: _pwdCtrl,
                                  icon: Icons.lock_outline_rounded,
                                  obscureText: _obscurePwd,
                                  isDark: isDark,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePwd
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: isDark
                                          ? HabitikColors.green300
                                          : HabitikColors.textLight,
                                      size: 20,
                                    ),
                                    onPressed: () =>
                                        setState(() => _obscurePwd = !_obscurePwd),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // Olvidaste tu contraseña (Solo en Login)
                                if (_isLogin)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: _navigateToForgotPassword,
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 4,
                                        ),
                                      ),
                                      child: Text(
                                        '¿Olvidaste tu contraseña?',
                                        style: GoogleFonts.outfit(
                                          color: isDark
                                              ? HabitikColors.green300
                                              : HabitikColors.green700,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),

                                const SizedBox(height: 18),

                                // Botón Principal
                                PrimaryButton(
                                  label: _isLogin
                                      ? 'Iniciar sesión'
                                      : 'Crear cuenta y hogar',
                                  icon: _isLogin
                                      ? Icons.arrow_forward_rounded
                                      : Icons.check_circle_outline_rounded,
                                  onTap: _submit,
                                  loading: _loading,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
// Sub-widgets Privados y Modulares
// ─────────────────────────────────────────────────────────────────────────────

class _ThemeToggleButton extends StatelessWidget {
  final bool isDark;
  const _ThemeToggleButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ThemeService.setDarkMode(!isDark),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.22),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: isDark ? const Color(0xFFFFD54F) : Colors.white,
              size: 15,
            ),
            const SizedBox(width: 5),
            Text(
              isDark ? 'Oscuro' : 'Claro',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthTabSwitcher extends StatelessWidget {
  final bool isLogin;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _AuthTabSwitcher({
    required this.isLogin,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF101C14) : const Color(0xFFF0F5F1);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE0EAE0);

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              title: 'Iniciar sesión',
              isSelected: isLogin,
              onTap: () => onChanged(true),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _TabButton(
              title: 'Crear cuenta',
              isSelected: !isLogin,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isSelected ? HabitikColors.green700 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: HabitikColors.green700.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: GoogleFonts.outfit(
            color: isSelected ? Colors.white : HabitikColors.textLight,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selectedBg = isDark ? const Color(0xFF1E3A26) : const Color(0xFFE8F5E9);
    final unselectedBg = isDark ? const Color(0xFF121F16) : const Color(0xFFF9FBF9);

    final selectedBorder = HabitikColors.green500;
    final unselectedBorder = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE2EBE2);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : unselectedBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? selectedBorder : unselectedBorder,
            width: isSelected ? 2 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: HabitikColors.green500.withValues(alpha: 0.20),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected
                      ? HabitikColors.green500
                      : (isDark ? Colors.white54 : HabitikColors.textMid),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: HabitikColors.green500,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white : HabitikColors.textDark,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white54 : HabitikColors.textLight,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final bool isDark;

  const _InputField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final fillBg = isDark ? const Color(0xFF121F16) : const Color(0xFFF7FAF7);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFE2EBE2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : HabitikColors.textDark,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : HabitikColors.textDark,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(
              color: isDark ? Colors.white38 : HabitikColors.textHint,
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: fillBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            prefixIcon: Icon(
              icon,
              color: isDark ? HabitikColors.green300 : HabitikColors.green600,
              size: 20,
            ),
            suffixIcon: suffixIcon,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: HabitikColors.green500, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
