import 'dart:convert';

/// Reversible local symbolic vocabulary, not a newly learned human language.
class NovaPrivateLanguage {
  const NovaPrivateLanguage();
  static const _header = 'NOVA-LANG/1';
  String encode(String text, Map<String, String> dictionary) {
    _validate(dictionary);
    final inverse = {for (final e in dictionary.entries) e.value: e.key};
    final words = RegExp(r'\S+|\s+').allMatches(text)
        .map((m) => m.group(0)!).toList();
    final tokens = words.map((word) => inverse.containsKey(word)
      ? ['s', inverse[word]] : ['l', word]).toList();
    return jsonEncode({'format': _header, 'dictionary': dictionary,
      'tokens': tokens});
  }
  String decode(String encoded) {
    final raw = jsonDecode(encoded);
    if (raw is! Map || raw['format'] != _header ||
        raw['dictionary'] is! Map || raw['tokens'] is! List) {
      throw const FormatException('Invalid private language.');
    }
    final dictionary = Map<String, String>.from(raw['dictionary'] as Map);
    _validate(dictionary);
    final out = StringBuffer();
    for (final token in raw['tokens'] as List) {
      if (token is! List || token.length != 2 || token[0] is! String ||
          token[1] is! String) throw const FormatException('Invalid token.');
      if (token[0] == 's') {
        final word = dictionary[token[1]];
        if (word == null) throw const FormatException('Unknown symbol.');
        out.write(word);
      } else if (token[0] == 'l') {
        out.write(token[1]);
      } else {
        throw const FormatException('Unknown token type.');
      }
    }
    return out.toString();
  }
  void _validate(Map<String, String> dictionary) {
    if (dictionary.length > 4096 ||
        dictionary.keys.any((k) => k.isEmpty || k.length > 32) ||
        dictionary.values.any((v) => v.isEmpty || v.length > 256) ||
        dictionary.values.toSet().length != dictionary.length) {
      throw const FormatException('Invalid dictionary.');
    }
  }
}
