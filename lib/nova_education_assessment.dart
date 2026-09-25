/// Educational advancement requires independently verified assessments.
/// Research volume is not evidence of mastery.
class NovaAssessment {
  const NovaAssessment({
    required this.topic,
    required this.correct,
    required this.total,
    required this.verified,
    required this.independent,
    required this.at,
  });
  final String topic;
  final int correct, total;
  final bool verified, independent;
  final DateTime at;

  double get accuracy => total > 0 ? correct / total : 0;
  bool get passed => verified && independent && total >= 20 &&
      correct >= 0 && correct <= total && accuracy >= .95;

  Map<String, dynamic> toJson() => {
    'topic': topic, 'correct': correct, 'total': total,
    'verified': verified, 'independent': independent,
    'at': at.toUtc().toIso8601String(),
  };

  factory NovaAssessment.fromJson(Map<String, dynamic> m) =>
      NovaAssessment(
        topic: m['topic']?.toString() ?? '',
        correct: (m['correct'] as num?)?.toInt() ?? 0,
        total: (m['total'] as num?)?.toInt() ?? 0,
        verified: m['verified'] == true,
        independent: m['independent'] == true,
        at: DateTime.tryParse(m['at']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      );
}

class NovaEducationProgress {
  static const schoolTopics = <String>[
    'alfabetização', 'aritmética', 'ciências naturais', 'geografia',
    'história', 'lógica', 'interpretação de texto', 'matemática',
  ];

  /// One independently evaluated result per discipline; no self-grading.
  static bool mayGraduate(List<NovaAssessment> assessments) =>
      schoolTopics.every((topic) => assessments.any(
        (a) => a.topic == topic && a.passed));

  static String? nextSchoolTopic(List<NovaAssessment> assessments) {
    for (final topic in schoolTopics) {
      if (!assessments.any((a) => a.topic == topic && a.passed)) return topic;
    }
    return null;
  }
}
