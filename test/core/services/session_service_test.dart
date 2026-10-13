import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitik/core/services/session_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SessionService Unit Tests', () {
    late SessionService sessionService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      sessionService = SessionService();
    });

    test('isTokenExpired retorna true para token nulo o vacío', () {
      expect(sessionService.isTokenExpired(null), isTrue);
      expect(sessionService.isTokenExpired(''), isTrue);
    });

    test('isTokenExpired retorna true para token malformado', () {
      expect(sessionService.isTokenExpired('token_invalido_sin_puntos'), isTrue);
    });

    test('isTokenExpired detecta correctamente un token expirado', () {
      final header = base64Url.encode(utf8.encode(jsonEncode({'alg': 'HS256', 'typ': 'JWT'})));
      final pastExp = DateTime.now().subtract(const Duration(hours: 2)).millisecondsSinceEpoch ~/ 1000;
      final payload = base64Url.encode(utf8.encode(jsonEncode({'exp': pastExp, 'userId': 'u1'})));
      final token = '$header.$payload.signature';

      expect(sessionService.isTokenExpired(token), isTrue);
    });

    test('isTokenExpired detecta correctamente un token válido vigente', () {
      final header = base64Url.encode(utf8.encode(jsonEncode({'alg': 'HS256', 'typ': 'JWT'})));
      final futureExp = DateTime.now().add(const Duration(hours: 12)).millisecondsSinceEpoch ~/ 1000;
      final payload = base64Url.encode(utf8.encode(jsonEncode({'exp': futureExp, 'userId': 'u1'})));
      final token = '$header.$payload.signature';

      expect(sessionService.isTokenExpired(token), isFalse);
    });

    test('saveLastEmail persiste el correo y elimina claves inseguras legadas', () async {
      SharedPreferences.setMockInitialValues({
        'temp_pwd': 'insecure_password_123',
        'temp_email': 'old@test.com',
      });
      await sessionService.init();

      await sessionService.saveLastEmail('nuevo@test.com');

      expect(sessionService.lastEmail, equals('nuevo@test.com'));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('temp_pwd'), isNull);
      expect(prefs.getString('temp_email'), isNull);
    });
  });
}
