import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animated three-dot indicator; visible only while an operation is active.
class NovaTypingIndicator extends StatefulWidget {
  const NovaTypingIndicator({super.key, required this.color,
    this.label = 'NOVA está pensando'});
  final Color color;
  final String label;

  @override
  State<NovaTypingIndicator> createState() => _NovaTypingIndicatorState();
}

class _NovaTypingIndicatorState extends State<NovaTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 1050))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: widget.label, liveRegion: true,
    child: ExcludeSemantics(child: AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Row(mainAxisSize: MainAxisSize.min, children: [
        Text(widget.label, style: const TextStyle(
          fontSize: 12, color: Color(0xFF9BA6BE))),
        const SizedBox(width: 10),
        for (var i = 0; i < 3; i++) ...[
          Transform.translate(
            offset: Offset(0, -4 * math.max(0,
              math.sin(2 * math.pi * (_controller.value - i * .17)))),
            child: Container(width: 7, height: 7,
              decoration: BoxDecoration(color: widget.color.withOpacity(
                .38 + .62 * math.max(0,
                  math.sin(2 * math.pi * (_controller.value - i * .17)))),
                shape: BoxShape.circle)),
          ),
          if (i != 2) const SizedBox(width: 5),
        ],
      ]),
    )),
  );
}

/// Stored as factual events, not inferred intelligence levels.
class NovaMilestone {
  const NovaMilestone({required this.id, required this.at,
    required this.title, required this.description,
    required this.generation, required this.concepts});
  final String id, title, description;
  final DateTime at;
  final int generation, concepts;

  Map<String, dynamic> toJson() => {
    'id': id, 'at': at.toIso8601String(), 'title': title,
    'description': description, 'generation': generation,
    'concepts': concepts,
  };

  static NovaMilestone? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final date = DateTime.tryParse(raw['at']?.toString() ?? '');
    final gen = raw['generation'], count = raw['concepts'];
    if (date == null || gen is! int || count is! int ||
        gen < 0 || count < 0) return null;
    return NovaMilestone(id: raw['id']?.toString() ?? '',
      at: date, title: raw['title']?.toString() ?? '',
      description: raw['description']?.toString() ?? '',
      generation: gen, concepts: count);
  }
}

class NovaGrowthTimeline extends StatelessWidget {
  const NovaGrowthTimeline({super.key, required this.events,
    required this.age, required this.generation, required this.concepts,
    required this.experiences, required this.color});
  final List<NovaMilestone> events;
  final Duration age;
  final int generation, concepts, experiences;
  final Color color;

  String get ageLabel {
    if (age.inDays > 0) return '${age.inDays}d ${age.inHours % 24}h';
    if (age.inHours > 0) return '${age.inHours}h ${age.inMinutes % 60}min';
    return '${math.max(0, age.inMinutes)}min';
  }

  @override
  Widget build(BuildContext context) {
    final ordered = events.toList()..sort((a,b) => a.at.compareTo(b.at));
    final current = experiences % 25;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('LINHA DO TEMPO', style: TextStyle(color: color,
        fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.7)),
      const SizedBox(height: 14),
      Wrap(spacing: 10, runSpacing: 10, children: [
        _pill(Icons.cake_outlined, 'Idade: $ageLabel'),
        _pill(Icons.account_tree_outlined, 'Geração $generation'),
        _pill(Icons.hub_outlined, '$concepts conceitos'),
      ]),
      const SizedBox(height: 16),
      Text('Experiências até o próximo marco de atividade: $current/25',
        style: const TextStyle(fontSize: 12)),
      const SizedBox(height: 7),
      LayoutBuilder(builder: (context, bounds) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: current / 25),
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeOutCubic,
        builder: (context, progress, _) => Stack(children: [
          Container(height: 12, width: bounds.maxWidth,
            decoration: BoxDecoration(color: Colors.white10,
              borderRadius: BorderRadius.circular(9))),
          Container(height: 12, width: bounds.maxWidth * progress,
            decoration: BoxDecoration(color: color,
              borderRadius: BorderRadius.circular(9))),
        ]),
      )),
      const SizedBox(height: 7),
      const Text('A barra mede atividade observada, não progresso rumo à inteligência.',
        style: TextStyle(color: Color(0xFF9BA6BE), fontSize: 10)),
      const SizedBox(height: 22),
      const Text('MARCOS REGISTRADOS', style: TextStyle(
        fontSize: 11, letterSpacing: 1.6, color: Color(0xFF9BA6BE))),
      const SizedBox(height: 12),
      for (var i = ordered.length - 1; i >= 0; i--)
        _event(ordered[i], last: i == 0),
    ]);
  }

  Widget _pill(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(color: color.withOpacity(.11),
      borderRadius: BorderRadius.circular(12)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: color, size: 16),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 12)),
    ]),
  );

  Widget _event(NovaMilestone event, {required bool last}) =>
      IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 23, child: Column(children: [
            Container(width: 13, height: 13, decoration: BoxDecoration(
              shape: BoxShape.circle, color: color,
              border: Border.all(color: Colors.white24, width: 2))),
            if (!last) Expanded(child: Container(width: 2,
              color: color.withOpacity(.28))),
          ])),
          const SizedBox(width: 8),
          Expanded(child: Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(event.description, style: const TextStyle(
                  fontSize: 12, color: Color(0xFF9BA6BE))),
                const SizedBox(height: 4),
                Text('${event.at.day.toString().padLeft(2, '0')}/'
                  '${event.at.month.toString().padLeft(2, '0')}/'
                  '${event.at.year} • G${event.generation} • '
                  '${event.concepts} conceitos',
                  style: TextStyle(color: color, fontSize: 10)),
              ])),
          )),
        ]));
}

/// An auditable ancestry: only real accepted generations form branches.
class NovaGenerationTree extends StatelessWidget {
  const NovaGenerationTree({super.key, required this.events,
    required this.currentGeneration, required this.color});
  final List<NovaMilestone> events;
  final int currentGeneration;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final generations = <int, NovaMilestone>{};
    for (final e in events) {
      if (e.id.startsWith('generation-')) generations[e.generation] = e;
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('ÁRVORE DE GERAÇÕES', style: TextStyle(color: color,
        fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.7)),
      const SizedBox(height: 12),
      _node('G0 · Gênese', 'Estado inicial', active: currentGeneration == 0),
      for (var i = 1; i <= currentGeneration && i <= 100; i++) ...[
        Container(margin: const EdgeInsets.only(left: 22),
          width: 2, height: 21, color: color.withOpacity(.38)),
        Padding(padding: EdgeInsets.only(left: math.min(i * 9.0, 72)),
          child: _node('G$i · Descendente de G${i-1}',
            generations[i]?.description ?? 'Geração recuperada do backup',
            active: i == currentGeneration)),
      ],
      if (currentGeneration > 100)
        const Text('Mostrando as primeiras 100 gerações.',
          style: TextStyle(fontSize: 11)),
      const SizedBox(height: 8),
      const Text('Cada ramo corresponde a uma geração registrada; '
        'não representa mutação de código-fonte.',
        style: TextStyle(color: Color(0xFF9BA6BE), fontSize: 10)),
    ]);
  }

  Widget _node(String title, String description, {bool active = false}) =>
    Container(width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: active ? color.withOpacity(.18) : Colors.white.withOpacity(.04),
        border: Border.all(color: active ? color : Colors.white12),
        borderRadius: BorderRadius.circular(13)),
      child: Row(children: [
        Icon(Icons.account_tree_rounded, color: color, size: 22),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700)),
            Text(description, style: const TextStyle(
              fontSize: 11, color: Color(0xFF9BA6BE))),
          ])),
        if (active) Icon(Icons.radio_button_checked, color: color, size: 17),
      ]));
}
