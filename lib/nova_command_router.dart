import 'dart:convert';

enum NovaCommandKind {
  help,
  status,
  tests,
  resources,
  evolve,
  research,
  studyNow,
  studyStart,
  studyStop,
  autonomyStart,
  autonomyStop,
  backup,
  diagnostics,
  refine,
  addEvaluation,
  network,
  plugins,
  unknown,
}

class NovaCommand {
  const NovaCommand(this.kind, {this.argument = ''});
  final NovaCommandKind kind;
  final String argument;
}

/// Offline intent router: deterministic, accent-tolerant and auditable.
/// It does not claim to be an LLM; it maps natural command variants to safe intents.
class NovaCommandRouter {
  const NovaCommandRouter();

  String normalize(String input) {
    var value = input.trim().toLowerCase();
    const accents = {
      'á':'a','à':'a','ã':'a','â':'a','ä':'a',
      'é':'e','è':'e','ê':'e','ë':'e',
      'í':'i','ì':'i','î':'i','ï':'i',
      'ó':'o','ò':'o','õ':'o','ô':'o','ö':'o',
      'ú':'u','ù':'u','û':'u','ü':'u',
      'ç':'c',
    };
    accents.forEach((key, replacement) {
      value = value.replaceAll(key, replacement);
    });
    return value.replaceAll(RegExp(r'\s+'), ' ');
  }

  NovaCommand parse(String input) {
    final q = normalize(input);
    if (q.isEmpty) return const NovaCommand(NovaCommandKind.unknown);
    if (const ['ajuda','help','comandos','o que voce consegue fazer'].contains(q)) {
      return const NovaCommand(NovaCommandKind.help);
    }
    final words = q.split(' ');
    final hasAny = (List<String> values) => values.any((value) => q.contains(value));
    if (hasAny(['teste', 'diagnostico', 'verificar integridade', 'rodar os testes'])) {
      return const NovaCommand(NovaCommandKind.tests);
    }
    if (const ['status','status da nova','como voce esta','como esta'].contains(q) ||
        hasAny(['qual o status', 'como anda a nova'])) {
      return const NovaCommand(NovaCommandKind.status);
    }
    if (q == 'recursos' || q == 'hardware' || q == 'mostre os recursos' ||
        hasAny(['recursos do celular', 'uso de memoria', 'uso de ram', 'bateria'])) {
      return const NovaCommand(NovaCommandKind.resources);
    }
    if (q == 'evoluir' || q == 'nova geracao' || q == 'evolucao' ||
        q == 'expandir modelo' || q == 'aumentar parametros' ||
        q == 'aumentar os parametros' || q == 'subir parametros' ||
        hasAny(['otimize o modelo', 'otimizar o modelo', 'evolua a nova',
          'deixe mais rapido', 'reduza os parametros', 'melhore o modelo'])) {
      return const NovaCommand(NovaCommandKind.evolve);
    }
    if (q == 'estudar agora' || q == 'estudar' || q == 'comece a estudar') {
      return const NovaCommand(NovaCommandKind.studyNow);
    }
    if (q == 'estudo autonomo iniciar') {
      return const NovaCommand(NovaCommandKind.studyStart);
    }
    if (q == 'estudo autonomo parar') {
      return const NovaCommand(NovaCommandKind.studyStop);
    }
    if (q == 'autonomia iniciar') {
      return const NovaCommand(NovaCommandKind.autonomyStart);
    }
    if (q == 'autonomia parar') {
      return const NovaCommand(NovaCommandKind.autonomyStop);
    }
    if (q == 'backup' || q == 'congelar memoria' || q == 'salvar memoria' ||
        q == 'faca um backup' || q == 'faz um backup' || hasAny(['salve meu estado', 'salvar meu estado'])) {
      return const NovaCommand(NovaCommandKind.backup);
    }
    if (q == 'exportar diagnostico' || q == 'diagnostico') {
      return const NovaCommand(NovaCommandKind.diagnostics);
    }
    if (q == 'refinar parametros' || q == 'refinar') {
      return const NovaCommand(NovaCommandKind.refine);
    }
    if (q == 'rede neural' || q == 'rede' || q == 'sinapses' ||
        q == 'ligacoes' || q == 'conexoes' || q == 'mostre a rede' ||
        q == 'mostre a rede neural' ||
        (hasAny(['mostre', 'exiba']) && hasAny(['rede', 'sinapses', 'conexoes']))) {
      return const NovaCommand(NovaCommandKind.network);
    }
    if (q == 'plugins' || q == 'pacotes') {
      return const NovaCommand(NovaCommandKind.plugins);
    }
    if (words.isNotEmpty && (q.startsWith('pesquisar ') || q.startsWith('pesquise ') ||
        q.startsWith('procure ') || q.startsWith('busque ') || q.startsWith('encontre '))) {
      final prefixes = <String>['pesquisar ', 'pesquise ', 'procure ', 'busque ', 'encontre '];
      final prefix = prefixes.firstWhere((value) => q.startsWith(value));
      return NovaCommand(NovaCommandKind.research,
          argument: input.trim().substring(prefix.length).trim());
    }
    if (q.startsWith('estude ')) {
      return NovaCommand(NovaCommandKind.research,
          argument: input.trim().substring(7).trim());
    }
    if (q.startsWith('avaliar:')) {
      return NovaCommand(NovaCommandKind.addEvaluation,
          argument: input.trim().substring(input.indexOf(':') + 1).trim());
    }
    if (q.startsWith('avaliar ')) {
      return NovaCommand(NovaCommandKind.addEvaluation,
          argument: input.trim().substring(9).trim());
    }
    return const NovaCommand(NovaCommandKind.unknown);
  }

  String get helpJson => jsonEncode({
    'comandos': [
      'status', 'testes', 'rede neural', 'recursos', 'evoluir', 'expandir modelo',
      'pesquisar <tema>', 'estude <tema>', 'estudar agora',
      'avaliar: pergunta | resposta esperada', 'backup',
      'exportar diagnostico', 'autonomia iniciar', 'autonomia parar',
      'estudo autonomo iniciar', 'estudo autonomo parar',
    ],
  });
}
