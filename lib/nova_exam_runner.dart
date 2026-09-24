import 'dart:convert';
import 'nova_developmental_language.dart';
import 'nova_education_assessment.dart';

class NovaExamQuestion {
  const NovaExamQuestion(this.prompt, this.expected, this.source);
  final String prompt, expected, source;
}

class NovaExamRunner {
  const NovaExamRunner();

  /// Import an externally prepared, held-out answer key. Never teach these
  /// answers to the agent before grading. This is a basic exact-fact exam,
  /// not a validated assessment of general reasoning.
  List<NovaExamQuestion> parse(String jsonText) {
    final decoded = jsonDecode(jsonText);
    if (decoded is! List || decoded.length < 20 || decoded.length > 100) {
      throw const FormatException('A prova deve conter de 20 a 100 questões.');
    }
    final questions = <NovaExamQuestion>[];
    final prompts = <String>{};
    for (final raw in decoded) {
      if (raw is! Map) throw const FormatException('Questão inválida.');
      final prompt = raw['question']?.toString().trim() ?? '';
      final expected = raw['answer']?.toString().trim() ?? '';
      final source = raw['source']?.toString().trim() ?? '';
      if (prompt.length < 12 || expected.length < 2 || source.isEmpty ||
          !prompts.add(prompt.toLowerCase())) {
        throw const FormatException('Questão duplicada ou sem gabarito/fonte.');
      }
      questions.add(NovaExamQuestion(prompt, expected, source));
    }
    return questions;
  }

  String _normalize(String text) => text.toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9à-ÿ]+'), ' ').trim();

  NovaAssessment grade({
    required String topic,
    required List<NovaExamQuestion> questions,
    required NovaDevelopmentalLanguage language,
    required DateTime now,
    required bool independentKeyConfirmed,
  }) {
    var correct = 0;
    for (final question in questions) {
      final answer = language.answer(question.prompt);
      final expected = _normalize(question.expected);
      // No points for generic fallback or answers without retrieved evidence.
      if (answer.startsWith('Encontrei estes trechos relacionados') &&
          _normalize(answer).contains(expected)) correct++;
    }
    return NovaAssessment(
      topic: topic, correct: correct, total: questions.length,
      verified: independentKeyConfirmed, independent: independentKeyConfirmed,
      at: now,
    );
  }
}
