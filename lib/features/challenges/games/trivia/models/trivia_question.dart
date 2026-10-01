class TriviaQuestion {
  final String questionId;
  final String question;
  final List<String> options;
  final String category;
  final String difficulty;
  final int timeLimitSeconds;
  final DateTime startedAt;

  const TriviaQuestion({
    required this.questionId,
    required this.question,
    required this.options,
    required this.category,
    required this.difficulty,
    required this.timeLimitSeconds,
    required this.startedAt,
  });

  factory TriviaQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['alternativas'];
    if (rawOptions == null || rawOptions is! List || rawOptions.length != 4) {
      throw const FormatException(
        'La pregunta debe contener exactamente 4 alternativas válidas.',
      );
    }

    final parsedOptions = rawOptions.map((e) => e?.toString() ?? '').toList();
    if (parsedOptions.any((opt) => opt.trim().isEmpty)) {
      throw const FormatException('Las alternativas no pueden estar vacías.');
    }

    final questionText = json['pregunta'] as String?;
    final questionId = json['pregunta_id'] as String?;
    if (questionText == null ||
        questionText.trim().isEmpty ||
        questionId == null ||
        questionId.isEmpty) {
      throw const FormatException('Datos incompletos en la pregunta recibida.');
    }

    DateTime parsedDate;
    final dateRaw = json['iniciada_en']?.toString();
    if (dateRaw != null && dateRaw.isNotEmpty) {
      parsedDate =
          DateTime.tryParse(dateRaw)?.toUtc() ?? DateTime.now().toUtc();
    } else {
      parsedDate = DateTime.now().toUtc();
    }

    return TriviaQuestion(
      questionId: questionId,
      question: questionText,
      options: List<String>.unmodifiable(parsedOptions),
      category: json['categoria'] as String? ?? 'general',
      difficulty: json['dificultad'] as String? ?? 'media',
      timeLimitSeconds: _parseInt(json['limite_segundos'], 30),
      startedAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'pregunta_id': questionId,
    'pregunta': question,
    'alternativas': options,
    'categoria': category,
    'dificultad': difficulty,
    'limite_segundos': timeLimitSeconds,
    'iniciada_en': startedAt.toUtc().toIso8601String(),
  };

  TriviaQuestion copyWith({
    String? questionId,
    String? question,
    List<String>? options,
    String? category,
    String? difficulty,
    int? timeLimitSeconds,
    DateTime? startedAt,
  }) {
    return TriviaQuestion(
      questionId: questionId ?? this.questionId,
      question: question ?? this.question,
      options: options ?? this.options,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
      startedAt: startedAt ?? this.startedAt,
    );
  }

  static int _parseInt(dynamic value, int fallback) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }
}
