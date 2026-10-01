class EcoWordleStatus {
  final int largoPalabra;
  final List<String> intentosRealizados;
  final String estado; // 'en_proceso', 'ganado', 'perdido'
  final bool pistaRevelada;
  final String? pistaEducativa;
  final String? palabraCorrecta;

  const EcoWordleStatus({
    required this.largoPalabra,
    required this.intentosRealizados,
    required this.estado,
    required this.pistaRevelada,
    this.pistaEducativa,
    this.palabraCorrecta,
  });

  factory EcoWordleStatus.fromJson(Map<String, dynamic> json) {
    return EcoWordleStatus(
      largoPalabra: json['largo_palabra'] ?? 5,
      intentosRealizados: List<String>.from(json['intentos_realizados'] ?? []),
      estado: json['estado'] ?? 'en_proceso',
      pistaRevelada: json['pista_revelada'] ?? false,
      pistaEducativa: json['pista_educativa'],
      palabraCorrecta: json['palabra_correcta'] ?? json['palabra'] ?? json['palabra_secreta'] ?? json['solucion'],
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
  final bool success;
  final List<EcoWordleEvaluationLetter> evaluacion;
  final String estado;
  final int intentosRestantes;
  final Map<String, dynamic>? recompensas;
  final String? pistaEducativa;
  final String? palabraCorrecta;

  const EcoWordleAttemptResult({
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
