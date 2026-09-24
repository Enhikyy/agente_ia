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
      title: 'Agente IA Responsivo',
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
        primaryColor: const Color(0xFF6A68DF),
      ),
      home: const MainScreen(),
    );
  }
}

Future<String> extrairTextoPesado(String caminhoArquivo) async {
  final arquivo = File(caminhoArquivo);
  if (caminhoArquivo.endsWith('.txt')) return await arquivo.readAsString();
  if (caminhoArquivo.endsWith('.pdf')) {
    final documento = PdfDocument(inputBytes: await arquivo.readAsBytes());
    final texto = PdfTextExtractor(documento).extractText();
    documento.dispose();
    return texto;
  }
  return "";
}

class HemisferioDireito {
  Map<String, Map<String, double>> sinapses = {};
  int interacoes = 0;
  final Set<String> stopwords = {"o", "a", "os", "as", "um", "uma", "de", "do", "da", "em", "no", "na", "que", "e", "é"};

  List<String> _limparTexto(String texto) {
    String semPontuacao = texto.toLowerCase().replaceAll(RegExp(r'[^\w\sÀ-ÿ]'), '');
    return semPontuacao.split(RegExp(r'\s+')).where((p) => p.length > 2 && !stopwords.contains(p)).toList();
  }

  void aprender(String texto) {
    List<String> palavras = _limparTexto(texto);
    if (palavras.length < 2) return;

    for (int i = 0; i < palavras.length - 1; i++) {
      String a = palavras[i];
      String b = palavras[i + 1];
      if (!sinapses.containsKey(a)) sinapses[a] = {};
      sinapses[a]![b] = min((sinapses[a]![b] ?? 0.0) + 1.5, 20.0);
    }
    interacoes++;
  }

  void comprimirMemoria() {
    Map<String, Map<String, double>> otimizado = {};
    sinapses.forEach((conceito, ligacoes) {
      Map<String, double> fortes = {};
      ligacoes.forEach((alvo, forca) {
        double novaForca = forca - 0.5;
        if (novaForca > 1.0) fortes[alvo] = novaForca;
      });
      if (fortes.isNotEmpty) otimizado[conceito] = fortes;
    });
    sinapses = otimizado;
    interacoes = 0;
  }

  String gerarResposta(String texto) {
    List<String> palavras = _limparTexto(texto);
    if (palavras.isEmpty) return "Envie-me um PDF para alimentar o meu córtex sináptico.";
    
    String chave = palavras.last;
    if (!sinapses.containsKey(chave)) return "Ainda não processei este conceito na matriz. Envie mais dados!";
    
    String resposta = "... $chave";
    int limite = 6;
    
    while (limite > 0 && sinapses.containsKey(chave)) {
      var ligacoes = sinapses[chave]!.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      if (ligacoes.isEmpty) break;
      
      chave = ligacoes.first.key;
      resposta += " $chave";
      limite--;
    }
    return resposta;
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
  final HemisferioDireito cerebroMatriz = HemisferioDireito();
  late File arquivoMemoria;
  
  List<Map<String, dynamic>> mensagens = [];
  bool isCarregando = true;
  bool isLendo = false;

  @override
  void initState() {
    super.initState();
    _arranqueBiologico();
  }

  Future<void> _arranqueBiologico() async {
    final dir = await getApplicationDocumentsDirectory();
    arquivoMemoria = File('${dir.path}/matriz_neural.json');

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
        }
      } catch (_) { arquivoMemoria.deleteSync(); }
    }

    setState(() {
      isCarregando = false;
      mensagens.add({"texto": "Sistemas neurais online e responsivos no Moto G62. Pronto para processar conhecimento.", "isSystem": true});
    });
  }

  Future<void> _processarEntrada(String textoUsuario) async {
    if (textoUsuario.trim().isEmpty || isLendo) return;

    setState(() {
      mensagens.add({"texto": textoUsuario, "isUser": true});
      _controller.clear();
      _rolarParaFinal();
    });

    cerebroMatriz.aprender(textoUsuario);
    String resposta = cerebroMatriz.gerarResposta(textoUsuario);

    setState(() {
      mensagens.add({"texto": resposta, "isUser": false});
      _rolarParaFinal();
    });

    await arquivoMemoria.writeAsString(json.encode(cerebroMatriz.sinapses));

    if (cerebroMatriz.interacoes > 15) {
      cerebroMatriz.comprimirMemoria();
    }
  }

  Future<void> _lerBaseDeDados() async {
    FilePickerResult? resultado = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'txt']);
    if (resultado != null) {
      setState(() {
        isLendo = true;
        mensagens.add({"texto": "[A ingerir documento em segundo plano...]", "isSystem": true});
        _rolarParaFinal();
      });
      
      String texto = await compute(extrairTextoPesado, resultado.files.single.path!);
      List<String> frases = texto.split('.');
      for (var frase in frases) {
        cerebroMatriz.aprender(frase);
      }
      
      await arquivoMemoria.writeAsString(json.encode(cerebroMatriz.sinapses));
      
      setState(() {
        isLendo = false;
        mensagens.add({"texto": "Documento absorvido com sucesso pela matriz neural.", "isSystem": true});
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
        body: Center(child: CircularProgressIndicator(color: Color(0xFF6A68DF))),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isLargeScreen = constraints.maxWidth > 600;

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isLargeScreen ? 600 : double.infinity),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6A68DF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Sinapses: ${cerebroMatriz.sinapses.length}",
                              style: const TextStyle(color: Color(0xFF6A68DF), fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: isLendo ? null : _lerBaseDeDados,
                            icon: const Icon(Icons.upload_file, size: 16),
                            label: const Text("Enviar PDF"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEFB995),
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Color(0xFFEFB995), Color(0xFF6A68DF)],
                          center: Alignment(-0.3, -0.5),
                          radius: 0.8,
                        ),
                        boxShadow: [BoxShadow(color: Color(0x406A68DF), blurRadius: 15, spreadRadius: 3)],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(left: 20, top: 24, child: Container(width: 6, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)))),
                          Positioned(right: 20, top: 24, child: Container(width: 6, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
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
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.75),
                              decoration: BoxDecoration(
                                color: isSystem ? Colors.transparent : (isUser ? const Color(0xFF6A68DF) : Colors.white),
                                borderRadius: BorderRadius.circular(isSystem ? 8 : 18),
                                border: isSystem ? Border.all(color: Colors.grey.shade300) : null,
                                boxShadow: isSystem ? [] : const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                              ),
                              child: Text(
                                msg["texto"], 
                                textAlign: isSystem ? TextAlign.center : TextAlign.left,
                                style: TextStyle(
                                  color: isSystem ? Colors.grey[600] : (isUser ? Colors.white : const Color(0xFF2E2C2D)),
                                  fontSize: isSystem ? 12 : 14,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (isLendo) const LinearProgressIndicator(color: Color(0xFF6A68DF)),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                enabled: !isLendo,
                                decoration: const InputDecoration(
                                  hintText: "Escreva uma mensagem...",
                                  border: InputBorder.none,
                                ),
                                onSubmitted: (val) => _processarEntrada(val),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send, color: Color(0xFF6A68DF)),
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
