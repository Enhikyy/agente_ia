import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

class NovaGenerationMetrics {
  const NovaGenerationMetrics({required this.accuracy,
    required this.latencyUs, required this.memoryKb});
  final double accuracy;
  final int latencyUs, memoryKb;
  bool get valid => accuracy.isFinite && accuracy >= .95 && accuracy <= 1 &&
      latencyUs > 0 && memoryKb > 0;
}

class NovaGenerationArchive {
  const NovaGenerationArchive();
  /// Require >=20% speed gain AND >=20% RAM reduction, no accuracy loss.
  bool qualifies(NovaGenerationMetrics old, NovaGenerationMetrics next) =>
      old.valid && next.valid && next.accuracy >= old.accuracy &&
      next.latencyUs <= old.latencyUs * .8 &&
      next.memoryKb <= old.memoryKb * .8;

  /// Save the previous generation before changing any live configuration.
  /// A data snapshot is not an APK or a copy of the application's source.
  Future<File> backupBeforePromotion(Directory directory,
      {required NovaGenerationMetrics old,
       required NovaGenerationMetrics next,
       required Map<String, dynamic> previousSnapshot}) async {
    if (!qualifies(old, next)) {
      throw StateError('20% performance and efficiency gate not met.');
    }
    await directory.create(recursive: true);
    final payload = jsonEncode({
      'format': 'nova-generation-backup', 'version': 1,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'previous': previousSnapshot,
      'baseline': {'accuracy': old.accuracy,
        'latencyUs': old.latencyUs, 'memoryKb': old.memoryKb},
      'candidate': {'accuracy': next.accuracy,
        'latencyUs': next.latencyUs, 'memoryKb': next.memoryKb},
    });
    final digest = sha256.convert(utf8.encode(payload)).toString();
    final stamp = DateTime.now().toUtc().microsecondsSinceEpoch;
    final temporary = File('${directory.path}/generation_$stamp.tmp');
    final destination = File('${directory.path}/generation_$stamp.novabackup');
    await temporary.writeAsString(jsonEncode({'sha256': digest,
      'payload': payload}), flush: true);
    final verified = jsonDecode(await temporary.readAsString()) as Map;
    if (sha256.convert(utf8.encode(verified['payload'] as String)).toString()
        != verified['sha256']) {
      throw const FormatException('Backup checksum mismatch.');
    }
    return temporary.rename(destination.path);
  }
}
