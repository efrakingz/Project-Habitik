/// Modelo para la Barra de Energía Colectiva Familiar (CA-4.1-1)
class FamilyEnergyModel {
  final int totalXpMes;
  final int metaMensualXp;
  final String periodo;

  const FamilyEnergyModel({
    required this.totalXpMes,
    this.metaMensualXp = 5000,
    this.periodo = 'Mes en curso',
  });

  /// Progreso porcentual calculado:
  /// (Suma XP de todos los miembros en el mes / Meta mensual del hogar) * 100
  double get porcentaje {
    if (metaMensualXp <= 0) return 0.0;
    final val = (totalXpMes / metaMensualXp) * 100.0;
    return val.clamp(0.0, 100.0);
  }

  /// Factor entre 0.0 y 1.0 para barras de progreso
  double get progresoFactor => (porcentaje / 100.0).clamp(0.0, 1.0);

  /// Faltante para completar la meta del hogar
  int get xpRestante => (metaMensualXp - totalXpMes).clamp(0, metaMensualXp);

  /// Indica si la familia ya completó la meta del mes
  bool get metaAlcanzada => totalXpMes >= metaMensualXp;

  factory FamilyEnergyModel.fromJson(Map<String, dynamic> json) {
    return FamilyEnergyModel(
      totalXpMes: json['total_xp_mes'] is num
          ? (json['total_xp_mes'] as num).toInt()
          : int.tryParse('${json['total_xp_mes']}') ?? 0,
      metaMensualXp: json['meta_mensual_xp'] is num
          ? (json['meta_mensual_xp'] as num).toInt()
          : int.tryParse('${json['meta_mensual_xp']}') ?? 5000,
      periodo: json['periodo']?.toString() ?? 'Mes en curso',
    );
  }

  Map<String, dynamic> toJson() => {
    'total_xp_mes': totalXpMes,
    'meta_mensual_xp': metaMensualXp,
    'periodo': periodo,
  };

  /// Datos iniciales mock para pruebas y visualización reactiva
  static const FamilyEnergyModel mockDefault = FamilyEnergyModel(
    totalXpMes: 3450,
    metaMensualXp: 5000,
    periodo: 'Octubre',
  );
}
