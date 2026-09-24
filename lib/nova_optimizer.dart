import 'dart:math';

/// Evaluates data-only retrieval configurations. Never executes downloaded
/// code, modifies APK files or elevates Android permissions.
class NovaOptimizer {
  const NovaOptimizer();

  NovaOptimizationReport optimize({
    required List<NovaBenchmarkCase> cases,
    required String Function(String question, double threshold) answer,
    required double currentThreshold,
  }) {
    final candidates = <double>{currentThreshold, .12, .20, .30, .42, .55}
        .where((v) => v >= 0 && v <= 1).toList()..sort();
    if (cases.length < 10) {
      return NovaOptimizationReport(currentThreshold, currentThreshold,
          false, 0, 0, cases.length,
          'São necessários pelo menos 10 casos de teste independentes.');
    }
    // Deterministic hold-out: do not optimize against the final 20%.
    final train = <NovaBenchmarkCase>[];
    final holdout = <NovaBenchmarkCase>[];
    for (var i = 0; i < cases.length; i++) {
      if (i % 5 == 0) { holdout.add(cases[i]); } else { train.add(cases[i]); }
    }
    double score(List<NovaBenchmarkCase> set, double threshold) {
      var correct = 0;
      for (final item in set) {
        final output = answer(item.question, threshold).toLowerCase();
        if (output.contains(item.expected.toLowerCase())) correct++;
      }
      return correct / set.length;
    }
    final baseline = score(holdout, currentThreshold);
    var best = currentThreshold;
    var bestTrain = score(train, currentThreshold);
    for (final candidate in candidates) {
      final value = score(train, candidate);
      if (value > bestTrain) {
        bestTrain = value;
        best = candidate;
      }
    }
    final validated = score(holdout, best);
    final accepted = best != currentThreshold &&
        validated > baseline && validated >= .80;
    return NovaOptimizationReport(currentThreshold,
        accepted ? best : currentThreshold, accepted,
        baseline, validated, cases.length,
        accepted ? 'Candidato aprovado no conjunto independente.' :
          'Configuração preservada: sem melhora validada.');
  }
}

class NovaBenchmarkCase {
  const NovaBenchmarkCase(this.question, this.expected);
  final String question, expected;
}

class NovaOptimizationReport {
  const NovaOptimizationReport(this.previousThreshold, this.threshold,
      this.accepted, this.baselineAccuracy, this.candidateAccuracy,
      this.samples, this.reason);
  final double previousThreshold, threshold, baselineAccuracy,
      candidateAccuracy;
  final bool accepted;
  final int samples;
  final String reason;
  double get estimatedAccuracy => candidateAccuracy * 100;
  // No claim of hallucination rate: requires independent claim-level labels.
  double? get hallucinationRate => null;
}
