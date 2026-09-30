class TriviaFinalResult {
  final String sessionId;
  final int correctCount;
  final int incorrectCount;
  final int xpEarned;
  final int coinsEarned;
  final int totalXp;
  final int coinBalance;
  final int currentLevel;
  final bool levelUp;

  const TriviaFinalResult({
    required this.sessionId,
    required this.correctCount,
    required this.incorrectCount,
    required this.xpEarned,
    required this.coinsEarned,
    required this.totalXp,
    required this.coinBalance,
    required this.currentLevel,
    required this.levelUp,
  });

  factory TriviaFinalResult.fromJson(Map<String, dynamic> json) {
    return TriviaFinalResult(
      sessionId: json['sesion_id']?.toString() ?? '',
      correctCount: _parseInt(json['correctas'], 0),
      incorrectCount: _parseInt(json['incorrectas'], 0),
      xpEarned: _parseInt(json['xp_ganada'], 0),
      coinsEarned: _parseInt(json['monedas_ganadas'], 0),
      totalXp: _parseInt(json['xp_total'], 0),
      coinBalance: _parseInt(json['saldo_monedas'], 0),
      currentLevel: _parseInt(json['nivel_actual'], 1),
      levelUp: json['level_up'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'sesion_id': sessionId,
    'correctas': correctCount,
    'incorrectas': incorrectCount,
    'xp_ganada': xpEarned,
    'monedas_ganadas': coinsEarned,
    'xp_total': totalXp,
    'saldo_monedas': coinBalance,
    'nivel_actual': currentLevel,
    'level_up': levelUp,
  };

  TriviaFinalResult copyWith({
    String? sessionId,
    int? correctCount,
    int? incorrectCount,
    int? xpEarned,
    int? coinsEarned,
    int? totalXp,
    int? coinBalance,
    int? currentLevel,
    bool? levelUp,
  }) {
    return TriviaFinalResult(
      sessionId: sessionId ?? this.sessionId,
      correctCount: correctCount ?? this.correctCount,
      incorrectCount: incorrectCount ?? this.incorrectCount,
      xpEarned: xpEarned ?? this.xpEarned,
      coinsEarned: coinsEarned ?? this.coinsEarned,
      totalXp: totalXp ?? this.totalXp,
      coinBalance: coinBalance ?? this.coinBalance,
      currentLevel: currentLevel ?? this.currentLevel,
      levelUp: levelUp ?? this.levelUp,
    );
  }

  static int _parseInt(dynamic value, int fallback) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }
}
