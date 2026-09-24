/// Pure-Dart experiment bench. No downloaded or generated code is executed.
class NovaExperimentResult {
  const NovaExperimentResult(this.hypothesis, this.baselineMs,
      this.candidateMs, this.baselineErrors, this.candidateErrors);
  final String hypothesis;
  final int baselineMs, candidateMs, baselineErrors, candidateErrors;
  bool get improvementVerified => baselineMs > 0 && candidateMs >= 0 &&
      candidateMs < baselineMs && candidateErrors <= baselineErrors &&
      baselineErrors == 0 && candidateErrors == 0;
}

class NovaExperimentLab {
  const NovaExperimentLab();
  /// Compare two already-approved implementations on identical held-out cases.
  /// Do not apply a change based solely on a single timing sample.
  NovaExperimentResult compare<T>(String hypothesis, List<T> cases,
      Object? Function(T) baseline, Object? Function(T) candidate) {
    if (cases.length < 20 || cases.length > 1000) {
      throw ArgumentError('Use between 20 and 1000 independent cases.');
    }
    var baseErrors = 0;
    var newErrors = 0;
    final baselineWatch = Stopwatch()..start();
    final expected = <Object?>[];
    for (final item in cases) {
      try { expected.add(baseline(item)); }
      catch (_) { baseErrors++; expected.add(null); }
    }
    baselineWatch.stop();
    final candidateWatch = Stopwatch()..start();
    for (var i = 0; i < cases.length; i++) {
      try { if (candidate(cases[i]) != expected[i]) newErrors++; }
      catch (_) { newErrors++; }
    }
    candidateWatch.stop();
    return NovaExperimentResult(hypothesis, baselineWatch.elapsedMicroseconds,
        candidateWatch.elapsedMicroseconds, baseErrors, newErrors);
  }
}
