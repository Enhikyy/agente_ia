import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:agente_ia/nova_generation_archive.dart';
import 'package:agente_ia/nova_portable_export.dart';

void main() {
  test('both efficiency metrics must improve by 20 percent', () {
    const archive = NovaGenerationArchive();
    const old = NovaGenerationMetrics(accuracy: .96, latencyUs: 1000, memoryKb: 100);
    expect(archive.qualifies(old, const NovaGenerationMetrics(
      accuracy: .96, latencyUs: 800, memoryKb: 80)), true);
    expect(archive.qualifies(old, const NovaGenerationMetrics(
      accuracy: .96, latencyUs: 790, memoryKb: 81)), false);
    expect(archive.qualifies(old, const NovaGenerationMetrics(
      accuracy: .95, latencyUs: 700, memoryKb: 70)), false);
  });
  test('archive is written before promotion and checksum is present', () async {
    final dir = await Directory.systemTemp.createTemp('nova_archive_');
    addTearDown(() => dir.delete(recursive: true));
    final file = await const NovaGenerationArchive().backupBeforePromotion(dir,
      old: const NovaGenerationMetrics(accuracy: .96, latencyUs: 1000, memoryKb: 100),
      next: const NovaGenerationMetrics(accuracy: .97, latencyUs: 700, memoryKb: 70),
      previousSnapshot: {'generation': 1});
    expect(await file.exists(), true);
    expect(jsonDecode(await file.readAsString())['sha256'], isNotEmpty);
  });
  test('portable format detects corruption and is not GGUF', () {
    const exporter = NovaPortableExport();
    final data = exporter.encode(genome: {'version': 1},
      learningState: {'memories': []}, metadata: {'app': 'NOVA'});
    expect(exporter.decode(data)['format'], 'nova-portable');
    expect(() => exporter.decode(data.replaceFirst('nova-portable', 'nova-broken')),
      throwsFormatException);
    expect(exporter.directlyCompatibleWithPocketPal, false);
  });
}
