class EcoWordleStatus {
  final String? sesionId;
  final int largoPalabra;
  final List<String> intentosRealizados;
  final String estado; // 'en_proceso', 'ganado', 'perdido'
  final bool pistaRevelada;
  final String? pistaEducativa;
  final String? palabraCorrecta;
  final bool completadoHoy;
  final int partidasCompletadasHoy;

  const EcoWordleStatus({
    this.sesionId,
    required this.largoPalabra,
    required this.intentosRealizados,
    required this.estado,
    required this.pistaRevelada,
    this.pistaEducativa,
    this.palabraCorrecta,
    this.completadoHoy = false,
    this.partidasCompletadasHoy = 0,
  });

  static int _parseInt(dynamic val, {int fallback = 0}) {
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? fallback;
    return fallback;
  }

  factory EcoWordleStatus.fromJson(Map<String, dynamic> json) {
    return EcoWordleStatus(
      sesionId: json['sesion_id']?.toString(),
      largoPalabra: _parseInt(json['largo_palabra'], fallback: 5),
      intentosRealizados: List<String>.from(json['intentos_realizados'] ?? []),
      estado: json['estado'] ?? 'en_proceso',
      pistaRevelada: json['pista_revelada'] ?? false,
      pistaEducativa: json['pista_educativa'],
      palabraCorrecta: json['palabra_correcta'] ?? json['palabra'] ?? json['palabra_secreta'] ?? json['solucion'],
      completadoHoy: json['completado_hoy'] == true,
      partidasCompletadasHoy: _parseInt(json['partidas_completadas_hoy']),
    );
  }
}

class EcoWordleEvaluationLetter {
  final String letra;
  final String estado; // 'verde', 'amarillo', 'gris'

  const EcoWordleEvaluationLetter({
    required this.letra,
    required this.estado,
  });

  factory EcoWordleEvaluationLetter.fromJson(Map<String, dynamic> json) {
    return EcoWordleEvaluationLetter(
      letra: json['letra'] ?? '',
      estado: json['estado'] ?? 'gris',
    );
  }
}

class EcoWordleAttemptResult {
  final String? sesionId;
  final bool success;
  final List<EcoWordleEvaluationLetter> evaluacion;
  final String estado;
  final int intentosRestantes;
  final Map<String, dynamic>? recompensas;
  final String? pistaEducativa;
  final String? palabraCorrecta;

  const EcoWordleAttemptResult({
    this.sesionId,
    required this.success,
    required this.evaluacion,
    required this.estado,
    required this.intentosRestantes,
    this.recompensas,
    this.pistaEducativa,
    this.palabraCorrecta,
  });

  factory EcoWordleAttemptResult.fromJson(Map<String, dynamic> json) {
    return EcoWordleAttemptResult(
      sesionId: json['sesion_id']?.toString(),
      success: json['success'] ?? false,
      evaluacion: (json['evaluacion'] as List<dynamic>?)
              ?.map((e) => EcoWordleEvaluationLetter.fromJson(e))
              .toList() ??
          [],
      estado: json['estado'] ?? 'en_proceso',
      intentosRestantes: json['intentos_restantes'] ?? 0,
      recompensas: json['recompensas'],
      pistaEducativa: json['pista_educativa'],
      palabraCorrecta: json['palabra_correcta'] ?? json['palabra'] ?? json['palabra_secreta'] ?? json['solucion'],
    );
  }
}
