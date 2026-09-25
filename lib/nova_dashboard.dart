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
              ? Image.memory(snapshot.data!, width: size, height: size, fit: BoxFit.cover)
              : Container(
                  width: size, height: size,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF9B7BFF), Color(0xFF4FD7FF)]),
                    borderRadius: BorderRadius.circular(size * .28),
                  ),
                  child: Icon(Icons.auto_awesome_rounded, color: Colors.white, size: size * .5),
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
  NovaAppearance({this.palette = NovaPalette.violet, this.density = NovaDensity.comfortable, this.avatar = 0});
  Color get accent => switch (palette) {
    NovaPalette.violet => const Color(0xFF9B7BFF),
    NovaPalette.ocean => const Color(0xFF4FD7FF),
    NovaPalette.forest => const Color(0xFF56E3A8),
  };
  IconData get avatarIcon => [
    Icons.hub_rounded, Icons.auto_awesome_rounded, Icons.psychology_rounded, Icons.blur_on_rounded,
  ][avatar.clamp(0, 3).toInt()];
  Map<String, dynamic> toJson() => {'palette': palette.index, 'density': density.index, 'avatar': avatar};
  void restore(Object? raw) {
    if (raw is! Map) return;
    final p = raw['palette'], d = raw['density'], a = raw['avatar'];
    if (p is int && p >= 0 && p < NovaPalette.values.length) palette = NovaPalette.values[p];
    if (d is int && d >= 0 && d < NovaDensity.values.length) density = NovaDensity.values[d];
    if (a is int && a >= 0 && a < 4) avatar = a;
  }
}

class NovaDashboard extends StatefulWidget {
  const NovaDashboard({
    super.key,
    required this.appearance, required this.generation, required this.concepts,
    required this.experiences, required this.connections, required this.synapses,
    required this.neuralTrainingPairs, required this.neuralParameters, required this.neuralModel,
    required this.neuralEntropy, required this.neuralSparsity, required this.nextNeuralParameters,
    required this.age, required this.status, required this.responseMs, required this.messages,
    required this.input, required this.scroll, required this.onSend, required this.onImport,
    required this.onBackup, required this.onEvolve, required this.onAppearance, required this.onResearch,
    required this.plugins, required this.onPlugin, required this.onInstallLocal, required this.onInstallUrl,
    required this.onRunTests, required this.onAddEvaluation, required this.onShowCommands,
    this.onDiagnostics, this.onCheckUpdates, this.onUpdate, this.availableUpdateBuild,
    this.checkingUpdates = false, this.onRefine, this.onSetSupervisedAutonomy,
    this.supervisedAutonomyConfigured = false, this.researchProgress = 0, this.researchStage = '',
    this.researchMs = 0, this.researching = false, this.generationReports = const [],
    this.resourceSamples = const [], this.checkpoints = const [], this.dictionaryEntries = 0,
    this.dictionaryStats = const {}, this.schoolTopics = const [], this.universityTopics = const [],
    this.postgraduateTopics = const [], this.passedEducationTopics = const [], this.activeNeuronBudget = 24,
    this.onRestoreCheckpoint, this.onSetNeuronBudget, this.onSetPalette, this.onSetDensity, this.onSetAvatar,
    this.onBenchmark, this.evaluationCount = 0, this.evaluationAccuracy, this.testPassed = 0,
    this.testTotal = 0, this.testFailed = 0, this.neuralLinks = const [], this.milestones = const [],
    this.isReading = false, this.isThinking = false, this.resourceState = 'indisponível',
    this.resourceReason = '', this.backgroundEnabled = false, this.autonomousStudyEnabled = true,
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
  final VoidCallback? onDiagnostics, onCheckUpdates, onUpdate, onRefine, onSetSupervisedAutonomy, onBenchmark;
  final ValueChanged<NovaPalette>? onSetPalette;
  final ValueChanged<NovaDensity>? onSetDensity;
  final ValueChanged<int>? onSetAvatar;
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
  final List<String> schoolTopics, universityTopics, postgraduateTopics, passedEducationTopics;
  final ValueChanged<String>? onRestoreCheckpoint;
  final ValueChanged<int>? onSetNeuronBudget;
  final List<String> plugins;
  final ValueChanged<String> onPlugin;
  final VoidCallback onInstallLocal, onInstallUrl;
  final VoidCallback onRunTests, onAddEvaluation, onShowCommands;
  final int evaluationCount, testPassed, testTotal, testFailed;
  final double? evaluationAccuracy;
  final List<String> neuralLinks;

  @override State<NovaDashboard> createState() => _NovaDashboardState();
}

class _PluginInfo {
  const _PluginInfo(this.id, this.title, this.subtitle, this.icon, this.color);
  final String id, title, subtitle;
  final IconData icon;
  final Color color;
}

const _plugins = <_PluginInfo>[
  _PluginInfo('neural_lab', 'Neural Lab', 'Evolução esparsa', Icons.auto_graph_rounded, Color(0xFF9B7BFF)),
  _PluginInfo('benchmarks', 'Benchmarks', 'Medição e regressão', Icons.speed_rounded, Color(0xFF4FD7FF)),
  _PluginInfo('research', 'Pesquisa', 'Busca e ingestão', Icons.travel_explore_rounded, Color(0xFF56E3A8)),
  _PluginInfo('documents', 'Documentos', 'Fontes locais', Icons.description_rounded, Color(0xFFFFB86C)),
  _PluginInfo('statistics', 'Estatística', 'Telemetria local', Icons.query_stats_rounded, Color(0xFFFF72C6)),
  _PluginInfo('optimizer', 'Refino', 'Avaliação e ajuste', Icons.tune_rounded, Color(0xFF77A7FF)),
  _PluginInfo('memory', 'Memória', 'Backup e rollback', Icons.shield_rounded, Color(0xFF8FE3FF)),
  _PluginInfo('autonomy', 'Autonomia', 'Estudo supervisionado', Icons.bolt_rounded, Color(0xFFA6E77A)),
];

class _NovaDashboardState extends State<NovaDashboard> with TickerProviderStateMixin {
  static const bg = Color(0xFF05060A);
  static const panel = Color(0xFF0C0E14);
  static const panel2 = Color(0xFF11141C);
  static const line = Color(0xFF202532);
  static const muted = Color(0xFF80899B);

  int page = 0;
  late final AnimationController pulse = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);
  late final AnimationController orbit = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 1800),
  )..repeat();

  Color get accent => widget.appearance.accent;
  double get pad => widget.appearance.density == NovaDensity.compact ? 14 : 18;

  @override
  void dispose() { pulse.dispose(); orbit.dispose(); super.dispose(); }

  double clamp01(double value) => value.clamp(0.0, 1.0).toDouble();
  String n(int value) {
    if (value >= 1000000) return (value / 1000000).toStringAsFixed(1) + 'M';
    if (value >= 1000) return (value / 1000).toStringAsFixed(1) + 'k';
    return value.toString();
  }

  double evolutionPercent() {
    final list = widget.generationReports.where((r) => r['kind']?.toString().contains('neural') ?? false).toList();
    if (list.isEmpty) return 0;
    final row = list.last;
    final bp = (row['baselineParameters'] as num?)?.toDouble() ?? 0;
    final cp = (row['bestParameters'] as num?)?.toDouble() ?? bp;
    final ba = (row['baselineAccuracy'] as num?)?.toDouble() ?? 0;
    final ca = (row['bestAccuracy'] as num?)?.toDouble() ?? ba;
    final bl = (row['baselineLatencyUs'] as num?)?.toDouble() ?? 0;
    final cl = (row['bestLatencyUs'] as num?)?.toDouble() ?? bl;
    if (bp <= 0) return 0;
    final sizeGain = clamp01((bp - cp) / bp);
    final accuracyGain = clamp01(ca - ba);
    final latencyGain = bl > 0 ? clamp01((bl - cl) / bl) : 0;
    return ((sizeGain * .4 + latencyGain * .4 + accuracyGain * 12) * 100).clamp(0, 100).toDouble();
  }

  double nextProgress() {
    if (widget.nextNeuralParameters <= widget.neuralParameters) return 1;
    return clamp01(widget.neuralParameters / widget.nextNeuralParameters);
  }

  Widget surface(Widget child, {EdgeInsets padding = const EdgeInsets.all(16), double radius = 24}) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: panel,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: line),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.22), blurRadius: 28, offset: const Offset(0, 12))],
    ),
    child: child,
  );

  @override
  Widget build(BuildContext context) => Theme(
    data: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(seedColor: accent, brightness: Brightness.dark),
      splashFactory: InkSparkle.splashFactory,
    ),
    child: Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(children: [
          Positioned.fill(child: IgnorePointer(child: AnimatedBuilder(
            animation: pulse, builder: (_, __) => CustomPaint(painter: _NovaBackgroundPainter(accent, pulse.value)),
          ))),
          Column(children: [
            topBar(),
            Expanded(child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              child: pageView(ValueKey(page)),
            )),
          ]),
          Positioned(left: 14, right: 14, bottom: 9, child: floatingEvolution()),
        ]),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xF7090B11),
        indicatorColor: accent.withOpacity(.14),
        height: 72,
        selectedIndex: page,
        onDestinationSelected: (v) { HapticFeedback.selectionClick(); setState(() => page = v); },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome_rounded), label: 'Núcleo'),
          NavigationDestination(icon: Icon(Icons.terminal_rounded), label: 'Comandos'),
          NavigationDestination(icon: Icon(Icons.hub_outlined), selectedIcon: Icon(Icons.hub_rounded), label: 'Rede'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights_rounded), label: 'Evolução'),
          NavigationDestination(icon: Icon(Icons.tune_outlined), selectedIcon: Icon(Icons.tune_rounded), label: 'Sistema'),
        ],
      ),
    ),
  );

  Widget topBar() => Padding(
    padding: EdgeInsets.fromLTRB(pad, 12, pad, 8),
    child: Row(children: [
      GestureDetector(onTap: openCustomize, child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [accent, accent.withOpacity(.15)]),
          boxShadow: [BoxShadow(color: accent.withOpacity(.28), blurRadius: 20)],
        ),
        child: CircleAvatar(radius: 20, backgroundColor: panel2, child: Icon(widget.appearance.avatarIcon, color: Colors.white)),
      )),
      const SizedBox(width: 11),
      Expanded(child: GestureDetector(
        onTap: () => setState(() => page = 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('NOVA', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -.4)),
          Row(children: [
            Container(width: 7, height: 7, decoration: BoxDecoration(color: statusColor(), shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(widget.status.toUpperCase(), style: const TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
          ]),
        ]),
      )),
      iconButton(Icons.search_rounded, () => setState(() => page = 1)),
      const SizedBox(width: 7),
      iconButton(Icons.settings_rounded, openCustomize),
    ]),
  );

  Color statusColor() {
    final s = widget.status.toLowerCase();
    if (s.contains('erro') || s.contains('falha')) return const Color(0xFFFF6B7A);
    if (s.contains('exec') || s.contains('pens') || s.contains('pesq') || s.contains('instal')) return const Color(0xFFFFB86C);
    return const Color(0xFF56E3A8);
  }

  Widget iconButton(IconData icon, VoidCallback onTap) => Material(
    color: panel, borderRadius: BorderRadius.circular(15),
    child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(15),
      child: SizedBox(width: 43, height: 43, child: Icon(icon, size: 20))),
  );

  Widget pageView(Key key) {
    switch (page) {
      case 1: return commandsPage(key);
      case 2: return networkPage(key);
      case 3: return evolutionPage(key);
      case 4: return systemPage(key);
      default: return homePage(key);
    }
  }

  Widget homePage(Key key) => ListView(
    key: key, padding: EdgeInsets.fromLTRB(pad, 5, pad, 103),
    children: [hero(), const SizedBox(height: 13), searchBar(), const SizedBox(height: 14),
      quickActions(), const SizedBox(height: 14), chat(), const SizedBox(height: 14), metrics()],
  );

  Widget hero() => surface(Row(children: [
    AnimatedBuilder(animation: pulse, builder: (_, __) => Transform.scale(
      scale: 1 + pulse.value * .04,
      child: Container(
        width: 64, height: 64,
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [accent.withOpacity(.72), accent.withOpacity(.04)])),
        child: const Icon(Icons.auto_awesome_rounded, size: 29),
      ),
    )),
    const SizedBox(width: 14),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('NÚCLEO NEURAL LOCAL', style: TextStyle(color: accent, fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 1.4)),
      const SizedBox(height: 4),
      Text('G' + widget.generation.toString(), style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
      const SizedBox(height: 4),
      Text(n(widget.neuralParameters) + ' parâmetros • ' + widget.activeNeuronBudget.toString() + ' ativos/etapa',
        style: const TextStyle(color: muted, fontSize: 11)),
    ])),
    metricSmall('LAT', widget.responseMs > 0 ? widget.responseMs.toString() + ' ms' : '—'),
  ]));

  Widget metricSmall(String label, String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(color: Colors.white.withOpacity(.035), borderRadius: BorderRadius.circular(14)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Text(label, style: const TextStyle(color: muted, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
      const SizedBox(height: 3),
      Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
    ]),
  );

  Widget searchBar() => Material(
    color: panel2, borderRadius: BorderRadius.circular(19),
    child: InkWell(
      onTap: () => setState(() => page = 1),
      borderRadius: BorderRadius.circular(19),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Row(children: [
          Icon(Icons.search_rounded, color: muted),
          SizedBox(width: 10),
          Expanded(child: Text('Pergunte, pesquise ou mande a NOVA agir…', style: TextStyle(color: muted, fontSize: 12.5))),
          Icon(Icons.arrow_outward_rounded, size: 17, color: muted),
        ]),
      ),
    ),
  );

  Widget quickActions() => SizedBox(
    height: 44,
    child: ListView(scrollDirection: Axis.horizontal, children: [
      actionChip('Evoluir', Icons.auto_graph_rounded, widget.onEvolve),
      actionChip('Benchmark', Icons.speed_rounded, widget.onBenchmark ?? noop),
      actionChip('Pesquisar', Icons.travel_explore_rounded, widget.onResearch),
      actionChip('Plugins', Icons.extension_rounded, openMarketplace),
      actionChip('Testes', Icons.verified_rounded, widget.onRunTests),
    ]),
  );

  VoidCallback get noop => () => ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Essa função não está disponível neste perfil.')),
  );

  Widget actionChip(String text, IconData icon, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: Material(
      color: panel2, borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(children: [Icon(icon, size: 16, color: accent), const SizedBox(width: 7),
            Text(text, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800))]),
        ),
      ),
    ),
  );

  Widget chat() {
    final items = widget.messages.length > 5 ? widget.messages.sublist(widget.messages.length - 5) : widget.messages;
    return surface(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('CONVERSA', style: TextStyle(color: accent, fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 1.4)),
        const Spacer(),
        if (widget.isThinking || widget.isReading) NovaTypingIndicator(
          color: accent, label: widget.isThinking ? 'Processando' : 'Lendo',
        ),
      ]),
      const SizedBox(height: 10),
      if (items.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text('Memória pronta. Comece uma conversa ou peça uma tarefa.', style: TextStyle(color: muted, fontSize: 12)),
        )
      else ...items.map(messageBubble),
      const SizedBox(height: 9),
      composer(),
    ]));
  }

  Widget messageBubble(Map<String, dynamic> item) {
    final system = item['isSystem'] == true;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(
          radius: 13,
          backgroundColor: system ? accent.withOpacity(.12) : Colors.white.withOpacity(.05),
          child: Icon(system ? Icons.auto_awesome_rounded : Icons.person_rounded, size: 13, color: system ? accent : Colors.white70),
        ),
        const SizedBox(width: 8),
        Expanded(child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: Colors.white.withOpacity(.022), borderRadius: BorderRadius.circular(14)),
          child: Text(item['texto']?.toString() ?? '', style: const TextStyle(fontSize: 12, height: 1.35)),
        )),
      ]),
    );
  }

  Widget composer() => Container(
    decoration: BoxDecoration(color: Colors.black.withOpacity(.15), borderRadius: BorderRadius.circular(17), border: Border.all(color: line)),
    child: Row(children: [
      Expanded(child: TextField(
        controller: widget.input, maxLines: 3, minLines: 1,
        decoration: const InputDecoration(
          hintText: 'Escreva um comando…', hintStyle: TextStyle(color: muted, fontSize: 12),
          border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        onSubmitted: (value) { final text = value.trim(); if (text.isNotEmpty) widget.onSend(text); },
      )),
      Padding(
        padding: const EdgeInsets.only(right: 5),
        child: IconButton(
          onPressed: () { final text = widget.input.text.trim(); if (text.isNotEmpty) widget.onSend(text); },
          style: IconButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
          icon: const Icon(Icons.arrow_upward_rounded, size: 18),
        ),
      ),
    ]),
  );

  Widget metrics() => surface(Row(children: [
    stat(Icons.hub_rounded, n(widget.concepts), 'conceitos'),
    divider(),
    stat(Icons.bolt_rounded, n(widget.experiences), 'experiências'),
    divider(),
    stat(Icons.link_rounded, n(widget.connections), 'conexões'),
    divider(),
    stat(Icons.memory_rounded, n(widget.synapses), 'sinapses'),
  ]));

  Widget stat(IconData icon, String value, String label) => Expanded(child: Column(children: [
    Icon(icon, size: 16, color: accent), const SizedBox(height: 4),
    Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
    Text(label, style: const TextStyle(color: muted, fontSize: 8.5)),
  ]));

  Widget divider() => Container(width: 1, height: 34, color: line);

  Widget commandsPage(Key key) => ListView(
    key: key, padding: EdgeInsets.fromLTRB(pad, 6, pad, 103),
    children: [
      header('Comandos', 'Ações reais, atalhos e pesquisa'),
      const SizedBox(height: 12),
      surface(Column(children: [
        TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Pesquisar uma ação…', prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: IconButton(onPressed: widget.onShowCommands, icon: const Icon(Icons.help_outline_rounded)),
            filled: true, fillColor: Colors.white.withOpacity(.025),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          onSubmitted: widget.onSend,
        ),
        const SizedBox(height: 10),
        commandTile('Evoluir o núcleo', 'Executar laboratório da próxima geração', Icons.auto_graph_rounded, widget.onEvolve),
        commandTile('Benchmark neural', 'Medir candidatos sem promoção automática', Icons.speed_rounded, widget.onBenchmark ?? noop),
        commandTile('Pesquisar conhecimento', 'Adicionar evidência à memória local', Icons.travel_explore_rounded, widget.onResearch),
        commandTile('Rodar testes', 'Verificar integridade do aplicativo', Icons.verified_rounded, widget.onRunTests),
        commandTile('Criar backup', 'Salvar o estado antes de mudanças', Icons.backup_rounded, widget.onBackup),
      ])),
    ],
  );

  Widget commandTile(String title, String subtitle, IconData icon, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Material(
      color: Colors.white.withOpacity(.025), borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(16),
        child: ListTile(
          leading: CircleAvatar(backgroundColor: accent.withOpacity(.11), child: Icon(icon, color: accent, size: 18)),
          title: Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
          subtitle: Text(subtitle, style: const TextStyle(color: muted, fontSize: 9.5)),
          trailing: const Icon(Icons.chevron_right_rounded, color: muted),
        ),
      ),
    ),
  );

  Widget networkPage(Key key) => ListView(
    key: key, padding: EdgeInsets.fromLTRB(pad, 6, pad, 103),
    children: [
      header('Rede', 'Pesquisa, recursos e memória conectada'),
      const SizedBox(height: 12),
      surface(Row(children: [
        AnimatedBuilder(
          animation: orbit,
          builder: (_, __) => Transform.rotate(
            angle: orbit.value * math.pi * 2,
            child: Container(
              width: 60, height: 60,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: accent.withOpacity(.35), width: 2)),
              child: Icon(Icons.travel_explore_rounded, color: accent),
            ),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Pesquisa local', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          const SizedBox(height: 4),
          Text(widget.researching
              ? widget.researchStage + ' • ' + widget.researchMs.toString() + ' ms'
              : 'Pronta para buscar e importar fontes',
            style: const TextStyle(color: muted, fontSize: 10)),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: widget.researching ? clamp01(widget.researchProgress) : 0, minHeight: 5, color: accent, backgroundColor: Colors.white.withOpacity(.04)),
        ])),
        IconButton(onPressed: widget.onResearch, icon: const Icon(Icons.add_rounded)),
      ])),
      const SizedBox(height: 11),
      Row(children: [
        Expanded(child: metricCard('Recursos', widget.resourceState, widget.resourceReason, Icons.memory_rounded)),
        const SizedBox(width: 10),
        Expanded(child: metricCard('Resposta', widget.responseMs > 0 ? widget.responseMs.toString() + ' ms' : '—', 'latência observada', Icons.bolt_rounded)),
      ]),
      const SizedBox(height: 11),
      surface(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        label('DICIONÁRIO PROPRIETÁRIO'),
        const SizedBox(height: 7),
        Text(n(widget.dictionaryEntries) + ' entradas', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text('Última redução medida: ' + ((widget.dictionaryStats['reductionPercent'] as num?)?.toDouble() ?? 0).toStringAsFixed(1) + '%',
          style: const TextStyle(color: muted, fontSize: 10)),
      ])),
      const SizedBox(height: 11),
      surface(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        label('ESTADO LOCAL'),
        const SizedBox(height: 9),
        resourceRow('Amostras', widget.resourceSamples.length.toString(), Icons.data_usage_rounded),
        resourceRow('Links neurais', widget.neuralLinks.length.toString(), Icons.link_rounded),
        resourceRow('Checkpoints', widget.checkpoints.length.toString(), Icons.restore_rounded),
        resourceRow('Plugins ativos', widget.plugins.length.toString(), Icons.extension_rounded),
      ])),
    ],
  );

  Widget metricCard(String title, String value, String detail, IconData icon) => surface(
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: accent, size: 18), const SizedBox(height: 8),
      Text(title.toUpperCase(), style: const TextStyle(color: muted, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
      const SizedBox(height: 4),
      Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
      const SizedBox(height: 3),
      Text(detail, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: muted, fontSize: 9)),
    ]),
  );

  Widget resourceRow(String title, String value, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Icon(icon, size: 16, color: accent), const SizedBox(width: 8), Expanded(child: Text(title, style: const TextStyle(fontSize: 11.5))),
      Text(value, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900)),
    ]),
  );

  Widget evolutionPage(Key key) => ListView(
    key: key, padding: EdgeInsets.fromLTRB(pad, 6, pad, 115),
    children: [
      header('Evolução', 'Insights por geração, benchmark e rollback'),
      const SizedBox(height: 12),
      nextGeneration(),
      const SizedBox(height: 11),
      benchmarkCard(),
      const SizedBox(height: 11),
      insights(),
      const SizedBox(height: 11),
      checkpoints(),
      const SizedBox(height: 11),
      education(),
    ],
  );

  Widget nextGeneration() {
    final progress = nextProgress();
    return surface(Row(children: [
      SizedBox(width: 96, height: 96, child: Stack(alignment: Alignment.center, children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: const Duration(milliseconds: 1100),
          curve: Curves.easeOutCubic,
          builder: (_, v, __) => CircularProgressIndicator(value: v, strokeWidth: 7, color: accent, backgroundColor: Colors.white.withOpacity(.05)),
        ),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text((progress * 100).toStringAsFixed(0) + '%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const Text('prontidão', style: TextStyle(color: muted, fontSize: 8)),
        ]),
        AnimatedBuilder(animation: pulse, builder: (_, __) => Container(
          width: 78 + pulse.value * 8, height: 78 + pulse.value * 8,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: accent.withOpacity(.1), width: 2)),
        )),
      ])),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          label('PRÓXIMA GERAÇÃO'),
          const Spacer(),
          Text('G' + (widget.generation + 1).toString(), style: TextStyle(color: accent, fontWeight: FontWeight.w900)),
        ]),
        const SizedBox(height: 7),
        Text(widget.nextNeuralParameters.toString() + ' parâmetros planejados', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        Text(widget.activeNeuronBudget.toString() + ' neurônios ativos por passo • promoção baseada em evidências',
          style: const TextStyle(color: muted, fontSize: 10.5, height: 1.35)),
      ])),
    ]));
  }

  Widget benchmarkCard() => surface(Row(children: [
    Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: accent.withOpacity(.10), borderRadius: BorderRadius.circular(14)),
      child: Icon(Icons.science_outlined, color: accent),
    ),
    const SizedBox(width: 11),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Benchmarks', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
      const SizedBox(height: 3),
      Text(widget.testTotal == 0 ? 'Ainda não executado' : widget.testPassed.toString() + '/' + widget.testTotal.toString() + ' testes passaram',
        style: const TextStyle(color: muted, fontSize: 10)),
    ])),
    FilledButton.tonal(onPressed: widget.onBenchmark ?? noop, child: const Text('Rodar')),
    const SizedBox(width: 5),
    IconButton(onPressed: widget.onRunTests, tooltip: 'Todos os testes', icon: const Icon(Icons.verified_rounded)),
  ]));

  Widget insights() {
    final rows = widget.generationReports.where((r) => r['kind']?.toString().contains('neural') ?? false).toList().reversed.take(12).toList();
    return surface(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [label('INSIGHTS DE CADA GERAÇÃO'), const Spacer(), Text(rows.length.toString() + ' registros', style: const TextStyle(color: muted, fontSize: 9))]),
      const SizedBox(height: 9),
      if (rows.isEmpty)
        const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Text('Execute um benchmark para começar o histórico.', style: TextStyle(color: muted, fontSize: 10.5)))
      else ...rows.map(generationRow),
    ]));
  }

  Widget generationRow(Map<String, dynamic> row) {
    final ba = (row['baselineAccuracy'] as num?)?.toDouble() ?? 0;
    final ca = (row['bestAccuracy'] as num?)?.toDouble() ?? ba;
    final bp = (row['baselineParameters'] as num?)?.toInt() ?? 0;
    final cp = (row['bestParameters'] as num?)?.toInt() ?? bp;
    final bl = (row['baselineLatencyUs'] as num?)?.toDouble() ?? 0;
    final cl = (row['bestLatencyUs'] as num?)?.toDouble() ?? bl;
    final delta = (ca - ba) * 100;
    final latency = bl > 0 ? ((bl - cl) / bl) * 100 : 0;
    final promoted = row['generationPromoted'] == true;
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white.withOpacity(.023), borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Container(
            width: 38, height: 38, alignment: Alignment.center,
            decoration: BoxDecoration(color: accent.withOpacity(.10), borderRadius: BorderRadius.circular(11)),
            child: Text('G' + (row['generation'] ?? widget.generation).toString(), style: TextStyle(color: accent, fontWeight: FontWeight.w900, fontSize: 10)),
          ),
          const SizedBox(width: 9),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(row['kind'] == 'neuralBenchmark' ? 'Benchmark' : 'Laboratório neural', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text('Acc ' + (ca * 100).toStringAsFixed(1) + '% • Δ ' + (delta >= 0 ? '+' : '') + delta.toStringAsFixed(1) + ' pp • ' + (cp > 0 ? n(cp) : '—') + ' params',
              style: const TextStyle(color: muted, fontSize: 9)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(promoted ? 'PROMOVIDA' : 'MEDIDA', style: TextStyle(color: promoted ? const Color(0xFF56E3A8) : muted, fontSize: 7.5, fontWeight: FontWeight.w900, letterSpacing: 1)),
            const SizedBox(height: 3),
            Text(bl > 0 && cl > 0 ? 'lat ' + (latency >= 0 ? '−' : '+') + latency.abs().toStringAsFixed(0) + '%' : 'lat —',
              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800)),
          ]),
        ]),
      ),
    );
  }

  Widget checkpoints() => surface(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [label('CHECKPOINTS'), const Spacer(), Text(widget.checkpoints.length.toString() + ' salvos', style: const TextStyle(color: muted, fontSize: 9))]),
    const SizedBox(height: 8),
    if (widget.checkpoints.isEmpty)
      const Text('Nenhum checkpoint ainda.', style: TextStyle(color: muted, fontSize: 10.5))
    else ...widget.checkpoints.take(4).map((cp) => ListTile(
      contentPadding: EdgeInsets.zero, dense: true,
      leading: const Icon(Icons.restore_rounded, size: 18, color: muted),
      title: Text(cp.label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
      subtitle: Text('G' + cp.generation.toString() + ' • ' + n(cp.parameters) + ' parâmetros • acc ' + (cp.accuracy * 100).toStringAsFixed(1) + '%',
        style: const TextStyle(color: muted, fontSize: 8.8)),
      trailing: TextButton(onPressed: widget.onRestoreCheckpoint == null ? null : () => widget.onRestoreCheckpoint!(cp.id), child: const Text('Restaurar')),
    )),
  ]));

  Widget education() {
    final all = <String, List<String>>{
      'Escola': widget.schoolTopics,
      'Universidade': widget.universityTopics,
      'Pós-graduação': widget.postgraduateTopics,
    };
    return surface(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      label('TRAJETÓRIA EDUCACIONAL'), const SizedBox(height: 8),
      for (final entry in all.entries) ...[
        Text(entry.key, style: TextStyle(color: accent, fontSize: 9.5, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        ...entry.value.take(4).map((topic) {
          final passed = widget.passedEducationTopics.contains(topic);
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(children: [
              Icon(passed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: passed ? const Color(0xFF56E3A8) : muted, size: 14),
              const SizedBox(width: 6), Expanded(child: Text(topic, style: const TextStyle(fontSize: 10))),
            ]),
          );
        }),
        const SizedBox(height: 6),
      ],
    ]));
  }

  Widget systemPage(Key key) => ListView(
    key: key, padding: EdgeInsets.fromLTRB(pad, 6, pad, 115),
    children: [
      header('Sistema', 'Personalização, plugins e integridade'),
      const SizedBox(height: 12),
      surface(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        label('PERSONALIZAÇÃO'), const SizedBox(height: 8),
        setting('Aparência', 'Tema, avatar e densidade', Icons.palette_outlined, openCustomize),
        setting('Neurônios ativos', widget.activeNeuronBudget.toString() + ' por passo', Icons.tune_rounded, () => openCustomize(neuronOnly: true)),
        setting('Laboratório', 'Benchmarks e evolução', Icons.auto_graph_rounded, () => setState(() => page = 3)),
        setting('Testes', widget.testTotal == 0 ? 'Ainda não executado' : widget.testPassed.toString() + '/' + widget.testTotal.toString(), Icons.verified_rounded, widget.onRunTests),
      ])),
      const SizedBox(height: 11),
      storeCard(),
      const SizedBox(height: 11),
      surface(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        label('MEMÓRIA & PORTABILIDADE'), const SizedBox(height: 8),
        setting('Importar documentos', 'Adicionar fontes locais', Icons.upload_file_rounded, widget.onImport),
        setting('Backup criogênico', 'Estado completo + rollback', Icons.backup_rounded, widget.onBackup),
        if (widget.onDiagnostics != null) setting('Diagnóstico', 'Métricas agregadas', Icons.bug_report_outlined, widget.onDiagnostics!),
        setting('Pacote local', '.nova.json', Icons.folder_open_rounded, widget.onInstallLocal),
        setting('Pacote HTTPS', 'HTTPS + SHA-256', Icons.link_rounded, widget.onInstallUrl),
      ])),
      const SizedBox(height: 11),
      surface(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        label('AUTONOMIA'), const SizedBox(height: 8),
        resourceBadge(),
        const SizedBox(height: 8),
        setting('Estudo autônomo', widget.autonomousStudyEnabled ? 'Ativo' : 'Pausado', widget.autonomousStudyEnabled ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
          () => widget.onSend(widget.autonomousStudyEnabled ? 'parar estudo autonomo' : 'estudar autonomamente')),
        setting('Segundo plano', widget.backgroundEnabled ? 'Ativo' : 'Inativo', widget.backgroundEnabled ? Icons.stop_circle_outlined : Icons.play_arrow_rounded,
          () => widget.onSend(widget.backgroundEnabled ? 'parar modo em segundo plano' : 'iniciar modo em segundo plano')),
      ])),
    ],
  );

  Widget storeCard() => surface(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [label('NOVA STORE'), const Spacer(), Text(widget.plugins.length.toString() + ' ativos', style: const TextStyle(color: muted, fontSize: 9))]),
    const SizedBox(height: 4),
    const Text('Plugins integrados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
    const SizedBox(height: 3),
    const Text('Instale e conecte ferramentas ao agente sem sair do aplicativo.', style: TextStyle(color: muted, fontSize: 10)),
    const SizedBox(height: 10),
    SizedBox(height: 134, child: ListView.separated(
      scrollDirection: Axis.horizontal, itemCount: _plugins.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, i) => pluginCard(_plugins[i]),
    )),
    const SizedBox(height: 8),
    OutlinedButton.icon(onPressed: openMarketplace, icon: const Icon(Icons.storefront_rounded), label: const Text('Abrir catálogo completo')),
  ]));

  Widget pluginCard(_PluginInfo plugin) {
    final installed = widget.plugins.contains(plugin.title);
    return Container(
      width: 205, padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(color: Colors.white.withOpacity(.023), borderRadius: BorderRadius.circular(17), border: Border.all(color: plugin.color.withOpacity(.15))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: plugin.color.withOpacity(.12), borderRadius: BorderRadius.circular(11)), child: Icon(plugin.icon, color: plugin.color, size: 17)),
          const Spacer(),
          if (installed) const Icon(Icons.check_circle_rounded, color: Color(0xFF56E3A8), size: 17),
        ]),
        const SizedBox(height: 7),
        Text(plugin.title, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(plugin.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: muted, fontSize: 9)),
        const Spacer(),
        SizedBox(width: double.infinity, child: FilledButton.tonal(
          onPressed: () { widget.onPlugin(plugin.id); },
          child: Text(installed ? 'Abrir' : 'Instalar'),
        )),
      ]),
    );
  }

  Widget setting(String title, String subtitle, IconData icon, VoidCallback action) => Padding(
    padding: const EdgeInsets.only(bottom: 3),
    child: Material(color: Colors.transparent, child: InkWell(
      onTap: action, borderRadius: BorderRadius.circular(15),
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2), child: Row(children: [
        Container(width: 35, height: 35, decoration: BoxDecoration(color: accent.withOpacity(.09), borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: accent, size: 17)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(color: muted, fontSize: 9)),
        ])),
        const Icon(Icons.chevron_right_rounded, size: 17, color: muted),
      ])),
    )),
  );

  Widget resourceBadge() => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(color: Colors.white.withOpacity(.023), borderRadius: BorderRadius.circular(15)),
    child: Row(children: [
      const Icon(Icons.memory_rounded, color: muted, size: 17),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Estado de recursos: ' + widget.resourceState, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(widget.resourceReason, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: muted, fontSize: 9)),
      ])),
      Icon(Icons.circle, color: statusColor(), size: 9),
    ]),
  );

  Widget floatingEvolution() {
    final value = clamp01(evolutionPercent() / 100);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => page = 3),
        borderRadius: BorderRadius.circular(21),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xEE0A0C12),
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: accent.withOpacity(.25)),
            boxShadow: [BoxShadow(color: accent.withOpacity(.12), blurRadius: 22, offset: const Offset(0, 9))],
          ),
          child: Row(children: [
            AnimatedBuilder(
              animation: orbit,
              builder: (_, __) => Transform.rotate(angle: orbit.value * math.pi * 2, child: Icon(Icons.auto_awesome_rounded, color: accent, size: 16)),
            ),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('EVOLUÇÃO', style: TextStyle(color: accent, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                const Spacer(),
                Text(evolutionPercent().toStringAsFixed(1) + '%', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900)),
              ]),
              const SizedBox(height: 4),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: value), duration: const Duration(milliseconds: 800),
                builder: (_, v, __) => LinearProgressIndicator(value: v, minHeight: 4, color: accent, backgroundColor: Colors.white.withOpacity(.05)),
              ),
            ])),
            const SizedBox(width: 8),
            Text('G' + widget.generation.toString(), style: const TextStyle(color: muted, fontSize: 8.5, fontWeight: FontWeight.w800)),
          ]),
        ),
      ),
    );
  }

  Widget header(String title, String subtitle) => Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -.5)),
      const SizedBox(height: 3),
      Text(subtitle, style: const TextStyle(color: muted, fontSize: 10.5)),
    ])),
    Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(color: accent.withOpacity(.09), borderRadius: BorderRadius.circular(11)),
      child: Text('G' + widget.generation.toString(), style: TextStyle(color: accent, fontSize: 9.5, fontWeight: FontWeight.w900))),
  ]);

  Widget label(String text) => Text(text, style: TextStyle(color: accent, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.35));

  Future<void> openMarketplace() async => showModalBottomSheet<void>(
    context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: .72, minChildSize: .52, maxChildSize: .92,
      builder: (context, controller) => Container(
        decoration: const BoxDecoration(color: Color(0xFF080A10), borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: ListView(
          controller: controller, padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
          children: [
            Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(.16), borderRadius: BorderRadius.circular(99)))),
            const SizedBox(height: 15),
            Row(children: [
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('NOVA Store', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                SizedBox(height: 3),
                Text('Plugins integrados ao agente', style: TextStyle(color: muted, fontSize: 10.5)),
              ])),
              Icon(Icons.verified_rounded, color: accent),
            ]),
            const SizedBox(height: 14),
            ..._plugins.map((p) => Padding(padding: const EdgeInsets.only(bottom: 8), child: marketplaceRow(p))),
            OutlinedButton.icon(onPressed: widget.onInstallLocal, icon: const Icon(Icons.file_open_rounded), label: const Text('Instalar pacote local')),
            const SizedBox(height: 6),
            OutlinedButton.icon(onPressed: widget.onInstallUrl, icon: const Icon(Icons.link_rounded), label: const Text('Instalar por HTTPS + SHA-256')),
          ],
        ),
      ),
    ),
  );

  Widget marketplaceRow(_PluginInfo plugin) {
    final installed = widget.plugins.contains(plugin.title);
    return Material(
      color: Colors.white.withOpacity(.023), borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () { widget.onPlugin(plugin.id); Navigator.pop(context); },
        borderRadius: BorderRadius.circular(18),
        child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
          Container(width: 43, height: 43, decoration: BoxDecoration(color: plugin.color.withOpacity(.12), borderRadius: BorderRadius.circular(13)), child: Icon(plugin.icon, color: plugin.color)),
          const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(plugin.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5)),
            const SizedBox(height: 2),
            Text(plugin.subtitle, style: const TextStyle(color: muted, fontSize: 9.5)),
          ])),
          FilledButton.tonal(onPressed: () { widget.onPlugin(plugin.id); Navigator.pop(context); }, child: Text(installed ? 'Abrir' : 'Instalar')),
        ])),
      ),
    );
  }

  Future<void> openCustomize({bool neuronOnly = false}) async => showModalBottomSheet<void>(
    context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(builder: (context, setSheet) => Container(
      padding: EdgeInsets.fromLTRB(18, 12, 18, MediaQuery.of(context).viewInsets.bottom + 22),
      decoration: const BoxDecoration(color: Color(0xFF080A10), borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(.16), borderRadius: BorderRadius.circular(99)))),
          const SizedBox(height: 15),
          const Text('Personalizar NOVA', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          const Text('As escolhas ficam salvas no perfil local.', style: TextStyle(color: muted, fontSize: 10)),
          const SizedBox(height: 16),
          label('COR DE ACENTO'), const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            paletteChip(NovaPalette.violet, 'Violeta', const Color(0xFF9B7BFF), setSheet),
            paletteChip(NovaPalette.ocean, 'Oceano', const Color(0xFF4FD7FF), setSheet),
            paletteChip(NovaPalette.forest, 'Floresta', const Color(0xFF56E3A8), setSheet),
          ]),
          const SizedBox(height: 16),
          label('DENSIDADE'), const SizedBox(height: 8),
          SegmentedButton<NovaDensity>(
            segments: const [
              ButtonSegment(value: NovaDensity.comfortable, label: Text('Confortável'), icon: Icon(Icons.view_agenda_outlined)),
              ButtonSegment(value: NovaDensity.compact, label: Text('Compacta'), icon: Icon(Icons.view_compact_outlined)),
            ],
            selected: {widget.appearance.density},
            onSelectionChanged: (values) { widget.onSetDensity?.call(values.first); setSheet(() {}); setState(() {}); },
          ),
          const SizedBox(height: 16),
          label('AVATAR'), const SizedBox(height: 8),
          Row(children: List.generate(4, (index) => Expanded(
            child: Padding(padding: const EdgeInsets.only(right: 7), child: InkWell(
              onTap: () { widget.onSetAvatar?.call(index); setSheet(() {}); setState(() {}); },
              borderRadius: BorderRadius.circular(15),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220), height: 52,
                decoration: BoxDecoration(
                  color: widget.appearance.avatar == index ? accent.withOpacity(.14) : Colors.white.withOpacity(.025),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: widget.appearance.avatar == index ? accent.withOpacity(.55) : line),
                ),
                child: Icon([Icons.hub_rounded, Icons.auto_awesome_rounded, Icons.psychology_rounded, Icons.blur_on_rounded][index],
                  color: widget.appearance.avatar == index ? accent : Colors.white70),
              ),
            )),
          ))),
          const SizedBox(height: 16),
          label('NEURÔNIOS ATIVOS POR PASSO'), const SizedBox(height: 4),
          Text(widget.activeNeuronBudget.toString() + ' / ' + math.min(64, 130).toString(), style: TextStyle(color: accent, fontSize: 17, fontWeight: FontWeight.w900)),
          Slider(
            value: widget.activeNeuronBudget.toDouble(), min: 4, max: 64, divisions: 15,
            label: widget.activeNeuronBudget.toString(),
            onChanged: widget.onSetNeuronBudget == null ? null : (value) { widget.onSetNeuronBudget!(value.round()); setSheet(() {}); setState(() {}); },
          ),
          Text('Sparsidade observada: ' + (widget.neuralSparsity * 100).toStringAsFixed(1) + '%', style: const TextStyle(color: muted, fontSize: 9.5)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: widget.onAppearance, child: const Text('Alternar acento'))),
            const SizedBox(width: 8),
            Expanded(child: FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Concluir'))),
          ]),
        ])),
      ),
    )),
  );

  Widget paletteChip(NovaPalette value, String title, Color color, void Function(void Function()) setSheet) {
    return ChoiceChip(
      label: Text(title), selected: widget.appearance.palette == value,
      avatar: CircleAvatar(radius: 7, backgroundColor: color),
      onSelected: (_) { widget.onSetPalette?.call(value); setSheet(() {}); setState(() {}); },
    );
  }
}

class _NovaBackgroundPainter extends CustomPainter {
  _NovaBackgroundPainter(this.color, this.phase);
  final Color color;
  final double phase;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < 8; i++) {
      final x = size.width * (.06 + i * .14);
      final y = size.height * (.15 + (math.sin(phase * math.pi * 2 + i) + 1) * .11);
      paint.color = color.withOpacity(.015 + i * .002);
      canvas.drawCircle(Offset(x, y), 2.2 + i * .35, paint);
    }
  }
  @override
  bool shouldRepaint(covariant _NovaBackgroundPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.color != color;
}
