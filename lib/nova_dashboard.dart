import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'nova_growth_widgets.dart';
import 'nova_neural_checkpoint.dart';

final Future<Uint8List> _novaEmblem = rootBundle
    .loadString('assets/branding/nova_icon.jpg.base64')
    .then((text) => base64Decode(text.trim()));

class NovaEmblem extends StatelessWidget {
  const NovaEmblem({super.key, required this.size});
  final double size;
  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List>(
    future: _novaEmblem,
    builder: (context, snapshot) => ClipRRect(
      borderRadius: BorderRadius.circular(size * .28),
      child: snapshot.hasData
          ? Image.memory(snapshot.data!, width: size, height: size,
              fit: BoxFit.cover, gaplessPlayback: true)
          : Container(
              width: size, height: size,
              color: const Color(0xFF7867FF).withOpacity(.14),
              child: Icon(Icons.auto_awesome_rounded,
                color: const Color(0xFFB8B0FF), size: size * .5),
            ),
    ),
  );
}

enum NovaPalette { violet, ocean, forest }
enum NovaDensity { comfortable, compact }

class NovaAppearance {
  NovaPalette palette;
  NovaDensity density;
  int avatar;
  NovaAppearance({
    this.palette = NovaPalette.violet,
    this.density = NovaDensity.comfortable,
    this.avatar = 0,
  });
  Color get accent => switch (palette) {
    NovaPalette.violet => const Color(0xFF8979FF),
    NovaPalette.ocean => const Color(0xFF49C9EA),
    NovaPalette.forest => const Color(0xFF4CE0A2),
  };
  IconData get avatarIcon => [
    Icons.hub_rounded, Icons.auto_awesome_rounded,
    Icons.psychology_rounded, Icons.blur_on_rounded,
  ][avatar.clamp(0, 3).toInt()];
  Map<String, dynamic> toJson() => {
    'palette': palette.index, 'density': density.index, 'avatar': avatar,
  };
  void restore(Object? raw) {
    if (raw is! Map) return;
    final p = raw['palette'], d = raw['density'], a = raw['avatar'];
    if (p is int && p >= 0 && p < NovaPalette.values.length) {
      palette = NovaPalette.values[p];
    }
    if (d is int && d >= 0 && d < NovaDensity.values.length) {
      density = NovaDensity.values[d];
    }
    if (a is int && a >= 0 && a < 4) avatar = a;
  }
}

class NovaDashboard extends StatefulWidget {
  const NovaDashboard({
    super.key,
    required this.appearance,
    required this.generation,
    required this.concepts,
    required this.experiences,
    required this.connections,
    required this.synapses,
    required this.neuralTrainingPairs,
    required this.neuralParameters,
    required this.neuralModel,
    required this.neuralSparsity,
    required this.nextNeuralParameters,
    required this.neuralEntropy,
    required this.age,
    required this.status,
    required this.responseMs,
    required this.messages,
    required this.input,
    required this.scroll,
    required this.onSend,
    required this.onImport,
    required this.onBackup,
    required this.onEvolve,
    required this.onAppearance,
    required this.onResearch,
    required this.plugins,
    required this.onPlugin,
    required this.onInstallLocal,
    required this.onInstallUrl,
    required this.onRunTests,
    required this.onAddEvaluation,
    required this.onShowCommands,
    this.onDiagnostics,
    this.onCheckUpdates,
    this.onUpdate,
    this.availableUpdateBuild,
    this.checkingUpdates = false,
    this.onRefine,
    this.onSetSupervisedAutonomy,
    this.supervisedAutonomyConfigured = false,
    this.researchProgress = 0,
    this.researchStage = '',
    this.researchMs = 0,
    this.researching = false,
    this.generationReports = const [],
    this.resourceSamples = const [],
    this.checkpoints = const [],
    this.dictionaryEntries = 0,
    this.dictionaryStats = const {},
    this.schoolTopics = const [],
    this.universityTopics = const [],
    this.postgraduateTopics = const [],
    this.passedEducationTopics = const [],
    this.activeNeuronBudget = 24,
    this.onRestoreCheckpoint,
    this.onSetNeuronBudget,
    this.evaluationCount = 0,
    this.evaluationAccuracy,
    this.testPassed = 0,
    this.testTotal = 0,
    this.testFailed = 0,
    this.neuralLinks = const [],
    this.milestones = const [],
    this.isReading = false,
    this.isThinking = false,
    this.resourceState = 'indisponível',
    this.resourceReason = '',
    this.backgroundEnabled = false,
    this.autonomousStudyEnabled = true,
  });

  final NovaAppearance appearance;
  final int generation, concepts, experiences, connections, synapses;
  final int neuralTrainingPairs, neuralParameters, nextNeuralParameters;
  final String neuralModel;
  final double neuralEntropy, neuralSparsity;
  final Duration age;
  final String status;
  final int responseMs;
  final List<Map<String, dynamic>> messages;
  final TextEditingController input;
  final ScrollController scroll;
  final ValueChanged<String> onSend;
  final VoidCallback onImport, onBackup, onEvolve, onAppearance, onResearch;
  final VoidCallback? onDiagnostics, onCheckUpdates, onUpdate, onRefine,
      onSetSupervisedAutonomy;
  final bool supervisedAutonomyConfigured, backgroundEnabled, autonomousStudyEnabled;
  final String resourceState, resourceReason;
  final int? availableUpdateBuild;
  final bool checkingUpdates, isReading, isThinking, researching;
  final double researchProgress;
  final String researchStage;
  final int researchMs;
  final List<NovaMilestone> milestones;
  final List<Map<String, dynamic>> generationReports, resourceSamples;
  final List<NovaNeuralCheckpoint> checkpoints;
  final int dictionaryEntries, activeNeuronBudget;
  final Map<String, dynamic> dictionaryStats;
  final List<String> schoolTopics, universityTopics, postgraduateTopics;
  final List<String> passedEducationTopics;
  final ValueChanged<String>? onRestoreCheckpoint;
  final ValueChanged<int>? onSetNeuronBudget;
  final List<String> plugins;
  final ValueChanged<String> onPlugin;
  final VoidCallback onInstallLocal, onInstallUrl;
  final VoidCallback onRunTests, onAddEvaluation, onShowCommands;
  final int evaluationCount, testPassed, testTotal, testFailed;
  final double? evaluationAccuracy;
  final List<String> neuralLinks;

  @override
  State<NovaDashboard> createState() => _NovaDashboardState();
}

class _NovaDashboardState extends State<NovaDashboard>
    with SingleTickerProviderStateMixin {
  static const bg = Color(0xFF050814);
  static const panel = Color(0xFF0D1322);
  static const panel2 = Color(0xFF111A2D);
  static const dim = Color(0xFF8290AA);
  int page = 0;
  late final AnimationController pulse = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 2400),
  )..repeat(reverse: true);

  Color get accent => widget.appearance.accent;

  @override
  void dispose() { pulse.dispose(); super.dispose(); }

  Widget card(Widget child, {EdgeInsets padding = const EdgeInsets.all(16),
      Color? color, double radius = 22}) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color ?? panel,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withOpacity(.055)),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(.22), blurRadius: 22,
          offset: const Offset(0, 11)),
      ],
    ),
    child: child,
  );

  Widget section(String text) => Text(text.toUpperCase(), style: TextStyle(
    color: dim, fontSize: 10, fontWeight: FontWeight.w800,
    letterSpacing: 1.7));

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(seedColor: accent,
          brightness: Brightness.dark),
      ),
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          titleSpacing: 16,
          title: Row(children: [
            AnimatedBuilder(
              animation: pulse,
              builder: (context, _) => Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(
                    color: accent.withOpacity(.08 + pulse.value * .13),
                    blurRadius: 24, spreadRadius: 2,
                  )],
                ),
                child: widget.appearance.avatar == 0
                    ? const NovaEmblem(size: 42)
                    : Container(
                        decoration: BoxDecoration(
                          color: accent.withOpacity(.13),
                          borderRadius: BorderRadius.circular(15)),
                        child: Icon(widget.appearance.avatarIcon,
                          color: accent)),
              ),
            ),
            const SizedBox(width: 11),
            const Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NOVA', style: TextStyle(fontSize: 19,
                  fontWeight: FontWeight.w900, letterSpacing: 2.6)),
                Text('NÚCLEO NEURAL LOCAL', style: TextStyle(
                  color: dim, fontSize: 9, letterSpacing: 1.5)),
              ]),
          ]),
          actions: [
            IconButton(
              tooltip: 'Executar testes',
              onPressed: widget.onRunTests,
              icon: const Icon(Icons.health_and_safety_outlined)),
            IconButton(
              tooltip: 'Backup',
              onPressed: widget.onBackup,
              icon: const Icon(Icons.save_alt_rounded)),
          ],
        ),
        body: SafeArea(child: IndexedStack(index: page, children: [
          _home(), _chat(), _network(), _evolution(), _system(),
        ])),
        floatingActionButton: page == 1
            ? FloatingActionButton.extended(
                onPressed: widget.onShowCommands,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('Comandos'))
            : null,
        bottomNavigationBar: NavigationBar(
          height: 72,
          backgroundColor: const Color(0xFF080D18),
          indicatorColor: accent.withOpacity(.19),
          selectedIndex: page,
          onDestinationSelected: (i) => setState(() => page = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded),
              label: 'Núcleo'),
            NavigationDestination(
              icon: Icon(Icons.forum_outlined),
              selectedIcon: Icon(Icons.forum_rounded),
              label: 'Comandos'),
            NavigationDestination(
              icon: Icon(Icons.hub_outlined),
              selectedIcon: Icon(Icons.hub_rounded),
              label: 'Rede'),
            NavigationDestination(
              icon: Icon(Icons.timeline_outlined),
              selectedIcon: Icon(Icons.timeline_rounded),
              label: 'Evolução'),
            NavigationDestination(
              icon: Icon(Icons.tune_outlined),
              selectedIcon: Icon(Icons.tune_rounded),
              label: 'Sistema'),
          ],
        ),
      ),
    );
  }

  Widget _home() {
    final eval = widget.evaluationAccuracy;
    final testRatio = widget.testTotal == 0
        ? 0.0 : widget.testPassed / widget.testTotal;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: [
        Container(
          padding: const EdgeInsets.all(21),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [accent.withOpacity(.23), panel2, const Color(0xFF090F1D)],
              stops: const [0, .48, 1],
            ),
            border: Border.all(color: accent.withOpacity(.18)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('NÚCLEO OPERACIONAL', style: TextStyle(
              color: accent, fontSize: 10, fontWeight: FontWeight.w900,
              letterSpacing: 1.8)),
            const SizedBox(height: 7),
            Row(children: [
              const Expanded(child: Text('NOVA está ligada.',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900,
                  letterSpacing: -.7))),
              Container(
                width: 57, height: 57,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  color: accent.withOpacity(.1),
                  border: Border.all(color: accent.withOpacity(.45))),
                child: Icon(Icons.bolt_rounded, color: accent, size: 29),
              ),
            ]),
            const SizedBox(height: 9),
            const Text('Memória + rede associativa + comandos naturais.',
              style: TextStyle(color: dim, fontSize: 12.5, height: 1.45)),
            const SizedBox(height: 17),
            Wrap(spacing: 7, runSpacing: 7, children: [
              _pill('G' + widget.generation.toString(), accent),
              _pill(widget.synapses.toString() + ' sinapses',
                const Color(0xFFFFC857)),
              _pill(widget.experiences.toString() + ' eventos', dim),
            ]),
          ]),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _stat('Conceitos', widget.concepts.toString(),
            Icons.psychology_alt_outlined, accent)),
          const SizedBox(width: 9),
          Expanded(child: _stat('Conexões', widget.connections.toString(),
            Icons.hub_outlined, const Color(0xFF4CC9F0))),
        ]),
        const SizedBox(height: 9),
        Row(children: [
          Expanded(child: _stat('Parâmetros neurais',
            _compact(widget.neuralParameters), Icons.auto_graph_rounded,
            const Color(0xFF59E391))),
          const SizedBox(width: 9),
          Expanded(child: _stat('Treino neural',
            _compact(widget.neuralTrainingPairs), Icons.school_outlined,
            const Color(0xFF59E391))),
          const SizedBox(width: 9),
          Expanded(child: _stat('Resposta', widget.responseMs.toString() + ' ms',
            Icons.speed_rounded, const Color(0xFFFFC857))),
        ]),
        const SizedBox(height: 14),
        card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            section('índices'),
            Text('G' + widget.generation.toString().padLeft(3, '0'),
              style: TextStyle(color: accent, fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 14),
          _bar('Cobertura dos testes', testRatio,
            widget.testTotal == 0
                ? 'nenhum teste executado'
                : widget.testPassed.toString() + '/' + widget.testTotal.toString(),
            accent),
          const SizedBox(height: 12),
          _bar('Acurácia de respostas cadastradas', eval ?? 0,
            eval == null ? 'não aferida' :
              (eval * 100).toStringAsFixed(1) + '%',
            eval == null ? dim : const Color(0xFF4CC9F0)),
          const SizedBox(height: 12),
          _bar('Densidade de conexões',
            math.min(1, widget.synapses / math.max(1, widget.concepts * 3)),
            widget.synapses.toString() + ' sinapses', const Color(0xFFFFC857)),
        ])),
        const SizedBox(height: 14),
        card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            section('atividade neural'),
            _status(widget.status),
          ]),
          const SizedBox(height: 10),
          SizedBox(height: 170, child: CustomPaint(
            painter: _NetworkPainter(
              color: accent, links: widget.neuralLinks, pulse: pulse.value),
          )),
          const SizedBox(height: 7),
          Row(children: [
            _mini('Parâmetros', _compact(widget.neuralParameters)),
            _mini('Entropia', widget.neuralEntropy.toStringAsFixed(2)),
            _mini('Latência', widget.responseMs.toString() + ' ms'),
          ]),
        ])),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: FilledButton.icon(onPressed: widget.onRunTests,
            icon: const Icon(Icons.verified_rounded),
            label: const Text('Testar'))),
          const SizedBox(width: 9),
          Expanded(child: OutlinedButton.icon(onPressed: widget.onAddEvaluation,
            icon: const Icon(Icons.playlist_add_rounded),
            label: const Text('Caso'))),
        ]),
      ],
    );
  }

  Widget _stat(String name, String value, IconData icon, Color color) => card(
    Row(children: [
      Container(width: 39, height: 39,
        decoration: BoxDecoration(color: color.withOpacity(.10),
          borderRadius: BorderRadius.circular(13)),
        child: Icon(icon, color: color, size: 20)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontSize: 19,
            fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(name, style: const TextStyle(color: dim, fontSize: 10)),
        ])),
    ]),
    padding: const EdgeInsets.all(13),
  );

  Widget _pill(String value, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(color: color.withOpacity(.10),
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: color.withOpacity(.15))),
    child: Text(value, style: TextStyle(color: color,
      fontSize: 10, fontWeight: FontWeight.w800)),
  );

  Widget _bar(String title, double value, String trailing, Color color) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Text(title, style: const TextStyle(
            fontSize: 11.5, fontWeight: FontWeight.w700))),
          Text(trailing, style: TextStyle(color: color, fontSize: 10,
            fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 7),
        ClipRRect(borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            minHeight: 8, value: value.clamp(0.0, 1.0).toDouble(),
            backgroundColor: Colors.white.withOpacity(.07),
            valueColor: AlwaysStoppedAnimation(color))),
      ]);

  Widget _status(String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(color: accent.withOpacity(.10),
      borderRadius: BorderRadius.circular(99)),
    child: Text(value.length > 20 ? value.substring(0, 20) : value,
      style: TextStyle(color: accent, fontSize: 9, fontWeight: FontWeight.w800)));

  Widget _mini(String title, String value) => Expanded(child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: const TextStyle(fontSize: 14,
        fontWeight: FontWeight.w900)),
      const SizedBox(height: 2),
      Text(title, style: const TextStyle(color: dim, fontSize: 9)),
    ]));

  Widget _chat() => Column(children: [
    Expanded(child: ListView(
      controller: widget.scroll,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
      children: [
        card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.auto_awesome_rounded, color: accent),
            const SizedBox(width: 9),
            const Expanded(child: Text('Entendimento de comandos',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15))),
            IconButton(onPressed: widget.onShowCommands,
              icon: const Icon(Icons.help_outline_rounded)),
          ]),
          const SizedBox(height: 5),
          const Text(
            'Exemplos: “pesquise relações internacionais”, “rode os testes”, '
            '“mostre a rede”, “faça backup” e “avaliar: pergunta | resposta”.',
            style: TextStyle(color: dim, fontSize: 11, height: 1.45)),
        ])),
        const SizedBox(height: 12),
        ...widget.messages.map(_bubble),
      ],
    )),
    if (widget.isThinking || widget.isReading)
      LinearProgressIndicator(color: accent, minHeight: 3),
    Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Row(children: [
        Expanded(child: TextField(
          controller: widget.input,
          enabled: !widget.isReading,
          minLines: 1, maxLines: 4,
          onSubmitted: widget.onSend,
          decoration: InputDecoration(
            hintText: 'Diga para a NOVA o que fazer…',
            filled: true, fillColor: panel2,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide.none),
            prefixIcon: Icon(Icons.hub_outlined, color: accent),
          ),
        )),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: widget.isReading ? null :
            () => widget.onSend(widget.input.text),
          icon: const Icon(Icons.arrow_upward_rounded)),
      ]),
    ),
  ]);

  Widget _bubble(Map<String, dynamic> m) {
    final user = m['isUser'] == true;
    final system = m['isSystem'] == true;
    final color = user ? accent :
      system ? const Color(0xFFFFC857) : accent;
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 365),
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: user ? accent.withOpacity(.13) : panel,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(user ? 18 : 5),
            bottomRight: Radius.circular(user ? 5 : 18),
          ),
          border: Border.all(color: color.withOpacity(.10)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(user ? 'VOCÊ' : system ? 'SISTEMA' : 'NOVA',
            style: TextStyle(color: color, fontSize: 9,
              fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          const SizedBox(height: 6),
          SelectableText(m['texto']?.toString() ?? '',
            style: const TextStyle(fontSize: 13.5, height: 1.48)),
        ]),
      ),
    );
  }

  Widget _network() => ListView(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
    children: [
      const Text('Rede associativa', style: TextStyle(fontSize: 27,
        fontWeight: FontWeight.w900)),
      const SizedBox(height: 5),
      const Text('Ligação entre conceitos, com pesos derivados de coocorrência.',
        style: TextStyle(color: dim, fontSize: 12, height: 1.45)),
      const SizedBox(height: 15),
      card(SizedBox(height: 255, child: CustomPaint(
        painter: _NetworkPainter(
          color: accent, links: widget.neuralLinks, pulse: pulse.value),
      ))),
      const SizedBox(height: 11),
      Row(children: [
        Expanded(child: _big('Conceitos', widget.concepts.toString(),
          Icons.psychology_alt_outlined, accent)),
        const SizedBox(width: 9),
        Expanded(child: _big('Conexões', widget.connections.toString(),
          Icons.route_outlined, const Color(0xFF4CC9F0))),
      ]),
      const SizedBox(height: 9),
      card(Row(children: [
        Icon(Icons.layers_outlined, color: accent), const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.neuralModel, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text('Próxima expansão: ${widget.neuralParameters < 197376 ? '197 mil' : 'etapa seguinte'} parâmetros',
            style: const TextStyle(color: dim, fontSize: 10.5)),
        ])),
      ]), padding: const EdgeInsets.all(14)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _big('Sinapses', widget.synapses.toString(),
          Icons.bolt_rounded, const Color(0xFFFFC857))),
        const SizedBox(width: 9),
        Expanded(child: _big('Treino', _compact(widget.neuralTrainingPairs),
          Icons.auto_graph_rounded, const Color(0xFF59E391))),
      ]),
      const SizedBox(height: 12),
      card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        section('ligações ativas'),
        const SizedBox(height: 9),
        if (widget.neuralLinks.isEmpty)
          const Text('Nenhuma ligação registrada ainda.',
            style: TextStyle(color: dim, fontSize: 12))
        else
          ...widget.neuralLinks.take(14).map((link) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              Icon(Icons.bolt_rounded, color: accent, size: 15),
              const SizedBox(width: 8),
              Expanded(child: Text(link,
                style: const TextStyle(fontSize: 11.5))),
            ]))),
      ])),
      const SizedBox(height: 12),
      const Text(
        'A rede associativa é uma estrutura conexionista local; não equivale a um cérebro artificial completo ou a um LLM.',
        style: TextStyle(color: dim, fontSize: 10.5, height: 1.35)),
    ],
  );

  Widget _big(String title, String value, IconData icon, Color color) => card(
    Row(children: [
      Icon(icon, color: color), const SizedBox(width: 9),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: const TextStyle(fontSize: 18,
          fontWeight: FontWeight.w900)),
        Text(title.toUpperCase(), style: const TextStyle(
          color: dim, fontSize: 9)),
      ]),
    ]),
    padding: const EdgeInsets.all(13),
  );

  Widget _evolution() {
    final ratio = widget.testTotal == 0
        ? 0.0 : widget.testPassed / widget.testTotal;
    final labReports = widget.generationReports.where((r) =>
      r['kind'] == 'laboratorioNeural').toList();
    final recent = labReports.reversed.take(6).toList();
    final nextParams = widget.nextNeuralParameters > 0
        ? widget.nextNeuralParameters : widget.neuralParameters;
    final paramProgress = (widget.neuralParameters / nextParams).clamp(0.0, 1.0).toDouble();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Laboratório', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
          _pill('G' + widget.generation.toString(), accent),
        ]),
        const SizedBox(height: 5),
        const Text('A evolução procura gastar menos parâmetros, acionar menos neurônios e responder com precisão.',
          style: TextStyle(color: dim, fontSize: 12, height: 1.4)),
        const SizedBox(height: 15),
        card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          section('capacidade e eficiência'),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _big('Parâmetros', _compact(widget.neuralParameters), Icons.memory_rounded, accent)),
            const SizedBox(width: 8),
            Expanded(child: _big('Ativos / passo', widget.activeNeuronBudget.toString(), Icons.bolt_rounded, const Color(0xFF59E391))),
          ]),
          const SizedBox(height: 10),
          _bar('Caminho até a próxima etapa', paramProgress,
            _compact(nextParams) + ' alvo', accent),
          const SizedBox(height: 9),
          Text(widget.neuralModel, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text((widget.neuralSparsity * 100).clamp(0, 99.9).toStringAsFixed(1) + '% da camada não é ativada em cada passo (roteamento esparso).',
            style: const TextStyle(color: dim, fontSize: 10)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            FilledButton.icon(onPressed: widget.onEvolve, icon: const Icon(Icons.science_rounded), label: const Text('Executar laboratório')),
            OutlinedButton.icon(onPressed: widget.onResearch, icon: const Icon(Icons.search_rounded), label: const Text('Pesquisar')),
            OutlinedButton.icon(onPressed: widget.onRefine, icon: const Icon(Icons.tune_rounded), label: const Text('Refinar')),
          ]),
        ])),
        const SizedBox(height: 11),
        card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            section('integridade'),
            _status(widget.testTotal == 0 ? 'SEM TESTE' : widget.testFailed == 0 ? 'OK' : 'ATENÇÃO'),
          ]),
          const SizedBox(height: 10),
          _bar('Testes funcionais', ratio, widget.testTotal == 0 ? '0 executados' :
            widget.testPassed.toString() + '/' + widget.testTotal.toString(), accent),
          const SizedBox(height: 9),
          Text(widget.evaluationCount.toString() + ' casos independentes • ' +
            (widget.evaluationAccuracy == null ? 'acurácia ainda não aferida' :
              (widget.evaluationAccuracy! * 100).toStringAsFixed(1) + '% acurácia'),
            style: const TextStyle(color: dim, fontSize: 11.5)),
          const SizedBox(height: 9),
          FilledButton.icon(onPressed: widget.onRunTests, icon: const Icon(Icons.verified_rounded),
            label: const Text('Rodar todos os testes')),
        ])),
        const SizedBox(height: 11),
        card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          section('ranking de gerações'),
          const SizedBox(height: 9),
          if (recent.isEmpty)
            const Text('O ranking aparecerá após o primeiro laboratório.', style: TextStyle(color: dim, fontSize: 11.5))
          else
            ...recent.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final r = entry.value;
              final params = (r['candidateParameters'] as num?)?.toInt();
              final acc = (r['candidateAccuracy'] as num?)?.toDouble();
              final lat = (r['candidateLatencyUs'] as num?)?.toInt();
              final delta = (params == null || params == (r['baselineParameters'] as num?)?.toInt())
                  ? 'mesmo tamanho' : (params < ((r['baselineParameters'] as num?)?.toInt() ?? params) ? '↓ parâmetros' : '↑ parâmetros');
              return Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [
                SizedBox(width: 24, child: Text('#' + rank.toString(), style: TextStyle(color: accent, fontWeight: FontWeight.w900))),
                Expanded(child: Text('G' + (r['generation'] ?? widget.generation).toString(), style: const TextStyle(fontWeight: FontWeight.w800))),
                Text(params == null ? '—' : _compact(params), style: const TextStyle(fontSize: 10.5)),
                const SizedBox(width: 8),
                Text(acc == null ? '—' : (acc * 100).toStringAsFixed(1) + '%', style: const TextStyle(fontSize: 10.5)),
                const SizedBox(width: 8),
                Text(lat == null ? '—' : (lat / 1000).toStringAsFixed(1) + ' ms', style: const TextStyle(fontSize: 10.5, color: dim)),
                const SizedBox(width: 8),
                Text(delta, style: TextStyle(fontSize: 9, color: delta.startsWith('↓') ? const Color(0xFF59E391) : dim)),
              ]));
            }),
          const SizedBox(height: 4),
          const Text('Ordenação local: precisão → latência → parâmetros. Não é um índice de inteligência.',
            style: TextStyle(color: dim, fontSize: 9.5)),
        ])),
        const SizedBox(height: 11),
        card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          section('checkpoints'),
          const SizedBox(height: 9),
          if (widget.checkpoints.isEmpty)
            const Text('Nenhum checkpoint salvo ainda.', style: TextStyle(color: dim, fontSize: 11.5))
          else
            ...widget.checkpoints.take(6).map((checkpoint) => ListTile(
              dense: true, contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.bookmark_rounded, color: accent, size: 20),
              title: Text(checkpoint.label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
              subtitle: Text('G' + checkpoint.generation.toString() + ' • ' + _compact(checkpoint.parameters) + ' parâmetros',
                style: const TextStyle(color: dim, fontSize: 9.5)),
              trailing: widget.onRestoreCheckpoint == null ? null : TextButton(
                onPressed: () => widget.onRestoreCheckpoint!(checkpoint.id), child: const Text('Restaurar')),
            )),
        ])),
        const SizedBox(height: 11),
        _educationTable(),
        const SizedBox(height: 11),
        card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          section('dicionário proprietário'),
          const SizedBox(height: 8),
          Text(widget.dictionaryEntries.toString() + ' entradas • formato NCD1', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(widget.dictionaryStats.isEmpty ? 'Aguardando dados para medir a compactação.' :
            'Último bloco: ' + (widget.dictionaryStats['rawBytes'] ?? 0).toString() + ' B → ' +
              (widget.dictionaryStats['packedBytes'] ?? 0).toString() + ' B (' +
              ((widget.dictionaryStats['reductionPercent'] as num?)?.toStringAsFixed(1) ?? '0.0') + '%)',
            style: const TextStyle(color: dim, fontSize: 10.5)),
        ])),
      ],
    );
  }

  Widget _educationTable() {
    final rows = <List<String>>[];
    for (final topic in widget.schoolTopics) rows.add(['Escola', topic]);
    for (final topic in widget.universityTopics) rows.add(['Universidade', topic]);
    for (final topic in widget.postgraduateTopics) rows.add(['Pós-graduação', topic]);
    return card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      section('trajetória educacional'),
      const SizedBox(height: 9),
      Table(
        columnWidths: const {0: FixedColumnWidth(110), 1: FlexColumnWidth(), 2: FixedColumnWidth(30)},
        children: [
          const TableRow(children: [
            Padding(padding: EdgeInsets.symmetric(vertical: 5), child: Text('ETAPA', style: TextStyle(color: dim, fontSize: 9, fontWeight: FontWeight.w800))),
            Padding(padding: EdgeInsets.symmetric(vertical: 5), child: Text('COMPETÊNCIA', style: TextStyle(color: dim, fontSize: 9, fontWeight: FontWeight.w800))),
            SizedBox(),
          ]),
          ...rows.map((row) {
            final done = widget.passedEducationTopics.contains(row[1]);
            return TableRow(children: [
              Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Text(row[0], style: const TextStyle(fontSize: 9.5, color: dim))),
              Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Text(row[1], style: const TextStyle(fontSize: 10.5))),
              Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                size: 15, color: done ? const Color(0xFF59E391) : dim)),
            ]);
          }),
        ],
      ),
      const SizedBox(height: 5),
      const Text('A aprovação continua exigindo avaliação independente; estudar sozinho não marca uma competência como concluída.',
        style: TextStyle(color: dim, fontSize: 9.5, height: 1.35)),
    ]));
  }
  Widget _system() => ListView(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
    children: [
      const Text('Sistema', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
      const SizedBox(height: 5),
      const Text('Controle fino do modelo, do aplicativo e dos pacotes.', style: TextStyle(color: dim, fontSize: 12)),
      const SizedBox(height: 15),
      card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        section('controle do modelo'),
        const SizedBox(height: 9),
        Text('Neurônios ativos por passo: ' + widget.activeNeuronBudget.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
        Slider(
          value: widget.activeNeuronBudget.toDouble().clamp(4.0, 64.0).toDouble(),
          min: 4, max: 64, divisions: 15,
          label: widget.activeNeuronBudget.toString(),
          onChanged: widget.onSetNeuronBudget == null ? null : (v) => widget.onSetNeuronBudget!(v.round()),
        ),
        const Text('Menor orçamento = menos neurônios acionados por passo. O laboratório valida se a precisão permanece.',
          style: TextStyle(color: dim, fontSize: 10, height: 1.35)),
        const SizedBox(height: 7),
        _row('Aparência', 'Alternar paleta do tema', Icons.palette_outlined, widget.onAppearance),
        _row('Executar laboratório', 'Testar compactação e velocidade', Icons.science_outlined, widget.onEvolve),
        _row('Pesquisa', 'Pesquisar e incorporar conteúdo', Icons.search_outlined, widget.onResearch),
        if (widget.onRefine != null) _row('Refinar recuperação', 'Otimizar o limiar com holdout', Icons.tune_outlined, widget.onRefine),
      ])),
      const SizedBox(height: 11),
      card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        section('estado do aparelho'),
        const SizedBox(height: 8),
        Row(children: [
          Icon(Icons.memory_rounded, color: accent, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(widget.resourceState + ' • ' + widget.resourceReason,
            style: const TextStyle(fontSize: 10.5, color: dim))),
        ]),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          OutlinedButton.icon(
            onPressed: () => widget.onSend(widget.backgroundEnabled ? 'autonomia parar' : 'autonomia iniciar'),
            icon: Icon(widget.backgroundEnabled ? Icons.pause_circle_outline : Icons.play_circle_outline, size: 16),
            label: Text(widget.backgroundEnabled ? 'Autonomia: parar' : 'Autonomia: iniciar')),
          OutlinedButton.icon(
            onPressed: () => widget.onSend(widget.autonomousStudyEnabled ? 'estudo autônomo parar' : 'estudo autônomo iniciar'),
            icon: Icon(widget.autonomousStudyEnabled ? Icons.school_outlined : Icons.school_rounded, size: 16),
            label: Text(widget.autonomousStudyEnabled ? 'Estudo: parar' : 'Estudo: iniciar')),
        ]),
      ])),
      const SizedBox(height: 11),
      card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        section('memória e segurança'),
        const SizedBox(height: 8),
        _row('Importar PDF/TXT', 'Adicionar conhecimento local', Icons.description_outlined, widget.onImport),
        _row('Fazer backup', 'Snapshot recuperável', Icons.save_alt_rounded, widget.onBackup),
        if (widget.onDiagnostics != null) _row('Exportar diagnóstico', 'Métricas agregadas', Icons.file_present_outlined, widget.onDiagnostics),
      ])),
      const SizedBox(height: 11),
      card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        section('plugins'),
        const SizedBox(height: 8),
        _pluginTile('Laboratório neural', 'Otimização e checkpoints', Icons.science_rounded, () => widget.onPlugin('neural_lab')),
        _pluginTile('Estatística', 'Métricas e relatórios', Icons.bar_chart_rounded, () => widget.onPlugin('statistics')),
        _pluginTile('Documentos', 'Leitor e indexador', Icons.menu_book_rounded, () => widget.onPlugin('documents')),
        const Divider(color: Colors.white10, height: 18),
        _row('Instalar .nova.json', 'Pacote de conhecimento local', Icons.install_desktop_outlined, widget.onInstallLocal),
        _row('Instalar por HTTPS', 'SHA-256 obrigatório', Icons.cloud_download_outlined, widget.onInstallUrl),
        if (widget.plugins.isNotEmpty) ...[
          const Divider(color: Colors.white10, height: 18),
          ...widget.plugins.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(children: [Icon(Icons.check_circle_rounded, color: accent, size: 14), const SizedBox(width: 7),
              Expanded(child: Text(p, style: const TextStyle(fontSize: 11.5)))],),
          )),
        ],
      ])),
      const SizedBox(height: 11),
      card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        section('atualização e autonomia'),
        const SizedBox(height: 8),
        Text(widget.availableUpdateBuild == null ? 'Nenhuma atualização encontrada.' : 'Build ' + widget.availableUpdateBuild.toString() + ' disponível.',
          style: const TextStyle(fontSize: 11.5)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: OutlinedButton(
            onPressed: widget.checkingUpdates ? null : widget.onCheckUpdates,
            child: Text(widget.checkingUpdates ? 'Consultando…' : 'Verificar'))),
          if (widget.availableUpdateBuild != null && widget.onUpdate != null) ...[
            const SizedBox(width: 8),
            Expanded(child: FilledButton(onPressed: widget.onUpdate, child: const Text('Abrir APK'))),
          ],
        ]),
        const SizedBox(height: 8),
        if (widget.onSetSupervisedAutonomy != null)
          Align(alignment: Alignment.centerLeft, child: OutlinedButton.icon(
            onPressed: widget.onSetSupervisedAutonomy, icon: const Icon(Icons.shield_outlined, size: 17),
            label: Text(widget.supervisedAutonomyConfigured ? 'Autonomia supervisionada ativa' : 'Ativar autonomia supervisionada'))),
      ])),
    ],
  );

  Widget _pluginTile(String title, String subtitle, IconData icon, VoidCallback action) =>
    ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(width: 38, height: 38, decoration: BoxDecoration(
        color: accent.withOpacity(.10), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: accent, size: 19)),
      title: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle, style: const TextStyle(color: dim, fontSize: 9.5)),
      trailing: const Icon(Icons.add_circle_outline_rounded, color: dim),
      onTap: action,
    );
  Widget _row(String title, String subtitle, IconData icon,
      VoidCallback? onTap) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Container(width: 37, height: 37,
      decoration: BoxDecoration(color: accent.withOpacity(.10),
        borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: accent, size: 18)),
    title: Text(title, style: const TextStyle(fontSize: 12,
      fontWeight: FontWeight.w800)),
    subtitle: Text(subtitle, style: const TextStyle(color: dim, fontSize: 9.5)),
    trailing: const Icon(Icons.chevron_right_rounded, color: dim),
    onTap: onTap,
  );

  String _compact(int value) {
    if (value >= 1000000) return (value / 1000000).toStringAsFixed(1) + 'M';
    if (value >= 1000) return (value / 1000).toStringAsFixed(1) + 'k';
    return value.toString();
  }
}

class _NetworkPainter extends CustomPainter {
  _NetworkPainter({required this.color, required this.links, required this.pulse});
  final Color color;
  final List<String> links;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final count = math.max(8, math.min(20, links.length + 8)).toInt();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height).toDouble() * .31;
    final nodes = <Offset>[];
    for (var i = 0; i < count; i++) {
      final a = 2 * math.pi * i / count;
      final r = radius * (.84 + .10 * math.sin(i * 1.7));
      nodes.add(center + Offset(math.cos(a) * r, math.sin(a) * r));
    }
    for (var i = 0; i < nodes.length; i++) {
      final j = (i * 3 + 1) % nodes.length;
      canvas.drawLine(nodes[i], nodes[j], Paint()
        ..strokeWidth = 1.2
        ..color = color.withOpacity(.12 + pulse * .06));
      if (i % 2 == 0) {
        canvas.drawLine(nodes[i], nodes[(i + 2) % nodes.length], Paint()
          ..strokeWidth = 1
          ..color = color.withOpacity(.06));
      }
    }
    canvas.drawCircle(center, 37 + pulse * 3,
      Paint()..color = color.withOpacity(.08));
    canvas.drawCircle(center, 7, Paint()..color = color);
    for (var i = 0; i < nodes.length; i++) {
      canvas.drawCircle(nodes[i], i % 3 == 0 ? 4.5 : 3,
        Paint()..color = i % 3 == 0 ? color : Colors.white.withOpacity(.38));
    }
  }

  @override
  bool shouldRepaint(covariant _NetworkPainter old) =>
      old.pulse != pulse || old.links.length != links.length;
}
