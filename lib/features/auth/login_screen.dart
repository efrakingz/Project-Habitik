import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/services/api_client.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/data/models/user.dart';
import 'package:habitik/shared/widgets/buttons/buttons.dart';

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
  final _pwdCtrl   = TextEditingController();
  final _nameCtrl  = TextEditingController();

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
        await SessionService().saveCredentials(email, pwd);
        
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
        await SessionService().saveCredentials(email, pwd);
        await SessionService().setOnboardingRole(_selectedRole);
        
        if (mounted) {
          _showSuccess('Cuenta creada con éxito!');
          widget.onLogin();
        }
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg.replaceAll('Exception:', '').trim()),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: HabitikColors.green700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: HabitikColors.heroGreen),
            child: SafeArea(
              child: Column(
                children: [
                  // ── Header ──────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      children: [
                        Container(
                          width: 72, height: 72,
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Center(child: Text('🌿', style: TextStyle(fontSize: 36))),
                        ).animate().scale(begin: const Offset(0.6, 0.6), duration: 500.ms, curve: Curves.elasticOut),
                        const SizedBox(height: 12),
                        const Text('HABITIK', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 3))
                            .animate().fadeIn(delay: 200.ms),
                        const SizedBox(height: 6),
                        Text(
                          _isLogin ? 'Bienvenido de vuelta 👋' : 'Crea tu cuenta 🚀',
                          style: const TextStyle(color: HabitikColors.green200, fontSize: 13),
                        ).animate().fadeIn(delay: 300.ms),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Form ────────────────────────────────────────────────────
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tab switcher
                            Container(
                              height: 44,
                              decoration: BoxDecoration(color: HabitikColors.green50, borderRadius: HabitikRadius.md_),
                              child: Row(children: ['Iniciar sesión', 'Crear cuenta'].asMap().entries.map((e) {
                                final isSelected = (e.key == 0) == _isLogin;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _isLogin = e.key == 0),
                                    child: AnimatedContainer(
                                      duration: 200.ms,
                                      margin: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: isSelected ? HabitikColors.green700 : Colors.transparent,
                                        borderRadius: HabitikRadius.sm_,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(e.value, style: TextStyle(color: isSelected ? Colors.white : HabitikColors.textLight, fontWeight: FontWeight.w700, fontSize: 13)),
                                    ),
                                  ),
                                );
                              }).toList()),
                            ),

                            const SizedBox(height: 28),

                            // Name field (only register)
                            if (!_isLogin) ...[
                              _label('Tipo de cuenta'),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: ChoiceChip(
                                      label: const Text('👑 Jefe/Admin'),
                                      selected: _selectedRole == 'jefe',
                                      onSelected: (val) {
                                        if (val) setState(() => _selectedRole = 'jefe');
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ChoiceChip(
                                      label: const Text('👥 Miembro'),
                                      selected: _selectedRole == 'miembro',
                                      onSelected: (val) {
                                        if (val) setState(() => _selectedRole = 'miembro');
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              _label('Tu nombre'),
                              const SizedBox(height: 6),
                              _textField('Ej: Carlos Torres', _nameCtrl, icon: Icons.person_outline),
                              const SizedBox(height: 16),
                            ],

                            _label('Correo electrónico'),
                            const SizedBox(height: 6),
                            _textField('correo@ejemplo.com', _emailCtrl, icon: Icons.email_outlined, type: TextInputType.emailAddress),
                            const SizedBox(height: 16),

                            _label('Contraseña'),
                            const SizedBox(height: 6),
                            _textField('••••••••', _pwdCtrl, icon: Icons.lock_outline, obscure: _obscurePwd,
                              suffix: IconButton(icon: Icon(_obscurePwd ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: HabitikColors.textLight, size: 20),
                                onPressed: () => setState(() => _obscurePwd = !_obscurePwd))),
                            const SizedBox(height: 28),

                            PrimaryButton(label: _isLogin ? 'Iniciar sesión' : 'Crear cuenta', onTap: _submit, loading: _loading),
                            const SizedBox(height: 16),

                            if (_isLogin)
                              Center(
                                child: TextButton(
                                  onPressed: () {},
                                  child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(color: HabitikColors.textLight, fontSize: 12)),
                                ),
                              ),

                            const SizedBox(height: 20),

                            // Social divider
                            Row(children: [
                              const Expanded(child: Divider(color: HabitikColors.divider)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text('o continúa con', style: const TextStyle(color: HabitikColors.textHint, fontSize: 11)),
                              ),
                              const Expanded(child: Divider(color: HabitikColors.divider)),
                            ]),

                            const SizedBox(height: 16),

                            Row(children: [
                              Expanded(child: _SocialBtn(label: 'Google', emoji: '🇬', onTap: _submit)),
                              const SizedBox(width: 12),
                              Expanded(child: _SocialBtn(label: 'Apple', emoji: '🍎', onTap: _submit)),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Pantalla de carga inteligente (Bloqueante)
          if (_loading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.6),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1B2A),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 44,
                          height: 44,
                          child: CircularProgressIndicator(
                            strokeWidth: 4.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _loadingMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text, style: const TextStyle(color: HabitikColors.textDark, fontSize: 13, fontWeight: FontWeight.w700));

  Widget _textField(String hint, TextEditingController ctrl, {
    IconData? icon, bool obscure = false, TextInputType? type, Widget? suffix}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: type,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, color: HabitikColors.textLight, size: 20) : null,
        suffixIcon: suffix,
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final String label;
  final String emoji;
  final VoidCallback onTap;
  const _SocialBtn({required this.label, required this.emoji, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: HabitikColors.green50,
          borderRadius: HabitikRadius.md_,
          border: Border.all(color: HabitikColors.divider),
        ),
        alignment: Alignment.center,
        child: Text('$emoji $label', style: const TextStyle(color: HabitikColors.textDark, fontWeight: FontWeight.w700, fontSize: 13)),
      ),
    );
  }
}
