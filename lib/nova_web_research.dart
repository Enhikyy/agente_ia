import 'dart:convert';
import 'dart:io';

/// Public encyclopedic web search; not unrestricted browsing or an LLM.
class NovaWebResearch {
  Future<NovaResearchResult> search(String query,
      {void Function(double, String)? onProgress}) async {
    final term = query.trim();
    if (term.length < 2 || term.length > 180) {
      throw const FormatException('Use de 2 a 180 caracteres na pesquisa.');
    }
    final timer = Stopwatch()..start();
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 12);
    try {
      onProgress?.call(.12, 'Conectando à Wikipédia');
      final uri = Uri.https('pt.wikipedia.org', '/w/api.php', {
        'action': 'query', 'generator': 'search', 'gsrsearch': term,
        'gsrlimit': '4', 'prop': 'extracts|info', 'inprop': 'url',
        'exintro': '1', 'explaintext': '1', 'exchars': '650',
        'format': 'json', 'formatversion': '2', 'redirects': '1',
      });
      final request = await client.getUrl(uri).timeout(const Duration(seconds: 15));
      request.headers.set(HttpHeaders.userAgentHeader, 'NOVA/1.0 (educational offline-first app)');
      final response = await request.close().timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw HttpException('Servidor retornou HTTP ${response.statusCode}');
      }
      onProgress?.call(.52, 'Recebendo resultados');
      final bytes = await response.fold<List<int>>(<int>[], (out, chunk) {
        if (out.length + chunk.length > 600000) {
          throw const FormatException('Resposta excedeu o limite de segurança.');
        }
        return out..addAll(chunk);
      }).timeout(const Duration(seconds: 18));
      onProgress?.call(.83, 'Filtrando e atribuindo fontes');
      final decoded = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      final queryData = decoded['query'];
      final pages = queryData is Map ? queryData['pages'] : null;
      final items = <NovaResearchPage>[];
      if (pages is List) {
        for (final raw in pages) {
          if (raw is! Map) continue;
          final title = raw['title']?.toString() ?? '';
          final extract = raw['extract']?.toString().trim() ?? '';
          final link = raw['fullurl']?.toString() ?? '';
          final parsed = Uri.tryParse(link);
          if (title.isEmpty || extract.isEmpty || parsed == null ||
              parsed.scheme != 'https' || parsed.host != 'pt.wikipedia.org') continue;
          items.add(NovaResearchPage(title, extract, link));
        }
      }
      timer.stop();
      onProgress?.call(1, 'Pesquisa concluída');
      return NovaResearchResult(items, timer.elapsedMilliseconds);
    } finally {
      client.close(force: true);
    }
  }
}

class NovaResearchPage {
  const NovaResearchPage(this.title, this.extract, this.url);
  final String title, extract, url;
}

class NovaResearchResult {
  const NovaResearchResult(this.pages, this.elapsedMs);
  final List<NovaResearchPage> pages;
  final int elapsedMs;
}
