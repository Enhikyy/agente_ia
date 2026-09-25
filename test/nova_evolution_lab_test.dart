import 'package:flutter_test/flutter_test.dart';
import 'package:agente_ia/nova_evolution_lab.dart';

void main() {
  test('genomes have versioned bounded data-only format', () {
    const parent = NovaGenome(1, 1, 128);
    expect(NovaGenome.fromJson(parent.toJson()).cacheSize, 128);
    expect(() => NovaGenome.fromJson({'format': 'nova-genome',
      'version': 1, 'retrievalWeight': 100, 'cacheSize': 128}), throwsFormatException);
    final children = const NovaEvolutionLab().candidates(parent);
    expect(children.length, 5);
    expect(children.every((g) => g.cacheSize >= 16 && g.cacheSize <= 1024), true);
  });
  test('a faster but inaccurate child cannot replace the parent', () {
    const parent = NovaGenome(1, 1, 128);
    const child = NovaGenome(1, 1.1, 128);
    final scores = <NovaGenome, ({double accuracy, int latencyUs, int memoryKb})>{
      parent: (accuracy: .96, latencyUs: 1000, memoryKb: 100),
      child: (accuracy: .94, latencyUs: 100, memoryKb: 90),
    };
    expect(const NovaEvolutionLab().select(parent, scores), same(parent));
  });
}
