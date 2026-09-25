import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:agente_ia/nova_pack_installer.dart';

void main() {
  late Directory dir;
  setUp(() async => dir = await Directory.systemTemp.createTemp('nova-packs-'));
  tearDown(() async { if (await dir.exists()) await dir.delete(recursive: true); });

  List<int> sample({String id = 'history.pt'}) => utf8.encode(jsonEncode({
    'format': 'nova-knowledge-v1', 'id': id,
    'name': 'História', 'description': 'Pacote local de teste',
    'documents': ['O Brasil tem uma história extensa.'],
  }));

  test('installs a bounded local pack and discovers it after restart', () async {
    final source = File('${dir.path}/incoming.json')..writeAsBytesSync(sample());
    final installer = NovaPackInstaller(Directory('${dir.path}/installed'));
    final pack = await installer.installLocal(source);
    expect(pack.id, 'history.pt');
    expect((await NovaPackInstaller(Directory('${dir.path}/installed'))
      .installed()).single.name, 'História');
  });

  test('rejects executable-looking or malformed packages', () {
    expect(() => NovaPack.parse(utf8.encode('{"format":"apk"}')),
      throwsFormatException);
    expect(() => NovaPack.parse(sample(id: '../escape')),
      throwsFormatException);
  });

  test('requires HTTPS and verified SHA-256 before fetching', () async {
    final installer = NovaPackInstaller(dir);
    await expectLater(installer.installHttps('http://example.com/file',
      '0' * 64), throwsFormatException);
    await expectLater(installer.installHttps('https://example.com/file',
      'bad'), throwsFormatException);
  });
}
