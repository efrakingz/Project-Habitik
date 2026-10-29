/// Modelo de Evidencia de Inspección Fotográfica (HU 2.2 - Cazador de Sombras).
class InspeccionEvidencia {
  final String id;
  final String? familyId;
  final String userId;
  final String tituloMision;
  final String fotoUrl;
  final String estado;
  final DateTime? createdAt;
  final String? usuarioNombre;
  final String? usuarioAvatar;

  const InspeccionEvidencia({
    required this.id,
    this.familyId,
    required this.userId,
    required this.tituloMision,
    required this.fotoUrl,
    this.estado = 'pendiente',
    this.createdAt,
    this.usuarioNombre,
    this.usuarioAvatar,
  });

  factory InspeccionEvidencia.fromJson(Map<String, dynamic> json) {
    DateTime? fecha;
    if (json['created_at'] != null) {
      fecha = DateTime.tryParse(json['created_at'].toString());
    }

    String url = json['foto_url']?.toString() ?? '';
    // Asegurar HTTPS en servidores remotos para evitar bloqueos de cleartext en Android
    if (url.startsWith('http://') &&
        !url.contains('localhost') &&
        !url.contains('10.0.2.2') &&
        !url.contains('192.168.')) {
      url = url.replaceFirst('http://', 'https://');
    }

    return InspeccionEvidencia(
      id: json['id']?.toString() ?? '',
      familyId: json['family_id']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      tituloMision: json['titulo_mision']?.toString() ?? 'Inspección del Hogar',
      fotoUrl: url,
      estado: json['estado']?.toString() ?? 'pendiente',
      createdAt: fecha,
      usuarioNombre: json['usuario_nombre']?.toString() ?? 'Familiar',
      usuarioAvatar: json['usuario_avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (familyId != null) 'family_id': familyId,
      'user_id': userId,
      'titulo_mision': tituloMision,
      'foto_url': fotoUrl,
      'estado': estado,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (usuarioNombre != null) 'usuario_nombre': usuarioNombre,
      if (usuarioAvatar != null) 'usuario_avatar': usuarioAvatar,
    };
  }
}

/// Resultado de la aprobación de una evidencia por el Jefe de Hogar
class AprobarEvidenciaResult {
  final bool exito;
  final String mensaje;
  final int xpGanada;
  final int monedasGanadas;
  final int? nuevoSaldoMonedas;
  final int? totalXp;
  final Map<String, dynamic> data;

  const AprobarEvidenciaResult({
    required this.exito,
    required this.mensaje,
    this.xpGanada = 80,
    this.monedasGanadas = 4,
    this.nuevoSaldoMonedas,
    this.totalXp,
    this.data = const {},
  });

  factory AprobarEvidenciaResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;
    final recomp = data['recompensas'] is Map ? data['recompensas'] as Map<String, dynamic> : <String, dynamic>{};

    return AprobarEvidenciaResult(
      exito: data['exito'] == true || json['ok'] == true,
      mensaje: data['mensaje']?.toString() ?? 'Evidencia aprobada con éxito.',
      xpGanada: recomp['xp_ganada'] is num ? (recomp['xp_ganada'] as num).toInt() : 80,
      monedasGanadas: recomp['monedas_ganadas'] is num ? (recomp['monedas_ganadas'] as num).toInt() : 4,
      nuevoSaldoMonedas: recomp['nuevo_saldo_monedas'] is num ? (recomp['nuevo_saldo_monedas'] as num).toInt() : null,
      totalXp: recomp['total_xp'] is num ? (recomp['total_xp'] as num).toInt() : null,
      data: data,
    );
  }

  dynamic operator [](String key) => data[key];
}
