import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agente_ia/nova_dashboard.dart';

void main() {
  testWidgets('dashboard navigation and appearance controls work', (tester) async {
    final appearance = NovaAppearance();
    await tester.pumpWidget(MaterialApp(home: NovaDashboard(
      appearance: appearance, generation: 2, concepts: 35,
      experiences: 12, connections: 18, synapses: 32,
      neuralTrainingPairs: 120, neuralEntropy: 2.4, age: const Duration(hours: 4),
      status: 'Repouso', responseMs: 14,
      messages: const [{'texto': 'Olá', 'isSystem': true}],
      input: TextEditingController(), scroll: ScrollController(),
      onSend: (_) {}, onImport: () {}, onBackup: () {},
      onEvolve: () {}, onAppearance: () {},
      onResearch: () {}, isReading: false,
      plugins: const [], onPlugin: (_) {},
      onRunTests: () {}, onAddEvaluation: () {}, onShowCommands: () {},
      isThinking: false, resourceState: 'pronto', resourceReason: 'teste', backgroundEnabled: false,
      autonomousStudyEnabled: true, milestones: const [],
      onInstallLocal: () {}, onInstallUrl: () {},
    )));
    expect(find.text('G2'), findsWidgets);
    expect(find.text('14 ms'), findsOneWidget);
    await tester.tap(find.text('Sistema'));
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.text('Sistema'), findsWidgets);
    await tester.tap(find.text('Comandos'));
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.text('Olá'), findsOneWidget);
  });
}
