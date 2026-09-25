import 'dart:convert';
import 'dart:math';

/// Núcleo neural treinável da NOVA, projetado para crescer por etapas.
/// A primeira arquitetura possui 100.384 parâmetros treináveis.
/// O modelo trabalha em bytes UTF-8 e aprende previsão do próximo byte.
class NovaNeuralCore {
  static const int vocabulario = 256;
  static const int dimensaoEntrada = 128;
  static const int dimensaoInicial = 160;
  static const int versao = 2;
  static const List<int> etapas = <int>[160, 256, 512, 768, 1024, 1536, 2048];

  NovaNeuralCore({int hiddenSize = dimensaoInicial})
      : hiddenSize = _validHidden(hiddenSize),
        embedding = _pesos(vocabulario * dimensaoEntrada),
        w1 = _pesos(dimensaoEntrada * hiddenSize),
        b1 = List<double>.filled(hiddenSize, 0),
        w2 = _pesos(hiddenSize * hiddenSize),
        b2 = List<double>.filled(hiddenSize, 0),
        w3 = _pesos(hiddenSize * vocabulario),
        b3 = List<double>.filled(vocabulario, 0) {
    _inicializar();
  }

  final int hiddenSize;
  final List<double> embedding;
  final List<double> w1, b1, w2, b2, w3, b3;
  int trainingPairs = 0;
  int generation = 0;

  static int _validHidden(int value) {
    if (!etapas.contains(value)) {
      throw ArgumentError.value(value, 'hiddenSize', 'Arquitetura não suportada.');
    }
    return value;
  }

  static List<double> _pesos(int count) => List<double>.filled(count, 0);

  void _inicializar() {
    for (var i = 0; i < embedding.length; i++) {
      embedding[i] = sin((i + 1) * 12.9898) * 0.025;
    }
    for (var i = 0; i < w1.length; i++) {
      w1[i] = sin((i + 11) * 7.233) * 0.035;
    }
    for (var i = 0; i < w2.length; i++) {
      w2[i] = sin((i + 17) * 5.417) * 0.030;
    }
    for (var i = 0; i < w3.length; i++) {
      w3[i] = sin((i + 23) * 3.971) * 0.025;
    }
  }

  int get parametros => embedding.length + w1.length + b1.length +
      w2.length + b2.length + w3.length + b3.length;

  int get bytesFloat32Estimados => parametros * 4;
  int get bytesFloat64Atuais => parametros * 8;
  int get bytesInt8Estimados => parametros;
  String get modelo => 'NOVA Neural ${parametros} parâmetros';

  int? get proximaEtapa {
    final index = etapas.indexOf(hiddenSize);
    if (index < 0 || index + 1 >= etapas.length) return null;
    return etapas[index + 1];
  }

  String get estagio => hiddenSize == 160 ? 'Fundação 100 mil' :
      hiddenSize < 512 ? 'Expansão inicial' :
      hiddenSize < 1024 ? 'Expansão intermediária' : 'Expansão avançada';

  List<int> _bytes(String text) => utf8.encode(text);

  void _ativacao(List<int> contexto, List<double> h1, List<double> h2,
      List<double> logits) {
    final n = max(1, contexto.length);
    final entrada = List<double>.filled(dimensaoEntrada, 0);
    for (final token in contexto) {
      final base = token * dimensaoEntrada;
      for (var j = 0; j < dimensaoEntrada; j++) {
        entrada[j] += embedding[base + j] / n;
      }
    }
    for (var j = 0; j < hiddenSize; j++) {
      var sum = b1[j];
      final base = j;
      for (var i = 0; i < dimensaoEntrada; i++) {
        sum += entrada[i] * w1[i * hiddenSize + base];
      }
      h1[j] = tanh(sum);
    }
    for (var j = 0; j < hiddenSize; j++) {
      var sum = b2[j];
      for (var i = 0; i < hiddenSize; i++) {
        sum += h1[i] * w2[i * hiddenSize + j];
      }
      h2[j] = tanh(sum);
    }
    for (var o = 0; o < vocabulario; o++) {
      var sum = b3[o];
      for (var i = 0; i < hiddenSize; i++) {
        sum += h2[i] * w3[i * vocabulario + o];
      }
      logits[o] = sum;
    }
  }

  /// Treino incremental, limitado para não monopolizar o aparelho.
  /// O limite pode ser aumentado em experiências controladas.
  int train(String text, {double learningRate = 0.025, int maxExamples = 64}) {
    if (!learningRate.isFinite || learningRate <= 0 || learningRate > 1) {
      throw ArgumentError.value(learningRate, 'learningRate');
    }
    if (maxExamples < 1 || maxExamples > 512) {
      throw ArgumentError.value(maxExamples, 'maxExamples');
    }
    final bytes = _bytes(text);
    if (bytes.length < 2) return 0;
    final examples = min(maxExamples, bytes.length - 1);
    final h1 = List<double>.filled(hiddenSize, 0);
    final h2 = List<double>.filled(hiddenSize, 0);
    final logits = List<double>.filled(vocabulario, 0);
    final probs = List<double>.filled(vocabulario, 0);
    final d2 = List<double>.filled(hiddenSize, 0);
    final d1 = List<double>.filled(hiddenSize, 0);
    for (var step = 0; step < examples; step++) {
      final end = step + 1;
      final start = max(0, end - 16);
      final contexto = bytes.sublist(start, end);
      _ativacao(contexto, h1, h2, logits);
      var peak = logits[0];
      for (var i = 1; i < vocabulario; i++) {
        peak = max(peak, logits[i]);
      }
      var total = 0.0;
      for (var i = 0; i < vocabulario; i++) {
        probs[i] = exp((logits[i] - peak).clamp(-30, 30));
        total += probs[i];
      }
      final inv = 1 / max(total, 1e-12);
      for (var i = 0; i < vocabulario; i++) {
        probs[i] *= inv;
      }
      final target = bytes[end];
      for (var i = 0; i < hiddenSize; i++) d2[i] = 0;
      for (var o = 0; o < vocabulario; o++) {
        final d3 = (o == target ? 1.0 : 0.0) - probs[o];
        final base = o;
        for (var i = 0; i < hiddenSize; i++) {
          d2[i] += d3 * w3[i * vocabulario + base];
        }
        for (var i = 0; i < hiddenSize; i++) {
          w3[i * vocabulario + base] += learningRate * d3 * h2[i];
        }
        b3[o] += learningRate * d3;
      }
      for (var i = 0; i < hiddenSize; i++) {
        d2[i] *= (1 - h2[i] * h2[i]);
      }
      for (var i = 0; i < hiddenSize; i++) {
        d1[i] = 0;
        for (var j = 0; j < hiddenSize; j++) {
          d1[i] += d2[j] * w2[i * hiddenSize + j];
        }
      }
      for (var i = 0; i < hiddenSize; i++) {
        for (var j = 0; j < hiddenSize; j++) {
          w2[i * hiddenSize + j] += learningRate * d2[j] * h1[i];
        }
      }
      for (var j = 0; j < hiddenSize; j++) {
        b2[j] += learningRate * d2[j];
        d1[j] *= (1 - h1[j] * h1[j]);
      }
      final n = max(1, contexto.length);
      final entrada = List<double>.filled(dimensaoEntrada, 0);
      for (final token in contexto) {
        final base = token * dimensaoEntrada;
        for (var i = 0; i < dimensaoEntrada; i++) {
          entrada[i] += embedding[base + i] / n;
        }
      }
      for (var i = 0; i < dimensaoEntrada; i++) {
        var grad = 0.0;
        for (var j = 0; j < hiddenSize; j++) {
          grad += d1[j] * w1[i * hiddenSize + j];
        }
        for (final token in contexto) {
          embedding[token * dimensaoEntrada + i] +=
              learningRate * grad / n;
        }
        for (var j = 0; j < hiddenSize; j++) {
          w1[i * hiddenSize + j] +=
              learningRate * d1[j] * entrada[i];
        }
      }
      trainingPairs++;
    }
    return examples;
  }

  int predictByte(List<int> contexto) {
    if (contexto.isEmpty) return 32;
    final limited = contexto.length <= 16
        ? contexto
        : contexto.sublist(contexto.length - 16);
    final h1 = List<double>.filled(hiddenSize, 0);
    final h2 = List<double>.filled(hiddenSize, 0);
    final logits = List<double>.filled(vocabulario, 0);
    _ativacao(limited, h1, h2, logits);
    var best = 0;
    for (var i = 1; i < vocabulario; i++) {
      if (logits[i] > logits[best]) best = i;
    }
    return best;
  }

  double accuracy(String text) {
    final bytes = _bytes(text);
    if (bytes.length < 2) return 0;
    var correct = 0;
    for (var i = 1; i < bytes.length; i++) {
      final start = max(0, i - 16);
      if (predictByte(bytes.sublist(start, i)) == bytes[i]) correct++;
    }
    return correct / (bytes.length - 1);
  }

  String generate(String prompt, {int maxBytes = 160}) {
    if (maxBytes < 1 || maxBytes > 1024) {
      throw ArgumentError.value(maxBytes, 'maxBytes');
    }
    final result = _bytes(prompt);
    for (var i = 0; i < maxBytes; i++) {
      final next = predictByte(result);
      result.add(next);
    }
    return utf8.decode(result, allowMalformed: true);
  }

  NovaNeuralCore copy() {
    final result = NovaNeuralCore(hiddenSize: hiddenSize);
    result.embedding.setAll(0, embedding);
    result.w1.setAll(0, w1);
    result.b1.setAll(0, b1);
    result.w2.setAll(0, w2);
    result.b2.setAll(0, b2);
    result.w3.setAll(0, w3);
    result.b3.setAll(0, b3);
    result.trainingPairs = trainingPairs;
    result.generation = generation;
    return result;
  }

  NovaNeuralCore candidate(String trainingText, {double rate = 0.025}) {
    final result = copy()..generation = generation + 1;
    result.train(trainingText, learningRate: rate, maxExamples: 64);
    return result;
  }

  NovaNeuralCore expandedCandidate(String trainingText, int targetHidden,
      {double rate = 0.02}) {
    final target = NovaNeuralCore(hiddenSize: targetHidden)
      ..generation = generation + 1;
    final overlap = min(hiddenSize, targetHidden);
    target.embedding.setAll(0, embedding);
    for (var i = 0; i < dimensaoEntrada; i++) {
      for (var j = 0; j < overlap; j++) {
        target.w1[i * targetHidden + j] = w1[i * hiddenSize + j];
      }
    }
    for (var j = 0; j < overlap; j++) {
      target.b1[j] = b1[j];
      target.b2[j] = b2[j];
      for (var k = 0; k < overlap; k++) {
        target.w2[j * targetHidden + k] = w2[j * hiddenSize + k];
      }
      for (var o = 0; o < vocabulario; o++) {
        target.w3[j * vocabulario + o] = w3[j * vocabulario + o];
      }
    }
    target.b3.setAll(0, b3);
    target.trainingPairs = trainingPairs;
    target.train(trainingText, learningRate: rate, maxExamples: 96);
    return target;
  }

  Map<String, dynamic> toJson() => {
    'format': 'nova-neural-mlp',
    'version': versao,
    'vocabulario': vocabulario,
    'dimensaoEntrada': dimensaoEntrada,
    'hiddenSize': hiddenSize,
    'generation': generation,
    'trainingPairs': trainingPairs,
    'embedding': embedding, 'w1': w1, 'b1': b1,
    'w2': w2, 'b2': b2, 'w3': w3, 'b3': b3,
  };

  factory NovaNeuralCore.fromJson(Object? raw) {
    if (raw is! Map || raw['format'] != 'nova-neural-mlp' ||
        raw['version'] != versao || raw['hiddenSize'] is! int) {
      // Estado neural antigo é incompatível com a nova arquitetura.
      // A memória textual permanece intacta no arquivo principal.
      return NovaNeuralCore();
    }
    final hidden = raw['hiddenSize'] as int;
    final result = NovaNeuralCore(hiddenSize: hidden);
    void restore(List<double> target, Object? value) {
      if (value is! List || value.length != target.length) {
        throw const FormatException('Dimensões neurais inválidas');
      }
      for (var i = 0; i < target.length; i++) {
        final n = value[i];
        if (n is! num || !n.toDouble().isFinite || n.toDouble().abs() > 10) {
          throw const FormatException('Peso neural inválido');
        }
        target[i] = n.toDouble();
      }
    }
    restore(result.embedding, raw['embedding']);
    restore(result.w1, raw['w1']);
    restore(result.b1, raw['b1']);
    restore(result.w2, raw['w2']);
    restore(result.b2, raw['b2']);
    restore(result.w3, raw['w3']);
    restore(result.b3, raw['b3']);
    final pairs = raw['trainingPairs'];
    final generation = raw['generation'];
    if (pairs is! int || pairs < 0 || generation is! int || generation < 0) {
      throw const FormatException('Contadores neurais inválidos');
    }
    result.trainingPairs = pairs;
    result.generation = generation;
    return result;
  }
}

class NovaNeuralExpansionGate {
  const NovaNeuralExpansionGate();

  bool qualifies({
    required NovaNeuralCore baseline,
    required NovaNeuralCore candidate,
    required double baselineAccuracy,
    required double candidateAccuracy,
  }) {
    if (candidate.parametros <= baseline.parametros) return false;
    if (candidateAccuracy < baselineAccuracy + 0.005) return false;
    if (candidate.trainingPairs < 128) return false;
    final bytes = candidate.bytesFloat32Estimados;
    if (bytes > 32 * 1024 * 1024) return false;
    return true;
  }
}