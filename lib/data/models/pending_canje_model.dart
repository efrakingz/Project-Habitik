class PendingCanje {
  final String id;
  final String rewardId;
  final String userId;
  final int costoPagado;
  final String estado;
  final String createdAt;
  final String usuarioNombre;
  final dynamic usuarioAvatar;
  final String rewardTitulo;
  final String rewardEmoji;

  PendingCanje({
    required this.id,
    required this.rewardId,
    required this.userId,
    required this.costoPagado,
    required this.estado,
    required this.createdAt,
    required this.usuarioNombre,
    this.usuarioAvatar,
    required this.rewardTitulo,
    required this.rewardEmoji,
  });

  factory PendingCanje.fromJson(Map<String, dynamic> json) {
    return PendingCanje(
      id: json['id']?.toString() ?? '',
      rewardId: json['reward_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      costoPagado: json['costo_pagado'] is num
          ? (json['costo_pagado'] as num).toInt()
          : int.tryParse('${json['costo_pagado']}') ?? 0,
      estado: json['estado']?.toString() ?? 'pendiente',
      createdAt: json['created_at']?.toString() ?? '',
      usuarioNombre: json['usuario_nombre']?.toString() ?? 'Integrante',
      usuarioAvatar: json['usuario_avatar'],
      rewardTitulo: json['reward_titulo']?.toString() ?? '',
      rewardEmoji: json['reward_emoji']?.toString() ?? '🎁',
    );
  }
}
