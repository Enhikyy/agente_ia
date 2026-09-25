import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'nova_neural_core.dart';

class NovaNeuralCheckpoint {
  const NovaNeuralCheckpoint({
    required this.id,
    required this.path,
    required this.createdAt,
    required this.generation,
    required this.parameters,
    required this.accuracy,
    required this.label,
  });
  final String id, path, label;
  final DateTime createdAt;
  final int generation, parameters;
  final double accuracy;

  Map<String, dynamic> toJson() => {
    'id': id,
    'path': path,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'generation': generation,
    'parameters': parameters,
    'accuracy': accuracy,
    'label': label,
  };
}

class NovaNeuralCheckpointStore {
  static const int maxCheckpoints = 12;
  final Directory directory;
  NovaNeuralCheckpointStore(this.directory);

  Future<NovaNeuralCheckpoint> save(
    NovaNeuralCore model, {
    required String label,
    double accuracy = 0,
  }) async {
    await directory.create(recursive: true);
    final id = DateTime.now().toUtc().microsecondsSinceEpoch.toString();
    final file = File(directory.path + '/checkpoint_' + id + '.json');
    final now = DateTime.now().toUtc();
    final payload = jsonEncode({
      'format': 'nova-neural-checkpoint',
      'version': 1,
      'model': model.toJson(),
      'label': label,
      'accuracy': accuracy,
      'createdAt': now.toIso8601String(),
    });
    final digest = sha256.convert(utf8.encode(payload)).toString();
    await file.writeAsString(
      jsonEncode({'sha256': digest, 'payload': payload}),
      flush: true,
    );
    await _trim();
    return NovaNeuralCheckpoint(
      id: id,
      path: file.path,
      createdAt: now,
      generation: model.generation,
      parameters: model.parametros,
      accuracy: accuracy,
      label: label,
    );
  }

  Future<NovaNeuralCore> restore(NovaNeuralCheckpoint checkpoint) async {
    final raw = await File(checkpoint.path).readAsString();
    final wrapper = jsonDecode(raw);
    if (wrapper is! Map || wrapper['payload'] is! String ||
        wrapper['sha256'] is! String) {
      throw const FormatException('Checkpoint inválido.');
    }
    final payload = wrapper['payload'] as String;
    if (sha256.convert(utf8.encode(payload)).toString() != wrapper['sha256']) {
      throw const FormatException('Checksum do checkpoint não confere.');
    }
    final data = jsonDecode(payload);
    if (data is! Map || data['format'] != 'nova-neural-checkpoint' ||
        data['version'] != 1) {
      throw const FormatException('Formato de checkpoint incompatível.');
    }
    return NovaNeuralCore.fromJson(data['model']);
  }

  Future<List<NovaNeuralCheckpoint>> list() async {
    if (!await directory.exists()) return [];
    final result = <NovaNeuralCheckpoint>[];
    await for (final entry in directory.list(followLinks: false)) {
      if (entry is! File || !entry.path.endsWith('.json')) continue;
      try {
        final wrapper = jsonDecode(await entry.readAsString());
        final payload = wrapper['payload'] as String;
        if (sha256.convert(utf8.encode(payload)).toString() != wrapper['sha256']) {
          continue;
        }
        final data = jsonDecode(payload) as Map;
        final model = NovaNeuralCore.fromJson(data['model']);
        final fileName = entry.uri.pathSegments.last;
        final id = fileName
            .replaceFirst(RegExp(r'^checkpoint_'), '')
            .replaceFirst(RegExp(r'\.json$'), '');
        result.add(NovaNeuralCheckpoint(
          id: id,
          path: entry.path,
          createdAt: DateTime.tryParse(
                data['createdAt']?.toString() ?? '',
              ) ??
              DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
          generation: model.generation,
          parameters: model.parametros,
          accuracy: (data['accuracy'] as num?)?.toDouble() ?? 0,
          label: data['label']?.toString() ?? '',
        ));
      } catch (_) {}
    }
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result.take(maxCheckpoints).toList();
  }

  Future<void> _trim() async {
    final all = await list();
    for (final checkpoint in all.skip(maxCheckpoints)) {
      try {
        await File(checkpoint.path).delete();
      } catch (_) {}
    }
  }
}
