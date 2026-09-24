import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// Experimental, deterministic symbolic evolution. No neural LLM is claimed.
class NovaEvolutionEngine {
  NovaEvolutionEngine({this.maxConcepts = 4096, this.maxEdges = 16384});
  final int maxConcepts;
  final int maxEdges;
  final Map<String, int> _symbols = {};
  final Map<String, int> _edges = {};
  final Map<String, int> _patterns = {};
  int generation = 0;
  int experiences = 0;
  int acceptedMutations = 0;

  int get concepts => _symbols.length;
  int get connections => _edges.length;
  int get patterns => _patterns.length;
  String get stage => generation == 0 ? 'Descoberta' :
      generation < 3 ? 'Associacao' : 'Consolidacao';

  static const _stop = {'de','da','do','dos','das','para','com','que',
    'uma','uns','umas','por','the','and','from'};
  List<String> _words(String text) => RegExp(r'[a-zA-ZÀ-ÿ0-9]+')
      .allMatches(text.toLowerCase())
      .map((m) => m.group(0)!)
      .where((w) => w.length > 2 && !_stop.contains(w))
      .take(2048).toList();

  /// Symbols are stable within a generation and reversible through the map.
  String? symbolFor(String word) {
    final id = _symbols[word.toLowerCase()];
    return id == null ? null : 'N${id.toRadixString(36).toUpperCase()}';
  }

  void observe(String text) {
    final words = _words(text);
    if (words.isEmpty) return;
    for (final word in words) {
      if (!_symbols.containsKey(word) && _symbols.length < maxConcepts) {
        _symbols[word] = _symbols.length + 1;
      }
    }
    for (var i = 0; i + 1 < words.length; i++) {
      final a = symbolFor(words[i]);
      final b = symbolFor(words[i + 1]);
      if (a == null || b == null || a == b) continue;
      final key = '$a>$b';
      if (_edges.containsKey(key) || _edges.length < maxEdges) {
        _edges[key] = min(65535, (_edges[key] ?? 0) + 1);
      }
    }
    experiences++;
  }

  /// A generation is accepted only when a reversible compact snapshot wins.
  EvolutionResult evolve() {
    final baseline = utf8.encode(jsonEncode(_canonicalPayload()));
    final packed = gzip.encode(baseline);
    final restored = gzip.decode(packed);
    if (base64Encode(restored) != base64Encode(baseline)) {
      return EvolutionResult(false, baseline.length, packed.length,
          generation, 'Integridade falhou');
    }
    if (packed.length >= baseline.length) {
      return EvolutionResult(false, baseline.length, packed.length,
          generation, 'Sem ganho real de compressao');
    }
    generation++;
    acceptedMutations++;
    return EvolutionResult(true, baseline.length, packed.length,
        generation, 'Snapshot comprimido sem perdas');
  }

  String exportCompressed() {
    final original = utf8.encode(jsonEncode(_canonicalPayload()));
    final packed = gzip.encode(original);
    return jsonEncode({'format': 'nova-gzip-v1',
      'payload': base64Encode(packed)});
  }

  bool importCompressed(String snapshot) {
    try {
      final wrapper = jsonDecode(snapshot) as Map<String, dynamic>;
      if (wrapper['format'] != 'nova-gzip-v1') return false;
      final compressed = base64Decode(wrapper['payload'] as String);
      if (compressed.length > 4 * 1024 * 1024) return false;
      final decoded = gzip.decode(compressed);
      if (decoded.length > 16 * 1024 * 1024) return false;
      return importState(jsonDecode(utf8.decode(decoded)));
    } catch (_) {
      return false;
    }
  }

  /// A generational milestone can also be earned by reproducible recall,
  /// independent of compression; this does not imply neural intelligence.
  bool evaluateRecall(List<String> prompts, List<String> expectedWords) {
    if (prompts.isEmpty || prompts.length != expectedWords.length) return false;
    var correct = 0;
    for (var i = 0; i < prompts.length; i++) {
      final tokens = _words(prompts[i]);
      final target = expectedWords[i].toLowerCase();
      if (_symbols.containsKey(target) && tokens.contains(target)) correct++;
    }
    if (correct != prompts.length) return false;
    generation++;
    return true;
  }

  Map<String, dynamic> _canonicalPayload() => {
    'symbols': _symbols, 'edges': _edges, 'patterns': _patterns,
    'experiences': experiences, 'generation': generation,
  };
  Map<String, dynamic> exportState() => _canonicalPayload();

  bool importState(Object? state) {
    try {
      if (state is! Map) return false;
      final symbols = Map<String, int>.from(state['symbols'] as Map);
      final edges = Map<String, int>.from(state['edges'] as Map);
      final patterns = Map<String, int>.from(state['patterns'] as Map);
      final count = state['experiences'] as int;
      final gen = state['generation'] as int;
      if (symbols.length > maxConcepts || edges.length > maxEdges ||
          count < 0 || gen < 0 || symbols.values.any((v) => v < 1) ||
          symbols.values.toSet().length != symbols.length ||
          edges.values.any((v) => v < 1 || v > 65535) ||
          patterns.values.any((v) => v < 1 || v > 65535)) return false;
      _symbols..clear()..addAll(symbols);
      _edges..clear()..addAll(edges);
      _patterns..clear()..addAll(patterns);
      experiences = count;
      generation = gen;
      return true;
    } catch (_) {
      return false;
    }
  }

  static bool _sameMap(Map<String, int> a, Map<String, int> b) =>
      a.length == b.length && a.keys.every((k) => a[k] == b[k]);
}

class EvolutionResult {
  const EvolutionResult(this.accepted, this.beforeBytes, this.afterBytes,
      this.generation, this.reason);
  final bool accepted;
  final int beforeBytes;
  final int afterBytes;
  final int generation;
  final String reason;
}
