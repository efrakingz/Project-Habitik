class RewardItem {
  final int id;
  final String titulo;
  final int costo;
  final String descripcion;
  final String emoji;
  final bool disponible;

  const RewardItem({
    required this.id,
    required this.titulo,
    required this.costo,
    required this.descripcion,
    this.emoji = '🎁',
    this.disponible = true,
  });

  static List<RewardItem> get mockList => const [
    RewardItem(
      id: 1,
      titulo: 'Pizza Familiar',
      costo: 50,
      descripcion: 'Una pizza para toda la familia el fin de semana',
      emoji: '🍕',
      disponible: true,
    ),
    RewardItem(
      id: 2,
      titulo: 'Noche de Cine',
      costo: 30,
      descripcion: 'Elige la película del viernes',
      emoji: '🎬',
      disponible: true,
    ),
    RewardItem(
      id: 3,
      titulo: 'Sin Tareas',
      costo: 20,
      descripcion: 'Un día libre sin tareas del hogar',
      emoji: '🛌',
      disponible: false,
    ),
    RewardItem(
      id: 4,
      titulo: 'Helado',
      costo: 10,
      descripcion: 'Un helado de tu sabor favorito',
      emoji: '🍦',
      disponible: true,
    ),
    RewardItem(
      id: 5,
      titulo: 'Videojuegos',
      costo: 15,
      descripcion: '2 horas extra de videojuegos',
      emoji: '🎮',
      disponible: true,
    ),
    RewardItem(
      id: 6,
      titulo: 'Paseo al Parque',
      costo: 25,
      descripcion: 'Paseo familiar al parque',
      emoji: '🏖️',
      disponible: true,
    ),
  ];
}
