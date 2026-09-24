import 'package:flutter_test/flutter_test.dart';
import 'package:agente_ia/nova_evolution_engine.dart';

void main() {
  test('learns stable symbols and bounded relations', () {
    final engine = NovaEvolutionEngine(maxConcepts: 3, maxEdges: 2);
    engine.observe('agua chuva rio lago agua chuva rio');
    expect(engine.concepts, 3);
    expect(engine.connections, lessThanOrEqualTo(2));
    expect(engine.symbolFor('agua'), 'N1');
    expect(engine.symbolFor('lago'), isNull);
  });

  test('snapshot compression is reversible and measurable', () {
    final engine = NovaEvolutionEngine();
    for (var i = 0; i < 50; i++) {
      engine.observe('agua chuva rio ciclo agua chuva rio ciclo');
    }
    final before = engine.exportState();
    final outcome = engine.evolve();
    expect(outcome.accepted, isTrue);
    expect(outcome.afterBytes, lessThan(outcome.beforeBytes));
    final restored = NovaEvolutionEngine();
    expect(restored.importCompressed(engine.exportCompressed()), isTrue);
    expect(restored.exportState(), engine.exportState());
    expect(engine.generation, 1);
    expect(before['experiences'], 50);
  });

  test('corrupt snapshot never erases current knowledge', () {
    final engine = NovaEvolutionEngine();
    engine.observe('aprendizado memoria confiavel');
    final before = engine.exportState();
    expect(engine.importCompressed('corrupted'), isFalse);
    expect(engine.exportState(), before);
  });

  test('generation does not advance without byte savings', () {
    final engine = NovaEvolutionEngine();
    final result = engine.evolve();
    expect(result.accepted, isFalse);
    expect(engine.generation, 0);
  });
}
