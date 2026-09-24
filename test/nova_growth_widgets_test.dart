import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agente_ia/nova_growth_widgets.dart';

void main() {
  test('milestone survives JSON round trip', () {
    final event = NovaMilestone(id: 'generation-1',
      at: DateTime.utc(2026, 9, 24), title: 'Geração 1',
      description: 'Compressão validada', generation: 1, concepts: 50);
    final restored = NovaMilestone.fromJson(event.toJson())!;
    expect(restored.id, event.id);
    expect(restored.generation, 1);
    expect(restored.at, event.at);
    expect(NovaMilestone.fromJson({'generation': -1}), isNull);
  });

  testWidgets('thinking indicator is animated and accessible', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(
      body: NovaTypingIndicator(color: Colors.purple))));
    expect(find.byType(NovaTypingIndicator), findsOneWidget);
    expect(find.text('NOVA está pensando'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets('progress and generation tree render factual milestones',
      (tester) async {
    final events = [NovaMilestone(id: 'generation-1',
      at: DateTime.utc(2026, 9, 24), title: 'Geração aprovada',
      description: 'Snapshot compactado', generation: 1, concepts: 42)];
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(
      child: Column(children: [
        NovaGrowthTimeline(events: events, age: const Duration(hours: 26),
          generation: 1, concepts: 42, experiences: 27, color: Colors.teal),
        NovaGenerationTree(events: events, currentGeneration: 1,
          color: Colors.teal),
      ])))));
    expect(find.text('Geração aprovada'), findsOneWidget);
    expect(find.text('Experiências até o próximo marco de atividade: 2/25'),
      findsOneWidget);
    expect(find.text('G1 · Descendente de G0'), findsOneWidget);
  });
}
