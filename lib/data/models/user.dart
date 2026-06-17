class UserProfile {
  final String id;
  final String nombre;
  final String avatarLetra;
  final String avatarColor;
  final String? avatarUrl;
  final String rol;
  final String? familyId;
  final int xp;
  final int nivel;
  final int monedas;
  final String? familyName;

  const UserProfile({
    this.id = '',
    required this.nombre,
    this.avatarLetra = 'U',
    this.avatarColor = '#43A047',
    this.avatarUrl,
    this.rol = 'miembro',
    this.familyId,
    this.xp = 0,
    this.nivel = 1,
    this.monedas = 0,
    this.familyName,
  });

  static UserProfile get mock => const UserProfile(
    id: 'mock-user-1',
    nombre: 'Sofía Torres',
    avatarLetra: 'S',
    avatarColor: '#9C27B0',
    rol: 'jefa',
    familyId: 'mock-family',
    xp: 350,
    nivel: 3,
    monedas: 42,
    familyName: 'Familia Torres',
  );

  static UserProfile get mockJefe => const UserProfile(
    id: 'mock-jefe',
    nombre: 'Carlos Torres',
    avatarLetra: 'C',
    avatarColor: '#2E7D32',
    rol: 'jefe',
    familyId: 'mock-family',
    xp: 820,
    nivel: 5,
    monedas: 80,
    familyName: 'Familia Torres',
  );
}
