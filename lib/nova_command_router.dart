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
    if (const ['ajuda','help','comandos','o que voce consegue fazer']
        .any(q ==)) {
      return const NovaCommand(NovaCommandKind.help);
    }
    if (const ['status','status da nova','como voce esta','como esta']
        .any(q ==)) return const NovaCommand(NovaCommandKind.status);
    if (const ['testar','testes','teste','diagnostico completo','rodar testes']
        .any(q ==)) return const NovaCommand(NovaCommandKind.tests);
    if (q == 'recursos' || q == 'hardware') {
      return const NovaCommand(NovaCommandKind.resources);
    }
    if (q == 'evoluir' || q == 'nova geracao' || q == 'evolucao') {
      return const NovaCommand(NovaCommandKind.evolve);
    }
    if (q == 'estudar agora' || q == 'estudar') {
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
    if (q == 'backup' || q == 'congelar memoria' || q == 'salvar memoria') {
      return const NovaCommand(NovaCommandKind.backup);
    }
    if (q == 'exportar diagnostico' || q == 'diagnostico') {
      return const NovaCommand(NovaCommandKind.diagnostics);
    }
    if (q == 'refinar parametros' || q == 'refinar') {
      return const NovaCommand(NovaCommandKind.refine);
    }
    if (q == 'rede neural' || q == 'rede' || q == 'sinapses' ||
        q == 'ligacoes' || q == 'conexoes') {
      return const NovaCommand(NovaCommandKind.network);
    }
    if (q == 'plugins' || q == 'pacotes') {
      return const NovaCommand(NovaCommandKind.plugins);
    }
    if (q.startsWith('pesquisar ')) {
      return NovaCommand(NovaCommandKind.research,
          argument: input.trim().substring(11).trim());
    }
    if (q.startsWith('pesquise ')) {
      return NovaCommand(NovaCommandKind.research,
          argument: input.trim().substring(9).trim());
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
      'status', 'testes', 'rede neural', 'recursos', 'evoluir',
      'pesquisar <tema>', 'estude <tema>', 'estudar agora',
      'avaliar: pergunta | resposta esperada', 'backup',
      'exportar diagnostico', 'autonomia iniciar', 'autonomia parar',
      'estudo autonomo iniciar', 'estudo autonomo parar',
    ],
  });
}
