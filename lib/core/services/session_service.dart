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
    await _prefs?.setString('token_jwt', token);
    await _prefs?.setString('user_profile', jsonEncode(profile.toJson()));
    currentUserNotifier.value = profile;
  }

  /// Carga la sesión desde la memoria local.
  Future<void> loadSession() async {
    final token = _prefs?.getString('token_jwt');
    final profileStr = _prefs?.getString('user_profile');
    if (token != null && profileStr != null) {
      try {
        final profileMap = jsonDecode(profileStr) as Map<String, dynamic>;
        currentUserNotifier.value = UserProfile.fromJson(profileMap);
      } catch (e) {
        await clearSession();
      }
    } else {
      currentUserNotifier.value = null;
    }
  }

  /// Elimina los datos de sesión (Cerrar Sesión).
  Future<void> clearSession() async {
    await _prefs?.remove('token_jwt');
    await _prefs?.remove('user_profile');
    currentUserNotifier.value = null;
  }

  /// Retorna verdadero si hay una sesión activa persistida.
  bool get hasSession => token != null && currentUser != null;

  /// Retorna verdadero si el usuario ya completó el onboarding localmente.
  bool get isOnboardingCompleted {
    final userId = currentUser?.id;
    if (userId == null) return false;
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
