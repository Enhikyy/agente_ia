import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:agente_ia/nova_generation_coordinator.dart';
import 'package:agente_ia/nova_generation_archive.dart';
import 'package:agente_ia/nova_private_language.dart';

void main() {
  const old = NovaGenerationMetrics(accuracy: .96, latencyUs: 1000, memoryKb: 100);
  const next = NovaGenerationMetrics(accuracy: .97, latencyUs: 700, memoryKb: 70);
  test('promotes only after archiving previous generation', () async {
    final dir = await Directory.systemTemp.createTemp('nova_promote_');
    addTearDown(() => dir.delete(recursive: true));
    Map<String, dynamic> active = {'threshold': 1};
    final file = await const NovaGenerationCoordinator().promote(
      archiveDirectory: dir, baseline: old, candidate: next,
      previousState: {'threshold': 1}, nextState: {'threshold': 2},
      persist: (state) async {
        expect((await dir.list().toList()).whereType<File>()
          .any((f) => f.path.endsWith('.novabackup')), true);
        active = state;
      });
    expect(await file.exists(), true);
    expect(active['threshold'], 2);
  });
  test('restores previous state after failed promotion', () async {
    final dir = await Directory.systemTemp.createTemp('nova_rollback_');
    addTearDown(() => dir.delete(recursive: true));
    Map<String, dynamic> active = {'threshold': 1};
    await expectLater(
      const NovaGenerationCoordinator().promote(
        archiveDirectory: dir, baseline: old, candidate: next,
        previousState: {'threshold': 1}, nextState: {'threshold': 2},
        persist: (state) async {
          active = state;
          if (state['threshold'] == 2) {
            throw StateError('simulated write failure');
          }
        }),
      throwsStateError);
    expect(active['threshold'], 1);
    expect((await dir.list().toList()).whereType<File>()
      .any((file) => file.path.endsWith('.novabackup')), true);
  });
  test('rejects candidate without both twenty percent gains', () async {
    final dir = await Directory.systemTemp.createTemp('nova_reject_');
    addTearDown(() => dir.delete(recursive: true));
    var persisted = false;
    await expectLater(
      const NovaGenerationCoordinator().promote(
        archiveDirectory: dir, baseline: old,
        candidate: const NovaGenerationMetrics(
          accuracy: .97, latencyUs: 810, memoryKb: 70),
        previousState: {'threshold': 1}, nextState: {'threshold': 2},
        persist: (_) async { persisted = true; }),
      throwsStateError);
    expect(persisted, false);
    expect(await dir.list().isEmpty, true);
  });
  test('private language preserves text exactly', () {
    const language = NovaPrivateLanguage();
    const text = 'Olá NOVA! Olá, mundo.\n';
    final encoded = language.encode(text, {'A': 'Olá', 'B': 'NOVA!'});
    expect(language.decode(encoded), text);
  });
}
