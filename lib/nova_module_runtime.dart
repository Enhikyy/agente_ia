import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

/// Versioned, bounded instruction format. Never evaluates Dart, shell or
/// native machine code; all modules execute inside this limited interpreter.
class NovaModule {
  NovaModule({required this.generation, required this.instructions});
  final int generation;
  final List<Map<String, dynamic>> instructions;

  factory NovaModule.parse(Object? input) {
    if (input is! Map || input['format'] != 'NOVA-MODULE/1' ||
        input['generation'] is! int || input['generation'] < 0 ||
        input['instructions'] is! List) {
      throw const FormatException('Invalid NOVA module header');
    }
    final raw = input['instructions'] as List;
    if (raw.isEmpty || raw.length > 64) {
      throw const FormatException('Module instruction limit exceeded');
    }
    final instructions = <Map<String, dynamic>>[];
    for (final entry in raw) {
      if (entry is! Map || entry['op'] is! String) {
        throw const FormatException('Invalid instruction');
      }
      final op = entry['op'];
      if (op == 'normalize') {
        if (entry.length != 1) throw const FormatException('Invalid normalize');
      } else if (op == 'replace') {
        if (entry.length != 3 || entry['from'] is! String ||
            entry['to'] is! String ||
            (entry['from'] as String).isEmpty ||
            (entry['from'] as String).length > 80 ||
            (entry['to'] as String).length > 80) {
          throw const FormatException('Invalid replacement');
        }
      } else if (op == 'truncate') {
        if (entry.length != 2 || entry['length'] is! int ||
            entry['length'] < 1 || entry['length'] > 4096) {
          throw const FormatException('Invalid truncation');
        }
      } else {
        throw const FormatException('Unsupported instruction');
      }
      instructions.add(Map<String, dynamic>.from(entry));
    }
    return NovaModule(
        generation: input['generation'] as int, instructions: instructions);
  }

  Map<String, dynamic> toJson() => {
    'format': 'NOVA-MODULE/1',
    'generation': generation,
    'instructions': instructions,
  };

  String execute(String input) {
    if (input.length > 4096) throw const FormatException('Input too long');
    var value = input;
    for (final instruction in instructions) {
      switch (instruction['op']) {
        case 'normalize':
          value = value.toLowerCase().trim().replaceAll(
              RegExp(r'\\s+'), ' ');
          break;
        case 'replace':
          value = value.replaceAll(
              instruction['from'] as String, instruction['to'] as String);
          break;
        case 'truncate':
          final length = instruction['length'] as int;
          if (value.length > length) value = value.substring(0, length);
          break;
      }
      if (value.length > 4096) {
        throw const FormatException('Module output too long');
      }
    }
    return value;
  }
}

/// Content-addressed modules, verified on load and activated atomically.
/// The previous active module remains available for explicit rollback.
class NovaModuleStore {
  NovaModuleStore(this.directory);
  final Directory directory;

  Future<String> stage(NovaModule module) async {
    await directory.create(recursive: true);
    final data = jsonEncode(module.toJson());
    final hash = sha256.convert(utf8.encode(data)).toString();
    final target = File('${directory.path}/$hash.nova');
    if (!await target.exists()) {
      final temp = File('${target.path}.tmp');
      await temp.writeAsString(data, flush: true);
      await temp.rename(target.path);
    }
    return hash;
  }

  Future<NovaModule> load(String hash) async {
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(hash)) {
      throw const FormatException('Invalid module hash');
    }
    final data = await File('${directory.path}/$hash.nova').readAsString();
    if (sha256.convert(utf8.encode(data)).toString() != hash) {
      throw const FormatException('Module integrity check failed');
    }
    return NovaModule.parse(jsonDecode(data));
  }

  Future<String?> activeHash() async {
    final pointer = File('${directory.path}/active.json');
    if (!await pointer.exists()) return null;
    final state = jsonDecode(await pointer.readAsString());
    if (state is! Map || state['active'] is! String) {
      throw const FormatException('Invalid activation state');
    }
    return state['active'] as String;
  }

  Future<void> activate(String hash) async {
    final next = await load(hash);
    final oldHash = await activeHash();
    if (oldHash != null) {
      final old = await load(oldHash);
      if (next.generation <= old.generation) {
        throw StateError('Candidate must be a newer generation');
      }
    }
    final pointer = File('${directory.path}/active.json');
    final temp = File('${directory.path}/active.tmp');
    await temp.writeAsString(
        jsonEncode({'active': hash, 'previous': oldHash}), flush: true);
    await temp.rename(pointer.path);
  }

  Future<void> rollback() async {
    final pointer = File('${directory.path}/active.json');
    final state = jsonDecode(await pointer.readAsString()) as Map;
    final previous = state['previous'];
    if (previous is! String) throw StateError('No previous generation');
    await load(previous);
    final temp = File('${directory.path}/active.tmp');
    await temp.writeAsString(
        jsonEncode({'active': previous, 'previous': null}), flush: true);
    await temp.rename(pointer.path);
  }

  Future<String?> runActive(String input) async {
    final hash = await activeHash();
    if (hash == null) return null;
    return (await load(hash)).execute(input);
  }
}
