import 'dart:math';

/// Small, genuinely trainable character-level neural predictor.
/// It is deliberately NOT an LLM. Training is bounded for mobile use.
class NovaNeuralCore {
  NovaNeuralCore({this.width = 32})
      : assert(width >= 8 && width <= 128),
        weights = List<double>.filled(width * width, 0);
  final int width;
  final List<double> weights;
  int trainingPairs = 0;
  int generation = 0;

  int _symbol(int code) => code % width;

  /// Online softmax gradient descent on adjacent UTF-16 code units.
  /// Limits each call to 2048 pairs to avoid prolonged UI blocking.
  void train(String text, {double learningRate = 0.08}) {
    if (!learningRate.isFinite || learningRate <= 0 || learningRate > 1) {
      throw ArgumentError.value(learningRate, 'learningRate');
    }
    final count = min(text.length - 1, 2048);
    if (count <= 0) return;
    final probabilities = List<double>.filled(width, 0);
    for (var i = 0; i < count; i++) {
      final input = _symbol(text.codeUnitAt(i));
      final target = _symbol(text.codeUnitAt(i + 1));
      final offset = input * width;
      var peak = weights[offset];
      for (var j = 1; j < width; j++) {
        peak = max(peak, weights[offset + j]);
      }
      var total = 0.0;
      for (var j = 0; j < width; j++) {
        probabilities[j] = exp(weights[offset + j] - peak);
        total += probabilities[j];
      }
      for (var j = 0; j < width; j++) {
        final probability = probabilities[j] / total;
        weights[offset + j] += learningRate *
            ((j == target ? 1.0 : 0.0) - probability);
      }
    }
    trainingPairs += count;
  }

  int predictSymbol(int inputCodeUnit) {
    final offset = _symbol(inputCodeUnit) * width;
    var best = 0;
    for (var i = 1; i < width; i++) {
      if (weights[offset + i] > weights[offset + best]) best = i;
    }
    return best;
  }

  double accuracy(String text) {
    if (text.length < 2) return 0;
    var correct = 0;
    for (var i = 0; i < text.length - 1; i++) {
      if (predictSymbol(text.codeUnitAt(i)) ==
          _symbol(text.codeUnitAt(i + 1))) correct++;
    }
    return correct / (text.length - 1);
  }

  NovaNeuralCore copy() {
    final result = NovaNeuralCore(width: width);
    result.weights.setAll(0, weights);
    result.trainingPairs = trainingPairs;
    result.generation = generation;
    return result;
  }

  /// A candidate is trained without mutating the active generation.
  NovaNeuralCore candidate(String trainingText, {double rate = 0.08}) {
    final result = copy()..generation = generation + 1;
    result.train(trainingText, learningRate: rate);
    return result;
  }

  Map<String, dynamic> toJson() => {
    'format': 'nova-neural-bigram', 'version': 1, 'width': width,
    'generation': generation, 'trainingPairs': trainingPairs,
    'weights': weights,
  };

  factory NovaNeuralCore.fromJson(Object? raw) {
    if (raw is! Map || raw['format'] != 'nova-neural-bigram' ||
        raw['version'] != 1 || raw['width'] is! int ||
        raw['weights'] is! List) {
      throw const FormatException('Invalid neural state');
    }
    final width = raw['width'] as int;
    if (width < 8 || width > 128 ||
        (raw['weights'] as List).length != width * width) {
      throw const FormatException('Invalid neural dimensions');
    }
    final result = NovaNeuralCore(width: width);
    for (var i = 0; i < result.weights.length; i++) {
      final value = (raw['weights'] as List)[i];
      if (value is! num || !value.toDouble().isFinite ||
          value.abs() > 1000) {
        throw const FormatException('Invalid neural weight');
      }
      result.weights[i] = value.toDouble();
    }
    final generation = raw['generation'];
    final pairs = raw['trainingPairs'];
    if (generation is! int || generation < 0 ||
        pairs is! int || pairs < 0) {
      throw const FormatException('Invalid neural counters');
    }
    result.generation = generation;
    result.trainingPairs = pairs;
    return result;
  }
}
