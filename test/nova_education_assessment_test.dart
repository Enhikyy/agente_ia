import 'package:flutter_test/flutter_test.dart';
import 'package:agente_ia/nova_education_assessment.dart';

void main() {
  NovaAssessment result(String topic, int correct, {int total = 20,
      bool verified = true, bool independent = true}) =>
    NovaAssessment(topic: topic, correct: correct, total: total,
      verified: verified, independent: independent, at: DateTime.utc(2026));

  test('95 percent threshold is inclusive; 90 percent fails', () {
    expect(result('lógica', 19).passed, true);
    expect(result('lógica', 20).passed, true);
    expect(result('lógica', 18).passed, false);
  });

  test('rejects self grading, unverified scores and tiny exams', () {
    expect(result('lógica', 20, independent: false).passed, false);
    expect(result('lógica', 20, verified: false).passed, false);
    expect(result('lógica', 1, total: 1).passed, false);
    expect(result('lógica', 21).passed, false);
  });

  test('graduation requires every school subject to pass', () {
    final all = NovaEducationProgress.schoolTopics
        .map((t) => result(t, 19)).toList();
    expect(NovaEducationProgress.mayGraduate(all), true);
    all.removeLast();
    expect(NovaEducationProgress.mayGraduate(all), false);
    expect(NovaEducationProgress.nextSchoolTopic(all), 'matemática');
  });
}
