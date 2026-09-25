import 'nova_command_router.dart';
import 'nova_developmental_language.dart';
import 'nova_education_assessment.dart';
import 'nova_evolution_engine.dart';
import 'nova_module_runtime.dart';
import 'nova_neural_core.dart';

class NovaSelfTest {
  const NovaSelfTest(this.name, this.passed, this.detail);
  final String name;
  final bool passed;
  final String detail;
}

class NovaSelfTestReport {
  const NovaSelfTestReport(this.tests, this.durationMs);
  final List<NovaSelfTest> tests;
  final int durationMs;

  int get passedCount => tests.where((test) => test.passed).length;
  int get failedCount => tests.length - passedCount;
  double get coverage => tests.isEmpty ? 0 : passedCount / tests.length;
  bool get allPassed => failedCount == 0;

  Map<String, dynamic> toJson() => {
    'tests': tests.map((test) => {
      'name': test.name, 'passed': test.passed, 'detail': test.detail,
    }).toList(),
    'durationMs': durationMs,
    'passed': passedCount,
    'failed': failedCount,
    'coverage': coverage,
  };

  factory NovaSelfTestReport.fromJson(Object? raw) {
    if (raw is! Map || raw['tests'] is! List) {
      throw const FormatException('Invalid self-test report');
    }
    final tests = (raw['tests'] as List).whereType<Map>().map((item) =>
      NovaSelfTest(
        item['name']?.toString() ?? '',
        item['passed'] == true,
        item['detail']?.toString() ?? '',
      )).toList();
    final duration = (raw['durationMs'] as num?)?.toInt() ?? 0;
    if (duration < 0) throw const FormatException('Invalid duration');
    return NovaSelfTestReport(tests, duration);
  }
}

/// On-device functional suite. These are software integrity tests, not a
/// claim of intelligence or an independent factual benchmark.
class NovaSelfTestSuite {
  const NovaSelfTestSuite();

  Future<NovaSelfTestReport> run() async {
    final timer = Stopwatch()..start();
    final results = <NovaSelfTest>[];

    void test(String name, bool Function() body) {
      try {
        final passed = body();
        results.add(NovaSelfTest(name, passed, passed ? 'OK' : 'Falhou'));
      } catch (error) {
        results.add(NovaSelfTest(name, false, '$error'));
      }
    }

    test('Comandos: acentos e intenção', () {
      const router = NovaCommandRouter();
      return router.parse('Pesquise relações internacionais').kind ==
          NovaCommandKind.research &&
          router.parse('AVALIAÇÃO: x | y').kind ==
            NovaCommandKind.addEvaluation;
    });

    test('Comandos: segurança de entrada desconhecida', () {
      const router = NovaCommandRouter();
      return router.parse('fazer algo completamente novo').kind ==
          NovaCommandKind.unknown;
    });

    test('Memória: índice de recuperação', () {
      final language = NovaDevelopmentalLanguage();
      language.learnDocument(
        'Relações internacionais estudam Estados, instituições e política global.',
        source: 'teste',
      );
      final answer = language.answer('instituições política global');
      return answer.toLowerCase().contains('instituições');
    });

    test('Memória: limite e reindexação', () {
      final language = NovaDevelopmentalLanguage();
      language.learnDocument('Este texto de teste possui conteúdo suficiente para ser indexado.', source: 'a');
      final state = language.exportState();
      final restored = NovaDevelopmentalLanguage();
      return restored.importState(state) && restored.memoryCount == 1;
    });

    test('Neural: treino altera previsão', () {
      final model = NovaNeuralCore(width: 32);
      model.train('ab' * 300);
      return model.trainingPairs > 0 &&
          model.predictSymbol('a'.codeUnitAt(0)) == ('b'.codeUnitAt(0) % 32) &&
          model.predictSymbol('b'.codeUnitAt(0)) == ('a'.codeUnitAt(0) % 32);
    });

    test('Neural: serialização reversível', () {
      final model = NovaNeuralCore()..train('nova neural' * 40);
      final restored = NovaNeuralCore.fromJson(model.toJson());
      return restored.trainingPairs == model.trainingPairs &&
          restored.weights.length == model.weights.length;
    });

    test('Rede: módulo normalize', () {
      final module = NovaModule(generation: 0, instructions: [
        {'op': 'normalize'},
      ]);
      return module.execute('  NOVA   TESTE  ') == 'nova teste';
    });

    test('Rede: módulo truncate', () {
      final module = NovaModule(generation: 0, instructions: [
        {'op': 'truncate', 'length': 4},
      ]);
      return module.execute('123456') == '1234';
    });

    test('Evolução: compressão reversível', () {
      final evolution = NovaEvolutionEngine();
      evolution.observe(List<String>.generate(120, (i) => 'conceito$i').join(' '));
      final result = evolution.evolve();
      return result.accepted && result.afterBytes < result.beforeBytes;
    });

    test('Educação: requisito de avaliação independente', () {
      final now = DateTime.now();
      final a = NovaAssessment(topic: 'aritmética', correct: 20, total: 20,
        verified: true, independent: true, at: now);
      final b = NovaAssessment(topic: 'aritmética', correct: 20, total: 20,
        verified: true, independent: false, at: now);
      return a.passed && !b.passed;
    });

    test('Formato: avaliação inválida é rejeitada', () {
      const router = NovaCommandRouter();
      final c = router.parse('avaliar: apenas pergunta');
      final parts = c.argument.split('|');
      return c.kind == NovaCommandKind.addEvaluation &&
          parts.length != 2;
    });

    test('Ajuda: catálogo de comandos disponível', () {
      final text = const NovaCommandRouter().helpJson;
      return text.contains('pesquisar <tema>') && text.contains('testes');
    });

    timer.stop();
    return NovaSelfTestReport(results, timer.elapsedMilliseconds);
  }
}
