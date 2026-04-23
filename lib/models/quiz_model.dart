class QuizModel {
  const QuizModel({
    required this.id,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
    required this.category,
    this.level = 1,
  });

  final int id;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  /// النص الكامل للإجابة الصحيحة (أحد الخيارات الأربعة)
  final String correctAnswer;
  final String category;
  final int level;

  List<String> get options => [optionA, optionB, optionC, optionD];

  factory QuizModel.fromMap(Map<String, dynamic> map) {
    return QuizModel(
      id: map['id'] as int,
      question: map['question'] as String,
      optionA: map['option_a'] as String,
      optionB: map['option_b'] as String,
      optionC: map['option_c'] as String,
      optionD: map['option_d'] as String,
      correctAnswer: map['correct_answer'] as String,
      category: map['category'] as String,
      level: (map['level'] as int?) ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'option_a': optionA,
      'option_b': optionB,
      'option_c': optionC,
      'option_d': optionD,
      'correct_answer': correctAnswer,
      'category': category,
      'level': level,
    };
  }
}
