import 'package:flutter_test/flutter_test.dart';
import 'package:agente_ia/nova_diagnostics.dart';

void main() {
  test('exports aggregate metrics without personal source content', () {
    final report = NovaDiagnostics.build(
      generationReports: [
        {'generation': 2, 'accuracyPercent': 75.0,
         'privateQuestion': 'SECRET QUESTION',
         'privateAnswer': 'SECRET ANSWER',
         'optimizerReason': 'SECRET INTERNAL NOTES'},
      ],
      responseSamplesMs: [100, 200, 300, 400],
      resourceSamples: [
        {'batteryPercent': 90, 'temperatureC': 34.0},
      ],
      evaluationCount: 10, generation: 2, concepts: 15,
      experiences: 20, retrievalThreshold: .2,
    );
    final json = NovaDiagnostics.encode(report);
    expect(report['schemaVersion'], 1);
    expect((report['responseMetrics'] as Map)['meanMs'], 250);
    expect((report['responseMetrics'] as Map)['p95Ms'], 400);
    expect(json, contains('"accuracyPercent": 75.0'));
    expect(json, isNot(contains('SECRET')));
  });

  test('empty response samples are explicitly unmeasured', () {
    final report = NovaDiagnostics.build(
      generationReports: [], responseSamplesMs: [], resourceSamples: [],
      evaluationCount: 0, generation: 0, concepts: 0,
      experiences: 0, retrievalThreshold: 0,
    );
    expect((report['responseMetrics'] as Map)['meanMs'], isNull);
    expect((report['responseMetrics'] as Map)['p95Ms'], isNull);
  });
}
