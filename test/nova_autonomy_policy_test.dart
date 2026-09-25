import 'package:flutter_test/flutter_test.dart';
import 'package:agente_ia/nova_autonomy_policy.dart';

void main() {
  final now = DateTime.utc(2026, 9, 24);
  const policy = NovaAutonomyPolicy();

  test('supervised autonomy is enabled', () {
    expect(policy.canResearchScheduled, true);
    expect(NovaAutonomyPolicy.fromJson(policy.toJson()).mode,
      NovaAutonomyMode.supervised);
  });

  test('purges only expired explicitly disposable app-generated records', () {
    NovaMemoryRecord record({bool disposable = true,
      bool protected = false, bool userProvided = false,
      int ageDays = 31}) => NovaMemoryRecord(
        id: 'cache', content: 'temporary', disposable: disposable,
        protected: protected, userProvided: userProvided,
        createdAt: now.subtract(Duration(days: ageDays)));
    expect(policy.mayDelete(record(), now), true);
    expect(policy.mayDelete(record(ageDays: 29), now), false);
    expect(policy.mayDelete(record(protected: true), now), false);
    expect(policy.mayDelete(record(userProvided: true), now), false);
    expect(policy.mayDelete(record(disposable: false), now), false);
  });

  test('invalid policy retention defaults to 30 days', () {
    final restored = NovaAutonomyPolicy.fromJson({
      'mode': 'supervised', 'deletion': 'disposableAutomatic',
      'retentionDays': -1,
    });
    expect(restored.disposableRetention.inDays, 30);
  });
}
