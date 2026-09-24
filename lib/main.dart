import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
​void main() {
WidgetsFlutterBinding.ensureInitialized();
runApp(const AgenteApp());
}
​class AgenteApp extends StatelessWidget {
const AgenteApp({super.key});
​@override
Widget build(BuildContext context) {
return MaterialApp(
debugShowCheckedModeBanner: false,
title: 'Agente Neural Quântico v4.0',
theme: ThemeData(
fontFamily: 'Poppins',
scaffoldBackgroundColor: const Color(0xFF0F172A), // Dark futuristic slate background
primaryColor: const Color(0xFF6366F1),
),
home: const MainScreen(),
);
}
}
​// Processador Otimizado com alocação em Cache Interno para o Moto G62 (4GB RAM)
Future<Map<String, dynamic>> extrairTextoComMetricas(String caminhoArquivo) async {
final sw = Stopwatch()..start();
final arquivo = File(caminhoArquivo);
String texto = "";
​if (caminhoArquivo.endsWith('.txt')) {
texto = await arquivo.readAsString();
} else if (caminhoArquivo.endsWith('.pdf')) {
final documento = PdfDocument(inputBytes: await arquivo.readAsBytes());
texto = PdfTextExtractor(documento).extractText();
documento.dispose();
}
​sw.stop();
return {
"texto": texto,
"tempoMs": sw.elapsedMilliseconds,
"tamanhoKb": (await arquivo.length()) / 1024
};
}
​class HemisferioDireito {
Map<String, Map<String, double>> sinapses = {};
int interacoesTotais = 0;
double entropiaNeural = 0.0;
final Set<String> stopwords = {"o", "a", "os", "as", "um", "uma", "de", "do", "da", "em", "no", "na", "que", "e", "é"};
​List<String> _limparTexto(String texto) {
String semPontuacao = texto.toLowerCase().replaceAll(RegExp(r'[^\w\sÀ-ÿ]'), '');
return semPontuacao.split(RegExp(r'\s+')).where((p) => p.length > 2 && !stopwords.contains(p)).toList();
}
​void aprenderComRastreio(String texto) {
List<String> palavras = _limparTexto(texto);
if (palavras.length < 2) return;
​for (int i = 0; i < palavras.length - 1; i++) {
String a = palavras[i];
String b = palavras[i + 1];
if (!sinapses.containsKey(a)) sinapses[a] = {};
sinapses[a]![b] = min((sinapses[a]![b] ?? 0.0) + 1.5, 25.0);
}
interacoesTotais++;
_calcularEntropia();
}
​// Matemática Avançada: Cálculo de Idade Baseado em Teoria da Informação e Entropia de Shannon/Conectividade de Grafos
void calcularEntropia() {
if (sinapses.isEmpty) {
entropiaNeural = 0.0;
return;
}
double totalConexoes = 0;
double somaPesos = 0;
sinapses.forEach((, ligacoes) {
ligacoes.forEach((_, peso) {
totalConexoes += 1;
somaPesos += peso;
});
});
// Fórmula matemática não-linear de evolução cognitiva baseada em densidade sináptica e logaritmo de interações
double densidade = somaPesos / (totalConexoes > 0 ? totalConexoes : 1.0);
entropiaNeural = (log(interacoesTotais + 1) * densidade * 0.45) + (totalConexoes * 0.02);
}
​// Estimar "Idade da IA" em termos de ciclos biológicos matemáticos equivalentes
String obterIdadeMatematica() {
if (interacoesTotais == 0 && sinapses.isEmpty) return "Ciclo 0 (Recém-Nascido)";
double idadeEmMeses = sqrt(interacoesTotais + (sinapses.length * 1.5)) * 0.8;
if (idadeEmMeses < 1) return "Estágio Fetal Quântico";
if (idadeEmMeses < 12) return "{idadeEmMeses.toStringAsFixed(1)} Meses (Infância Sináptica)";
double anos = idadeEmMeses / 12;
return "{anos.toStringAsFixed(1)} Anos (Córtex Adolescente)";
}
​void comprimirMemoria() {
Map<String, Map<String, double>> otimizado = {};
sinapses.forEach((conceito, ligacoes) {
Map<String, double> fortes = {};
ligacoes.forEach((alvo, forca) {
double novaForca = forca - 0.4;
if (novaForca > 1.2) fortes[alvo] = novaForca;
});
if (fortes.isNotEmpty) otimizado[conceito] = fortes;
});
sinapses = otimizado;
}
​Map<String, dynamic> gerarRespostaComTrand(String texto) {
List<String> palavras = _limparTexto(texto);
if (palavras.isEmpty) return {"resposta": "Envie-me um PDF para alimentar o meu córtex sináptico.", "rota": "Nenhuma rota ativa"};
​String chave = palavras.last;
if (!sinapses.containsKey(chave)) return {"resposta": "Ainda não processei este conceito na matriz. Envie mais dados!", "rota": "Rede Isolada: [$chave]"};
​String resposta = "... $chave";
String redeNeuralAtiva = "Núcleo [$chave]";
int limite = 6;
​while (limite > 0 && sinapses.containsKey(chave)) {
var ligacoes = sinapses[chave]!.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
if (ligacoes.isEmpty) break;
​chave = ligacoes.first.key;
resposta += " $chave";
redeNeuralAtiva += " ➔ [$chave]";
limite--;
}
return {"resposta": resposta, "rota": redeNeuralAtiva};
}
}
​class MainScreen extends StatefulWidget {
const MainScreen({super.key});
@override
State<MainScreen> createState() => _MainScreenState();
}
​class _MainScreenState extends State<MainScreen> {
final TextEditingController _controller = TextEditingController();
final ScrollController _scrollController = ScrollController();
final HemisferioDireito cerebroMatriz = HemisferioDireito();
​late File arquivoMemoria;
String statusPensamento = "Repouso Sináptico";
String redeConectadaAtual = "Nenhuma";
String estimativaTempo = "";
bool isCarregando = true;
bool isLendo = false;
​// Customização de Layout em Tempo Real Pelo Chatbot
Color corPrimaria = const Color(0xFF6366F1);
Color corSecundaria = const Color(0xFFEC4899);
double raioBordas = 18.0;
bool modoEscuroChat = true;
​@override
void initState() {
super.initState();
_arranqueBiologico();
}
​Future<void> _arranqueBiologico() async {
final dir = await getTemporaryDirectory();
arquivoMemoria = File('${dir.path}/matriz_neural_acelerada.json');
​if (await arquivoMemoria.exists()) {
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
cerebroMatriz.calcularEntropia();
}
} catch () { arquivoMemoria.deleteSync(); }
}
​setState(() {
isCarregando = false;
mensagens.add({"texto": "Geração 4.0 Quantum Core ativada. Cache interno alocado. Pronto para customização de layout via chat e cálculos de idade matemática.", "isSystem": true});
});
}
​List<Map<String, dynamic>> mensagens = [];
​Future<void> _processarEntrada(String textoUsuario) async {
if (textoUsuario.trim().isEmpty || isLendo) return;
​// Comandos de Customização de Layout via Chatbot em Tempo Real
String comando = textoUsuario.toLowerCase().trim();
if (comando.startsWith("mudar cor ")) {
setState(() {
if (comando.contains("verde")) corPrimaria = Colors.green.shade600;
else if (comando.contains("vermelho")) corPrimaria = Colors.red.shade400;
else if (comando.contains("azul")) corPrimaria = Colors.blue.shade400;
else if (comando.contains("roxo")) corPrimaria = const Color(0xFF6366F1);
mensagens.add({"texto": textoUsuario, "isUser": true});
mensagens.add({"texto": "Layout atualizado com sucesso através do comando de chat!", "isSystem": true});
_controller.clear();
_rolarParaFinal();
});
return;
} else if (comando == "modo escuro" || comando == "modo claro") {
setState(() {
modoEscuroChat = !modoEscuroChat;
mensagens.add({"texto": textoUsuario, "isUser": true});
mensagens.add({"texto": "Modo visual alternado com sucesso.", "isSystem": true});
_controller.clear();
_rolarParaFinal();
});
return;
}
​setState(() {
mensagens.add({"texto": textoUsuario, "isUser": true});
_controller.clear();
_rolarParaFinal();
statusPensamento = "Varrendo Sinapses...";
estimativaTempo = "~0.05s";
});
​await Future.delayed(const Duration(milliseconds: 120));
​cerebroMatriz.aprenderComRastreio(textoUsuario);
var resultado = cerebroMatriz.gerarRespostaComTrand(textoUsuario);
​setState(() {
redeConectadaAtual = resultado["rota"];
statusPensamento = "Concluído";
estimativaTempo = "";
mensagens.add({"texto": resultado["resposta"], "isUser": false});
_rolarParaFinal();
});
​await arquivoMemoria.writeAsString(json.encode(cerebroMatriz.sinapses));
​if (cerebroMatriz.interacoesTotais > 20) {
cerebroMatriz.comprimirMemoria();
}
}
​Future<void> _lerBaseDeDados() async {
FilePickerResult? resultado = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'txt']);
if (resultado != null) {
setState(() {
isLendo = true;
statusPensamento = "A alocar ficheiro no Armazenamento Interno...";
estimativaTempo = "Calculando...";
mensagens.add({"texto": "[A ingerir documento com aceleração de cache...]", "isSystem": true});
_rolarParaFinal();
});
​final sw = Stopwatch()..start();
var dadosArquivo = await compute(extrairTextoComMetricas, resultado.files.single.path!);
String texto = dadosArquivo["texto"];
int tempoExtração = dadosArquivo["tempoMs"];
double tamanhoKb = dadosArquivo["tamanhoKb"];
​List<String> frases = texto.split('.');
int totalFrases = frases.length;
​for (int i = 0; i < totalFrases; i++) {
cerebroMatriz.aprenderComRastreio(frases[i]);
if (i % 40 == 0) {
double progresso = (i / totalFrases) * 100;
int tempoRestanteMs = ((totalFrases - i) * (tempoExtraktionPorFrase(tempoExtração, totalFrases))).toInt();
setState(() {
estimativaTempo = "~{(tempoRestanteMs / 1000).toStringAsFixed(1)}s restantes";
statusPensamento = "Processando blocos ({progresso.toStringAsFixed(0)}%)";
});
}
}
​sw.stop();
await arquivoMemoria.writeAsString(json.encode(cerebroMatriz.sinapses));
​setState(() {
isLendo = false;
statusPensamento = "Repouso Sináptico";
estimativaTempo = "";
redeConectadaAtual = "Múltiplas Redes (${tamanhoKb.toStringAsFixed(1)} KB no Cache)";
mensagens.add({"texto": "Documento absorvido pelo cache interno em ${sw.elapsedMilliseconds}ms. Idade matemática recalculada.", "isSystem": true});
_rolarParaFinal();
});
}
}
​double tempoExtraktionPorFrase(int totalMs, int totalFrases) {
if (totalFrases == 0) return 0.1;
return totalMs / totalFrases;
}
​void _rolarParaFinal() {
Future.delayed(const Duration(milliseconds: 100), () {
if (_scrollController.hasClients) {
_scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
}
});
}
​@override
Widget build(BuildContext context) {
if (isCarregando) {
return const Scaffold(
backgroundColor: Color(0xFF0F172A),
body: Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
);
}
​return LayoutBuilder(
builder: (context, constraints) {
bool isLargeScreen = constraints.maxWidth > 600;
​return Scaffold(
backgroundColor: modoEscuroChat ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
body: SafeArea(
child: Center(
child: ConstrainedBox(
constraints: BoxConstraints(maxWidth: isLargeScreen ? 600 : double.infinity),
child: Column(
children: [
// Painel de Telemetria Superior (Geração, Idade Matemática e Cache)
Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: modoEscuroChat ? const Color(0xFF1E293B) : Colors.white,
borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
),
child: Column(
children: [
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Container(
padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
decoration: BoxDecoration(
color: corPrimaria.withOpacity(0.2),
borderRadius: BorderRadius.circular(20),
),
child: Text(
"Ger 4.0 | Sinapses: ${cerebroMatriz.sinapses.length}",
style: TextStyle(color: corPrimaria, fontWeight: FontWeight.bold, fontSize: 11),
),
),
ElevatedButton.icon(
onPressed: isLendo ? null : _lerBaseDeDados,
icon: const Icon(Icons.upload_file, size: 14),
label: const Text("PDF Cache"),
style: ElevatedButton.styleFrom(
backgroundColor: corSecundaria,
foregroundColor: Colors.white,
shape: const StadiumBorder(),
padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
),
)
],
),
const SizedBox(height: 8),
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text("Idade Matemática (Entropia):", style: TextStyle(fontSize: 11, color: modoEscuroChat ? Colors.white70 : Colors.grey[700])),
Text(cerebroMatriz.obterIdadeMatematica(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: corPrimaria)),
],
),
const SizedBox(height: 4),
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Expanded(
child: Text(
"Estado: $statusPensamento ${estimativaTempo.isNotEmpty ? '($estimativaTempo)' : ''}",
style: TextStyle(fontSize: 10, color: modoEscuroChat ? Colors.white54 : Colors.grey, fontWeight: FontWeight.w600),
overflow: TextOverflow.ellipsis,
),
),
Text(
"Rede: $redeConectadaAtual",
style: TextStyle(fontSize: 10, color: corSecundaria),
overflow: TextOverflow.ellipsis,
),
],
),
],
),
),
​const SizedBox(height: 12),
​// Orbe Neural Holográfico Dinâmico
Container(
width: 70,
height: 70,
decoration: BoxDecoration(
shape: BoxShape.circle,
gradient: RadialGradient(
colors: [corSecundaria, corPrimaria],
center: const Alignment(-0.3, -0.5),
radius: 0.8,
),
boxShadow: [BoxShadow(color: corPrimaria.withOpacity(0.5), blurRadius: 15, spreadRadius: 3)],
),
child: Stack(
alignment: Alignment.center,
children: [
Positioned(left: 18, top: 20, child: Container(width: 5, height: 10, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)))),
Positioned(right: 18, top: 20, child: Container(width: 5, height: 10, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)))),
],
),
),
​const SizedBox(height: 8),
​// Chat Moderno Estilo App Profissional
Expanded(
child: ListView.builder(
controller: _scrollController,
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
itemCount: mensagens.length,
itemBuilder: (context, index) {
final msg = mensagens[index];
final isUser = msg["isUser"] ?? false;
final isSystem = msg["isSystem"] ?? false;
​return Align(
alignment: isSystem ? Alignment.center : (isUser ? Alignment.centerRight : Alignment.centerLeft),
child: Container(
margin: const EdgeInsets.only(bottom: 12),
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.8),
decoration: BoxDecoration(
color: isSystem ? Colors.transparent : (isUser ? corPrimaria : (modoEscuroChat ? const Color(0xFF1E293B) : Colors.white)),
borderRadius: BorderRadius.circular(isSystem ? 10 : raioBordas),
border: isSystem ? Border.all(color: Colors.white24) : null,
boxShadow: isSystem ? [] : [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3))],
),
child: Text(
msg["texto"],
textAlign: isSystem ? TextAlign.center : TextAlign.left,
style: TextStyle(
color: isSystem ? Colors.white65 : (isUser ? Colors.white : (modoEscuroChat ? Colors.white : const Color(0xFF1E293B))),
fontSize: isSystem ? 12 : 14,
),
),
),
);
},
),
),
​if (isLendo) LinearProgressIndicator(color: corPrimaria, backgroundColor: Colors.transparent),
​// Barra de Entrada de Mensagens e Comandos de Chat
Padding(
padding: const EdgeInsets.all(12),
child: Container(
decoration: BoxDecoration(
color: modoEscuroChat ? const Color(0xFF1E293B) : Colors.white,
borderRadius: BorderRadius.circular(30),
boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, -2))],
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
hintText: "Mensagem ou 'mudar cor verde'...",
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
}    final documento = PdfDocument(inputBytes: await arquivo.readAsBytes());
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
