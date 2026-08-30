import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../data/models/user.dart';
import 'api_client.dart';
import 'background_service.dart';
import 'notification_service.dart';
import 'socket_service.dart';

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
      final cachedName = _prefs?.getString('fam_name_${profile.familyId}') ?? 'Hogar Familiar';
      enriched = profile.copyWith(familyName: cachedName);
    }

    if (enriched.onboardingCompleted) {
      await setOnboardingCompleted(true);
    }

    await _prefs?.setString('token_jwt', token);
    await _prefs?.setString('user_profile', jsonEncode(enriched.toJson()));
    currentUserNotifier.value = enriched;

    // Conectar a la sala familiar de notificaciones en tiempo real y persistir en background
    if (enriched.familyId != null && enriched.familyId!.isNotEmpty) {
      await _prefs?.setString('bg_family_id', enriched.familyId!);
      await _prefs?.setString('bg_user_id', enriched.id);
      await _prefs?.setString('bg_backend_url', ApiClient.baseUrl);

      await BackgroundServiceManager.conectarFamilia(
        enriched.familyId!,
        userId: enriched.id,
        backendUrl: ApiClient.baseUrl,
      );
      SocketService.initSocket(enriched.familyId!, (data) async {
        debugPrint('🔔 [SessionService] Notificación recibida para la familia: ${data['titulo']}');
        try {
          final String notifKey = '${data['id'] ?? data['titulo']}_${data['tipo'] ?? 'ALERTA'}';
          final int notifId = notifKey.hashCode.abs() % 100000;
          final String sender = data['usuario_nombre'] ?? data['sender_name'] ?? 'Familiar';
          final String titulo = '${data['titulo'] ?? data['title'] ?? 'Alerta Familiar'}';
          final String cuerpo = '${data['mensaje'] ?? data['desc_text'] ?? 'Nueva notificación'}';

          await NotificationService.mostrarNotificacionSistema(
            id: notifId,
            titulo: '$sender: $titulo',
            cuerpo: cuerpo,
            tipo: data['tipo'],
            deduplicationKey: notifKey,
            payload: jsonEncode(data),
          );
        } catch (e) {
          debugPrint('⚠️ Error mostrando notificación en primer plano: $e');
        }
      });
    }
  }

  /// Guarda temporalmente email y contraseña para re-login silencioso de fondo.
  Future<void> saveCredentials(String email, String pwd) async {
    await _prefs?.setString('temp_email', email);
    await _prefs?.setString('temp_pwd', pwd);
  }

  String? get tempEmail => _prefs?.getString('temp_email');
  String? get tempPwd => _prefs?.getString('temp_pwd');

  /// Evalúa si el token JWT ya expiró o expira en los próximos 2 minutos
  bool isTokenExpired(String? jwtToken) {
    if (jwtToken == null || jwtToken.isEmpty) return true;
    try {
      final parts = jwtToken.split('.');
      if (parts.length != 3) return true;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final payloadMap = jsonDecode(resp);
      if (payloadMap is Map && payloadMap.containsKey('exp')) {
        final expSec = payloadMap['exp'] as int;
        final expDate = DateTime.fromMillisecondsSinceEpoch(expSec * 1000);
        // Margen de gracia de 2 minutos
        return DateTime.now().add(const Duration(minutes: 2)).isAfter(expDate);
      }
    } catch (_) {
      return false;
    }
    return false;
  }

  /// Ejecuta un inicio de sesión silencioso en segundo plano con las credenciales guardadas
  Future<bool> silentRelogin() async {
    final email = tempEmail;
    final pwd = tempPwd;
    if (email == null || email.isEmpty || pwd == null || pwd.isEmpty) {
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiClient.baseUrl}/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': pwd,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final newToken = data['token_jwt'];
        final newProfile = UserProfile.fromJson(data['profile']);
        await saveSession(token: newToken, profile: newProfile);
        return true;
      }
    } catch (e) {
      debugPrint("Re-login silencioso no completado: $e");
    }
    return false;
  }

  /// Carga la sesión desde la memoria local con renovación preventiva.
  Future<void> loadSession() async {
    final tokenStr = _prefs?.getString('token_jwt');
    final profileStr = _prefs?.getString('user_profile');

    if (tokenStr != null && profileStr != null) {
      try {
        final profileMap = jsonDecode(profileStr) as Map<String, dynamic>;
        var p = UserProfile.fromJson(profileMap);
        if ((p.familyName == null || p.familyName!.isEmpty) && p.familyId != null) {
          final cachedName = _prefs?.getString('fam_name_${p.familyId}') ?? 'Hogar Familiar';
          p = p.copyWith(familyName: cachedName);
        }

        // Si el token expiró o está por vencer, intentar re-login silencioso de fondo
        if (isTokenExpired(tokenStr)) {
          final refreshed = await silentRelogin();
          if (!refreshed) {
            // Si no hay red, mantener el perfil para modo offline sin desloguear
            currentUserNotifier.value = p;
          }
        } else {
          currentUserNotifier.value = p;
        }

        // Conectar a la sala familiar si existe sesión válida
        if (p.familyId != null && p.familyId!.isNotEmpty) {
          await _prefs?.setString('bg_family_id', p.familyId!);
          await _prefs?.setString('bg_user_id', p.id);
          await _prefs?.setString('bg_backend_url', ApiClient.baseUrl);

          await BackgroundServiceManager.conectarFamilia(
            p.familyId!,
            userId: p.id,
            backendUrl: ApiClient.baseUrl,
          );
          SocketService.initSocket(p.familyId!, (data) async {
            debugPrint('🔔 [SessionService] Notificación recibida para la familia: ${data['titulo']}');
            try {
              final String notifKey = '${data['id'] ?? data['titulo']}_${data['tipo'] ?? 'ALERTA'}';
              final int notifId = notifKey.hashCode.abs() % 100000;
              final String sender = data['usuario_nombre'] ?? data['sender_name'] ?? 'Familiar';
              final String titulo = '${data['titulo'] ?? data['title'] ?? 'Alerta Familiar'}';
              final String cuerpo = '${data['mensaje'] ?? data['desc_text'] ?? 'Nueva notificación'}';

              await NotificationService.mostrarNotificacionSistema(
                id: notifId,
                titulo: '$sender: $titulo',
                cuerpo: cuerpo,
                tipo: data['tipo'],
                deduplicationKey: notifKey,
                payload: jsonEncode(data),
              );
            } catch (e) {
              debugPrint('⚠️ Error mostrando notificación en primer plano: $e');
            }
          });
        }
      } catch (e) {
        final refreshed = await silentRelogin();
        if (!refreshed) {
          await clearSession();
        }
      }
    } else {
      currentUserNotifier.value = null;
    }
  }

  /// Elimina los datos de sesión activa preservando preferencias de hardware
  Future<void> clearSession() async {
    SocketService.disconnect();
    await BackgroundServiceManager.detenerServicio();
    await _prefs?.remove('token_jwt');
    await _prefs?.remove('user_profile');
    await _prefs?.remove('temp_email');
    await _prefs?.remove('temp_pwd');
    await _prefs?.remove('bg_family_id');
    await _prefs?.remove('bg_user_id');
    currentUserNotifier.value = null;
  }

  /// Retorna verdadero si hay una sesión activa en memoria
  bool get hasSession => currentUser != null;

  /// Retorna verdadero si el onboarding está completado
  bool get isOnboardingCompleted {
    final userId = currentUser?.id;
    if (userId == null) return false;
    if (currentUser?.onboardingCompleted == true) return true;
    return _prefs?.getBool('ob_completed_$userId') ?? false;
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    final userId = currentUser?.id;
    if (userId != null) {
      await _prefs?.setBool('ob_completed_$userId', completed);
    }
  }

  String getOnboardingRole() {
    final userId = currentUser?.id;
    if (userId == null) return 'jefe';
    final dbRol = currentUser?.rol.toLowerCase() ?? '';
    if (dbRol == 'miembro') return 'miembro';
    return _prefs?.getString('ob_role_$userId') ?? 'jefe';
  }

  Future<void> updateRewardsAndXp({
    int? xp,
    int? monedas,
    int? nivel,
  }) async {
    final current = currentUser;
    if (current == null) return;
    final updated = current.copyWith(
      xp: xp ?? current.xp,
      monedas: monedas ?? current.monedas,
      nivel: nivel ?? current.nivel,
    );
    await _prefs?.setString('user_profile', jsonEncode(updated.toJson()));
    currentUserNotifier.value = updated;
  }

  Future<void> setOnboardingRole(String role) async {
    final userId = currentUser?.id;
    if (userId != null) {
      await _prefs?.setString('ob_role_$userId', role.toLowerCase());
    }
  }
}
