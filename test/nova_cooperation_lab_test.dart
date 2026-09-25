import 'package:flutter_test/flutter_test.dart';
import 'package:agente_ia/nova_cooperation_lab.dart';

class _Peer implements NovaPeer {
  _Peer(this.id, this.reply, {this.fails = false});
  @override
  final String id;
  final String reply;
  final bool fails;
  @override
  Future<String> answer(String prompt) async {
    if (fails) throw StateError('unavailable');
    return reply;
  }
}

void main() {
  const lab = NovaCooperationLab();
  const holdout = [NovaExercise('2+2?', '4')];

  test('never approves solely because peers agree', () async {
    final report = await lab.evaluate(
      peers: [_Peer('a', '5'), _Peer('b', '5')],
      independentHoldout: holdout,
      verify: (prompt, answer) async => answer == '4',
      validateNova: (_) async => true,
    );
    expect(report.approved, isFalse);
    expect(report.examples, isEmpty);
  });

  test('promotion needs independent NOVA validation', () async {
    final report = await lab.evaluate(
      peers: [_Peer('a', '4')],
      independentHoldout: holdout,
      verify: (prompt, answer) async => answer == '4',
      validateNova: (_) async => false,
    );
    expect(report.results.single.accuracy, 1);
    expect(report.approved, isFalse);
  });

  test('peer failure is isolated and other peers continue', () async {
    final report = await lab.evaluate(
      peers: [_Peer('broken', '', fails: true), _Peer('working', '4')],
      independentHoldout: holdout,
      verify: (prompt, answer) async => answer == '4',
      validateNova: (_) async => true,
    );
    expect(report.results.first.errors, isNotEmpty);
    expect(report.results.last.correct, 1);
    expect(report.approved, isTrue);
  });

  test('holdout and unique peers are mandatory', () async {
    expect(
      () => lab.evaluate(peers: [], independentHoldout: [],
        verify: (_, __) async => true, validateNova: (_) async => true),
      throwsArgumentError,
    );
    expect(
      () => lab.evaluate(peers: [_Peer('same', '4'), _Peer('same', '4')],
        independentHoldout: holdout,
        verify: (_, __) async => true, validateNova: (_) async => true),
      throwsArgumentError,
    );
  });
}
