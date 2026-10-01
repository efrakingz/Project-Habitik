/// Banco de preguntas ecológicas locales para fallback o simulación offline.
class TriviaMockQuestionData {
  final String questionId;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;
  final String category;
  final String difficulty;
  final int timeLimitSeconds;

  const TriviaMockQuestionData({
    required this.questionId,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    required this.category,
    required this.difficulty,
    this.timeLimitSeconds = 30,
  });

  Map<String, dynamic> toQuestionJson({DateTime? startedAt}) {
    return {
      'pregunta_id': questionId,
      'pregunta': question,
      'alternativas': options,
      'categoria': category,
      'dificultad': difficulty,
      'limite_segundos': timeLimitSeconds,
      'iniciada_en': (startedAt ?? DateTime.now().toUtc()).toIso8601String(),
    };
  }
}

const List<TriviaMockQuestionData> kMockTriviaQuestions = [
  TriviaMockQuestionData(
    questionId: 'q-eco-001',
    question:
        '¿Qué acción reduce el consumo eléctrico en espera (consumo vampiro)?',
    options: [
      'Desenchufar equipos o usar zapatilla con interruptor',
      'Subir el brillo de las pantallas',
      'Dejar los cargadores conectados a la pared',
      'Mantener encendido el modo reposo',
    ],
    correctOptionIndex: 0,
    explanation:
        'Los aparatos electrónicos en modo espera o apagados pero enchufados pueden representar hasta un 10% del consumo del hogar.',
    category: 'energia',
    difficulty: 'facil',
  ),
  TriviaMockQuestionData(
    questionId: 'q-eco-002',
    question:
        '¿Cuál de los siguientes materiales tarda más de 400 años en degradarse en la naturaleza?',
    options: [
      'Cáscara de plátano',
      'Botella de plástico (PET)',
      'Periódico de papel',
      'Caja de cartón corrugado',
    ],
    correctOptionIndex: 1,
    explanation:
        'El plástico PET puede tardar entre 400 y 500 años en descomponerse completamente en el medio ambiente.',
    category: 'reciclaje',
    difficulty: 'facil',
  ),
  TriviaMockQuestionData(
    questionId: 'q-eco-003',
    question:
        'Al ducharse, ¿cuántos litros de agua en promedio se consumen por cada minuto de ducha estándar?',
    options: [
      'Aproximadamente 2 litros',
      'Alrededor de 15 a 20 litros',
      'Más de 80 litros',
      'Menos de medio litro',
    ],
    correctOptionIndex: 1,
    explanation:
        'Una ducha convencional gasta entre 15 y 20 litros por minuto. Acortar la ducha a 5 minutos ahorra decenas de litros diarios.',
    category: 'agua',
    difficulty: 'media',
  ),
  TriviaMockQuestionData(
    questionId: 'q-eco-004',
    question:
        '¿Por qué las abejas son cruciales para los ecosistemas y la alimentación mundial?',
    options: [
      'Porque polinizan cerca del 75% de los cultivos alimentarios del planeta',
      'Porque producen agua potable en los panales',
      'Porque eliminan todos los tipos de maleza',
      'Porque absorben dióxido de carbono directamente',
    ],
    correctOptionIndex: 0,
    explanation:
        'Las abejas y otros polinizadores son esenciales para la reproducción de más del 75% de las especies de cultivo que consumimos.',
    category: 'biodiversidad',
    difficulty: 'facil',
  ),
  TriviaMockQuestionData(
    questionId: 'q-eco-005',
    question:
        'En la regla de las 3R (Reducir, Reutilizar, Reciclar), ¿cuál es la acción con mayor impacto ambiental positivo?',
    options: [
      'Reciclar después de consumir mucho',
      'Reducir la generación de residuos desde el origen',
      'Comprar productos de un solo uso',
      'Quemar la basura acumulada',
    ],
    correctOptionIndex: 1,
    explanation:
        'Reducir el consumo innecesario previene la extracción de materias primas y la generación de residuos desde el inicio.',
    category: 'consumo',
    difficulty: 'media',
  ),
  TriviaMockQuestionData(
    questionId: 'q-eco-006',
    question:
        '¿Qué tipo de residuo debe depositarse en una compostera doméstica?',
    options: [
      'Pilas usadas y baterías',
      'Restos de frutas, verduras y café',
      'Envases de plástico y latas',
      'Vidrios y cerámicas rotas',
    ],
    correctOptionIndex: 1,
    explanation:
        'El compostaje aprovecha materia orgánica vegetal para crear abono natural rico en nutrientes sin generar metano nocivo.',
    category: 'reciclaje',
    difficulty: 'facil',
  ),
  TriviaMockQuestionData(
    questionId: 'q-eco-007',
    question:
        '¿A qué temperatura recomendada debe ajustarse el aire acondicionado en verano para un consumo eficiente?',
    options: [
      '16 °C para enfriar más rápido',
      '24 °C a 25 °C',
      '30 °C con ventilador apagado',
      '18 °C de manera continua',
    ],
    correctOptionIndex: 1,
    explanation:
        'Cada grado que se baja la temperatura por debajo de 24 °C incrementa el consumo de electricidad entre un 7% y un 10%.',
    category: 'energia',
    difficulty: 'media',
  ),
  TriviaMockQuestionData(
    questionId: 'q-eco-008',
    question:
        '¿Qué impacto negativo produce verter 1 litro de aceite usado por el desagüe del fregadero?',
    options: [
      'Mejora el flujo en las tuberías',
      'Puede contaminar hasta 1.000 litros de agua potable',
      'No tiene ningún impacto ambiental',
      'Genera oxígeno en los ríos',
    ],
    correctOptionIndex: 1,
    explanation:
        'El aceite vegetal usado forma una película sobre el agua que impide la oxigenación y daña las redes de alcantarillado.',
    category: 'agua',
    difficulty: 'media',
  ),
  TriviaMockQuestionData(
    questionId: 'q-eco-009',
    question:
        '¿Qué significa la "huella de carbono" de un producto o actividad humana?',
    options: [
      'La marca de ceniza que deja el carbón al quemarse',
      'La totalidad de gases de efecto invernadero emitidos en su ciclo de vida',
      'La cantidad de dinero que cuesta transportar un producto',
      'El peso en kilogramos del empaque del producto',
    ],
    correctOptionIndex: 1,
    explanation:
        'Mide la cantidad total de emisiones de gases de efecto invernadero (expresadas en CO2 equivalente) causadas directa o indirectamente.',
    category: 'consumo',
    difficulty: 'dificil',
  ),
  TriviaMockQuestionData(
    questionId: 'q-eco-010',
    question:
        '¿Cuál de los siguientes medios de transporte emite cero emisiones de gases contaminantes en su trayecto?',
    options: [
      'Bicicleta convencional',
      'Vehículo diésel utilitario',
      'Motocicleta de 2 tiempos',
      'Avión comercial',
    ],
    correctOptionIndex: 0,
    explanation:
        'La movilidad activa en bicicleta o caminata es 100% limpia en su uso diario y mejora la salud cardiovascular.',
    category: 'energia',
    difficulty: 'facil',
  ),
];
