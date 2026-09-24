import 'dart:convert';
import 'dart:math';

/// Private data format; never executable code and never network replication.
class NovaGenome {
  const NovaGenome(this.version, this.retrievalWeight, this.cacheSize);
  final int version;
  final double retrievalWeight;
  final int cacheSize;
  Map<String, dynamic> toJson() => {
    'format': 'nova-genome', 'version': version,
    'retrievalWeight': retrievalWeight, 'cacheSize': cacheSize,
  };
  factory NovaGenome.fromJson(Object? raw) {
    if (raw is! Map || raw['format'] != 'nova-genome' ||
        raw['version'] != 1 || raw['retrievalWeight'] is! num ||
        raw['cacheSize'] is! int) {
      throw const FormatException('Invalid genome format.');
    }
    final weight = (raw['retrievalWeight'] as num).toDouble();
    final cache = raw['cacheSize'] as int;
    if (!weight.isFinite || weight < 0.1 || weight > 4 ||
        cache < 16 || cache > 1024) {
      throw const FormatException('Genome outside safe bounds.');
    }
    return NovaGenome(1, weight, cache);
  }
  String encode() => jsonEncode(toJson());
}

class NovaEvolutionLab {
  const NovaEvolutionLab();
  /// Mutate data-only local candidates, not executable source or APKs.
  List<NovaGenome> candidates(NovaGenome parent) {
    final values = <NovaGenome>[parent];
    for (final factor in <double>[0.75, 0.9, 1.1, 1.25]) {
      values.add(NovaGenome(1,
        (parent.retrievalWeight * factor).clamp(0.1, 4.0),
        (parent.cacheSize * factor).round().clamp(16, 1024)));
    }
    return values;
  }
  /// Promote only after an external held-out evaluator supplies results.
  NovaGenome select(NovaGenome incumbent,
      Map<NovaGenome, ({double accuracy, int latencyUs, int memoryKb})> scores) {
    final baseline = scores[incumbent];
    if (baseline == null || baseline.accuracy < .95 || baseline.latencyUs <= 0) {
      return incumbent;
    }
    var winner = incumbent;
    for (final entry in scores.entries) {
      final score = entry.value;
      if (!score.accuracy.isFinite || score.accuracy < .95 ||
          score.accuracy < baseline.accuracy || score.latencyUs <= 0 ||
          score.memoryKb <= 0 || score.memoryKb > baseline.memoryKb) continue;
      final best = scores[winner]!;
      if (score.latencyUs < best.latencyUs &&
          score.accuracy >= best.accuracy) winner = entry.key;
    }
    return winner;
  }
}
