class TriviaSession {
  final String sessionId;
  final int lives;
  final bool extraLifePurchased;
  final int correctCount;
  final int accumulatedXp;
  final int estimatedCoins;

  const TriviaSession({
    required this.sessionId,
    required this.lives,
    required this.extraLifePurchased,
    required this.correctCount,
    required this.accumulatedXp,
    required this.estimatedCoins,
  });

  factory TriviaSession.fromJson(Map<String, dynamic> json) {
    return TriviaSession(
      sessionId: json['sesion_id']?.toString() ?? '',
      lives: _parseInt(json['vidas'], 3),
      extraLifePurchased: json['vida_extra_comprada'] == true,
      correctCount: _parseInt(json['correctas'], 0),
      accumulatedXp: _parseInt(json['xp_acumulada'], 0),
      estimatedCoins: _parseInt(json['monedas_estimadas'], 0),
    );
  }

  Map<String, dynamic> toJson() => {
    'sesion_id': sessionId,
    'vidas': lives,
    'vida_extra_comprada': extraLifePurchased,
    'correctas': correctCount,
    'xp_acumulada': accumulatedXp,
    'monedas_estimadas': estimatedCoins,
  };

  TriviaSession copyWith({
    String? sessionId,
    int? lives,
    bool? extraLifePurchased,
    int? correctCount,
    int? accumulatedXp,
    int? estimatedCoins,
  }) {
    return TriviaSession(
      sessionId: sessionId ?? this.sessionId,
      lives: lives ?? this.lives,
      extraLifePurchased: extraLifePurchased ?? this.extraLifePurchased,
      correctCount: correctCount ?? this.correctCount,
      accumulatedXp: accumulatedXp ?? this.accumulatedXp,
      estimatedCoins: estimatedCoins ?? this.estimatedCoins,
    );
  }

  static int _parseInt(dynamic value, int fallback) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }
}
