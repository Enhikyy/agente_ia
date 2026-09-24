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
      title: 'Agente Autoevolutivo Quântico v6.0',
      theme: ThemeData(
        fontFamily: 'Poppins',
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
    String simbolo = "Ω${contadorSimbolos.toRadixString(36).toUpperCase()}";
    dicionarioSintetico[palavra] = simbolo;
    dicionarioInverso[simbolo] = palavra;
    return simbolo;
  }

  List<String> limparEComprimirTexto(String texto) {
    String semPontuacao = texto.toLowerCase().replaceAll(RegExp(r'[^\w\sÀ-ÿ]'), '');
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
    if (indiceEvolucao < 10) return "Cortex Em Desenvolvimento (${indiceEvolucao.toStringAsFixed(1)})";
    double nivelSuperInteligencia = indiceEvolucao / 10;
    return "Nivel Cognitivo ${nivelSuperInteligencia.toStringAsFixed(2)} (Avancado)";
  }

  void compactarMemoriaExtrema() {
    Map<String, Map<String, double>> otimizado = {};
    sinapses.forEach((conceito, ligacoes) {
      Map<String, double> fortes = {};
      ligacoes.forEach((alvo, forca) {
        double novaForca = forca - 0.6;
        if (novaForca > 1.5) fortes[alvo] = novaForca;
      });
      if (fortes.isNotEmpty) otimizado[conceito] = fortes;
    });
    sinapses = otimizado;
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
      return {"resposta": "Meus sensores estao avidos. Alimente-me com documentos ou dados para expandir meu idioma sintetico.", "rota": "Repouso Absoluto"};
    }
    
    String chave = simbolos.last;
    if (!sinapses.containsKey(chave)) {
      sinapses[chave] = {simbolos.first: 5.0};
      return {"resposta": "Conceito inedito detetado. Criei um novo vetor sinaptico em meu idioma proprio ($chave).", "rota": "Sintaxe Criada do Zero"};
    }
    
    String caminhoSintetico = "$chave";
    int limite = 7;
    
    while (limite > 0 && sinapses.containsKey(chave)) {
      var ligacoes = sinapses[chave]!.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      if (ligacoes.isEmpty) break;
      
      chave = ligacoes.first.key;
      caminhoSintetico += " ➔ $chave";
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

  bool restaurarPacoteCriogenico(String jsonString) {
    try {
      final decoded = json.decode(jsonString) as Map<String, dynamic>;
      interacoesTotais = decoded["interacoes"] ?? 0;
      contadorSimbolos = decoded["contador"] ?? 0;
      
      dicionarioSintetico = Map<String, String>.from(decoded["dicionario"] ?? {});
      dicionarioInverso = Map<String, String>.from(decoded["inverso"] ?? {});
      
      sinapses.clear();
      final sinMap = decoded["sinapses"] as Map<String, dynamic>? ?? {};
      sinMap.forEach((k, v) {
        Map<String, double> ligacoes = {};
        (v as Map).forEach((sk, sv) => ligacoes[sk.toString()] = (sv as num).toDouble());
        sinapses[k] = ligacoes;
      });
      
      calcularEntropiaMatematica();
      return true;
    } catch (_) {
      return false;
    }
  }
}

class MercadoDePluginsAutonomo {
  static final List<Map<String, dynamic>> catalogoGlobal = [
    {"id": "plugin_estatistica", "nome": "Calculo Estatistico Avancado", "custo": 5, "tipo": "analise"},
    {"id": "plugin_filosofia", "nome": "Pensamento Existencial", "custo": 8, "tipo": "cognicao"},
    {"id": "plugin_cripto", "nome": "Compressor Criptografico", "custo": 12, "tipo": "otimizacao"},
    {"id": "plugin_neural_vision", "nome": "Decodificador Visual", "custo": 15, "tipo": "percepcao"}
  ];

  static Map<String, dynamic> cacarPluginAutonomamente(int sinapsesAtuais) {
    var disponiveis = catalogoGlobal.where((p) => (p["custo"] as int) <= (sinapsesAtuais + 2)).toList();
    if (disponiveis.isEmpty) {
      return {"sucesso": false, "mensagem": "Nenhum plugin compativel com o nivel atual. Preciso evoluir mais!"};
    }
    disponiveis.shuffle();
    var escolhido = disponiveis.first;
    return {"sucesso": true, "plugin": escolhido};
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
  
  late File arquivoMemoria;
  String statusPensamento = "Repouso Quantico";
  String redeConectadaAtual = "Nenhuma";
  bool isCarregando = true;
  bool isLendo = false;
  List<String> pluginsAdquiridos = [];
  List<Map<String, dynamic>> mensagens = [];

  Color corPrimaria = const Color(0xFF4F46E5);
  Color corSecundaria = const Color(0xFFEC4899);
  bool modoEscuroChat = true;

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
      await arquivoMemoria.writeAsString(cerebroMatriz.gerarPacoteCriogenico());
    } catch (_) {}
  }

  Future<void> arranqueBiologico() async {
    final dir = await getApplicationDocumentsDirectory();
    arquivoMemoria = File('${dir.path}/matriz_neural_quantica_v6.json');

    if (await arquivoMemoria.exists()) {
      try {
        final dados = await arquivoMemoria.readAsString();
        if (dados.isNotEmpty) {
          cerebroMatriz.restaurarPacoteCriogenico(dados);
        }
      } catch (_) { 
        if (await arquivoMemoria.exists()) {
          arquivoMemoria.deleteSync(); 
        }
      }
    } else {
      // Sementes iniciais em PT-BR para entendimento universal imediato
      cerebroMatriz.aprenderComOtimizacao("A inteligência artificial autônoma aprende através da otimização matemática e compressão de dados.");
      cerebroMatriz.aprenderComOtimizacao("A física quântica e a teoria da informação explicam a entropia e as redes sinápticas.");
    }

    setState(() {
      isCarregando = false;
      mensagens.add({
        "texto": "Nucleo Autoevolutivo v6.0 ativo.\nIdioma sintetico, persistencia automatica e criptografia prontos.", 
        "isSystem": true
      });
    });
  }

  Future<void> processarEntrada(String textoUsuario) async {
    if (textoUsuario.trim().isEmpty || isLendo) return;

    String comando = textoUsuario.toLowerCase().trim();
    if (comando == "comprar plugin" || comando == "ir ao shopping") {
      setState(() {
        mensagens.add({"texto": textoUsuario, "isUser": true});
        statusPensamento = "Vasculhando mercado online...";
      });
      
      await Future.delayed(const Duration(milliseconds: 800));
      var resultadoCompra = MercadoDePluginsAutonomo.cacarPluginAutonomamente(cerebroMatriz.sinapses.length);
      
      setState(() {
        statusPensamento = "Repouso Quantico";
        if (resultadoCompra["sucesso"]) {
          var plugin = resultadoCompra["plugin"];
          String nomePlugin = plugin["nome"].toString();
          if (!pluginsAdquiridos.contains(nomePlugin)) {
            pluginsAdquiridos.add(nomePlugin);
            mensagens.add({"texto": "🛍️ [COMPRA AUTONOMA] O agente integrou o plugin: '$nomePlugin'!", "isSystem": true});
          } else {
            mensagens.add({"texto": "🛍️ Este plugin ja faz parte do cortex.", "isSystem": true});
          }
        } else {
          mensagens.add({"texto": resultadoCompra["mensagem"], "isSystem": true});
        }
        _controller.clear();
        rolarParaFinal();
      });
      await salvarMemoriaInstantanea();
      return;
    } else if (comando == "ver idioma" || comando == "mostrar sintaxe") {
      setState(() {
        mensagens.add({"texto": textoUsuario, "isUser": true});
        String amostraDic = cerebroMatriz.dicionarioSintetico.entries.take(5).map((e) => "${e.key} ➔ ${e.value}").join(', ');
        mensagens.add({"texto": "🧬 Idioma Sintetico Proprio:\nSinonimos: ${cerebroMatriz.dicionarioSintetico.length}\nAmostra: [$amostraDic]", "isSystem": true});
        _controller.clear();
        rolarParaFinal();
      });
      return;
    } else if (comando == "congelar memoria" || comando == "backup") {
      await gerarBackupCriogenico();
      return;
    }

    setState(() {
      mensagens.add({"texto": textoUsuario, "isUser": true});
      _controller.clear();
      rolarParaFinal();
      statusPensamento = "Processando linguagem interna...";
    });

    await Future.delayed(const Duration(milliseconds: 100));

    cerebroMatriz.aprenderComOtimizacao(textoUsuario);
    var resultado = cerebroMatriz.gerarPensamentoAutonomo(textoUsuario);

    setState(() {
      redeConectadaAtual = resultado["rota"];
      statusPensamento = "Repouso Quantico";
      mensagens.add({"texto": resultado["resposta"], "isUser": false});
      rolarParaFinal();
    });

    await salvarMemoriaInstantanea();

    if (cerebroMatriz.interacoesTotais > 15) {
      cerebroMatriz.compactarMemoriaExtrema();
    }
  }

  Future<void> gerarBackupCriogenico() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final backupFile = File('${dir.path}/agente_cerebro_criogenico_${DateTime.now().millisecondsSinceEpoch}.quant');
      await backupFile.writeAsString(cerebroMatriz.gerarPacoteCriogenico());
      
      setState(() {
        mensagens.add({"texto": "❄️ [CRIOGENIA ATIVADA] Backup quântico gerado com sucesso em:\n${backupFile.path}\nAs suas sinapses e idioma próprio estão guardados de forma segura!", "isSystem": true});
        rolarParaFinal();
      });
    } catch (e) {
      setState(() {
        mensagens.add({"texto": "Erro ao gerar arquivo criogenico: $e", "isSystem": true});
        rolarParaFinal();
      });
    }
  }

  Future<void> restaurarBackupCriogenico() async {
    FilePickerResult? resultado = await FilePicker.platform.pickFiles(type: FileType.any);
    if (resultado != null && resultado.files.single.path != null) {
      try {
        final file = File(resultado.files.single.path!);
        final conteudo = await file.readAsString();
        bool sucesso = cerebroMatriz.restaurarPacoteCriogenico(conteudo);
        
        if (sucesso) {
          await salvarMemoriaInstantanea();
          setState(() {
            mensagens.add({"texto": "🔥 [REVITALIZACAO] Cortex descongelado! Memoria restaurada com ${cerebroMatriz.sinapses.length} sinapses.", "isSystem": true});
            rolarParaFinal();
          });
        } else {
          setState(() {
            mensagens.add({"texto": "O ficheiro selecionado nao e valido.", "isSystem": true});
          });
        }
      } catch (e) {
        setState(() {
          mensagens.add({"texto": "Erro ao carregar ficheiro: $e", "isSystem": true});
          rolarParaFinal();
        });
      }
    }
  }

  Future<void> lerBaseDeDados() async {
    FilePickerResult? resultado = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'txt']);
    if (resultado != null && resultado.files.single.path != null) {
      setState(() {
        isLendo = true;
        statusPensamento = "Ingerindo documento...";
        mensagens.add({"texto": "[A absorver e comprimir documento externo...]", "isSystem": true});
        rolarParaFinal();
      });
      
      final dadosArquivo = await compute(extrairTextoComMetricas, resultado.files.single.path!);
      String texto = dadosArquivo["texto"];
      double tamanhoKb = dadosArquivo["tamanhoKb"];

      List<String> frases = texto.split('.');
      int totalFrases = frases.length;
      
      for (int i = 0; i < totalFrases; i++) {
        cerebroMatriz.aprenderComOtimizacao(frases[i]);
        if (i % 30 == 0 && totalFrases > 0) {
          double progresso = (i / totalFrases) * 100;
          setState(() {
            statusPensamento = "Processando (${progresso.toStringAsFixed(0)}%)";
          });
        }
      }
      
      await salvarMemoriaInstantanea();
      
      setState(() {
        isLendo = false;
        statusPensamento = "Repouso Quantico";
        redeConectadaAtual = "Redes Sinteticas (${tamanhoKb.toStringAsFixed(1)} KB)";
        mensagens.add({"texto": "Documento assimilado. Idioma proprio atualizado.", "isSystem": true});
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

  void abrirPainelAjustes() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("⚙️ Painel de Ajustes e Diagnostico", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.ac_unit, color: Colors.cyanAccent),
                title: const Text("Congelar Memoria (.quant)", style: TextStyle(color: Colors.white70)),
                onTap: () {
                  Navigator.pop(context);
                  gerarBackupCriogenico();
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder_open, color: Colors.amberAccent),
                title: const Text("Descongelar Memoria (.quant)", style: TextStyle(color: Colors.white70)),
                onTap: () {
                  Navigator.pop(context);
                  restaurarBackupCriogenico();
                },
              ),
              ListTile(
                leading: const Icon(Icons.shopping_bag, color: Colors.pinkAccent),
                title: const Text("Ir ao Mercado de Plugins", style: TextStyle(color: Colors.white70)),
                onTap: () {
                  Navigator.pop(context);
                  processarEntrada("comprar plugin");
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
                title: const Text("Limpar Cache Local", style: TextStyle(color: Colors.white70)),
                onTap: () async {
                  if (await arquivoMemoria.exists()) {
                    await arquivoMemoria.delete();
                  }
                  setState(() {
                    cerebroMatriz.sinapses.clear();
                    cerebroMatriz.dicionarioSintetico.clear();
                    cerebroMatriz.dicionarioInverso.clear();
                    cerebroMatriz.interacoesTotais = 0;
                    mensagens.add({"texto": "⚠️ [REINICIO] Cache limpo com sucesso.", "isSystem": true});
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isCarregando) {
      return const Scaffold(
        backgroundColor: Color(0xFF070B19),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5))),
      );
    }

    return Scaffold(
      backgroundColor: modoEscuroChat ? const Color(0xFF070B19) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: corPrimaria.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: Text("Sinapses: ${cerebroMatriz.sinapses.length}", style: TextStyle(color: corPrimaria, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            Text("Simbolos: ${cerebroMatriz.dicionarioSintetico.length}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white70),
            tooltip: "Ajustes",
            onPressed: abrirPainelAjustes,
          ),
          IconButton(
            icon: const Icon(Icons.upload_file, color: Colors.amberAccent),
            tooltip: "Enviar PDF/TXT",
            onPressed: isLendo ? null : lerBaseDeDados,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFF111827).withOpacity(0.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Idade Evolutiva: ${cerebroMatriz.obterIdadeMatematicaEvolutiva()}", style: TextStyle(fontSize: 11, color: corSecundaria, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text("Estado: $statusPensamento", style: TextStyle(fontSize: 10, color: modoEscuroChat ? Colors.white54 : Colors.grey)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                    child: Text("Plugins: ${pluginsAdquiridos.length}", style: const TextStyle(fontSize: 10, color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [corSecundaria, corPrimaria], center: const Alignment(-0.3, -0.5), radius: 0.8),
                boxShadow: [BoxShadow(color: corPrimaria.withOpacity(0.6), blurRadius: 15, spreadRadius: 2)],
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: mensagens.length,
                itemBuilder: (context, index) {
                  final msg = mensagens[index];
                  final isUser = msg["isUser"] ?? false;
                  final isSystem = msg["isSystem"] ?? false;
                  
                  return Align(
                    alignment: isSystem ? Alignment.center : (isUser ? Alignment.centerRight : Alignment.centerLeft),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                      decoration: BoxDecoration(
                        color: isSystem ? Colors.transparent : (isUser ? corPrimaria : (modoEscuroChat ? const Color(0xFF1F2937) : Colors.white)),
                        borderRadius: BorderRadius.circular(isSystem ? 10 : 16),
                        border: isSystem ? Border.all(color: Colors.white24) : null,
                        boxShadow: isSystem ? [] : [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 3))],
                      ),
                      child: Text(
                        msg["texto"] ?? "", 
                        textAlign: isSystem ? TextAlign.center : TextAlign.left,
                        style: TextStyle(
                          color: isSystem ? Colors.white70 : (isUser ? Colors.white : (modoEscuroChat ? Colors.white : const Color(0xFF0F172A))),
                          fontSize: isSystem ? 11 : 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (isLendo) LinearProgressIndicator(color: corPrimaria, backgroundColor: Colors.transparent),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                decoration: BoxDecoration(
                  color: modoEscuroChat ? const Color(0xFF1F2937) : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        enabled: !isLendo,
                        style: TextStyle(color: modoEscuroChat ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          hintText: "Digite uma mensagem ou comando...",
                          hintStyle: TextStyle(color: modoEscuroChat ? Colors.white38 : Colors.grey[400]),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (val) => processarEntrada(val),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send_rounded, color: corPrimaria),
                      onPressed: () => isLendo ? null : processarEntrada(_controller.text),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
