import 'dart:math';
import 'nova_neural_core.dart';

class NovaNeuralBenchScore {
  const NovaNeuralBenchScore({
    required this.label,
    required this.parameters,
    required this.activeParameters,
    required this.activeNeurons,
    required this.accuracy,
    required this.latencyUs,
    required this.sampleCount,
  });
  final String label;
  final int parameters, activeParameters, activeNeurons, latencyUs, sampleCount;
  final double accuracy;

  Map<String, dynamic> toJson() => {
    'label': label,
    'parameters': parameters,
    'activeParameters': activeParameters,
    'activeNeurons': activeNeurons,
    'accuracy': accuracy,
    'latencyUs': latencyUs,
    'sampleCount': sampleCount,
  };
}

class NovaNeuralLabResult {
  const NovaNeuralLabResult({
    required this.baseline,
    required this.candidates,
    required this.promotedLabel,
    required this.promotedModel,
  });
  final NovaNeuralBenchScore baseline;
  final List<NovaNeuralBenchScore> candidates;
  final String? promotedLabel;
  final NovaNeuralCore? promotedModel;

  List<NovaNeuralBenchScore> get ranking {
    final all = <NovaNeuralBenchScore>[baseline, ...candidates];
    all.sort((a, b) {
      final accuracy = b.accuracy.compareTo(a.accuracy);
      if (accuracy != 0) return accuracy;
      final latency = a.latencyUs.compareTo(b.latencyUs);
      if (latency != 0) return latency;
      return a.parameters.compareTo(b.parameters);
    });
    return all;
  }
}

class NovaNeuralLab {
  const NovaNeuralLab();

  NovaNeuralBenchScore benchmark(
    String label,
    NovaNeuralCore model,
    String holdout,
  ) {
    final usable = holdout.length.clamp(32, 900).toInt();
    final sample = holdout.substring(0, usable);
    final warmup = Stopwatch()..start();
    model.accuracy(sample);
    warmup.stop();
    final sw = Stopwatch()..start();
    for (var i = 0; i < 2; i++) {
      model.accuracy(sample);
    }
    sw.stop();
    final latency = max(1, sw.elapsedMicroseconds ~/ 2);
    return NovaNeuralBenchScore(
      label: label,
      parameters: model.parametros,
      activeParameters: model.parametrosAtivosEstimados,
      activeNeurons: model.neuronsActive,
      accuracy: model.accuracy(sample),
      latencyUs: latency,
      sampleCount: sample.length - 1,
    );
  }

  List<NovaNeuralCore> buildCandidates(
    NovaNeuralCore baseline,
    String training,
  ) {
    final candidates = <NovaNeuralCore>[];
    const budgets = <int>[8, 12, 16, 20];
    for (final budget in budgets) {
      if (budget < baseline.neuronsActive) {
        candidates.add(baseline.candidate(
          training,
          activeNeuronBudget: budget,
          rate: 0.012,
        ));
      }
    }
    for (final hidden in <int>[112, 96, 80, 64]) {
      if (hidden < baseline.hiddenSize) {
        candidates.add(baseline.resizedCandidate(
          training,
          hidden,
          activeNeuronBudget: min(hidden, 16),
          rate: 0.012,
        ));
      }
    }
    final next = baseline.proximaEtapa;
    if (next != null) {
      candidates.add(baseline.resizedCandidate(
        training,
        next,
        activeNeuronBudget: min(next, baseline.neuronsActive),
        rate: 0.018,
      ));
    }
    return candidates;
  }

  NovaNeuralLabResult run({
    required NovaNeuralCore baseline,
    required String training,
    required String holdout,
  }) {
    final base = benchmark('ATIVA', baseline, holdout);
    final models = buildCandidates(baseline, training);
    final scores = <NovaNeuralBenchScore>[];
    for (final model in models) {
      final kind = model.parametros < baseline.parametros
          ? 'Compactação '
          : 'Expansão ';
      scores.add(benchmark(kind + model.parametros.toString() + 'p',
        model, holdout));
    }
    String? promoted;
    NovaNeuralCore? promotedModel;
    final byLabel = <String, NovaNeuralCore>{};
    for (var i = 0; i < models.length; i++) {
      final model = models[i];
      final kind = model.parametros < baseline.parametros
          ? 'Compactação '
          : 'Expansão ';
      final score = benchmark(kind + model.parametros.toString() + 'p',
        model, holdout);
      scores.add(score);
      byLabel[score.label] = model;
    }
    for (final score in scores) {
      final faster = score.latencyUs <= base.latencyUs * 0.8;
      final smaller = score.parameters <= base.parameters;
      final precise = score.accuracy >= base.accuracy;
      if (faster && smaller && precise) {
        if (promoted == null) {
          promoted = score.label;
        } else {
          final current = scores.firstWhere((item) => item.label == promoted);
          if (_better(score, current)) promoted = score.label;
        }
      }
    }
    promotedModel = promoted == null ? null : byLabel[promoted];
    return NovaNeuralLabResult(
      baseline: base,
      candidates: scores,
      promotedLabel: promoted,
      promotedModel: promotedModel,
    );
  }

  bool _better(NovaNeuralBenchScore a, NovaNeuralBenchScore b) {
    if (a.accuracy != b.accuracy) return a.accuracy > b.accuracy;
    if (a.latencyUs != b.latencyUs) return a.latencyUs < b.latencyUs;
    return a.parameters < b.parameters;
  }
}
