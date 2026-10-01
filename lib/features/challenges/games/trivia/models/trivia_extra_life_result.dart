class TriviaExtraLifeResult {
  final int lives;
  final int coinBalance;
  final bool extraLifePurchased;

  const TriviaExtraLifeResult({
    required this.lives,
    required this.coinBalance,
    required this.extraLifePurchased,
  });

  factory TriviaExtraLifeResult.fromJson(Map<String, dynamic> json) {
    return TriviaExtraLifeResult(
      lives: _parseInt(json['vidas'], 1),
      coinBalance: _parseInt(json['saldo_monedas'], 0),
      extraLifePurchased: json['vida_extra_comprada'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'vidas': lives,
    'saldo_monedas': coinBalance,
    'vida_extra_comprada': extraLifePurchased,
  };

  TriviaExtraLifeResult copyWith({
    int? lives,
    int? coinBalance,
    bool? extraLifePurchased,
  }) {
    return TriviaExtraLifeResult(
      lives: lives ?? this.lives,
      coinBalance: coinBalance ?? this.coinBalance,
      extraLifePurchased: extraLifePurchased ?? this.extraLifePurchased,
    );
  }

  static int _parseInt(dynamic value, int fallback) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }
}
