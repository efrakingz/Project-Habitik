class NotificationItem {
  final String id;
  final String titulo;
  final String descripcion;
  final String time;
  final String iconNombre;
  final String colorHex;
  final bool leida;

  const NotificationItem({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.time,
    required this.iconNombre,
    required this.colorHex,
    this.leida = false,
  });

  static List<NotificationItem> get mockList => const [
    NotificationItem(
      id: '1',
      titulo: '✅ Reto Aprobado',
      descripcion: 'Tu evidencia de "Inspección del Día" fue aprobada. +100 XP',
      time: 'Hace 20 min',
      iconNombre: 'check_circle',
      colorHex: '#4CAF50',
    ),
    NotificationItem(
      id: '2',
      titulo: '🆕 Nuevo Miembro',
      descripcion: 'Tomás Torres se unió al hogar',
      time: 'Hace 2h',
      iconNombre: 'person_add',
      colorHex: '#2196F3',
    ),
    NotificationItem(
      id: '3',
      titulo: '⚡ ¡Subiste de Nivel!',
      descripcion: 'Has alcanzado el Nivel 3. ¡Sigue así!',
      time: 'Ayer',
      iconNombre: 'emoji_events',
      colorHex: '#FFD600',
      leida: true,
    ),
    NotificationItem(
      id: '4',
      titulo: '❌ Reto Rechazado',
      descripcion: '"Eco-Puzzle" fue rechazado. Motivo: Foto borrosa.',
      time: 'Hace 3 días',
      iconNombre: 'cancel',
      colorHex: '#E53935',
      leida: true,
    ),
  ];
}
