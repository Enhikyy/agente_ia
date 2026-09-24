import 'package:flutter_test/flutter_test.dart';
import 'package:agente_ia/nova_education_assessment.dart';
import 'package:agente_ia/nova_research_curriculum.dart';
import 'package:agente_ia/nova_experiment_lab.dart';

void main() {
  test('university requires every independently verified exam', () {
    final exams = NovaResearchCurriculum.university.map((topic) =>
      NovaAssessment(topic: topic, correct: 19, total: 20,
        verified: true, independent: true, at: DateTime.utc(2026))).toList();
    expect(NovaResearchCurriculum.universityCompleted(exams), true);
    exams.removeLast();
    expect(NovaResearchCurriculum.universityCompleted(exams), false);
    expect(NovaResearchCurriculum.nextUniversityTopic(exams), 'ética em inteligência artificial');
  });
  test('experiment rejects incorrect optimization and small samples', () {
    const lab = NovaExperimentLab();
    expect(() => lab.compare<int>('tiny', [1], (x) => x, (x) => x), throwsArgumentError);
    final cases = List.generate(100, (i) => i);
    final result = lab.compare<int>('incorrect', cases, (x) => x * 2, (x) => x * 3);
    expect(result.improvementVerified, false);
    expect(result.candidateErrors, greaterThan(0));
  });
}
