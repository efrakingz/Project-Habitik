class RewardProposal {
  final int id;
  final String familyId;
  final String titulo;
  final String descripcion;
  final String emoji;
  final bool esFamiliar;
  final String createdAt;
  final String fechaPropuesta;
  final String usuarioId;
  final String usuarioNombre;
  final dynamic usuarioAvatar;
  final int usuarioMonedas;

  const RewardProposal({
    required this.id,
    required this.familyId,
    required this.titulo,
    required this.descripcion,
    this.emoji = '🎁',
    this.esFamiliar = false,
    required this.createdAt,
    required this.fechaPropuesta,
    required this.usuarioId,
    required this.usuarioNombre,
    this.usuarioAvatar,
    this.usuarioMonedas = 0,
  });

  RewardProposal copyWith({
    int? id,
    String? familyId,
    String? titulo,
    String? descripcion,
    String? emoji,
    bool? esFamiliar,
    String? createdAt,
    String? fechaPropuesta,
    String? usuarioId,
    String? usuarioNombre,
    dynamic usuarioAvatar,
    int? usuarioMonedas,
  }) {
    return RewardProposal(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      emoji: emoji ?? this.emoji,
      esFamiliar: esFamiliar ?? this.esFamiliar,
      createdAt: createdAt ?? this.createdAt,
      fechaPropuesta: fechaPropuesta ?? this.fechaPropuesta,
      usuarioId: usuarioId ?? this.usuarioId,
      usuarioNombre: usuarioNombre ?? this.usuarioNombre,
      usuarioAvatar: usuarioAvatar ?? this.usuarioAvatar,
      usuarioMonedas: usuarioMonedas ?? this.usuarioMonedas,
    );
  }

  factory RewardProposal.fromJson(Map<String, dynamic> json) {
    return RewardProposal(
      id: _parseInt(json['id']),
      familyId: json['family_id']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? json['icono']?.toString() ?? '🎁',
      esFamiliar: json['es_familiar'] == true,
      createdAt: json['created_at']?.toString() ?? '',
      fechaPropuesta: json['fecha_propuesta']?.toString() ?? '',
      usuarioId: json['usuario_id']?.toString() ?? '',
      usuarioNombre: json['usuario_nombre']?.toString() ?? 'Familiar',
      usuarioAvatar: json['usuario_avatar'],
      usuarioMonedas: _parseInt(json['usuario_monedas']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'family_id': familyId,
    'titulo': titulo,
    'descripcion': descripcion,
    'emoji': emoji,
    'es_familiar': esFamiliar,
    'created_at': createdAt,
    'fecha_propuesta': fechaPropuesta,
    'usuario_id': usuarioId,
    'usuario_nombre': usuarioNombre,
    'usuario_avatar': usuarioAvatar,
    'usuario_monedas': usuarioMonedas,
  };

  static int _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  static const RewardProposal empty = RewardProposal(
    id: 0,
    familyId: '',
    titulo: '',
    descripcion: '',
    createdAt: '',
    fechaPropuesta: '',
    usuarioId: '',
    usuarioNombre: '',
  );
}
