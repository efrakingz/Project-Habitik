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
