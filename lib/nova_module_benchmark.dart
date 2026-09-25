import 'dart:math';
import 'package:flutter/services.dart';
import 'nova_module_runtime.dart';

class NovaModuleBenchmark {
  const NovaModuleBenchmark({
    required this.accuracy, required this.latencyUs,
    required this.processPssKb, required this.sampleCount,
  });
  final double accuracy;
  final int latencyUs, processPssKb, sampleCount;
  Map<String, dynamic> toJson() => {
    'accuracy': accuracy, 'latencyUs': latencyUs,
    'processPssKb': processPssKb, 'sampleCount': sampleCount,
    'memoryMetric': 'Android Debug.MemoryInfo.totalPss',
  };
}

/// Strictly fail-closed: missing PSS measurements prevent promotion.
class NovaModuleGate {
  const NovaModuleGate();
  bool eligible(NovaModuleBenchmark baseline, NovaModuleBenchmark candidate) =>
      baseline.sampleCount >= 20 && candidate.sampleCount >= 20 &&
      baseline.accuracy >= .95 && candidate.accuracy >= .95 &&
      candidate.accuracy >= baseline.accuracy &&
      baseline.latencyUs > 0 && baseline.processPssKb > 0 &&
      candidate.latencyUs > 0 && candidate.processPssKb > 0 &&
      candidate.latencyUs <= baseline.latencyUs * .8 &&
      candidate.processPssKb <= baseline.processPssKb * .8;
}

class NovaModuleBenchmarker {
  const NovaModuleBenchmarker();
  static const _memory = MethodChannel('nova/process_memory');

  Future<int?> _pss() async {
    try {
      final result = await _memory.invokeMapMethod<String, dynamic>('read');
      final value = result?['totalPssKb'];
      return value is int && value > 0 ? value : null;
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  /// Compare two implementations on the exact same held-out inputs.
  /// A result with unavailable process PSS cannot be promoted.
  Future<NovaModuleBenchmark?> measure(
    NovaModule module, List<String> holdout,
    String Function(String) reference,
  ) async {
    if (holdout.length < 20) return null;
    final before = await _pss();
    if (before == null) return null;
    final outputs = <String>[];
    final timings = <int>[];
    for (final input in holdout.take(100)) {
      final stopwatch = Stopwatch()..start();
      final output = module.execute(input);
      stopwatch.stop();
      outputs.add(output);
      timings.add(max(1, stopwatch.elapsedMicroseconds));
    }
    final after = await _pss();
    if (after == null) return null;
    var correct = 0;
    for (var i = 0; i < outputs.length; i++) {
      if (outputs[i] == reference(holdout[i])) correct++;
    }
    timings.sort();
    return NovaModuleBenchmark(
      accuracy: correct / outputs.length,
      latencyUs: timings[timings.length ~/ 2],
      processPssKb: max(before, after),
      sampleCount: outputs.length,
    );
  }
}
