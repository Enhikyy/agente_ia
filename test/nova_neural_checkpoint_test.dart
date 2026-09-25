import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:agente_ia/nova_neural_checkpoint.dart';
import 'package:agente_ia/nova_neural_core.dart';

void main() {
  test('checkpoint salva, lista e restaura o modelo com checksum', () async {
    final root = await Directory.systemTemp.createTemp('nova_checkpoint_test');
    try {
      final model = NovaNeuralCore()..train('nova local aprende ' * 20, maxExamples: 32);
      final store = NovaNeuralCheckpointStore(Directory(root.path + '/checkpoints'));
      final checkpoint = await store.save(model, label: 'Teste', accuracy: .81);
      final listed = await store.list();
      expect(listed.any((item) => item.id == checkpoint.id), isTrue);
      final restored = await store.restore(checkpoint);
      expect(restored.parametros, model.parametros);
      expect(restored.trainingPairs, model.trainingPairs);
    } finally {
      await root.delete(recursive: true);
    }
  });
}
