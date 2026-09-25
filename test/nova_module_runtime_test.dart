import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:agente_ia/nova_module_runtime.dart';

void main() {
  test('validates bounded instructions and executes deterministic modules', () {
    final module = NovaModule.parse({
      'format': 'NOVA-MODULE/1', 'generation': 1,
      'instructions': [
        {'op': 'normalize'},
        {'op': 'replace', 'from': 'ola', 'to': 'olá'},
      ],
    });
    expect(module.execute('  OLA   MUNDO  '), 'olá mundo');
    expect(() => NovaModule.parse({
      'format': 'NOVA-MODULE/1', 'generation': 1,
      'instructions': [{'op': 'shell', 'command': 'rm -rf /'}],
    }), throwsFormatException);
  });
  test('stages, activates, detects tampering and rolls back', () async {
    final dir = await Directory.systemTemp.createTemp('nova-modules-');
    try {
      final store = NovaModuleStore(dir);
      final first = await store.stage(NovaModule(
          generation: 1, instructions: [{'op': 'normalize'}]));
      await store.activate(first);
      final second = await store.stage(NovaModule(
          generation: 2, instructions: [
            {'op': 'normalize'}, {'op': 'truncate', 'length': 4},
          ]));
      await store.activate(second);
      expect(await store.runActive('  ABCDEF  '), 'abcd');
      await store.rollback();
      expect(await store.runActive('  ABCDEF  '), 'abcdef');
      final file = File('${dir.path}/$second.nova');
      await file.writeAsString(jsonEncode({'tampered': true}));
      expect(() => store.load(second), throwsFormatException);
    } finally {
      await dir.delete(recursive: true);
    }
  });
}
