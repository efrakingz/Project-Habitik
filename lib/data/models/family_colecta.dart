class ColectaAporte {
  final String userId;
  final String nombre;
  final Map<String, dynamic> avatar;
  final int montoAsignado;
  final int montoPagado;
  final bool pagado;

  const ColectaAporte({
    required this.userId,
    required this.nombre,
    this.avatar = const {},
    required this.montoAsignado,
    required this.montoPagado,
    required this.pagado,
  });

  factory ColectaAporte.fromJson(Map<String, dynamic> json) {
    return ColectaAporte(
      userId: json['user_id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? 'Familiar',
      avatar: json['avatar'] is Map ? Map<String, dynamic>.from(json['avatar']) : {},
      montoAsignado: _parseInt(json['monto_asignado']),
      montoPagado: _parseInt(json['monto_pagado']),
      pagado: json['pagado'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'nombre': nombre,
    'avatar': avatar,
    'monto_asignado': montoAsignado,
    'monto_pagado': montoPagado,
    'pagado': pagado,
  };

  static int _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }
}

class FamilyColecta {
  final String canjeId;
  final int rewardId;
  final int totalRequerido;
  final int totalRecaudado;
  final String estado;
  final List<ColectaAporte> aportes;

  const FamilyColecta({
    required this.canjeId,
    required this.rewardId,
    required this.totalRequerido,
    required this.totalRecaudado,
    required this.estado,
    required this.aportes,
  });

  double get progreso => totalRequerido > 0 
      ? (totalRecaudado / totalRequerido).clamp(0.0, 1.0) 
      : 0.0;

  bool get estaCompletada => totalRecaudado >= totalRequerido && totalRequerido > 0;

  ColectaAporte? miAporte(String myUserId) {
    try {
      return aportes.firstWhere((a) => a.userId == myUserId);
    } catch (_) {
      return null;
    }
  }

  factory FamilyColecta.fromJson(Map<String, dynamic> json) {
    final list = json['aportes'];
    return FamilyColecta(
      canjeId: json['canje_id']?.toString() ?? '',
      rewardId: _parseInt(json['reward_id']),
      totalRequerido: _parseInt(json['total_requerido']),
      totalRecaudado: _parseInt(json['total_recaudado']),
      estado: json['estado']?.toString() ?? 'recaudando',
      aportes: list is List
          ? list.map((e) => ColectaAporte.fromJson(Map<String, dynamic>.from(e as Map))).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'canje_id': canjeId,
    'reward_id': rewardId,
    'total_requerido': totalRequerido,
    'total_recaudado': totalRecaudado,
    'estado': estado,
    'aportes': aportes.map((a) => a.toJson()).toList(),
  };

  static int _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  static const FamilyColecta empty = FamilyColecta(
    canjeId: '',
    rewardId: 0,
    totalRequerido: 0,
    totalRecaudado: 0,
    estado: 'recaudando',
    aportes: [],
  );
}
