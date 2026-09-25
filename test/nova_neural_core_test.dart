import 'package:flutter_test/flutter_test.dart';
import 'package:agente_ia/nova_neural_core.dart';

void main() {
  test('neural weights train on local text and round-trip', () {
    final model = NovaNeuralCore(width: 16);
    final before = model.accuracy('abababababab');
    model.train('abababababababababababababab');
    expect(model.trainingPairs, greaterThan(0));
    expect(model.accuracy('abababababab'), greaterThan(before));
    final restored = NovaNeuralCore.fromJson(model.toJson());
    expect(restored.accuracy('abababababab'),
        model.accuracy('abababababab'));
    expect(restored.weights, model.weights);
  });
  test('candidate cannot mutate incumbent', () {
    final active = NovaNeuralCore(width: 16);
    final candidate = active.candidate('abababababababab');
    expect(active.trainingPairs, 0);
    expect(candidate.trainingPairs, greaterThan(0));
    expect(candidate.generation, active.generation + 1);
  });
  test('corrupt weights are rejected', () {
    final state = NovaNeuralCore(width: 16).toJson();
    (state['weights'] as List)[0] = double.nan;
    expect(() => NovaNeuralCore.fromJson(state), throwsFormatException);
  });
}
