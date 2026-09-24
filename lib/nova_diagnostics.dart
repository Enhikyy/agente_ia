import 'dart:convert';

/// Exports only aggregate metrics. No conversations, questions, documents,
/// file paths, installed packages, or personally identifying device data.
class NovaDiagnostics {
  static const schemaVersion = 1;

  static Map<String, dynamic> build({
    required List<Map<String, dynamic>> generationReports,
    required List<int> responseSamplesMs,
    required List<Map<String, dynamic>> resourceSamples,
    required int evaluationCount,
    required int generation,
    required int concepts,
    required int experiences,
    required double retrievalThreshold,
  }) {
    final times = responseSamplesMs.where((n) => n >= 0).toList()..sort();
    final reports = generationReports.map((r) => <String, dynamic>{
      for (final key in [
        'generation', 'accepted', 'at', 'durationMs', 'meanResponseMs',
        'beforeBytes', 'afterBytes', 'compressionPercent', 'conceptDelta',
        'connectionDelta', 'accuracyPercent', 'evaluationCount',
        'hallucinationEstimatePercent', 'optimizerAccepted',
        'previousThreshold', 'threshold', 'holdoutBefore', 'holdoutAfter'
      ])
        if (r[key] == null || r[key] is num || r[key] is bool ||
            (key == 'at' && r[key] is String))
          key: r[key],
    }).take(100).toList();
    return {
      'schemaVersion': schemaVersion,
      'generatedAtUtc': DateTime.now().toUtc().toIso8601String(),
      'privacy': 'Aggregate metrics only; no raw conversations or documents.',
      'model': 'NOVA symbolic retrieval',
      'generation': generation,
      'concepts': concepts,
      'experiences': experiences,
      'retrievalThreshold': retrievalThreshold,
      'evaluationCount': evaluationCount,
      'responseMetrics': {
        'sampleCount': times.length,
        'meanMs': times.isEmpty ? null :
            times.reduce((a, b) => a + b) / times.length,
        'p95Ms': times.isEmpty ? null :
            times[((times.length * .95).ceil() - 1).clamp(0, times.length - 1)],
      },
      'resourceSamples': resourceSamples.take(500).toList(),
      'generationReports': reports,
      'limitations': [
        'Textual accuracy is not an independently verified factual accuracy.',
        'Hallucination rate is unavailable without independent claim labels.',
        'Battery and thermal measurements are sampled while app is open.',
      ],
    };
  }

  static String encode(Map<String, dynamic> report) =>
      const JsonEncoder.withIndent('  ').convert(report);
}
