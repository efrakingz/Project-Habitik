import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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
  /// Compatible tanto con parámetros directos como con los de la guía técnica.
  Future<InspeccionEvidencia> enviarEvidencia({
    required String tituloMision,
    File? foto,
    File? fotoComprimida,
    String? baseUrl,
    String? tokenJwt,
  }) async {
    final file = fotoComprimida ?? foto;
    if (file == null) {
      throw ArgumentError('Se requiere un archivo de imagen (foto o fotoComprimida).');
    }

    final activeBaseUrl = baseUrl ?? ApiClient.baseUrl;
    final activeToken = tokenJwt ?? _sessionService.token;
    final uri = Uri.parse('$activeBaseUrl/reto/inspeccion/evidencia');
    final request = http.MultipartRequest('POST', uri);

    if (activeToken != null && activeToken.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $activeToken';
    }

    request.fields['titulo_mision'] = tituloMision;

    // Detectar formato para que Multer lo reconozca como mimetype image/*
    final extension = file.path.split('.').last.toLowerCase();
    MediaType mediaType;
    if (extension == 'png') {
      mediaType = MediaType('image', 'png');
    } else if (extension == 'webp') {
      mediaType = MediaType('image', 'webp');
    } else {
      mediaType = MediaType('image', 'jpeg');
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'foto',
        file.path,
        contentType: mediaType,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      body = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300 && body is Map && body['ok'] == true) {
      return InspeccionEvidencia.fromJson(body['data'] as Map<String, dynamic>);
    } else {
      final errorMsg = body is Map
          ? (body['error'] ?? body['message'])
          : null;
      throw Exception(errorMsg ?? 'Error al registrar la evidencia (${response.statusCode}).');
    }
  }

  /// 4. Listar evidencias pendientes en formato `List<dynamic>` (contrato de la guía)
  Future<List<dynamic>> listarPendientes({
    String? baseUrl,
    String? tokenJwt,
  }) async {
    final activeBaseUrl = baseUrl ?? ApiClient.baseUrl;
    final activeToken = tokenJwt ?? _sessionService.token;
    final uri = Uri.parse('$activeBaseUrl/reto/inspeccion/pendientes');

    final response = await http.get(
      uri,
      headers: {
        if (activeToken != null && activeToken.isNotEmpty)
          'Authorization': 'Bearer $activeToken',
      },
    );

    final dynamic data = jsonDecode(response.body);
    if (response.statusCode == 200 && data is Map && data['ok'] == true && data['data'] is List) {
      return data['data'] as List<dynamic>;
    } else {
      final errorMsg = data is Map ? data['error'] : null;
      throw Exception(errorMsg ?? 'Error al obtener inspecciones pendientes.');
    }
  }

  /// 5. Listar evidencias pendientes tipadas de la familia (Exclusivo Jefe de Hogar)
  Future<List<InspeccionEvidencia>> obtenerPendientes({
    String? baseUrl,
    String? tokenJwt,
  }) async {
    try {
      final list = await listarPendientes(baseUrl: baseUrl, tokenJwt: tokenJwt);
      return list
          .map((json) => InspeccionEvidencia.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('⚠️ [InspeccionService] Error al obtener pendientes: $e');
      return [];
    }
  }

  /// 6. Aprobar evidencia fotográfica (Exclusivo Jefe de Hogar)
  Future<AprobarEvidenciaResult> aprobarEvidencia(
    String evidenciaId, {
    String? baseUrl,
    String? tokenJwt,
  }) async {
    final activeBaseUrl = baseUrl ?? ApiClient.baseUrl;
    final activeToken = tokenJwt ?? _sessionService.token;

    final uri = Uri.parse('$activeBaseUrl/reto/inspeccion/aprobar');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (activeToken != null && activeToken.isNotEmpty)
          'Authorization': 'Bearer $activeToken',
      },
      body: jsonEncode({'evidencia_id': evidenciaId}),
    );

    final dynamic body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300 && body is Map && body['ok'] == true) {
      return AprobarEvidenciaResult.fromJson(body as Map<String, dynamic>);
    } else {
      final errorMsg = body is Map ? (body['error'] ?? body['message']) : null;
      throw Exception(errorMsg ?? 'Error al aprobar la evidencia.');
    }
  }

  /// 7. Rechazar evidencia fotográfica con motivo (Exclusivo Jefe de Hogar)
  Future<bool> rechazarEvidencia(
    String evidenciaId,
    String motivo, {
    String? baseUrl,
    String? tokenJwt,
  }) async {
    final activeBaseUrl = baseUrl ?? ApiClient.baseUrl;
    final activeToken = tokenJwt ?? _sessionService.token;

    final uri = Uri.parse('$activeBaseUrl/reto/inspeccion/rechazar');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (activeToken != null && activeToken.isNotEmpty)
          'Authorization': 'Bearer $activeToken',
      },
      body: jsonEncode({
        'evidencia_id': evidenciaId,
        'motivo': motivo,
      }),
    );

    final dynamic body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300 && body is Map && body['ok'] == true) {
      return true;
    } else {
      final errorMsg = body is Map ? (body['error'] ?? body['message']) : null;
      throw Exception(errorMsg ?? 'Error al rechazar la evidencia.');
    }
  }
}
