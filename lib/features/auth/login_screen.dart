import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitik/core/theme/theme.dart';
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
  final _emailCtrl = TextEditingController(text: 'admin@habitik.com');
  final _pwdCtrl   = TextEditingController(text: 'admin123');
  final _nameCtrl  = TextEditingController(text: 'Admin');

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    setState(() => _loading = true);
    await Future.delayed(1200.ms); // simulate auth
    if (mounted) { setState(() => _loading = false); widget.onLogin(); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
