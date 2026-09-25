import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:agente_ia/nova_exam_runner.dart';
import 'package:agente_ia/nova_developmental_language.dart';

void main() {
  test('rejects too few questions and missing sources', () {
    const runner = NovaExamRunner();
    expect(() => runner.parse('[]'), throwsFormatException);
    final invalid = List.generate(20, (i) => {
      'question': 'Questão de teste número $i?',
      'answer': 'resposta', 'source': '',
    });
    expect(() => runner.parse(jsonEncode(invalid)), throwsFormatException);
  });

  test('preliminary exams cannot approve graduation', () {
    const runner = NovaExamRunner();
    final questions = List.generate(20, (i) => NovaExamQuestion(
      'Qual é o conceito número $i?', 'resposta', 'fonte externa'));
    final assessment = runner.grade(
      topic: 'lógica', questions: questions,
      language: NovaDevelopmentalLanguage(),
      now: DateTime.utc(2026), independentKeyConfirmed: false);
    expect(assessment.passed, false);
    expect(assessment.correct, 0);
  });
}
