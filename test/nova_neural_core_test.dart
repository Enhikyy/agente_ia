import 'package:flutter_test/flutter_test.dart';
import 'package:agente_ia/nova_neural_core.dart';

void main() {
  test('modelo inicial possui cerca de 100 mil parâmetros', () {
    final model = NovaNeuralCore();
    expect(model.parametros, 100489);
    expect(model.hiddenSize, 160);
    expect(model.bytesFloat32Estimados, 401536);
    expect(model.bytesInt8Estimados, 100384);
  });

  test('treino neural altera a previsão e gera texto', () {
    final model = NovaNeuralCore();
    final antes = model.accuracy('abababababababababab');
    final treinados = model.train(
      'abababababababababababababababab',
      maxExamples: 64,
    );
    expect(treinados, greaterThan(0));
    expect(model.trainingPairs, greaterThan(0));
    expect(model.accuracy('abababababababababab'), greaterThanOrEqualTo(antes));
    final saida = model.generate('a', maxBytes: 8);
    expect(saida.isNotEmpty, isTrue);
  });

  test('serialização preserva os parâmetros treinados', () {
    final model = NovaNeuralCore()..train('nova e inteligencia artificial ' * 20);
    final restaurado = NovaNeuralCore.fromJson(model.toJson());
    expect(restaurado.parametros, model.parametros);
    expect(restaurado.trainingPairs, model.trainingPairs);
    expect(restaurado.generation, model.generation);
    expect(restaurado.parametros, model.parametros);
  });

  test('candidato não altera o modelo ativo', () {
    final ativo = NovaNeuralCore();
    final candidato = ativo.candidate('n nova nova nova ' * 20);
    expect(ativo.trainingPairs, 0);
    expect(candidato.trainingPairs, greaterThan(0));
    expect(candidato.generation, ativo.generation + 1);
    expect(candidato.parametros, ativo.parametros);
  });

  test('expansão inicial sobe para aproximadamente 200 mil parâmetros', () {
    final ativo = NovaNeuralCore()..train('relações internacionais e política global ' * 15);
    final candidato = ativo.expandedCandidate(
      'relações internacionais e política global ' * 20,
      256,
    );
    expect(candidato.parametros, 197376);
    expect(candidato.parametros, greaterThan(ativo.parametros));
    expect(candidato.trainingPairs, greaterThan(ativo.trainingPairs));
  });

  test('estado neural antigo não derruba a memória textual', () {
    final antigo = {
      'format': 'nova-neural-bigram',
      'version': 1,
      'width': 32,
      'generation': 44,
      'trainingPairs': 100,
      'weights': List<double>.filled(1024, 0),
    };
    final migrado = NovaNeuralCore.fromJson(antigo);
    expect(migrado.parametros, 100384);
  });

  test('pesos corrompidos são rejeitados', () {
    final estado = NovaNeuralCore().toJson();
    (estado['w1'] as List)[0] = double.nan;
    expect(() => NovaNeuralCore.fromJson(estado), throwsFormatException);
  });
}
