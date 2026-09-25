import 'package:flutter_test/flutter_test.dart';
import 'package:agente_ia/nova_optimizer.dart';

void main() {
  test('rejects optimization with insufficient evaluation samples', () {
    final report = const NovaOptimizer().optimize(
      cases: const [NovaBenchmarkCase('pergunta', 'resposta')],
      answer: (_, __) => 'resposta', currentThreshold: 0);
    expect(report.accepted, false);
    expect(report.hallucinationRate, isNull);
  });

  test('preserves configuration when holdout does not improve', () {
    final cases = List.generate(20,
      (i) => NovaBenchmarkCase('pergunta $i', 'resposta'));
    final report = const NovaOptimizer().optimize(
      cases: cases, answer: (_, __) => 'resposta',
      currentThreshold: 0);
    expect(report.accepted, false);
    expect(report.threshold, 0);
    expect(report.baselineAccuracy, 1);
  });
}
