import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../data/models/inspeccion_evidencia.dart';
import 'api_client.dart';
import 'session_service.dart';

/// Servicio Singleton para el reto HU 2.2 — Misión Fotográfica de Inspección
/// (Cazador de Sombras) y Panel de Moderación del Jefe de Hogar.
class InspeccionService {
  static final InspeccionService _instance = InspeccionService._internal();
  factory InspeccionService() => _instance;
  InspeccionService._internal();

  final ImagePicker _picker = ImagePicker();
  final ApiClient _apiClient = ApiClient();
  final SessionService _sessionService = SessionService();

  /// 1. Seleccionar foto desde cámara o galería
  Future<File?> capturarFoto(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      debugPrint('⚠️ [InspeccionService] Error al capturar foto: $e');
      return null;
    }
  }

  /// 2. Comprimir la imagen en el cliente (< 500 KB, máx 1080x1080, calidad 65%)
  Future<File?> comprimirImagen(File archivoOriginal) async {
    try {
      final String pathOriginal = archivoOriginal.absolute.path;
      final String targetPath = '${pathOriginal}_compressed.jpg';

      final XFile? resultado = await FlutterImageCompress.compressAndGetFile(
        pathOriginal,
        targetPath,
        quality: 65,
        minWidth: 1080,
        minHeight: 1080,
      );

      if (resultado != null) {
        return File(resultado.path);
      }
      return archivoOriginal;
    } catch (e) {
      debugPrint('⚠️ [InspeccionService] Falló compresión de imagen, usando original: $e');
      return archivoOriginal;
    }
  }

  /// 3. Subir evidencia comprimida mediante multipart/form-data
  Future<InspeccionEvidencia> enviarEvidencia({
    required String tituloMision,
    required File foto,
  }) async {
    final uri = Uri.parse('${ApiClient.baseUrl}/reto/inspeccion/evidencia');
    final request = http.MultipartRequest('POST', uri);

    final token = _sessionService.token;
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['titulo_mision'] = tituloMision;
    request.files.add(await http.MultipartFile.fromPath('foto', foto.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final dynamic body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300 && body['ok'] == true) {
      return InspeccionEvidencia.fromJson(body['data'] as Map<String, dynamic>);
    } else {
      throw Exception(body['error'] ?? 'Error al subir evidencia al servidor.');
    }
  }

  /// 4. Listar evidencias pendientes de la familia (Exclusivo Jefe de Hogar)
  Future<List<InspeccionEvidencia>> obtenerPendientes() async {
    final response = await _apiClient.get('/reto/inspeccion/pendientes');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic body = jsonDecode(response.body);
      if (body['ok'] == true && body['data'] is List) {
        return (body['data'] as List)
            .map((json) => InspeccionEvidencia.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  /// 5. Aprobar evidencia fotográfica (Exclusivo Jefe de Hogar)
  Future<AprobarEvidenciaResult> aprobarEvidencia(String evidenciaId) async {
    final response = await _apiClient.post(
      '/reto/inspeccion/aprobar',
      {'evidencia_id': evidenciaId},
    );

    final dynamic body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300 && body['ok'] == true) {
      return AprobarEvidenciaResult.fromJson(body);
    } else {
      throw Exception(body['error'] ?? 'Error al aprobar la evidencia.');
    }
  }

  /// 6. Rechazar evidencia fotográfica con motivo (Exclusivo Jefe de Hogar)
  Future<bool> rechazarEvidencia(String evidenciaId, String motivo) async {
    final response = await _apiClient.post(
      '/reto/inspeccion/rechazar',
      {
        'evidencia_id': evidenciaId,
        'motivo': motivo,
      },
    );

    final dynamic body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300 && body['ok'] == true) {
      return true;
    } else {
      throw Exception(body['error'] ?? 'Error al rechazar la evidencia.');
    }
  }
}
