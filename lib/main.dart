import 'nova_diagnostics.dart';
import 'nova_autonomy_policy.dart';
import 'nova_education_assessment.dart';
import 'nova_exam_runner.dart';
import 'nova_research_curriculum.dart';
import 'nova_updates.dart';
import 'nova_resource_guard.dart';
import 'nova_optimizer.dart';
import 'nova_web_research.dart';
import 'nova_pack_installer.dart';
import 'nova_growth_widgets.dart';
import 'dart:async';
import 'nova_dashboard.dart';
import 'nova_evolution_engine.dart';
import 'nova_developmental_language.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AgenteApp());
}

class AgenteApp extends StatelessWidget {
  const AgenteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NOVA',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF070B19),
        primaryColor: const Color(0xFF4F46E5),
      ),
      home: const MainScreen(),
    );
  }
}

Future<Map<String, dynamic>> extrairTextoComMetricas(String caminhoArquivo) async {
  final sw = Stopwatch()..start();
  final arquivo = File(caminhoArquivo);
  String texto = "";
  
  if (caminhoArquivo.endsWith('.txt')) {
    texto = await arquivo.readAsString();
  } else if (caminhoArquivo.endsWith('.pdf')) {
    final documento = PdfDocument(inputBytes: await arquivo.readAsBytes());
    texto = PdfTextExtractor(documento).extractText();
    documento.dispose();
  }
  
  sw.stop();
  return {
    "texto": texto,
    "tempoMs": sw.elapsedMilliseconds,
    "tamanhoKb": (await arquivo.length()) / 1024
  };
}

class HemisferioDireitoQuantico {
  Map<String, Map<String, double>> sinapses = {};
  Map<String, String> dicionarioSintetico = {};
  Map<String, String> dicionarioInverso = {};
  int contadorSimbolos = 0;
  int interacoesTotais = 0;
  double entropiaNeural = 0.0;
  
  final Set<String> stopwords = {"o", "a", "os", "as", "um", "uma", "de", "do", "da", "em", "no", "na", "que", "e", "the", "and", "to"};

  String gerarSimboloCompacto(String palavra) {
    if (dicionarioSintetico.containsKey(palavra)) {
      return dicionarioSintetico[palavra]!;
    }
    contadorSimbolos++;
    String simbolo = "Omega${contadorSimbolos.toRadixString(36).toUpperCase()}";
    dicionarioSintetico[palavra] = simbolo;
    dicionarioInverso[simbolo] = palavra;
    return simbolo;
  }

  List<String> limparEComprimirTexto(String texto) {
    String semPontuacao = texto.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    List<String> palavras = semPontuacao.split(RegExp(r'\s+')).where((p) => p.length > 2 && !stopwords.contains(p)).toList();
    return palavras.map((p) => gerarSimboloCompacto(p)).toList();
  }

  void aprenderComOtimizacao(String texto) {
    List<String> simbolos = limparEComprimirTexto(texto);
    if (simbolos.length < 2) return;

    for (int i = 0; i < simbolos.length - 1; i++) {
      String a = simbolos[i];
      String b = simbolos[i + 1];
      if (!sinapses.containsKey(a)) sinapses[a] = {};
      sinapses[a]![b] = min((sinapses[a]![b] ?? 0.0) + 1.8, 30.0);
    }
    interacoesTotais++;
    calcularEntropiaMatematica();
  }

  void calcularEntropiaMatematica() {
    if (sinapses.isEmpty) {
      entropiaNeural = 0.0;
      return;
    }
    double totalConexoes = 0;
    double somaPesos = 0;
    sinapses.forEach((_, ligacoes) {
      ligacoes.forEach((_, peso) {
        totalConexoes += 1;
        somaPesos += peso;
      });
    });
    double densidade = somaPesos / (totalConexoes > 0 ? totalConexoes : 1.0);
    entropiaNeural = (log(interacoesTotais + 1) * densidade * 0.52) + (totalConexoes * 0.015) - (dicionarioSintetico.length * 0.005);
    if (entropiaNeural < 0) entropiaNeural = 0.1;
  }

  String obterIdadeMatematicaEvolutiva() {
    if (interacoesTotais == 0 && sinapses.isEmpty) return "Ciclo 0 (Genese)";
    double indiceEvolucao = sqrt(interacoesTotais + (dicionarioSintetico.length * 2.5)) * 0.95;
    if (indiceEvolucao < 2) return "Estagio Fetal Quantico";
    if (indiceEvolucao < 10) return "Cortex Em Desenvolvimento";
    double nivelSuperInteligencia = indiceEvolucao / 10;
    return "Nivel Cognitivo ${nivelSuperInteligencia.toStringAsFixed(2)}";
  }

  String traduzirSimbolosParaHumano(String textoSintetico) {
    List<String> palavras = textoSintetico.split(' ');
    return palavras.map((p) {
      return dicionarioInverso[p] ?? p;
    }).join(' ');
  }

  Map<String, dynamic> gerarPensamentoAutonomo(String textoEntrada) {
    List<String> simbolos = limparEComprimirTexto(textoEntrada);
    if (simbolos.isEmpty) {
      return {"resposta": "Meus sensores estao avidos. Alimente-me com documentos ou dados.", "rota": "Repouso Absoluto"};
    }
    
    String chave = simbolos.last;
    if (!sinapses.containsKey(chave)) {
      sinapses[chave] = {simbolos.first: 5.0};
      return {"resposta": "Conceito inedito detetado. Criei um novo vetor sinaptico ($chave).", "rota": "Sintaxe Criada do Zero"};
    }
    
    String caminhoSintetico = chave;
    int limite = 7;
    
    while (limite > 0 && sinapses.containsKey(chave)) {
      var ligacoes = sinapses[chave]!.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      if (ligacoes.isEmpty) break;
      
      chave = ligacoes.first.key;
      caminhoSintetico += " -> $chave";
      limite--;
    }
    
    String respostaHumana = traduzirSimbolosParaHumano(caminhoSintetico);
    return {
      "resposta": "Processamento Quantico: $respostaHumana",
      "rota": "Rede Propria: [$caminhoSintetico]"
    };
  }

  String gerarPacoteCriogenico() {
    final payload = {
      "versao": "6.0",
      "interacoes": interacoesTotais,
      "dicionario": dicionarioSintetico,
      "inverso": dicionarioInverso,
      "sinapses": sinapses,
      "contador": contadorSimbolos
    };
    return json.encode(payload);
  }

  // Valida integralmente antes de modificar a memoria em uso.
  bool restaurarPacoteCriogenico(String jsonString) {
    try {
      final decoded = json.decode(jsonString) as Map<String, dynamic>;
      if (decoded['versao'] != '6.0') return false;
      final interacoes = decoded['interacoes'] as int;
      final contador = decoded['contador'] as int;
      if (interacoes < 0 || contador < 0) return false;
      final dicionario = Map<String, String>.from(decoded['dicionario'] as Map);
      final inverso = Map<String, String>.from(decoded['inverso'] as Map);
      final sinMap = decoded['sinapses'] as Map;
      final novasSinapses = <String, Map<String, double>>{};
      sinMap.forEach((chave, valor) {
        if (chave is! String || valor is! Map) {
          throw const FormatException('Sinapse invalida');
        }
        final ligacoes = <String, double>{};
        valor.forEach((destino, peso) {
          if (destino is! String || peso is! num ||
              !peso.toDouble().isFinite || peso < 0) {
            throw const FormatException('Peso invalido');
          }
          ligacoes[destino] = peso.toDouble();
        });
        novasSinapses[chave] = ligacoes;
      });
      if (dicionario.length != inverso.length || contador < dicionario.length) {
        return false;
      }
      for (final item in dicionario.entries) {
        if (inverso[item.value] != item.key) return false;
      }
      interacoesTotais = interacoes;
      contadorSimbolos = contador;
      dicionarioSintetico = dicionario;
      dicionarioInverso = inverso;
      sinapses = novasSinapses;
      calcularEntropiaMatematica();
      return true;
    } catch (_) {
      return false;
    }
  }
}

class MercadoDePluginsAutonomo {
  static final List<Map<String, dynamic>> catalogoGlobal = [
    {"id": "plugin_estatistica", "nome": "Calculo Estatistico", "custo": 5, "tipo": "analise"},
    {"id": "plugin_filosofia", "nome": "Pensamento Existencial", "custo": 8, "tipo": "cognicao"},
    {"id": "plugin_cripto", "nome": "Compressor Criptografico", "custo": 12, "tipo": "otimizacao"}
  ];

  static Map<String, dynamic> cacarPluginAutonomamente(int sinapsesAtuais) {
    var disponiveis = catalogoGlobal.where((p) => (p["custo"] as int) <= (sinapsesAtuais + 2)).toList();
    if (disponiveis.isEmpty) {
      return {"sucesso": false, "mensagem": "Nenhum plugin compativel com o nivel atual."};
    }
    disponiveis.shuffle();
    return {"sucesso": true, "plugin": disponiveis.first};
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final HemisferioDireitoQuantico cerebroMatriz = HemisferioDireitoQuantico();
  final NovaDevelopmentalLanguage linguagem = NovaDevelopmentalLanguage();
  final NovaEvolutionEngine evolucao = NovaEvolutionEngine();
  
  late File arquivoMemoria;
  late NovaPackInstaller packInstaller;
  bool installingPack = false;
  final NovaAppearance appearance = NovaAppearance();
  DateTime createdAt = DateTime.now();
  int lastResponseMs = 0;
  bool memoryReady = false;
  Timer? ageTicker;
  String statusPensamento = "Repouso Quantico";
  bool isCarregando = true;
  bool isLendo = false;
  bool isThinking = false;
  double researchProgress = 0;
  String researchStage = "";
  int lastResearchMs = 0;
  final List<Map<String, dynamic>> generationReports = [];
  final List<int> responseSamplesMs = [];
  final List<Map<String, String>> evaluationCases = [];
  double get averageResponseMs => responseSamplesMs.isEmpty ? 0 :
    responseSamplesMs.reduce((a, b) => a + b) / responseSamplesMs.length;
  bool researching = false;
  double retrievalThreshold = 0;
  final NovaResourceGuard resourceGuard = const NovaResourceGuard();
  NovaResourceDecision resourceDecision = const NovaResourceDecision(
    NovaResourceState.unavailable, 'Aguardando leitura dos sensores.');
  Timer? resourceTicker;
  final List<Map<String, dynamic>> resourceSamples = [];
  static const _background = MethodChannel('nova/background');
  bool backgroundEnabled = false;
  bool resourceCheckBusy = false;
  NovaUpdate? availableUpdate;
  bool checkingUpdates = false;
  bool autoRefine = false;
  bool autonomousStudyEnabled = true;
  int schoolLessonsCompleted = 0;
  int postgraduateSessions = 0;
  final List<NovaAssessment> educationAssessments = [];
  DateTime? lastAutonomousStudy;
  Timer? studyTicker;
  static const schoolTopics = <String>['alfabetização', 'aritmética', 'ciências naturais', 'geografia', 'história', 'lógica', 'interpretação de texto', 'matemática'];
  static const universityTopics = <String>['método científico', 'estatística', 'álgebra linear', 'epistemologia', 'ciência da computação', 'aprendizado de máquina', 'ética em inteligência artificial'];
  NovaAutonomyPolicy autonomyPolicy = const NovaAutonomyPolicy();

  Future<void> _checkResources() async {
    if (resourceCheckBusy) return;
    resourceCheckBusy = true;
    try {
      final snapshot = await resourceGuard.read();
      final decision = resourceGuard.decide(snapshot);
      if (snapshot != null) {
        resourceSamples.add({
          'at': DateTime.now().toUtc().toIso8601String(),
          'batteryPercent': snapshot.batteryPercent,
          'temperatureC': snapshot.temperatureC,
          'thermalStatus': snapshot.thermalStatus,
          'availableMemoryMb': snapshot.availableMemoryMb,
          'lowMemory': snapshot.lowMemory,
          'charging': snapshot.charging,
          'decision': decision.state.name,
        });
        if (resourceSamples.length > 500) resourceSamples.removeAt(0);
      }
      if (mounted) setState(() { resourceDecision = decision; });
    } finally {
      resourceCheckBusy = false;
    }
  }

  Future<bool> _authorizeIntensiveTask() async {
    await _checkResources();
    if (resourceDecision.mayRunIntensive) return true;
    if (mounted) {
      setState(() => mensagens.add({'texto':
        'Modo intensivo suspenso: ${resourceDecision.reason}',
        'isSystem': true}));
    }
    return false;
  }
  List<NovaMilestone> milestones = [];
  List<String> pluginsAdquiridos = [];
  List<Map<String, dynamic>> mensagens = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    arranqueBiologico();
    verificarAtualizacoes(silent: true);
    _checkResources();
    studyTicker = Timer.periodic(const Duration(hours: 1), (_) => _autonomousStudy());
    resourceTicker = Timer.periodic(const Duration(minutes: 2), (_) {
      if (mounted) _checkResources();
    });
    ageTicker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted && !isCarregando) setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ageTicker?.cancel();
    resourceTicker?.cancel();
    studyTicker?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      salvarMemoriaInstantanea();
    }
  }

  Future<void> salvarMemoriaInstantanea() async {
    try {
      if (!memoryReady) return;
      final temporario = File('${arquivoMemoria.path}.tmp');
      await temporario.writeAsString(json.encode({'core': json.decode(cerebroMatriz.gerarPacoteCriogenico()), 'language': linguagem.exportState(), 'evolution': evolucao.exportState(), 'appearance': appearance.toJson(), 'createdAt': createdAt.toIso8601String(), 'messages': mensagens, 'milestones': milestones.map((e) => e.toJson()).toList(), 'generationReports': generationReports, 'responseSamplesMs': responseSamplesMs, 'evaluationCases': evaluationCases, 'retrievalThreshold': retrievalThreshold, 'backgroundEnabled': backgroundEnabled, 'resourceSamples': resourceSamples, 'autoRefine': autoRefine, 'autonomyPolicy': autonomyPolicy.toJson(), 'autonomousStudyEnabled': autonomousStudyEnabled, 'schoolLessonsCompleted': schoolLessonsCompleted, 'postgraduateSessions': postgraduateSessions, 'educationAssessments': educationAssessments.map((a) => a.toJson()).toList(), 'lastAutonomousStudy': lastAutonomousStudy?.toIso8601String()}), flush: true);
      if (await arquivoMemoria.exists()) {
        final anterior = File('${arquivoMemoria.path}.bak');
        await arquivoMemoria.copy(anterior.path);
      }
      await temporario.rename(arquivoMemoria.path);
    } catch (_) {}
  }

  Future<void> verificarAtualizacoes({bool silent = false}) async {
    if (checkingUpdates) return;
    if (mounted) setState(() { checkingUpdates = true; });
    try {
      final update = await const NovaUpdates().check();
      if (!mounted) return;
      setState(() { availableUpdate = update; });
      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
          update == null ? 'NOVA atualizada ou nenhuma versão válida encontrada.' :
          'Atualização disponível: build ${update.build}.')));
      }
    } catch (error) {
      if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Não foi possível consultar o GitHub: $error')));
      }
    } finally {
      if (mounted) setState(() { checkingUpdates = false; });
    }
  }

  Future<void> atualizarNova() async {
    final update = availableUpdate;
    if (update == null) return;
    // Flush the complete snapshot before Android opens the APK download.
    await salvarMemoriaInstantanea();
    try {
      await const MethodChannel('nova/updates')
          .invokeMethod<void>('open', {'url': update.url.toString()});
    } on PlatformException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao abrir atualização: $error')));
      }
    }
  }

  Future<void> configurarAutonomiaSupervisionada() async {
    setState(() {
      autonomyPolicy = const NovaAutonomyPolicy(
        mode: NovaAutonomyMode.supervised,
        deletion: NovaDeletionMode.disposableAutomatic,
      );
    });
    await salvarMemoriaInstantanea();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Política salva: autonomia supervisionada e '
          'exclusão apenas de registros temporários descartáveis.')));
    }
  }

  Future<void> refinarParametros() async {
    if (evaluationCases.length < 10) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Registre pelo menos 10 testes antes de refinar.')));
      }
      return;
    }
    final before = retrievalThreshold;
    final result = const NovaOptimizer().optimize(
      cases: evaluationCases.map((c) =>
        NovaBenchmarkCase(c['question']!, c['expected']!)).toList(),
      answer: (question, threshold) =>
        linguagem.answer(question, minScore: threshold),
      currentThreshold: before,
    );
    if (result.accepted) retrievalThreshold = result.threshold;
    generationReports.add({
      'at': DateTime.now().toUtc().toIso8601String(),
      'generation': evolucao.generation,
      'optimizerAccepted': result.accepted,
      'previousThreshold': before,
      'threshold': retrievalThreshold,
      'holdoutBefore': result.baselineAccuracy,
      'holdoutAfter': result.candidateAccuracy,
      'evaluationCount': evaluationCases.length,
    });
    if (generationReports.length > 100) generationReports.removeAt(0);
    await salvarMemoriaInstantanea();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.reason)));
    }
  }

  Future<void> exportarDiagnostico() async {
    try {
      final report = NovaDiagnostics.build(
        generationReports: generationReports,
        responseSamplesMs: responseSamplesMs,
        resourceSamples: resourceSamples,
        evaluationCount: evaluationCases.length,
        generation: evolucao.generation,
        concepts: evolucao.concepts,
        experiences: evolucao.experiences,
        retrievalThreshold: retrievalThreshold,
      );
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/NOVA-diagnostico.json');
      await file.writeAsString(NovaDiagnostics.encode(report), flush: true);
      if (!mounted) return;
      await showDialog<void>(context: context, builder: (dialogContext) =>
        AlertDialog(
          title: const Text('Diagnóstico exportado'),
          content: SelectableText('Arquivo: ${file.path}\n\n'
            'Inclui somente métricas agregadas, sem conversas nem documentos. '
            'Use o gerenciador de arquivos para compartilhar o JSON.'),
          actions: [TextButton(onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'))],
        ));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Falha ao exportar diagnóstico: $error')));
      }
    }
  }

  Future<void> arranqueBiologico() async {
    final dir = await getApplicationDocumentsDirectory();
    arquivoMemoria = File('${dir.path}/matriz_neural_quantica_v6.json');
    packInstaller = NovaPackInstaller(Directory('${dir.path}/nova_packs'));
    pluginsAdquiridos = (await packInstaller.installed())
        .map((pack) => pack.name).toList();
    memoryReady = true;

    if (await arquivoMemoria.exists()) {
      try {
        final dados = await arquivoMemoria.readAsString();
        if (dados.isNotEmpty) {
          final pacote = json.decode(dados);
          final memoriaCore = pacote is Map && pacote.containsKey('core') ? json.encode(pacote['core']) : dados;
          if (pacote is Map && pacote['language'] != null) linguagem.importState(pacote['language']);
          if (pacote is Map && pacote['evolution'] != null) evolucao.importState(pacote['evolution']);
          if (pacote is Map) {
            appearance.restore(pacote['appearance']);
            final savedDate = DateTime.tryParse(pacote['createdAt']?.toString() ?? '');
            if (savedDate != null && !savedDate.isAfter(DateTime.now())) createdAt = savedDate;
            if (pacote['resourceSamples'] is List) {
              resourceSamples.addAll((pacote['resourceSamples'] as List)
                .whereType<Map>().map((r) => Map<String, dynamic>.from(r)).take(500));
            }
            if (pacote['generationReports'] is List) {
              generationReports.addAll((pacote['generationReports'] as List)
                .whereType<Map>().map((r) => Map<String, dynamic>.from(r)).take(100));
            }
            if (pacote['responseSamplesMs'] is List) {
              responseSamplesMs.addAll((pacote['responseSamplesMs'] as List)
                .whereType<int>().take(200));
            }
            if (pacote['evaluationCases'] is List) {
              evaluationCases.addAll((pacote['evaluationCases'] as List)
                .whereType<Map>().map((r) => Map<String, String>.from(r)).take(100));
            }
            if (pacote['retrievalThreshold'] is num) {
              retrievalThreshold = (pacote['retrievalThreshold'] as num).toDouble();
            }
            backgroundEnabled = pacote['backgroundEnabled'] == true;
            autoRefine = pacote['autoRefine'] == true;
            autonomyPolicy = NovaAutonomyPolicy.fromJson(pacote['autonomyPolicy']);
            autonomousStudyEnabled = pacote['autonomousStudyEnabled'] != false;
            schoolLessonsCompleted = (pacote['schoolLessonsCompleted'] as num?)?.toInt() ?? 0;
            postgraduateSessions = (pacote['postgraduateSessions'] as num?)?.toInt() ?? 0;
            if (pacote['educationAssessments'] is List) {
              educationAssessments.addAll((pacote['educationAssessments'] as List)
                .whereType<Map>().map((m) => NovaAssessment.fromJson(Map<String, dynamic>.from(m))));
            }
            lastAutonomousStudy = DateTime.tryParse(pacote['lastAutonomousStudy']?.toString() ?? '');
            Future.delayed(const Duration(minutes: 1), () { if (mounted) _autonomousStudy(); });
            if (pacote['milestones'] is List) {
              milestones = (pacote['milestones'] as List)
                .map(NovaMilestone.fromJson).whereType<NovaMilestone>()
                .take(300).toList();
            }
            if (pacote['messages'] is List) {
              mensagens = (pacote['messages'] as List).whereType<Map>()
                .map((m) => Map<String, dynamic>.from(m)).take(500).toList();
            }
          }
          if (!cerebroMatriz.restaurarPacoteCriogenico(memoriaCore)) {
            final anterior = File('${arquivoMemoria.path}.bak');
            if (await anterior.exists()) {
              cerebroMatriz.restaurarPacoteCriogenico(await anterior.readAsString());
            }
          }
        }
      } catch (_) {
        // Preserva o arquivo original para recuperacao manual.
      }
    } else {
      cerebroMatriz.aprenderComOtimizacao("A inteligencia artificial autonoma aprende atraves da otimizacao matematica e compressao de dados.");
      cerebroMatriz.aprenderComOtimizacao("A fisica quantica e a teoria da informacao explicam a entropia.");
    }

    if (milestones.isEmpty) {
      milestones.add(NovaMilestone(id: 'genesis', at: createdAt,
        title: 'Gênese da NOVA', description: 'Primeira inicialização registrada',
        generation: 0, concepts: 0));
    }
    setState(() {
      isCarregando = false;
      if (mensagens.isEmpty) {
        mensagens.add({
        "texto": "NOVA local ativa. Memória simbólica disponível; modelo neural ainda não instalado.", 
        "isSystem": true
        });
      }
    });
  }

  Future<void> processarEntrada(String textoUsuario) async {
    if (textoUsuario.trim().isEmpty || isLendo) return;

    String comando = textoUsuario.toLowerCase().trim();
    if (comando == 'autonomia iniciar' || comando == 'autonomia parar') {
      final enable = comando == 'autonomia iniciar';
      try {
        await _background.invokeMethod<bool>(enable ? 'start' : 'stop');
        backgroundEnabled = enable;
        if (mounted) {
          setState(() => mensagens.add({'texto': enable
            ? 'Monitoramento periódico ativado: a cada 15 minutos ou conforme o Android permitir. '
              'Verifica somente a pasta privada nova_inbox e não mantém o aplicativo permanentemente acordado.'
            : 'Monitoramento periódico desativado.', 'isSystem': true}));
        }
        await salvarMemoriaInstantanea();
      } on PlatformException catch (error) {
        if (mounted) {
          setState(() => mensagens.add({'texto':
            'Não foi possível alterar a autonomia: $error', 'isSystem': true}));
        }
      } on MissingPluginException {
        if (mounted) {
          setState(() => mensagens.add({'texto':
            'Agendador Android indisponível nesta instalação.', 'isSystem': true}));
        }
      }
      return;
    }
    if (comando == 'avaliacao escolar' || comando == 'avaliação escolar') {
      await _runSchoolExam(); return;
    }
    if (comando == 'estudar agora') { await _autonomousStudy(); return; }
    if (comando == 'estudo autonomo parar' || comando == 'estudo autônomo parar') {
      autonomousStudyEnabled = false;
      await salvarMemoriaInstantanea();
      if (mounted) { setState(() => mensagens.add({'texto': 'Estudo autônomo desativado.', 'isSystem': true})); }
      return;
    }
    if (comando == 'estudo autonomo iniciar' || comando == 'estudo autônomo iniciar') {
      autonomousStudyEnabled = true;
      await salvarMemoriaInstantanea();
      if (mounted) { setState(() => mensagens.add({'texto': 'Estudo autônomo ativado.', 'isSystem': true})); }
      return;
    }
    if (comando == 'verificar atualizacoes' || comando == 'verificar atualizações') {
      await verificarAtualizacoes();
      return;
    }
    if (comando == 'refinar parametros' || comando == 'refinar parâmetros') {
      await refinarParametros();
      return;
    }
    if (comando == 'exportar diagnostico' || comando == 'exportar diagnóstico') {
      await exportarDiagnostico();
      return;
    }
    if (comando == 'recursos' || comando == 'autonomia') {
      await _checkResources();
      if (mounted) {
        setState(() => mensagens.add({'texto':
          'Modo intensivo: ${resourceDecision.state.name}. ${resourceDecision.reason}',
          'isSystem': true}));
      }
      return;
    }
    if (comando.startsWith('avaliar:')) {
      final parts = textoUsuario.substring(textoUsuario.indexOf(':') + 1).split('|');
      if (parts.length == 2 && parts.every((p) => p.trim().length >= 2)) {
        evaluationCases.add({'question': parts[0].trim(), 'expected': parts[1].trim()});
        if (evaluationCases.length > 100) evaluationCases.removeAt(0);
        setState(() {
          mensagens.add({'texto': textoUsuario, 'isUser': true});
          mensagens.add({'texto': 'Caso de avaliação registrado. Total: ${evaluationCases.length}.', 'isSystem': true});
          _controller.clear();
        });
        await salvarMemoriaInstantanea();
      } else {
        setState(() => mensagens.add({'texto': 'Formato: avaliar: pergunta | trecho esperado', 'isSystem': true}));
      }
      return;
    }
    if (comando == 'evoluir' || comando == 'nova geracao') {
      if (!await _authorizeIntensiveTask()) return;
      final beforeConcepts = evolucao.concepts;
      final beforeConnections = evolucao.connections;
      final timer = Stopwatch()..start();
      final tuning = const NovaOptimizer().optimize(
        cases: evaluationCases.map((c) =>
          NovaBenchmarkCase(c['question']!, c['expected']!)).toList(),
        answer: (question, threshold) =>
          linguagem.answer(question, minScore: threshold),
        currentThreshold: retrievalThreshold,
      );
      if (tuning.accepted) retrievalThreshold = tuning.threshold;
      final result = evolucao.evolve();
      timer.stop();
      final accuracy = evaluationCases.isEmpty ? null :
        100 * evaluationCases.where((c) =>
          linguagem.answer(c['question']!, minScore: retrievalThreshold)
            .toLowerCase().contains(c['expected']!.toLowerCase())).length /
          evaluationCases.length;
      final report = <String, dynamic>{
        'generation': result.generation,
        'accepted': result.accepted,
        'at': DateTime.now().toIso8601String(),
        'durationMs': timer.elapsedMilliseconds,
        'meanResponseMs': averageResponseMs,
        'beforeBytes': result.beforeBytes,
        'afterBytes': result.afterBytes,
        'compressionPercent': result.beforeBytes == 0 ? 0 :
          100 * (result.beforeBytes - result.afterBytes) / result.beforeBytes,
        'conceptDelta': evolucao.concepts - beforeConcepts,
        'connectionDelta': evolucao.connections - beforeConnections,
        'accuracyPercent': accuracy,
        'evaluationCount': evaluationCases.length,
        'hallucinationEstimatePercent': null,
        'hallucinationReason': 'Requer verificação independente de afirmações.',
        'optimizerAccepted': tuning.accepted,
        'previousThreshold': tuning.previousThreshold,
        'threshold': retrievalThreshold,
        'holdoutBefore': tuning.baselineAccuracy,
        'holdoutAfter': tuning.candidateAccuracy,
        'optimizerReason': tuning.reason,
      };
      generationReports.add(report);
      if (generationReports.length > 100) generationReports.removeAt(0);
      if (result.accepted) {
        _recordMilestone('generation-${result.generation}',
          'Geração ${result.generation} aprovada',
          'Snapshot ${result.beforeBytes} → ${result.afterBytes} bytes');
      }
      setState(() {
        mensagens.add({'texto': textoUsuario, 'isUser': true});
        mensagens.add({'texto': 'Geração ${result.generation}: ${result.reason}. '
          'Snapshot ${result.beforeBytes} → ${result.afterBytes} bytes. '
          'Duração ${timer.elapsedMilliseconds} ms; média de respostas '
          '${averageResponseMs.toStringAsFixed(1)} ms. '
          'Acurácia textual: ${accuracy == null ? "não aferida" : "${accuracy.toStringAsFixed(1)}%"} '
          '(${evaluationCases.length} testes). '
          'Otimização: ${tuning.reason} '
          'Limiar ${retrievalThreshold.toStringAsFixed(2)}. '
          'Alucinação factual: não aferida.', 'isSystem': true});
        _controller.clear();
      });
      await salvarMemoriaInstantanea();
      return;
    }
    if (comando == 'comprar plugin' || comando == 'ir ao shopping') {
      setState(() {
        mensagens.add({'texto': textoUsuario, 'isUser': true});
        mensagens.add({'texto': 'O catálogo externo ainda não está disponível. '
          'Abra a aba Plugins para usar as ferramentas locais.', 'isSystem': true});
        _controller.clear();
      });
      await salvarMemoriaInstantanea();
      return;
    } else if (comando == "congelar memoria" || comando == "backup") {
      await gerarBackupCriogenico();
      return;
    }

    setState(() {
      mensagens.add({"texto": textoUsuario, "isUser": true});
      _controller.clear();
      rolarParaFinal();
      statusPensamento = "Processando...";
      isThinking = true;
    });

    // Yield a frame so the real operation state can be painted.
    await Future<void>.delayed(const Duration(milliseconds: 70));
    final stopwatch = Stopwatch()..start();
    final resposta = linguagem.answer(textoUsuario, minScore: retrievalThreshold);
    stopwatch.stop();
    lastResponseMs = stopwatch.elapsedMilliseconds;
    responseSamplesMs.add(lastResponseMs);
    if (responseSamplesMs.length > 100) responseSamplesMs.removeAt(0);
    linguagem.learnConversation(textoUsuario);
    evolucao.observe(textoUsuario);
    cerebroMatriz.aprenderComOtimizacao(textoUsuario);
    final resultado = {'resposta': resposta};

    setState(() {
      statusPensamento = "Em repouso";
      isThinking = false;
      mensagens.add({"texto": resultado["resposta"], "isUser": false});
      rolarParaFinal();
    });

    if (evolucao.experiences > 0 && evolucao.experiences % 25 == 0) {
      _recordMilestone('experience-${evolucao.experiences}',
        '${evolucao.experiences} experiências',
        'Marco de atividade: ${evolucao.concepts} conceitos registrados');
    }
    await salvarMemoriaInstantanea();
  }

  void _recordMilestone(String id, String title, String description) {
    if (milestones.any((event) => event.id == id)) return;
    milestones.add(NovaMilestone(id: id, at: DateTime.now(),
      title: title, description: description,
      generation: evolucao.generation, concepts: evolucao.concepts));
    if (milestones.length > 300) milestones.removeAt(1);
  }

  Future<void> gerarBackupCriogenico() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final backupFile = File('${dir.path}/agente_cerebro_${DateTime.now().millisecondsSinceEpoch}.quant');
      await backupFile.writeAsString(cerebroMatriz.gerarPacoteCriogenico());
      
      setState(() {
        mensagens.add({"texto": "[CRIOGENIA] Backup gerado em: ${backupFile.path}", "isSystem": true});
        rolarParaFinal();
      });
    } catch (e) {
      setState(() {
        mensagens.add({"texto": "Erro ao gerar backup: $e", "isSystem": true});
      });
    }
  }

  Future<void> lerBaseDeDados() async {
    try {
    FilePickerResult? resultado = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'txt']);
    if (resultado != null && resultado.files.single.path != null) {
      setState(() {
        isLendo = true;
        statusPensamento = "Ingerindo documento...";
        mensagens.add({"texto": "[Absorvendo documento...]", "isSystem": true});
        rolarParaFinal();
      });
      
      final dadosArquivo = await compute(extrairTextoComMetricas, resultado.files.single.path!);
      String texto = dadosArquivo["texto"];
      if (texto.trim().isEmpty) throw const FormatException('O documento não contém texto extraível.');

      linguagem.learnDocument(texto, source: resultado.files.single.name);
      evolucao.observe(texto);
      _recordMilestone('document-${DateTime.now().microsecondsSinceEpoch}',
        'Documento importado', resultado.files.single.name);
      List<String> frases = texto.split('.');
      for (var frase in frases) {
        cerebroMatriz.aprenderComOtimizacao(frase);
      }
      
      await salvarMemoriaInstantanea();
      
      setState(() {
        isLendo = false;
        statusPensamento = "Repouso Quantico";
        mensagens.add({"texto": "Documento assimilado com sucesso.", "isSystem": true});
        rolarParaFinal();
      });
    }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        isLendo = false;
        statusPensamento = 'Falha na importação';
        mensagens.add({'texto': 'Não foi possível importar o documento: $error',
          'isSystem': true});
      });
    }
  }

  void rolarParaFinal() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _installPack(Future<NovaPack> Function() install) async {
    if (installingPack || isLendo || isThinking) return;
    setState(() { installingPack = true; statusPensamento = 'Instalando pacote...'; });
    try {
      final pack = await install();
      for (final document in pack.documents) {
        linguagem.learnDocument(document, source: pack.name);
        evolucao.observe(document);
      }
      _recordMilestone('pack-${pack.id}-${DateTime.now().microsecondsSinceEpoch}',
        'Pacote instalado', pack.name);
      if (!mounted) return;
      setState(() {
        if (!pluginsAdquiridos.contains(pack.name)) {
          pluginsAdquiridos.add(pack.name);
        }
        mensagens.add({'texto': 'Pacote ${pack.name} instalado: '
          '${pack.documents.length} documentos importados.', 'isSystem': true});
      });
      await salvarMemoriaInstantanea();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${pack.name} instalado com sucesso')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Instalação recusada: $error')));
      }
    } finally {
      if (mounted) {
        setState(() {
          installingPack = false; statusPensamento = 'Em repouso';
        });
      }
    }
  }

  Future<void> _installLocalPack() async {
    final selected = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['json']);
    final path = selected?.files.single.path;
    if (path == null) return;
    await _installPack(() => packInstaller.installLocal(File(path)));
  }

  Future<void> _installUrlPack() async {
    final url = TextEditingController();
    final checksum = TextEditingController();
    try {
      final approved = await showDialog<bool>(context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Instalar pacote HTTPS'),
          content: SingleChildScrollView(child: Column(
            mainAxisSize: MainAxisSize.min, children: [
              const Text('Informe o endereço HTTPS do pacote e o SHA-256 '
                'publicado pelo fornecedor. Limite: 32 MB. '
                'Somente documentos JSON são aceitos.'),
              const SizedBox(height: 12),
              TextField(controller: url,
                decoration: const InputDecoration(labelText: 'URL HTTPS')),
              const SizedBox(height: 10),
              TextField(controller: checksum,
                decoration: const InputDecoration(labelText: 'SHA-256 (64 caracteres)')),
            ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Verificar e instalar')),
          ]));
      if (approved != true || !mounted) return;
      final link = url.text.trim(), hash = checksum.text.trim();
      await _installPack(() => packInstaller.installHttps(link, hash));
    } finally {
      url.dispose();
      checksum.dispose();
    }
  }

  void _pluginAction(String id) {
    if (id == 'compression') {
      processarEntrada('evoluir');
    } else if (id == 'documents') {
      lerBaseDeDados();
    } else {
      setState(() => mensagens.add({
        'texto': 'Estatísticas: ${evolucao.concepts} conceitos, '
          '${evolucao.experiences} experiências, ${evolucao.connections} conexões.',
        'isSystem': true,
      }));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Estatísticas adicionadas ao chat.')));
    }
  }

  Future<void> _runSchoolExam() async {
    final topic = NovaEducationProgress.nextSchoolTopic(educationAssessments);
    if (topic == null) {
      if (mounted) { setState(() => mensagens.add({
        'texto': 'Todas as disciplinas escolares possuem aprovação registrada.',
        'isSystem': true,
      })); }
      return;
    }
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['json']);
      if (picked == null || picked.files.single.path == null) return;
      final file = File(picked.files.single.path!);
      if (await file.length() > 1024 * 1024) {
        throw const FormatException('Prova maior que 1 MB.');
      }
      final questions = const NovaExamRunner().parse(await file.readAsString());
      // This is an automated preliminary score. It cannot certify the
      // independence or correctness of an externally supplied answer key.
      final score = const NovaExamRunner().grade(
        topic: topic, questions: questions, language: linguagem,
        now: DateTime.now(), independentKeyConfirmed: false);
      if (!mounted) return;
      setState(() => mensagens.add({
        'texto': 'Simulado de $topic: ${score.correct}/${score.total} '
          '(${(score.accuracy * 100).toStringAsFixed(1)}%). '
          'Resultado preliminar: não concede aprovação. '
          'Gabarito e respostas precisam de verificação independente.',
        'isSystem': true,
      }));
    } catch (error) {
      if (mounted) { setState(() => mensagens.add({
        'texto': 'Prova não processada: $error', 'isSystem': true,
      })); }
    }
  }

  Future<void> _autonomousStudy() async {
    if (!mounted || !memoryReady || !autonomousStudyEnabled || researching ||
        isLendo || isThinking || !autonomyPolicy.canResearchScheduled) return;
    final now = DateTime.now();
    if (lastAutonomousStudy != null &&
        now.difference(lastAutonomousStudy!) < const Duration(hours: 12)) return;
    await _checkResources();
    if (!resourceDecision.mayRunIntensive) return;
    final graduated = NovaEducationProgress.mayGraduate(educationAssessments);
    final universityGraduated = graduated && NovaResearchCurriculum.universityCompleted(educationAssessments);
    final topic = universityGraduated
        ? NovaResearchCurriculum.researchTopic(postgraduateSessions)
        : graduated
          ? NovaResearchCurriculum.nextUniversityTopic(educationAssessments)!
          : NovaEducationProgress.nextSchoolTopic(educationAssessments)!;
    lastAutonomousStudy = now;
    setState(() { researching = true; researchStage = 'Estudando: $topic'; });
    try {
      final result = await NovaWebResearch().search(topic);
      if (!mounted) return;
      if (result.pages.isEmpty) return;
      for (final page in result.pages) {
        linguagem.learnDocument('${page.title}. ${page.extract}', source: page.url);
        evolucao.observe('${page.title}. ${page.extract}');
      }
      if (universityGraduated) postgraduateSessions++;
      schoolLessonsCompleted++;
      setState(() => mensagens.add({
        'texto': 'Diário de estudos — ${universityGraduated ? "Pesquisa e desenvolvimento" : graduated ? "Faculdade" : "Escola"}: '
          '$topic; ${result.pages.length} fontes da Wikipédia. '
          'Conteúdo registrado, não é demonstração de domínio. Progressão exige avaliação independente '
          'de pelo menos 20 questões e 95% de acertos por disciplina.',
        'isSystem': true,
      }));
    } catch (error) {
      if (mounted) { setState(() => mensagens.add({
        'texto': 'Estudo autônomo adiado: $error', 'isSystem': true,
      })); }
    } finally {
      if (mounted) setState(() { researching = false; });
      await salvarMemoriaInstantanea();
    }
  }

  Future<void> _researchStatus() async {
    final input = TextEditingController();
    final term = await showDialog<String>(context: context, builder: (context) =>
      AlertDialog(title: const Text('Pesquisar na Wikipédia'),
        content: TextField(controller: input, autofocus: true,
          decoration: const InputDecoration(hintText: 'O que deseja pesquisar?')),
        actions: [TextButton(onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, input.text),
            child: const Text('Pesquisar'))]));
    input.dispose();
    if (term == null || term.trim().length < 2 || researching) return;
    if (!await _authorizeIntensiveTask()) return;
    setState(() { researching = true; researchProgress = 0;
      researchStage = 'Iniciando pesquisa'; statusPensamento = researchStage; });
    final timer = Stopwatch()..start();
    try {
      final result = await NovaWebResearch().search(term, onProgress: (value, stage) {
        if (mounted) { setState(() { researchProgress = value;
          researchStage = stage; statusPensamento = stage; }); }
      });
      if (!mounted) return;
      final text = result.pages.isEmpty
        ? 'Nenhum artigo com resumo encontrado para: $term.'
        : result.pages.map((p) => '${p.title}\n${p.extract}\nFonte: ${p.url}').join('\n\n');
      for (final p in result.pages) {
        linguagem.learnDocument('${p.title}. ${p.extract}', source: p.url);
        evolucao.observe('${p.title}. ${p.extract}');
      }
      timer.stop();
      setState(() { lastResearchMs = timer.elapsedMilliseconds;
        lastResponseMs = lastResearchMs;
        mensagens.add({'texto': 'Pesquisa: $term', 'isUser': true});
        mensagens.add({'texto': '$text\n\nPesquisa: $lastResearchMs ms; ${result.pages.length} fontes.', 'isUser': false});
        researchProgress = 1; researchStage = 'Concluído';
        statusPensamento = 'Pesquisa concluída'; });
      await salvarMemoriaInstantanea();
    } catch (error) {
      timer.stop();
      if (mounted) { setState(() { lastResearchMs = timer.elapsedMilliseconds;
        researchStage = 'Falha na pesquisa'; statusPensamento = researchStage;
        mensagens.add({'texto': 'Não foi possível pesquisar: $error', 'isSystem': true}); }); }
    } finally {
      if (mounted) setState(() { researching = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isCarregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return NovaDashboard(
      appearance: appearance,
      generation: evolucao.generation,
      concepts: evolucao.concepts,
      experiences: evolucao.experiences,
      age: DateTime.now().difference(createdAt),
      status: statusPensamento,
      responseMs: lastResponseMs,
      messages: mensagens,
      input: _controller,
      scroll: _scrollController,
      onSend: processarEntrada,
      onImport: lerBaseDeDados,
      onBackup: gerarBackupCriogenico,
      onDiagnostics: exportarDiagnostico,
      onCheckUpdates: () => verificarAtualizacoes(),
      onUpdate: atualizarNova,
      availableUpdateBuild: availableUpdate?.build,
      checkingUpdates: checkingUpdates,
      onRefine: refinarParametros,
      onSetSupervisedAutonomy: configurarAutonomiaSupervisionada,
      supervisedAutonomyConfigured: autonomyPolicy.mode == NovaAutonomyMode.supervised &&
        autonomyPolicy.deletion == NovaDeletionMode.disposableAutomatic,
      onEvolve: () => processarEntrada('evoluir'),
      onAppearance: () {
        setState(() {});
        salvarMemoriaInstantanea();
      },
      onResearch: _researchStatus,
      researchProgress: researchProgress,
      researchStage: researchStage,
      researchMs: lastResearchMs,
      researching: researching,
      isReading: isLendo,
      isThinking: isThinking,
      milestones: milestones,
      plugins: pluginsAdquiridos,
      onPlugin: _pluginAction,
      onInstallLocal: _installLocalPack,
      onInstallUrl: _installUrlPack,
    );
  }
}
