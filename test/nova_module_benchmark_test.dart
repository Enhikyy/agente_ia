import 'package:flutter_test/flutter_test.dart';
import 'package:agente_ia/nova_module_benchmark.dart';

void main() {
  const gate = NovaModuleGate();
  NovaModuleBenchmark score(double accuracy, int latency, int pss,
      {int samples = 40}) => NovaModuleBenchmark(
        accuracy: accuracy, latencyUs: latency, processPssKb: pss,
        sampleCount: samples,
      );

  test('requires simultaneous 20 percent latency and real PSS improvements',
      () {
    final baseline = score(.96, 1000, 100000);
    expect(gate.eligible(baseline, score(.96, 800, 80000)), isTrue);
    expect(gate.eligible(baseline, score(.96, 801, 80000)), isFalse);
    expect(gate.eligible(baseline, score(.96, 800, 80001)), isFalse);
    expect(gate.eligible(baseline, score(.95, 700, 70000)), isFalse);
    expect(gate.eligible(baseline, score(.96, 700, 70000, samples: 5)),
        isFalse);
    expect(gate.eligible(baseline, score(.96, 700, 0)), isFalse);
  });
}
