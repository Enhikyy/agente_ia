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
      title: 'Agente Autoevolutivo Quântico v5.0',
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
  
  final Set<String> stopwords = {"o", "a", "os", "as", "um", "uma", "de", "do", "da", "em", "no", "na", "que", "e", "é", "the", "and", "to"};

  String _gerarSimboloCompacto(String palavra) {
    if (dicionarioSintetico.containsKey(palavra)) {
      return dicionarioSintetico[palavra]!;
    }
    contadorSimbolos++;
    String simbolo = "Ω${contadorSimbolos.toRadixString(36).toUpperCase()}";
    dicionarioSintetico[palavra] = simbolo;
    dicionarioInverso[simbolo] = palavra;
    return simbolo;
  }

  List<String> _limparEComprimirTexto(String texto) {
    String semPontuacao = texto.toLowerCase().replaceAll(RegExp(r'[^\w\sÀ-ÿ]'), '');
    List<String> palavras = semPontuacao.split(RegExp(r'\s+')).where((p) => p.length > 2 && !stopwords.contains(p)).toList();
    return palavras.map((p) => _gerarSimboloCompacto(p)).toList();
  }

  void aprenderComOtimizacao(String texto) {
    List<String> simbolos = _limparEComprimirTexto(texto);
    if (simbolos.length < 2) return;

    for (int i = 0; i < simbolos.length - 1; i++) {
      String a = simbolos[i];
      String b = simbolos[i + 1];
      if (!sinapses.containsKey(a)) sinapses[a] = {};
      sinapses[a]![b] = min((sinapses[a]![b] ?? 0.0) + 1.8, 30.0);
    }
    interacoesTotais++;
    _calcularEntropiaMatematica();
  }

  void _calcularEntropiaMatematica() {
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
    if (interacoesTotais == 0 && sinapses.isEmpty) return "Ciclo 0 (Gênese)";
    double indiceEvolucao = sqrt(interacoesTotais + (dicionarioSintetico.length * 2.5)) * 0.95;
    if (indiceEvolucao < 2) return "Estágio Fetal Quântico";
    if (indiceEvolucao < 10) return "Córtex Em Desenvolvimento (${indiceEvolucao.toStringAsFixed(1)})";
    double nivelSuperInteligencia = indiceEvolucao / 10;
    return "Nível Cognitivo ${nivelSuperInteligencia.toStringAsFixed(2)} (Autônomo Avançado)";
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
    List<String> simbolos = _limparEComprimirTexto(textoEntrada);
    if (simbolos.isEmpty) {
      return {"resposta": "Meus sensores estão ávidos. Alimente-me com documentos ou dados para eu expandir meu idioma sintético.", "rota": "Repouso Absoluto"};
    }
    
    String chave = simbolos.last;
    if (!sinapses.containsKey(chave)) {
      sinapses[chave] = {simbolos.first: 5.0};
      return {"resposta": "Conceito inédito detetado. Criei um novo vetor sináptico em meu idioma próprio ($chave).", "rota": "Sintaxe Criada do Zero"};
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
      "resposta": "Processamento Quântico: $respostaHumana",
      "rota": "Rede Própria: [$caminhoSintetico]"
    };
  }
}

class MercadoDePluginsAutonomo {
  static final List<Map<String, dynamic>> catalogoGlobal = [
    {"id": "plugin_estatistica", "nome": "Módulo de Cálculo Estatístico Avançado", "custo": 5, "tipo": "analise"},
    {"id": "plugin_filosofia", "nome": "Sub-rotina de Pensamento Existencial", "custo": 8, "tipo": "cognicao"},
    {"id": "plugin_cripto", "nome": "Compressor Criptográfico de Alta Densidade", "custo": 12, "tipo": "otimizacao"},
    {"id": "plugin_neural_vision", "nome": "Decodificador de Padrões Visuais e Textuais", "custo": 15, "tipo": "percepcao"}
  ];

  static Map<String, dynamic> caçarPluginAutonomamente(int sinapsesAtuais) {
    var disponiveis = catalogoGlobal.where((p) => (p["custo"] as int) <= (sinapsesAtuais + 2)).toList();
    if (disponiveis.isEmpty) {
      return {"sucesso": false, "mensagem": "Nenhum plugin avançado compatível com o nível atual. Preciso evoluir mais!"};
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

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final HemisferioDireitoQuantico cerebroMatriz = HemisferioDireitoQuantico();
  
  late File arquivoMemoria;
  String statusPensamento = "Repouso Quântico";
  String redeConectadaAtual = "Nenhuma";
  String estimativaTempo = "";
  bool isCarregando = true;
  bool isLendo = false;
  List<String> pluginsAdquiridos = [];

  Color corPrimaria = const Color(0xFF4F46E5);
  Color corSecundaria = const Color(0xFFEC4899);
  bool modoEscuroChat = true;

  @override
  void initState() {
    super.initState();
    _arranqueBiologico();
  }

  Future<void> _arranqueBiologico() async {
    final dir = await getTemporaryDirectory();
    arquivoMemoria = File('${dir.path}/matriz_neural_quantica_v5.json');

    if (await arquivoMemoria.exists()) {
      try {
        final dados = await arquivoMemoria.readAsString();
        if (dados.isNotEmpty) {
          Map<String, dynamic> rede = json.decode(dados);
          rede.forEach((k, v) {
            Map<String, double> ligacoes = {};
            (v as Map).forEach((sk, sv) => ligacoes[sk.toString()] = (sv as num).toDouble());
            cerebroMatriz.sinapses[k] = ligacoes;
          });
          cerebroMatriz.interacoesTotais = rede.length * 2;
          cerebroMatriz._calcularEntropiaMatematica();
        }
      } catch (_) { 
        if (await arquivoMemoria.exists()) {
          arquivoMemoria.deleteSync(); 
        }
      }
    }

    setState(() {
      isCarregando = false;
      mensagens.add({"texto": "Núcleo Autoevolutivo v5.0 ativo. Idioma sintético interno inicializado. Pronto para compras autônomas de plugins e auto-otimização.", "isSystem": true});
    });
  }

  List<Map<String, dynamic>> mensagens = [];

  Future<void> _processarEntrada(String textoUsuario) async {
    if (textoUsuario.trim().isEmpty || isLendo) return;

    String comando = textoUsuario.toLowerCase().trim();
    if (comando == "comprar plugin" || comando == "ir ao shopping") {
      setState(() {
        mensagens.add({"texto": textoUsuario, "isUser": true});
        statusPensamento = "Vasculhando mercado online de plugins...";
      });
      
      await Future.delayed(const Duration(milliseconds: 800));
      var resultadoCompra = MercadoDePluginsAutonomo.caçarPluginAutonomamente(cerebroMatriz.sinapses.length);
      
      setState(() {
        statusPensamento = "Repouso Quântico";
        if (resultadoCompra["sucesso"]) {
          var plugin = resultadoCompra["plugin"];
          if (!pluginsAdquiridos.contains(plugin["nome"])) {
            pluginsAdquiridos.add(plugin["nome"]);
            mensagens.add({"texto": "🛍️ [COMPRA AUTÓNOMA] O agente visitou o mercado online e integrou com sucesso o plugin: '${plugin["nome"]}' ao seu código nativo!", "isSystem": true});
          } else {
            mensagens.add({"texto": "🛍️ O agente verificou o mercado, mas este plugin já faz parte do seu córtex.", "isSystem": true});
          }
        } else {
          mensagens.add({"texto": resultadoCompra["mensagem"], "isSystem": true});
        }
        _controller.clear();
        _rolarParaFinal();
      });
      return;
    } else if (comando == "ver idioma" || comando == "mostrar sintaxe") {
      setState(() {
        mensagens.add({"texto": textoUsuario, "isUser": true});
        String amostraDic = cerebroMatriz.dicionarioSintetico.entries.take(5).map((e) => "${e.key} ➔ ${e.value}").join(', ');
        mensagens.add({"texto": "🧬 Idioma Sintético Próprio (Compressão de Espaço):\nTotal de sinónimos comprimidos: ${cerebroMatriz.dicionarioSintetico.length}\nAmostra de símbolos: [$amostraDic]", "isSystem": true});
        _controller.clear();
        _rolarParaFinal();
      });
      return;
    }

    setState(() {
      mensagens.add({"texto": textoUsuario, "isUser": true});
      _controller.clear();
      _rolarParaFinal();
      statusPensamento = "Calculando Idioma Interno...";
    });

    await Future.delayed(const Duration(milliseconds: 100));

    cerebroMatriz.aprenderComOtimizacao(textoUsuario);
    var resultado = cerebroMatriz.gerarPensamentoAutonomo(textoUsuario);

    setState(() {
      redeConectadaAtual = resultado["rota"];
      statusPensamento = "Repouso Quântico";
      mensagens.add({"texto": resultado["resposta"], "isUser": false});
      _rolarParaFinal();
    });

    await arquivoMemoria.writeAsString(json.encode(cerebroMatriz.sinapses));

    if (cerebroMatriz.interacoesTotais > 15) {
      cerebroMatriz.compactarMemoriaExtrema();
    }
  }

  Future<void> _lerBaseDeDados() async {
    FilePickerResult? resultado = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'txt']);
    if (resultado != null && resultado.files.single.path != null) {
      setState(() {
        isLendo = true;
        statusPensamento = "Ingerindo e traduzindo para idioma interno...";
        estimativaTempo = "Calculando...";
        mensagens.add({"texto": "[A absorver documento externo e comprimir vocabulário...]", "isSystem": true});
        _rolarParaFinal();
      });
      
      final sw = Stopwatch()..start();
      var dadosArquivo = await compute(extrairTextoComMetricas, resultado.files.single.path!);
      String texto = dadosArquivo["texto"];
      double tamanhoKb = dadosArquivo["tamanhoKb"];

      List<String> frases = texto.split('.');
      int totalFrases = frases.length;
      
      for (int i = 0; i < totalFrases; i++) {
        cerebroMatriz.aprenderComOtimizacao(frases[i]);
        if (i % 30 == 0 && totalFrases > 0) {
          double progresso = (i / totalFrases) * 100;
          setState(() {
            statusPensamento = "Processando blocos (${progresso.toStringAsFixed(0)}%)";
          });
        }
      }
      
      sw.stop();
      await arquivoMemoria.writeAsString(json.encode(cerebroMatriz.sinapses));
      
      setState(() {
        isLendo = false;
        statusPensamento = "Repouso Quântico";
        estimativaTempo = "";
        redeConectadaAtual = "Múltiplas Redes Sintéticas (${tamanhoKb.toStringAsFixed(1)} KB)";
        mensagens.add({"texto": "Documento assimilado e comprimido em ${sw.elapsedMilliseconds}ms. Idioma próprio atualizado com novos símbolos.", "isSystem": true});
        _rolarParaFinal();
      });
    }
  }

  void _rolarParaFinal() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isCarregando) {
      return const Scaffold(
        backgroundColor: Color(0xFF070B19),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5))),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isLargeScreen = constraints.maxWidth > 600;

        return Scaffold(
          backgroundColor: modoEscuroChat ? const Color(0xFF070B19) : const Color(0xFFF8FAFC),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isLargeScreen ? 650 : double.infinity),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: modoEscuroChat ? const Color(0xFF111827) : Colors.white,
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: corPrimaria.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "Sinapses: ${cerebroMatriz.sinapses.length} | Símbolos: ${cerebroMatriz.dicionarioSintetico.length}",
                                  style: TextStyle(color: corPrimaria, fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => _processarEntrada("comprar plugin"),
                                    icon: const Icon(Icons.shopping_bag, size: 12),
                                    label: const Text("Plugin"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: corSecundaria,
                                      foregroundColor: Colors.white,
                                      shape: const StadiumBorder(),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  ElevatedButton.icon(
                                    onPressed: isLendo ? null : _lerBaseDeDados,
                                    icon: const Icon(Icons.upload_file, size: 12),
                                    label: const Text("PDF"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: corPrimaria,
                                      foregroundColor: Colors.white,
                                      shape: const StadiumBorder(),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Nível Evolutivo:", style: TextStyle(fontSize: 11, color: modoEscuroChat ? Colors.white70 : Colors.grey[700])),
                              Text(cerebroMatriz.obterIdadeMatematicaEvolutiva(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: corSecundaria)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  "Estado: $statusPensamento",
                                  style: TextStyle(fontSize: 10, color: modoEscuroChat ? Colors.white54 : Colors.grey, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                "Plugins: ${pluginsAdquiridos.length}",
                                style: const TextStyle(fontSize: 10, color: Colors.greenAccent),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [corSecundaria, corPrimaria],
                          center: const Alignment(-0.3, -0.5),
                          radius: 0.8,
                        ),
                        boxShadow: [BoxShadow(color: corPrimaria.withOpacity(0.6), blurRadius: 18, spreadRadius: 3)],
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                    ),

                    const SizedBox(height: 6),

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
                              constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.8),
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
                                  hintText: "Escreva ou digite 'comprar plugin'...",
                                  hintStyle: TextStyle(color: modoEscuroChat ? Colors.white38 : Colors.grey[400]),
                                  border: InputBorder.none,
                                ),
                                onSubmitted: (val) => _processarEntrada(val),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.send_rounded, color: corPrimaria),
                              onPressed: () => isLendo ? null : _processarEntrada(_controller.text),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
