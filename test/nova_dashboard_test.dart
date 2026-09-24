import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agente_ia/nova_dashboard.dart';

void main() {
  testWidgets('dashboard navigation and appearance controls work', (tester) async {
    final appearance = NovaAppearance();
    var saved = 0;
    await tester.pumpWidget(MaterialApp(home: NovaDashboard(
      appearance: appearance, generation: 2, concepts: 35,
      experiences: 12, age: const Duration(hours: 4),
      status: 'Repouso', responseMs: 14,
      messages: const [{'texto': 'Olá', 'isSystem': true}],
      input: TextEditingController(), scroll: ScrollController(),
      onSend: (_) {}, onImport: () {}, onBackup: () {},
      onEvolve: () {}, onAppearance: () => saved++,
      onResearch: () {}, isReading: false,
      plugins: const [], onPlugin: (_) {},
      isThinking: false, milestones: const [],
      onInstallLocal: () {}, onInstallUrl: () {},
    )));
    expect(find.text('Geração 002'), findsOneWidget);
    expect(find.text('14 ms'), findsOneWidget);
    await tester.tap(find.text('Ajustes'));
    await tester.pumpAndSettle();
    expect(find.text('Personalização'), findsOneWidget);
    await tester.tap(find.text('Oceano'));
    await tester.pumpAndSettle();
    expect(appearance.palette, NovaPalette.ocean);
    expect(saved, greaterThan(0));
    await tester.tap(find.text('Plugins'));
    await tester.pumpAndSettle();
    expect(find.text('Compactação GZIP'), findsOneWidget);
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();
    expect(find.text('Olá'), findsOneWidget);
  });
}
