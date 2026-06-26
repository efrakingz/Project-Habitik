import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/navigation/app_router.dart';
import 'package:habitik/data/models/models.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';
import 'package:habitik/shared/widgets/avatar/avatar.dart';
import 'package:habitik/shared/widgets/stats/stats.dart';
import 'package:habitik/shared/widgets/buttons/buttons.dart';
import 'package:habitik/shared/widgets/badges/badges.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/core/services/api_client.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserProfile _user;
  List<FamilyMember> _familyMembers = [];
  bool _loadingMembers = true;
  String? _errorMessage;
  bool _generatingInvite = false;

  @override
  void initState() {
    super.initState();
    _user = SessionService().currentUser ?? UserProfile.mock;
    _fetchFamilyMembers();
  }

  Future<void> _fetchFamilyMembers() async {
    if (!mounted) return;
    setState(() {
      _loadingMembers = true;
      _errorMessage = null;
    });

    final familyId = _user.familyId;
    if (familyId == null || familyId.isEmpty) {
      if (mounted) {
        setState(() {
          _familyMembers = [];
          _loadingMembers = false;
        });
      }
      return;
    }

    try {
      final response = await ApiClient().get('/familia/miembros');
      if (!mounted) return;

      final List<dynamic> data = jsonDecode(response.body);
      final List<FamilyMember> members = data.map((json) {
        return FamilyMember.fromJson(json);
      }).toList();

      setState(() {
        _familyMembers = members;
        _loadingMembers = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception:', '').trim();
          _loadingMembers = false;
        });
      }
    }
  }

  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: _user.nombre);
    final letterCtrl = TextEditingController(text: _user.avatarLetra);
    String selectedColor = _user.avatarColor;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final List<String> presetColors = [
              '#43A047', // Verde
              '#2E7D32', // Verde oscuro
              '#9C27B0', // Púrpura
              '#FF5722', // Naranja
              '#2196F3', // Azul
              '#E91E63', // Rosa
              '#FFCA28', // Amarillo
            ];

            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF16251B) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: HabitikRadius.lg_),
              title: Row(
                children: [
                  const Text('👤', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Text(
                    'Editar Perfil',
                    style: TextStyle(
                      color: isDark ? Colors.white : HabitikColors.textDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nombre',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : HabitikColors.textDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Ingresa tu nombre',
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : HabitikColors.textDark,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Inicial del Avatar (Máx. 2 letras)',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : HabitikColors.textDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: letterCtrl,
                      maxLength: 2,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        hintText: 'Ej. S',
                        counterText: '',
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : HabitikColors.textDark,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Color del Avatar',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : HabitikColors.textDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: presetColors.length,
                        itemBuilder: (context, index) {
                          final colorHex = presetColors[index];
                          final color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
                          final isSelected = selectedColor.toUpperCase() == colorHex.toUpperCase();
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedColor = colorHex;
                              });
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? (isDark ? Colors.white : HabitikColors.textDark)
                                      : Colors.transparent,
                                  width: 3.0,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.grey,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newName = nameCtrl.text.trim();
                    final newLetter = letterCtrl.text.trim().toUpperCase();
                    if (newName.isEmpty || newLetter.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor completa todos los campos.'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    final updatedProfile = _user.copyWith(
                      nombre: newName,
                      avatarLetra: newLetter,
                      avatarColor: selectedColor,
                    );

                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);

                    await SessionService().saveSession(
                      token: SessionService().token!,
                      profile: updatedProfile,
                    );

                    if (mounted) {
                      setState(() {
                        _user = updatedProfile;
                      });
                      navigator.pop();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Perfil actualizado exitosamente.'),
                          backgroundColor: HabitikColors.green600,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HabitikColors.green600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: HabitikRadius.sm_),
                  ),
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }



  Future<void> _generateInviteToken() async {
    if (_generatingInvite) return;
    setState(() => _generatingInvite = true);

    try {
      final response = await ApiClient().get('/familia/invite');
      final data = jsonDecode(response.body);
      final String inviteToken = data['invite_token'] ?? '';
      
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF16251B) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: HabitikRadius.lg_),
            title: Row(
              children: [
                const Text('🎟️', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Text(
                  'Invitación Familiar',
                  style: TextStyle(
                    color: isDark ? Colors.white : HabitikColors.textDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Pide a tu familiar que escanee este código QR o ingresa el código manual para unirse a tu hogar.',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : HabitikColors.textLight,
                      fontSize: 12,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  // QR Code Render using qr_flutter
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: HabitikRadius.md_,
                      border: Border.all(color: HabitikColors.green100, width: 2),
                    ),
                    child: QrImageView(
                      data: inviteToken,
                      version: QrVersions.auto,
                      size: 150.0,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.circle,
                        color: Color(0xFF1B5E20),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.circle,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C2C21) : const Color(0xFFEBF7EC),
                      borderRadius: HabitikRadius.md_,
                      border: Border.all(
                        color: isDark ? const Color(0x30FFFFFF) : HabitikColors.green100,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            inviteToken,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : HabitikColors.textDark,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: inviteToken));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Código copiado al portapapeles.'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: HabitikColors.green600,
                              ),
                            );
                          },
                          color: isDark ? HabitikColors.green400 : HabitikColors.green700,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Expira en 10 minutos y es de un solo uso.',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.grey.shade500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cerrar',
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.grey,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  SharePlus.instance.share(
                    ShareParams(
                      text: '¡Únete a mi grupo familiar en Habitik! Usa este código de invitación: $inviteToken',
                    ),
                  );
                },
                icon: const Icon(Icons.share_rounded, size: 16),
                label: const Text('Compartir'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HabitikColors.green600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: HabitikRadius.sm_),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception:', '').trim()),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _generatingInvite = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: HabitikColors.heroGreen),
        child: SafeArea(
          bottom: false,
          child: ScreenShell(
            titulo: 'Mi Perfil',
            subtitulo: '${_user.nombre} · ${_user.rol.toUpperCase()}',
            headerActions: [
              IconActionButton(
                icon: Icons.logout_rounded,
                onTap: () => RootRouter.logout(context),
                bgColor: HabitikColors.orange500,
              ),
            ],
            body: RefreshIndicator(
              onRefresh: _fetchFamilyMembers,
              color: HabitikColors.green600,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Column(
                  children: [
                    // Tarjeta de Identidad de Perfil
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2E22) : Colors.white,
                        borderRadius: HabitikRadius.lg_,
                        border: Border.all(
                          color: isDark ? const Color(0x30FFFFFF) : Colors.grey.shade200,
                          width: 2,
                        ),
                        boxShadow: HabitikShadows.card,
                      ),
                      child: Column(
                        children: [
                          UserAvatar(
                            letra: _user.avatarLetra,
                            colorHex: _user.avatarColor,
                            avatarUrl: _user.avatarUrl,
                            radius: 42,
                            showBorder: true,
                          ).animate().scale(
                                begin: const Offset(0.8, 0.8),
                                duration: 500.ms,
                                curve: Curves.elasticOut,
                              ),
                          const SizedBox(height: 12),
                          Text(
                            _user.nombre,
                            style: TextStyle(
                              color: isDark ? Colors.white : HabitikColors.textDark,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (_user.email != null && _user.email!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              _user.email!,
                              style: TextStyle(
                                color: isDark ? Colors.white70 : HabitikColors.textLight,
                                fontSize: 13,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          RolBadge(_user.rol, fontSize: 11),
                          const SizedBox(height: 16),
                          XpProgressBar(xp: _user.xp, nivel: _user.nivel),
                          if (_user.familyName != null && _user.familyName!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              '🏡 Hogar: ${_user.familyName}',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : HabitikColors.textMid,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                          if (_user.rol.toLowerCase().contains('jefe') || _user.rol.toLowerCase() == 'admin') ...[
                            const SizedBox(height: 16),
                            PrimaryButton(
                              label: _generatingInvite ? 'Generando...' : '🎟️ Invitar Familiar (Generar Código/QR)',
                              loading: _generatingInvite,
                              onTap: _generateInviteToken,
                              gradient: HabitikColors.heroGreen,
                              height: 46,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Gestión de Cuenta
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2E22) : Colors.white,
                        borderRadius: HabitikRadius.lg_,
                        border: Border.all(
                          color: isDark ? const Color(0x30FFFFFF) : Colors.grey.shade200,
                          width: 2,
                        ),
                        boxShadow: HabitikShadows.card,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '⚙️ Gestión de Cuenta',
                            style: TextStyle(
                              color: isDark ? Colors.white : HabitikColors.textDark,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Botón Editar Perfil
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: HabitikColors.green50.withAlpha(isDark ? 20 : 255),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.person_outline_rounded, color: isDark ? HabitikColors.green400 : HabitikColors.green700),
                            ),
                            title: Text(
                              'Editar Perfil',
                              style: TextStyle(
                                color: isDark ? Colors.white : HabitikColors.textDark,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              'Cambia tu nombre, letra y color de avatar',
                              style: TextStyle(
                                color: isDark ? Colors.white60 : HabitikColors.textLight,
                                fontSize: 11,
                              ),
                            ),
                            trailing: Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white54 : Colors.grey),
                            onTap: _showEditProfileDialog,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Ajustes rápidos: Modo Oscuro
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2E22) : Colors.white,
                        borderRadius: HabitikRadius.lg_,
                        border: Border.all(
                          color: isDark ? const Color(0x30FFFFFF) : Colors.grey.shade200,
                          width: 2,
                        ),
                        boxShadow: HabitikShadows.card,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                isDark ? '🌙' : '☀️',
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Tema Oscuro',
                                style: TextStyle(
                                  color: isDark ? Colors.white : HabitikColors.textDark,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: isDarkModeNotifier,
                            builder: (context, isDarkTheme, _) {
                              return Switch(
                                value: isDarkTheme,
                                onChanged: (val) {
                                  isDarkModeNotifier.value = val;
                                },
                                activeThumbColor: HabitikColors.green500,
                                activeTrackColor: HabitikColors.green900,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Encabezado de Miembros del Hogar
                    Row(
                      children: [
                        const Text('👥', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Text(
                          'Miembros del Hogar',
                          style: TextStyle(
                            color: isDark ? Colors.white : HabitikColors.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Listado de Miembros
                    if (_loadingMembers)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                          child: CircularProgressIndicator(color: HabitikColors.green600),
                        ),
                      )
                    else if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2C1E1E) : Colors.red.shade50,
                          borderRadius: HabitikRadius.md_,
                          border: Border.all(
                            color: isDark ? Colors.redAccent.withAlpha(50) : Colors.red.shade200,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Error al cargar miembros: $_errorMessage',
                              style: TextStyle(
                                color: isDark ? Colors.redAccent : Colors.red.shade800,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            SecondaryButton(
                              label: 'Reintentar',
                              onTap: _fetchFamilyMembers,
                              color: Colors.redAccent,
                            ),
                          ],
                        ),
                      )
                    else if (_familyMembers.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2E22) : Colors.white,
                          borderRadius: HabitikRadius.md_,
                          border: Border.all(
                            color: isDark ? const Color(0x30FFFFFF) : Colors.grey.shade200,
                          ),
                        ),
                        child: const Text(
                          'No hay otros miembros en la familia todavía.',
                          style: TextStyle(color: HabitikColors.textLight, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _familyMembers.length,
                        itemBuilder: (context, index) {
                          final member = _familyMembers[index];
                          final maxXP = _familyMembers.fold<int>(
                            1,
                            (prev, elem) => elem.xp > prev ? elem.xp : prev,
                          );
                          return RankingCard(
                            position: index + 1,
                            member: member,
                            maxXp: maxXP,
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
