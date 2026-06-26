class FamilyMember {
  final String id;
  final String nombre;
  final String rol;
  final int xp;
  final int nivel;
  final String avatarLetra;
  final String avatarColor;
  final String? avatarUrl;

  const FamilyMember({
    this.id = '',
    required this.nombre,
    required this.rol,
    required this.xp,
    required this.nivel,
    required this.avatarLetra,
    required this.avatarColor,
    this.avatarUrl,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      rol: json['rol'] ?? 'miembro',
      xp: json['xp'] ?? 0,
      nivel: json['nivel'] ?? 1,
      avatarLetra: json['avatar_letra'] ?? 'U',
      avatarColor: json['avatar_color'] ?? '#43A047',
      avatarUrl: json['avatar_url'],
    );
  }

  static List<FamilyMember> get mockList => const [
    FamilyMember(
      id: '1',
      nombre: 'Carlos Torres',
      rol: 'jefe',
      xp: 820,
      nivel: 5,
      avatarLetra: 'C',
      avatarColor: '#2E7D32',
    ),
    FamilyMember(
      id: '2',
      nombre: 'Sofía Torres',
      rol: 'jefa',
      xp: 350,
      nivel: 3,
      avatarLetra: 'S',
      avatarColor: '#9C27B0',
    ),
    FamilyMember(
      id: '3',
      nombre: 'Lucía Torres',
      rol: 'hija',
      xp: 210,
      nivel: 2,
      avatarLetra: 'L',
      avatarColor: '#E91E63',
    ),
    FamilyMember(
      id: '4',
      nombre: 'Tomás Torres',
      rol: 'hijo',
      xp: 95,
      nivel: 1,
      avatarLetra: 'T',
      avatarColor: '#FF5722',
    ),
  ];
}
