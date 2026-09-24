import 'nova_dashboard.dart';
import 'nova_evolution_engine.dart';
import 'nova_developmental_language.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
      title: 'Agente Autoevolutivo Quantico',
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
  final NovaAppearance appearance = NovaAppearance();
  DateTime createdAt = DateTime.now();
  int lastResponseMs = 0;
  bool memoryReady = false;
  String statusPensamento = "Repouso Quantico";
  bool isCarregando = true;
  bool isLendo = false;
  List<String> pluginsAdquiridos = [];
  List<Map<String, dynamic>> mensagens = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    arranqueBiologico();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
      await temporario.writeAsString(json.encode({'core': json.decode(cerebroMatriz.gerarPacoteCriogenico()), 'language': linguagem.exportState(), 'evolution': evolucao.exportState(), 'appearance': appearance.toJson(), 'createdAt': createdAt.toIso8601String(), 'messages': mensagens}), flush: true);
      if (await arquivoMemoria.exists()) {
        final anterior = File('${arquivoMemoria.path}.bak');
        await arquivoMemoria.copy(anterior.path);
      }
      await temporario.rename(arquivoMemoria.path);
    } catch (_) {}
  }

  Future<void> arranqueBiologico() async {
    final dir = await getApplicationDocumentsDirectory();
    arquivoMemoria = File('${dir.path}/matriz_neural_quantica_v6.json');
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

    setState(() {
      isCarregando = false;
      if (mensagens.isEmpty) mensagens.add({
        "texto": "NOVA local ativa. Memória simbólica disponível; modelo neural ainda não instalado.", 
        "isSystem": true
      });
    });
  }

  Future<void> processarEntrada(String textoUsuario) async {
    if (textoUsuario.trim().isEmpty || isLendo) return;

    String comando = textoUsuario.toLowerCase().trim();
    if (comando == 'evoluir' || comando == 'nova geracao') {
      final resultado = evolucao.evolve();
      setState(() {
        mensagens.add({'texto': textoUsuario, 'isUser': true});
        mensagens.add({'texto': resultado.accepted
            ? 'Geracao ${resultado.generation} aprovada. Snapshot: ${resultado.beforeBytes} -> ${resultado.afterBytes} bytes.'
            : 'Geracao mantida: ${resultado.reason}. Original: ${resultado.beforeBytes} bytes; candidato: ${resultado.afterBytes} bytes.',
            'isSystem': true});
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
    });

    final stopwatch = Stopwatch()..start();
    final resposta = linguagem.answer(textoUsuario);
    stopwatch.stop();
    lastResponseMs = stopwatch.elapsedMilliseconds;
    linguagem.learnConversation(textoUsuario);
    evolucao.observe(textoUsuario);
    cerebroMatriz.aprenderComOtimizacao(textoUsuario);
    final resultado = {'resposta': resposta};

    setState(() {
      statusPensamento = "Repouso Quantico";
      mensagens.add({"texto": resultado["resposta"], "isUser": false});
      rolarParaFinal();
    });

    await salvarMemoriaInstantanea();
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

      linguagem.learnDocument(texto, source: resultado.files.single.name);
      evolucao.observe(texto);
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
  }

  void rolarParaFinal() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
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

  void _researchStatus() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Pesquisa na web ainda não habilitada. '
        'A NOVA permanece offline.')));
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
      onEvolve: () => processarEntrada('evoluir'),
      onAppearance: () {
        setState(() {});
        salvarMemoriaInstantanea();
      },
      onResearch: _researchStatus,
      isReading: isLendo,
      plugins: pluginsAdquiridos,
      onPlugin: _pluginAction,
    );
  }
}
