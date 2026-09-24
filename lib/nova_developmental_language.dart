import 'dart:math';

/// Local developmental language layer. This is retrieval and intent matching,
/// not a trained neural LLM. All knowledge stays in the app's local snapshot.
class NovaDevelopmentalLanguage {
  int generation = 0;
  int experiences = 0;
  final List<_Memory> _memories = [];
  final Map<String, Set<int>> _index = {};
  void _indexMemory(_Memory memory) {
    final id = _memories.length;
    _memories.add(memory);
    for (final token in _tokens(memory.text).toSet()) {
      _index.putIfAbsent(token, () => <int>{}).add(id);
    }
  }
  void _rebuildIndex() {
    final old = List<_Memory>.from(_memories);
    _memories.clear();
    _index.clear();
    for (final memory in old) { _indexMemory(memory); }
  }
  static const _stop = <String>{
    'a','as','o','os','um','uma','de','do','da','dos','das','e','em',
    'no','na','nos','nas','para','por','que','qual','quais','me','voce',
    'eu','the','and','to','is','are','of','it','what'
  };

  List<String> _tokens(String text) => RegExp(r'[a-zA-ZÀ-ÿ0-9]+')
      .allMatches(text.toLowerCase())
      .map((m) => m.group(0)!)
      .where((w) => w.length > 2 && !_stop.contains(w))
      .toList();

  bool get hasDocuments => _memories.any((m) => m.source != 'conversa');
  int get memoryCount => _memories.length;

  void learnDocument(String text, {String source = 'documento'}) {
    if (text.trim().isEmpty) return;
    // Split by paragraph and sentence; bound the amount of retained text.
    final chunks = text.split(RegExp(r'(?<=[.!?])\s+|\n\s*\n'))
        .map((s) => s.trim())
        .where((s) => s.length > 24);
    for (final chunk in chunks) {
      if (_memories.length >= 1500) break;
      final normalized = chunk.length > 750 ? chunk.substring(0, 750) : chunk;
      if (_memories.any((m) => m.text == normalized)) continue;
      _indexMemory(_Memory(normalized, source));
    }
    experiences++;
    generation = experiences ~/ 25;
  }

  void learnConversation(String text) {
    if (text.trim().length < 18) return;
    if (_memories.length < 1500) {
      _indexMemory(_Memory(text.trim(), 'conversa'));
    }
    experiences++;
    generation = experiences ~/ 25;
  }

  Map<String, dynamic> exportState() => {
    'generation': generation,
    'experiences': experiences,
    'memories': _memories.map((m) => {'text': m.text, 'source': m.source}).toList(),
  };

  bool importState(Object? raw) {
    if (raw is! Map || raw['memories'] is! List) return false;
    try {
      final entries = (raw['memories'] as List).map((e) {
        if (e is! Map || e['text'] is! String || e['source'] is! String) {
          throw const FormatException('Memoria invalida');
        }
        return _Memory(e['text'] as String, e['source'] as String);
      }).take(1500).toList();
      final count = raw['experiences'];
      if (count is! int || count < 0) return false;
      _memories..clear()..addAll(entries);
      _rebuildIndex();
      experiences = count;
      generation = experiences ~/ 25;
      return true;
    } catch (_) {
      return false;
    }
  }

  String answer(String question) {
    final q = question.toLowerCase().trim();
    if (q.isEmpty) return 'Pode me contar o que voce gostaria de saber?';
    final wantsSummary = RegExp(r'resum|sintetiz|sumari|summary').hasMatch(q);
    final documentMemories = _memories.where((m) => m.source != 'conversa').toList();
    if (wantsSummary && documentMemories.isEmpty) {
      return 'Ainda nao tenho um documento para resumir. Importe um PDF ou TXT primeiro.';
    }
    final query = _tokens(question).toSet();
    final ids = <int>{};
    for (final token in query) { ids.addAll(_index[token] ?? const <int>{}); }
    final candidates = wantsSummary ? documentMemories :
      ids.map((id) => _memories[id]).toList();
    final ranked = candidates.map((m) {
      final words = _tokens(m.text).toSet();
      final overlap = query.intersection(words).length;
      final sourceWeight = m.source == 'conversa' ? 1.4 : 1.0;
      final score = sourceWeight * overlap / sqrt(max(words.length, 1));
      return (memory: m, score: score);
    }).toList()..sort((a,b) => b.score.compareTo(a.score));
    if (wantsSummary) {
      // Extractive overview, deliberately not claiming abstractive understanding.
      final selection = documentMemories.take(4).map((m) => m.text).join(' ');
      return 'Resumo extrativo do material importado:\n$selection\n\n'
          'Esta versao seleciona trechos; ainda nao produz sinteses com um modelo neural.';
    }
    if (ranked.isNotEmpty && ranked.first.score > 0) {
      final selected = ranked.take(2).where((r) => r.score > 0).toList();
      final evidence = selected.map((r) => r.memory.text).join('\n\n');
      final sources = selected.map((r) => r.memory.source).toSet().join(', ');
      return 'Encontrei estes trechos relacionados ($sources):\n$evidence\n\n'
          'Ainda estou aprendendo a relacionar ideias; isso nao e uma resposta gerada por LLM.';
    }
    return 'Ainda nao encontrei informacao suficiente na minha memoria local '
        'para responder. Voce pode me ensinar ou importar um documento.';
  }
}

class _Memory {
  final String text;
  final String source;
  const _Memory(this.text, this.source);
}
