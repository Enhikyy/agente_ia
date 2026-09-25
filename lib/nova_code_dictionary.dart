import 'dart:convert';

/// Dicionário proprietário reversível para compactar memória textual.
/// Não é criptografia; a decodificação recompõe exatamente o texto recebido.
class NovaCodeDictionary {
  static const int version = 1;
  final Map<String, int> _ids = <String, int>{};
  final Map<int, String> _words = <int, String>{};
  int _nextId = 1;

  int get entries => _ids.length;

  List<String> _segments(String text) => RegExp(
    r'[A-Za-zÀ-ÿ0-9]+|\s+|[^A-Za-zÀ-ÿ0-9\s]+',
  ).allMatches(text).map((m) => m.group(0)!).toList();

  String _key(String value) => value.toLowerCase();

  int _intern(String word) {
    final key = _key(word);
    final existing = _ids[key];
    if (existing != null) return existing;
    final id = _nextId++;
    _ids[key] = id;
    _words[id] = word;
    return id;
  }

  int learn(String text) {
    var added = 0;
    for (final segment in _segments(text)) {
      if (RegExp(r'^[A-Za-zÀ-ÿ0-9]+$').hasMatch(segment)) {
        final before = _ids.length;
        _intern(segment);
        if (_ids.length > before) added++;
      }
    }
    return added;
  }

  List<int> _varint(int value) {
    var n = value;
    final output = <int>[];
    do {
      var byte = n & 0x7f;
      n >>= 7;
      if (n != 0) byte |= 0x80;
      output.add(byte);
    } while (n != 0);
    return output;
  }

  int _readVarint(List<int> bytes, int start, List<int> next) {
    var value = 0;
    var shift = 0;
    var index = start;
    while (index < bytes.length) {
      final byte = bytes[index++];
      value |= (byte & 0x7f) << shift;
      if ((byte & 0x80) == 0) {
        next[0] = index;
        return value;
      }
      shift += 7;
      if (shift > 28) {
        throw const FormatException('Varint excedeu o limite.');
      }
    }
    throw const FormatException('Varint incompleto.');
  }

  List<int> encode(String text) {
    learn(text);
    final output = <int>[78, 67, 68, 49];
    for (final segment in _segments(text)) {
      final isWord = RegExp(r'^[A-Za-zÀ-ÿ0-9]+$').hasMatch(segment);
      if (isWord) {
        output.add(1);
        output.addAll(_varint(_intern(segment)));
      } else {
        final raw = utf8.encode(segment);
        output.add(0);
        output.addAll(_varint(raw.length));
        output.addAll(raw);
      }
    }
    return output;
  }

  String decode(List<int> encoded) {
    if (encoded.length < 4 ||
        encoded[0] != 78 || encoded[1] != 67 ||
        encoded[2] != 68 || encoded[3] != 49) {
      throw const FormatException('Cabeçalho NCD inválido.');
    }
    final output = StringBuffer();
    var index = 4;
    while (index < encoded.length) {
      final tag = encoded[index++];
      if (tag == 1) {
        final next = <int>[index];
        final id = _readVarint(encoded, index, next);
        index = next[0];
        final word = _words[id];
        if (word == null) {
          throw const FormatException('ID ausente no dicionário.');
        }
        output.write(word);
      } else if (tag == 0) {
        final next = <int>[index];
        final length = _readVarint(encoded, index, next);
        index = next[0];
        if (index + length > encoded.length) {
          throw const FormatException('Literal fora dos limites.');
        }
        output.write(
          utf8.decode(encoded.sublist(index, index + length)),
        );
        index += length;
      } else {
        throw const FormatException('Tipo de segmento desconhecido.');
      }
    }
    return output.toString();
  }

  Map<String, dynamic> stats(String text) {
    final rawBytes = utf8.encode(text).length;
    final packedBytes = encode(text).length;
    return {
      'entries': entries,
      'rawBytes': rawBytes,
      'packedBytes': packedBytes,
      'savedBytes': rawBytes - packedBytes,
      'reductionPercent': rawBytes == 0
          ? 0.0
          : 100 * (rawBytes - packedBytes) / rawBytes,
      'format': 'NCD1',
    };
  }

  Map<String, dynamic> toJson() => {
    'format': 'nova-code-dictionary',
    'version': version,
    'nextId': _nextId,
    'entries': _words.map((k, v) => MapEntry(k.toString(), v)),
  };

  bool fromJson(Object? raw) {
    try {
      if (raw is! Map || raw['format'] != 'nova-code-dictionary' ||
          raw['version'] != version || raw['entries'] is! Map) {
        return false;
      }
      final values = <int, String>{};
      (raw['entries'] as Map).forEach((key, value) {
        final id = int.tryParse(key.toString());
        if (id == null || id <= 0 || value is! String || value.isEmpty) {
          throw const FormatException('Entrada de dicionário inválida.');
        }
        values[id] = value;
      });
      final next = (raw['nextId'] as num?)?.toInt() ?? 1;
      if (next < 1 || values.keys.any((id) => id >= next)) return false;
      _ids.clear();
      _words.clear();
      values.forEach((id, word) {
        _ids[_key(word)] = id;
        _words[id] = word;
      });
      _nextId = next;
      return true;
    } catch (_) {
      return false;
    }
  }
}
