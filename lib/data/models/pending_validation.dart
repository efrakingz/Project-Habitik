class PendingValidation {
  final int id;
  final String userId;
  final String usuario;
  final String avatarLetra;
  final String avatarColor;
  final String reto;
  final String hora;
  final int xp;
  final int monedas;
  final List<String> evidencias;
  final bool requiereEvidencia;

  const PendingValidation({
    required this.id,
    required this.userId,
    required this.usuario,
    required this.avatarLetra,
    required this.avatarColor,
    required this.reto,
    required this.hora,
    required this.xp,
    required this.monedas,
    required this.evidencias,
    required this.requiereEvidencia,
  });

  factory PendingValidation.fromJson(Map<String, dynamic> json) {
    String nombre = 'Usuario';
    String letra = 'U';
    String color = '#43A047';

    if (json['snapshot_usuario'] != null && json['snapshot_usuario'] is Map) {
      final snap = json['snapshot_usuario'] as Map;
      nombre = snap['nombre']?.toString() ?? 'Usuario';
      if (snap['avatar'] is Map) {
        letra = snap['avatar']['letra']?.toString() ?? (nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U');
        color = snap['avatar']['color']?.toString() ?? '#43A047';
      }
    } else {
      nombre = json['usuario'] ?? json['nombre'] ?? 'Usuario';
      letra = json['avatar_letra'] ?? (nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U');
      color = json['avatar_color'] ?? '#43A047';
    }

    List<String> evList = [];
    if (json['evidencias'] != null) {
      if (json['evidencias'] is List) {
        evList = (json['evidencias'] as List).map((e) {
          if (e is Map) {
            return e.values.join(' - ');
          }
          return e.toString();
        }).toList();
      } else if (json['evidencias'] is String) {
        evList = [json['evidencias'].toString()];
      }
    }

    return PendingValidation(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse('${json['id']}') ?? 0,
      userId: json['user_id']?.toString() ?? '',
      usuario: nombre,
      avatarLetra: letra,
      avatarColor: color,
      reto: json['reto'] ?? '',
      hora: json['hora'] ?? 'Recién',
      xp: json['xp'] is num ? (json['xp'] as num).toInt() : int.tryParse('${json['xp']}') ?? 0,
      monedas: json['monedas'] is num ? (json['monedas'] as num).toInt() : int.tryParse('${json['monedas']}') ?? 0,
      evidencias: evList,
      requiereEvidencia: json['requiere_evidencia'] == true,
    );
  }

  static List<PendingValidation> get mockList => [
    PendingValidation(
      id: 1,
      userId: '2',
      usuario: 'Sofía Torres',
      avatarLetra: 'S',
      avatarColor: '#9C27B0',
      reto: 'Inspección del Día',
      hora: 'Hace 30 min',
      xp: 100,
      monedas: 15,
      evidencias: const ['Revisé todas las luces y tomacorrientes del hogar'],
      requiereEvidencia: true,
    ),
    PendingValidation(
      id: 2,
      userId: '3',
      usuario: 'Lucía Torres',
      avatarLetra: 'L',
      avatarColor: '#E91E63',
      reto: 'Speedrun de la Ducha',
      hora: 'Hace 1h',
      xp: 50,
      monedas: 5,
      evidencias: const ['Tiempo: 8:22'],
      requiereEvidencia: false,
    ),
  ];
}
