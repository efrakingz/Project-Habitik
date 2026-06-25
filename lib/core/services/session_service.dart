import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  SharedPreferences? _prefs;
  final ValueNotifier<UserProfile?> currentUserNotifier = ValueNotifier<UserProfile?>(null);

  String? get token => _prefs?.getString('token_jwt');
  UserProfile? get currentUser => currentUserNotifier.value;

  /// Inicializa SharedPreferences y carga la sesión guardada si existe.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await loadSession();
  }

  /// Guarda los datos de sesión en SharedPreferences.
  Future<void> saveSession({
    required String token,
    required UserProfile profile,
  }) async {
    UserProfile enriched = profile;
    // Si el perfil trae familyName, guardarlo en caché por familyId
    if (profile.familyName != null && profile.familyName!.isNotEmpty && profile.familyId != null) {
      await _prefs?.setString('fam_name_${profile.familyId}', profile.familyName!);
    } else if (profile.familyId != null && profile.familyId!.isNotEmpty) {
      // Si falta familyName pero tenemos uno guardado (o usamos un fallback), enriquecer el perfil
      final cachedName = _prefs?.getString('fam_name_${profile.familyId}') ?? 'Hogar Familiar';
      enriched = profile.copyWith(familyName: cachedName);
    }

    if (enriched.onboardingCompleted) {
      await setOnboardingCompleted(true);
    }

    await _prefs?.setString('token_jwt', token);
    await _prefs?.setString('user_profile', jsonEncode(enriched.toJson()));
    currentUserNotifier.value = enriched;
  }

  /// Guarda temporalmente email y contraseña para re-login silencioso al vincular familia.
  Future<void> saveCredentials(String email, String pwd) async {
    await _prefs?.setString('temp_email', email);
    await _prefs?.setString('temp_pwd', pwd);
  }

  /// Lee el email temporal guardado.
  String? get tempEmail => _prefs?.getString('temp_email');

  /// Lee la contraseña temporal guardada.
  String? get tempPwd => _prefs?.getString('temp_pwd');

  /// Carga la sesión desde la memoria local.
  Future<void> loadSession() async {
    final token = _prefs?.getString('token_jwt');
    final profileStr = _prefs?.getString('user_profile');
    if (token != null && profileStr != null) {
      try {
        final profileMap = jsonDecode(profileStr) as Map<String, dynamic>;
        var p = UserProfile.fromJson(profileMap);
        if ((p.familyName == null || p.familyName!.isEmpty) && p.familyId != null) {
          final cachedName = _prefs?.getString('fam_name_${p.familyId}') ?? 'Hogar Familiar';
          p = p.copyWith(familyName: cachedName);
        }
        currentUserNotifier.value = p;
      } catch (e) {
        await clearSession();
      }
    } else {
      currentUserNotifier.value = null;
    }
  }

  /// Elimina los datos de sesión activa (Cerrar Sesión) conservando el caché de preferencias por usuario.
  Future<void> clearSession() async {
    await _prefs?.remove('token_jwt');
    await _prefs?.remove('user_profile');
    await _prefs?.remove('temp_email');
    await _prefs?.remove('temp_pwd');
    currentUserNotifier.value = null;
  }

  /// Retorna verdadero si hay una sesión activa persistida.
  bool get hasSession => token != null && currentUser != null;

  /// Retorna verdadero si el usuario ya completó el onboarding localmente o en la base de datos.
  bool get isOnboardingCompleted {
    final userId = currentUser?.id;
    if (userId == null) return false;
    if (currentUser?.onboardingCompleted == true) return true;
    return _prefs?.getBool('ob_completed_$userId') ?? false;
  }

  /// Guarda el estado de completado del onboarding.
  Future<void> setOnboardingCompleted(bool completed) async {
    final userId = currentUser?.id;
    if (userId != null) {
      await _prefs?.setBool('ob_completed_$userId', completed);
    }
  }

  /// Retorna el rol del usuario para el flujo de onboarding.
  String getOnboardingRole() {
    final userId = currentUser?.id;
    if (userId == null) return 'jefe';
    final dbRol = currentUser?.rol.toLowerCase() ?? '';
    if (dbRol == 'miembro') return 'miembro';
    return _prefs?.getString('ob_role_$userId') ?? 'jefe';
  }

  /// Guarda el rol seleccionado del usuario para el onboarding.
  Future<void> setOnboardingRole(String role) async {
    final userId = currentUser?.id;
    if (userId != null) {
      await _prefs?.setString('ob_role_$userId', role.toLowerCase());
    }
  }
}
