import 'family_colecta.dart';

class RewardItem {
  final int id;
  final String titulo;
  final int costo;
  final String descripcion;
  final String emoji;
  final bool disponible;
  final bool esFamiliar;
  final String estado; // 'activo', 'propuesto', 'rechazado'
  final String? propuestoPor;
  final String? fechaPropuesta;
  final DateTime? createdAt;
  final DateTime? lastRedeemedAt;
  final String? lastRedeemedByNombre;
  final Map<String, dynamic> metadata;
  final FamilyColecta? colectaActiva;

  const RewardItem({
    required this.id,
    required this.titulo,
    required this.costo,
    required this.descripcion,
    this.emoji = '🎁',
    this.disponible = true,
    this.esFamiliar = true,
    this.estado = 'activo',
    this.propuestoPor,
    this.fechaPropuesta,
    this.createdAt,
    this.lastRedeemedAt,
    this.lastRedeemedByNombre,
    this.metadata = const {},
    this.colectaActiva,
  });

  bool get isCooldownActive {
    if (!disponible) return true;
    if (lastRedeemedAt == null) return false;
    final String frecuencia = metadata['frecuencia']?.toString() ?? '';
    final now = DateTime.now();
    if (frecuencia == 'diario') {
      return now.difference(lastRedeemedAt!).inHours < 24;
    } else if (frecuencia == 'semanal') {
      return now.difference(lastRedeemedAt!).inDays < 7;
    } else if (frecuencia == 'mensual') {
      return now.difference(lastRedeemedAt!).inDays < 30;
    } else if (frecuencia == 'unico') {
      return true;
    }
    return false;
  }

  RewardItem copyWith({
    int? id,
    String? titulo,
    int? costo,
    String? descripcion,
    String? emoji,
    bool? disponible,
    bool? esFamiliar,
    String? estado,
    String? propuestoPor,
    String? fechaPropuesta,
    DateTime? createdAt,
    DateTime? lastRedeemedAt,
    String? lastRedeemedByNombre,
    Map<String, dynamic>? metadata,
    FamilyColecta? colectaActiva,
  }) {
    return RewardItem(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      costo: costo ?? this.costo,
      descripcion: descripcion ?? this.descripcion,
      emoji: emoji ?? this.emoji,
      disponible: disponible ?? this.disponible,
      esFamiliar: esFamiliar ?? this.esFamiliar,
      estado: estado ?? this.estado,
      propuestoPor: propuestoPor ?? this.propuestoPor,
      fechaPropuesta: fechaPropuesta ?? this.fechaPropuesta,
      createdAt: createdAt ?? this.createdAt,
      lastRedeemedAt: lastRedeemedAt ?? this.lastRedeemedAt,
      lastRedeemedByNombre: lastRedeemedByNombre ?? this.lastRedeemedByNombre,
      metadata: metadata ?? this.metadata,
      colectaActiva: colectaActiva ?? this.colectaActiva,
    );
  }

  factory RewardItem.fromJson(Map<String, dynamic> json) {
    return RewardItem(
      id: _parseInt(json['id']),
      titulo: json['titulo']?.toString() ?? '',
      costo: _parseInt(json['costo']),
      descripcion: json['descripcion']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '🎁',
      disponible: json['disponible'] != false,
      esFamiliar: json['es_familiar'] == true,
      estado: json['estado']?.toString() ?? 'activo',
      propuestoPor: json['propuesto_por']?.toString(),
      fechaPropuesta: json['fecha_propuesta']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      lastRedeemedAt: json['last_redeemed_at'] != null ? DateTime.tryParse(json['last_redeemed_at'].toString()) : null,
      lastRedeemedByNombre: json['last_redeemed_by_nombre']?.toString(),
      metadata: json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata']) : {},
      colectaActiva: json['colecta_activa'] != null && json['colecta_activa'] is Map
          ? FamilyColecta.fromJson(Map<String, dynamic>.from(json['colecta_activa']))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'costo': costo,
    'descripcion': descripcion,
    'emoji': emoji,
    'disponible': disponible,
    'es_familiar': esFamiliar,
    'estado': estado,
    'propuesto_por': propuestoPor,
    'fecha_propuesta': fechaPropuesta,
    'created_at': createdAt?.toIso8601String(),
    'last_redeemed_at': lastRedeemedAt?.toIso8601String(),
    'last_redeemed_by_nombre': lastRedeemedByNombre,
    'metadata': metadata,
    'colecta_activa': colectaActiva?.toJson(),
  };

  static int _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  static const RewardItem empty = RewardItem(
    id: 0,
    titulo: '',
    costo: 0,
    descripcion: '',
  );
}
