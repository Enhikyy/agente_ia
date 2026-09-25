import 'package:flutter_test/flutter_test.dart';
import 'package:agente_ia/nova_neural_lab.dart';
import 'package:agente_ia/nova_neural_core.dart';

void main() {
  test('laboratório gera candidatos compactos e de orçamento esparso', () {
    final model = NovaNeuralCore();
    final candidates = const NovaNeuralLab().buildCandidates(
      model,
      'relações internacionais e linguagem natural ' * 20,
    );
    expect(candidates, isNotEmpty);
    expect(candidates.every((c) => c.parametros > 0), isTrue);
    expect(candidates.any((c) => c.parametros < model.parametros), isTrue);
    expect(candidates.any((c) => c.neuronsActive < model.neuronsActive), isTrue);
  });

  test('sessão de laboratório retorna ranking determinístico', () {
    final model = NovaNeuralCore()..train('ab' * 200, maxExamples: 64);
    final result = const NovaNeuralLab().run(
      baseline: model,
      training: 'ab' * 200,
      holdout: 'ab' * 120,
    );
    expect(result.ranking, isNotEmpty);
    expect(result.baseline.sampleCount, greaterThan(20));
    expect(result.candidates, isNotEmpty);
  });
}
