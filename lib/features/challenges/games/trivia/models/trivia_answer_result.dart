class TriviaAnswerResult {
  final bool isCorrect;
  final int correctOption;
  final String explanation;
  final int timeSeconds;
  final int xpEarned;
  final int remainingLives;
  final int correctCount;
  final int accumulatedXp;
  final bool canContinue;

  const TriviaAnswerResult({
    required this.isCorrect,
    required this.correctOption,
    required this.explanation,
    required this.timeSeconds,
    required this.xpEarned,
    required this.remainingLives,
    required this.correctCount,
    required this.accumulatedXp,
    required this.canContinue,
  });

  factory TriviaAnswerResult.fromJson(Map<String, dynamic> json) {
    return TriviaAnswerResult(
      isCorrect: json['correcta'] == true,
      correctOption: _parseInt(json['opcion_correcta'], 0),
      explanation: json['explicacion']?.toString() ?? '',
      timeSeconds: _parseInt(json['tiempo_segundos'], 0),
      xpEarned: _parseInt(json['xp_ganada'], 0),
      remainingLives: _parseInt(json['vidas_restantes'], 0),
      correctCount: _parseInt(json['correctas'], 0),
      accumulatedXp: _parseInt(json['xp_acumulada'], 0),
      canContinue: json['puede_continuar'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'correcta': isCorrect,
    'opcion_correcta': correctOption,
    'explicacion': explanation,
    'tiempo_segundos': timeSeconds,
    'xp_ganada': xpEarned,
    'vidas_restantes': remainingLives,
    'correctas': correctCount,
    'xp_acumulada': accumulatedXp,
    'puede_continuar': canContinue,
  };

  TriviaAnswerResult copyWith({
    bool? isCorrect,
    int? correctOption,
    String? explanation,
    int? timeSeconds,
    int? xpEarned,
    int? remainingLives,
    int? correctCount,
    int? accumulatedXp,
    bool? canContinue,
  }) {
    return TriviaAnswerResult(
      isCorrect: isCorrect ?? this.isCorrect,
      correctOption: correctOption ?? this.correctOption,
      explanation: explanation ?? this.explanation,
      timeSeconds: timeSeconds ?? this.timeSeconds,
      xpEarned: xpEarned ?? this.xpEarned,
      remainingLives: remainingLives ?? this.remainingLives,
      correctCount: correctCount ?? this.correctCount,
      accumulatedXp: accumulatedXp ?? this.accumulatedXp,
      canContinue: canContinue ?? this.canContinue,
    );
  }

  static int _parseInt(dynamic value, int fallback) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }
}
