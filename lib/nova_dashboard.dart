import 'nova_growth_widgets.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

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
      borderRadius: BorderRadius.circular(size * .23),
      child: snapshot.hasData
          ? Image.memory(snapshot.data!, width: size, height: size,
              fit: BoxFit.cover, gaplessPlayback: true)
          : SizedBox(width: size, height: size,
              child: const Icon(Icons.hub_rounded)),
    ),
  );
}

enum NovaPalette { violet, ocean, forest }
enum NovaDensity { comfortable, compact }

class NovaAppearance {
  NovaPalette palette;
  NovaDensity density;
  int avatar;
  NovaAppearance({this.palette = NovaPalette.violet,
    this.density = NovaDensity.comfortable, this.avatar = 0});
  Color get accent => switch (palette) {
    NovaPalette.violet => const Color(0xFF9B8AFF),
    NovaPalette.ocean => const Color(0xFF48BFE3),
    NovaPalette.forest => const Color(0xFF4ADEA2),
  };
  IconData get avatarIcon => [
    Icons.hub_rounded, Icons.auto_awesome_rounded,
    Icons.psychology_rounded, Icons.blur_on_rounded
  ][avatar.clamp(0, 3)];
  Map<String, dynamic> toJson() => {
    'palette': palette.index, 'density': density.index, 'avatar': avatar};
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
  const NovaDashboard({super.key, required this.appearance,
    required this.generation, required this.concepts, required this.experiences,
    required this.age, required this.status, required this.responseMs,
    required this.messages, required this.input, required this.scroll,
    required this.onSend, required this.onImport, required this.onBackup,
    required this.onEvolve, required this.onAppearance, required this.isReading,
    this.onDiagnostics, this.onCheckUpdates, this.onUpdate,
    this.availableUpdateBuild, this.checkingUpdates = false, this.onRefine,
    this.onSetSupervisedAutonomy, this.supervisedAutonomyConfigured = false,
    required this.plugins, required this.onPlugin, required this.onResearch,
    required this.isThinking, required this.milestones,
    required this.onInstallLocal, required this.onInstallUrl,
    this.researchProgress = 0, this.researchStage = '',
    this.researchMs = 0, this.researching = false,
    this.generationReports = const [], this.resourceSamples = const []});
  final NovaAppearance appearance;
  final int generation, concepts, experiences, responseMs;
  final Duration age;
  final String status;
  final List<Map<String, dynamic>> messages;
  final TextEditingController input;
  final ScrollController scroll;
  final ValueChanged<String> onSend;
  final VoidCallback onImport, onBackup, onEvolve, onAppearance, onResearch;
  final VoidCallback? onDiagnostics, onCheckUpdates, onUpdate, onRefine,
      onSetSupervisedAutonomy;
  final bool supervisedAutonomyConfigured;
  final int? availableUpdateBuild;
  final bool checkingUpdates;
  final bool isReading, isThinking, researching;
  final double researchProgress;
  final String researchStage;
  final int researchMs;
  final List<NovaMilestone> milestones;
  final List<Map<String, dynamic>> generationReports, resourceSamples;
  final List<String> plugins;
  final ValueChanged<String> onPlugin;
  final VoidCallback onInstallLocal, onInstallUrl;

  @override
  State<NovaDashboard> createState() => _NovaDashboardState();
}

class _NovaDashboardState extends State<NovaDashboard> {
  int page = 0;
  static const bg = Color(0xFF090D19);
  static const surface = Color(0xFF151B2B);
  static const subtle = Color(0xFF9BA6BE);

  Widget panel(Widget child, {EdgeInsets? padding}) => Container(
    padding: padding ?? const EdgeInsets.all(16),
    decoration: BoxDecoration(color: surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(.065))),
    child: child);

  Widget stat(String name, String value, IconData icon) => Expanded(
    child: panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: widget.appearance.accent, size: 19),
      const SizedBox(height: 13),
      Text(value, style: const TextStyle(color: Colors.white,
        fontSize: 21, fontWeight: FontWeight.w700)),
      const SizedBox(height: 3),
      Text(name, style: const TextStyle(color: subtle, fontSize: 11)),
    ]), padding: const EdgeInsets.all(13)));

  @override
  Widget build(BuildContext context) {
    final accent = widget.appearance.accent;
    return Theme(data: ThemeData.dark(useMaterial3: true).copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: accent,
        brightness: Brightness.dark, surface: surface),
      scaffoldBackgroundColor: bg),
      child: Scaffold(
        appBar: AppBar(backgroundColor: bg, elevation: 0,
          titleSpacing: 18,
          title: Row(children: [
            Container(width: 38, height: 38,
              decoration: BoxDecoration(color: accent.withOpacity(.16),
                borderRadius: BorderRadius.circular(13)),
              child: widget.appearance.avatar == 0
                ? const NovaEmblem(size: 38)
                : Icon(widget.appearance.avatarIcon, color: accent)),
            const SizedBox(width: 11),
            const Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NOVA', style: TextStyle(fontSize: 19,
                  fontWeight: FontWeight.w800, letterSpacing: 2)),
                Text('NÚCLEO LOCAL', style: TextStyle(
                  color: subtle, fontSize: 9, letterSpacing: 1.8)),
              ]),
          ]),
          actions: [
            IconButton(tooltip: 'Importar PDF ou TXT',
              onPressed: widget.isReading ? null : widget.onImport,
              icon: const Icon(Icons.note_add_outlined)),
            IconButton(tooltip: 'Backup', onPressed: widget.onBackup,
              icon: const Icon(Icons.save_alt_rounded)),
          ]),
        body: SafeArea(child: IndexedStack(index: page, children: [
          _home(accent), _chat(accent), _growth(accent),
          _plugins(accent), _settings(accent),
        ])),
        bottomNavigationBar: NavigationBar(
          backgroundColor: const Color(0xFF101626),
          selectedIndex: page, indicatorColor: accent.withOpacity(.19),
          onDestinationSelected: (i) => setState(() => page = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.space_dashboard_outlined),
              selectedIcon: Icon(Icons.space_dashboard_rounded), label: 'Painel'),
            NavigationDestination(icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble_rounded), label: 'Chat'),
            NavigationDestination(icon: Icon(Icons.account_tree_outlined),
              selectedIcon: Icon(Icons.account_tree_rounded), label: 'Evolução'),
            NavigationDestination(icon: Icon(Icons.extension_outlined),
              selectedIcon: Icon(Icons.extension_rounded), label: 'Plugins'),
            NavigationDestination(icon: Icon(Icons.tune_rounded),
              label: 'Ajustes'),
          ]),
      ));
  }

  Widget _home(Color accent) {
    final hours = widget.age.inHours;
    return ListView(padding: const EdgeInsets.all(18), children: [
      panel(Row(children: [
        Container(width: 52, height: 52,
          decoration: BoxDecoration(color: accent.withOpacity(.15),
            borderRadius: BorderRadius.circular(17)),
          child: widget.appearance.avatar == 0
              ? const NovaEmblem(size: 52)
              : Icon(widget.appearance.avatarIcon, color: accent, size: 29)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Geração ${widget.generation.toString().padLeft(3, '0')}',
              style: const TextStyle(fontSize: 19,
                fontWeight: FontWeight.w700)),
            const SizedBox(height: 5),
            Text(widget.status, maxLines: 2,
              style: const TextStyle(color: subtle, fontSize: 12)),
          ])),
        Container(width: 9, height: 9,
          decoration: const BoxDecoration(color: Color(0xFF4ADEA2),
            shape: BoxShape.circle)),
      ])),
      const SizedBox(height: 20),
      const Text('TELEMETRIA', style: TextStyle(color: subtle,
        fontSize: 11, letterSpacing: 2)),
      const SizedBox(height: 10),
      Row(children: [
        stat('Idade desde a criação', '${hours}h', Icons.schedule_rounded),
        const SizedBox(width: 10),
        stat('Conceitos', '${widget.concepts}', Icons.hub_outlined),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        stat('Experiências', '${widget.experiences}', Icons.bolt_outlined),
        const SizedBox(width: 10),
        stat('Última resposta', '${widget.responseMs} ms', Icons.speed_rounded),
      ]),
      const SizedBox(height: 20),
      panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('ATIVIDADE ATUAL', style: TextStyle(
          color: subtle, fontSize: 11, letterSpacing: 1.7)),
        const SizedBox(height: 12),
        Row(children: [
          Icon(widget.isReading ? Icons.downloading_rounded :
            Icons.memory_rounded, color: accent),
          const SizedBox(width: 10),
          Expanded(child: Text(widget.status)),
        ]),
        if (widget.isReading) ...[
          const SizedBox(height: 14),
          LinearProgressIndicator(color: accent),
        ],
      ])),
      const SizedBox(height: 12),
      panel(NovaGrowthTimeline(events: widget.milestones.reversed.take(3).toList(),
        age: widget.age, generation: widget.generation,
        concepts: widget.concepts, experiences: widget.experiences,
        color: accent)),
      const SizedBox(height: 12),
      FilledButton.icon(onPressed: widget.onEvolve,
        icon: const Icon(Icons.auto_awesome_rounded),
        label: const Text('Testar nova geração')),
      const SizedBox(height: 8),
      panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('PESQUISA NA WEB', style: TextStyle(color: subtle,
          fontSize: 11, letterSpacing: 1.7)),
        const SizedBox(height: 12),
        Text(widget.researching ? widget.researchStage :
          widget.researchProgress >= 1 ? 'Pesquisa concluída' :
          'Wikipédia em português • fontes identificadas',
          style: const TextStyle(fontSize: 13)),
        const SizedBox(height: 12),
        LinearProgressIndicator(value: widget.researchProgress,
          minHeight: 9, borderRadius: BorderRadius.circular(12),
          backgroundColor: Colors.white12,
          color: widget.researchProgress >= 1 ? const Color(0xFF35D399) :
            widget.researchProgress >= .5 ? const Color(0xFFFFA940) :
            const Color(0xFFFF646E)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${(widget.researchProgress * 100).round()}% • '
            '${widget.researchProgress >= 1 ? 'Concluído' : widget.researchProgress >= .5 ? 'Médio' : 'Baixo'}',
            style: const TextStyle(color: subtle, fontSize: 12)),
          Text('${widget.researchMs} ms',
            style: const TextStyle(color: subtle, fontSize: 12)),
        ]),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: FilledButton.icon(
          onPressed: widget.researching ? null : widget.onResearch,
          icon: const Icon(Icons.travel_explore_rounded),
          label: Text(widget.researching ? 'Pesquisando...' : 'Pesquisar na web'))),
      ])),
      const SizedBox(height: 12),
      const Text('As gerações representam compactação validada; não medem inteligência.',
        style: TextStyle(color: subtle, fontSize: 11)),
    ]);
  }

  Widget _chat(Color accent) => Column(children: [
    Expanded(child: ListView.builder(controller: widget.scroll,
      padding: const EdgeInsets.all(17),
      itemCount: widget.messages.length,
      itemBuilder: (context, i) {
        final m = widget.messages[i];
        final user = m['isUser'] == true;
        final system = m['isSystem'] == true;
        return Align(alignment: user ? Alignment.centerRight :
          Alignment.centerLeft,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 340),
            margin: const EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(widget.appearance.density ==
              NovaDensity.compact ? 10 : 15),
            decoration: BoxDecoration(
              color: user ? accent.withOpacity(.24) : surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: user ?
                accent.withOpacity(.35) : Colors.white10)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user ? 'VOCÊ' : system ? 'SISTEMA' : 'NOVA',
                  style: TextStyle(color: user ? accent : subtle,
                    fontSize: 10, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                SelectableText(m['texto']?.toString() ?? '',
                  style: const TextStyle(fontSize: 14, height: 1.5)),
              ])));
      })),
    if (widget.isThinking || widget.isReading)
      Padding(padding: const EdgeInsets.fromLTRB(17, 6, 17, 6),
        child: Align(alignment: Alignment.centerLeft,
          child: panel(NovaTypingIndicator(color: accent,
            label: widget.isReading ? 'NOVA está lendo' : 'NOVA está pensando')))),
    if (widget.isReading) LinearProgressIndicator(color: accent),
    Padding(padding: const EdgeInsets.all(12),
      child: Row(children: [
        Expanded(child: TextField(controller: widget.input,
          enabled: !widget.isReading, maxLines: 4, minLines: 1,
          textInputAction: TextInputAction.send,
          onSubmitted: widget.onSend,
          decoration: InputDecoration(hintText: 'Converse com a NOVA…',
            filled: true, fillColor: surface,
            border: OutlineInputBorder(borderRadius:
              BorderRadius.circular(20), borderSide: BorderSide.none)))),
        const SizedBox(width: 8),
        IconButton.filled(onPressed: widget.isReading ? null :
          () => widget.onSend(widget.input.text),
          icon: const Icon(Icons.arrow_upward_rounded)),
      ])),
  ]);

  Widget _growth(Color accent) => ListView(
    padding: const EdgeInsets.all(18), children: [
      const Text('Evolução', style: TextStyle(
        fontSize: 25, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      const Text('Histórico verificável de atividades e gerações.',
        style: TextStyle(color: subtle)),
      const SizedBox(height: 18),
      panel(NovaGrowthTimeline(events: widget.milestones,
        age: widget.age, generation: widget.generation,
        concepts: widget.concepts, experiences: widget.experiences,
        color: accent)),
      const SizedBox(height: 14),
      panel(NovaGenerationTree(events: widget.milestones,
        currentGeneration: widget.generation, color: accent)),
      const SizedBox(height: 14),
      NovaBenchmarkPanel(reports: widget.generationReports,
        resourceSamples: widget.resourceSamples, accent: accent),
    ]);

  Widget _plugins(Color accent) => ListView(
    padding: const EdgeInsets.all(18), children: [
      const Text('Plugins', style: TextStyle(fontSize: 25,
        fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      const Text('Ferramentas locais reais. Downloads e execução de código '
        'externo ainda não estão habilitados.',
        style: TextStyle(color: subtle)),
      const SizedBox(height: 18),
      panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('PACOTES EXTERNOS', style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.4)),
        const SizedBox(height: 8),
        const Text('Instale pacotes de conhecimento por arquivo ou HTTPS. '
          'O APK continua leve; nenhum código externo é executado.',
          style: TextStyle(color: subtle, fontSize: 12)),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: widget.onInstallLocal,
          icon: const Icon(Icons.folder_open_rounded),
          label: const Text('Instalar arquivo .nova.json')),
        const SizedBox(height: 8),
        OutlinedButton.icon(onPressed: widget.onInstallUrl,
          icon: const Icon(Icons.cloud_download_outlined),
          label: const Text('Instalar por URL HTTPS')),
        if (widget.plugins.isNotEmpty) ...[
          const SizedBox(height: 10),
          ...widget.plugins.map((name) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(children: [Icon(Icons.check_circle_outline,
              color: accent, size: 17), const SizedBox(width: 7),
              Expanded(child: Text(name, style: const TextStyle(fontSize: 12)))]))),
        ],
      ])),
      const SizedBox(height: 18),
      ...[
        ('Estatísticas locais', 'Contagem de conceitos e experiências',
          Icons.bar_chart_rounded, 'stats'),
        ('Compactação GZIP', 'Snapshots reversíveis da memória',
          Icons.inventory_2_outlined, 'compression'),
        ('Leitor PDF/TXT', 'Importação de documentos locais',
          Icons.description_outlined, 'documents'),
      ].map((p) => Padding(padding: const EdgeInsets.only(bottom: 10),
        child: panel(Row(children: [
          Icon(p.$3, color: accent), const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 5),
              Text(p.$2, style: const TextStyle(color: subtle, fontSize: 12)),
            ])),
          TextButton(onPressed: () => widget.onPlugin(p.$4),
            child: const Text('Abrir')),
        ])))),
      const SizedBox(height: 8),
      panel(const Text('Pacotes externos aceitos: dados e documentos JSON. '
        'Instalação de APKs, bibliotecas nativas ou código de terceiros '
        'não está habilitada.',
        style: TextStyle(color: subtle, height: 1.5))),
    ]);

  Widget _settings(Color accent) => ListView(
    padding: const EdgeInsets.all(18), children: [
      const Text('Personalização', style: TextStyle(
        fontSize: 25, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      const Text('Altere o visual da NOVA. As preferências são salvas '
        'na memória local.', style: TextStyle(color: subtle)),
      const SizedBox(height: 20),
      panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Ícone dentro do aplicativo',
          style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(spacing: 12, children: List.generate(4, (i) =>
          ChoiceChip(label: i == 0 ? const NovaEmblem(size: 26) : Icon([
            Icons.hub_rounded, Icons.auto_awesome_rounded,
            Icons.psychology_rounded, Icons.blur_on_rounded][i]),
            selected: widget.appearance.avatar == i,
            onSelected: (_) {
              setState(() => widget.appearance.avatar = i);
              widget.onAppearance();
            }))),
        const SizedBox(height: 10),
        const Text('O ícone da tela inicial do Android usa o emblema NOVA.',
          style: TextStyle(color: subtle, fontSize: 11)),
      ])),
      const SizedBox(height: 12),
      panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Cor do tema', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        ...NovaPalette.values.map((p) => RadioListTile<NovaPalette>(
          title: Text(switch (p) {
            NovaPalette.violet => 'Violeta',
            NovaPalette.ocean => 'Oceano',
            NovaPalette.forest => 'Floresta',
          }), value: p, groupValue: widget.appearance.palette,
          onChanged: (value) {
            if (value == null) return;
            setState(() => widget.appearance.palette = value);
            widget.onAppearance();
          })),
      ])),
      const SizedBox(height: 12),
      panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Densidade do layout',
          style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        SegmentedButton<NovaDensity>(
          segments: const [
            ButtonSegment(value: NovaDensity.comfortable,
              label: Text('Confortável')),
            ButtonSegment(value: NovaDensity.compact,
              label: Text('Compacto')),
          ], selected: {widget.appearance.density},
          onSelectionChanged: (v) {
            setState(() => widget.appearance.density = v.first);
            widget.onAppearance();
          }),
      ])),
      const SizedBox(height: 15),
      if (widget.availableUpdateBuild != null)
        FilledButton.icon(onPressed: widget.onUpdate,
          icon: const Icon(Icons.system_update),
          label: Text('Atualizar NOVA (build ${widget.availableUpdateBuild})')),
      OutlinedButton.icon(onPressed: widget.checkingUpdates ? null : widget.onCheckUpdates,
        icon: const Icon(Icons.refresh), label: const Text('Verificar atualizações')),
      panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Autonomia e memória',
          style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(widget.supervisedAutonomyConfigured
          ? 'Supervisionada: pesquisa autorizada e limpeza de cache descartável.'
          : 'Configure a política de autonomia supervisionada.',
          style: const TextStyle(color: subtle)),
        const SizedBox(height: 8),
        OutlinedButton.icon(onPressed: widget.onSetSupervisedAutonomy,
          icon: const Icon(Icons.shield_outlined),
          label: const Text('Ativar autonomia supervisionada')),
        const SizedBox(height: 6),
        const Text('Documentos e memórias fornecidos por você não são '
          'excluídos automaticamente. Pesquisa geral autônoma ainda requer '
          'um agente com modelo de linguagem.',
          style: TextStyle(color: subtle, fontSize: 12)),
      ])),
      const SizedBox(height: 12),
      OutlinedButton.icon(onPressed: widget.onRefine,
        icon: const Icon(Icons.tune), label: const Text('Refinar parâmetros')),
      OutlinedButton.icon(onPressed: widget.onDiagnostics,
        icon: const Icon(Icons.monitor_heart_outlined),
        label: const Text('Exportar diagnóstico JSON')),
      const SizedBox(height: 12),
      OutlinedButton.icon(onPressed: widget.onBackup,
        icon: const Icon(Icons.backup_outlined),
        label: const Text('Salvar backup local')),
    ]);
}


/// Real recorded measurements only. Missing energy and RAM benchmarks remain N/A.
class NovaBenchmarkPanel extends StatelessWidget {
  const NovaBenchmarkPanel({super.key, required this.reports,
    required this.resourceSamples, required this.accent});
  final List<Map<String, dynamic>> reports, resourceSamples;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final rows = reports.where((r) => r['generationPromoted'] == true ||
      r['holdoutBefore'] is num).toList().reversed.take(12).toList().reversed.toList();
    Widget metric(String title, String value) => Expanded(child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF151B2B),
        borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Color(0xFF9BA6BE), fontSize: 11)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold,
          fontSize: 17)),
      ])));
    final last = rows.isEmpty ? null : rows.last;
    final accuracy = last?['accuracy'] ?? last?['holdoutAfter'];
    final latency = last?['latencyUs'];
    final ram = last?['memoryKb'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('BENCHMARK POR GERAÇÃO', style: TextStyle(
        fontWeight: FontWeight.w700, letterSpacing: 1.1)),
      const SizedBox(height: 5),
      const Text('Resultados registrados, não estimativas de inteligência.',
        style: TextStyle(color: Color(0xFF9BA6BE), fontSize: 12)),
      const SizedBox(height: 12),
      Row(children: [
        metric('Precisão', accuracy is num ?
          '${(accuracy * 100).toStringAsFixed(1)}%' : 'N/D'),
        const SizedBox(width: 8),
        metric('Latência', latency is num ? '${latency} µs' : 'N/D'),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        metric('RAM medida', ram is num ? '${ram} KB' : 'N/D'),
        const SizedBox(width: 8),
        metric('Energia / geração', 'N/D'),
      ]),
      const SizedBox(height: 14),
      if (rows.isEmpty) const Text('Nenhum benchmark de geração registrado.',
        style: TextStyle(color: Color(0xFF9BA6BE)))
      else ...[
        const Text('Histórico de precisão', style: TextStyle(fontSize: 13)),
        const SizedBox(height: 8),
        SizedBox(height: 110, child: CustomPaint(
          painter: _NovaAccuracyPainter(rows, accent),
          child: const SizedBox.expand())),
        const SizedBox(height: 8),
        ...rows.reversed.take(5).map((r) {
          final a = r['accuracy'] ?? r['holdoutAfter'];
          final speed = r['latencyUs'];
          final memory = r['memoryKb'];
          return ListTile(dense: true, contentPadding: EdgeInsets.zero,
            title: Text(r['generationPromoted'] == true ?
              'Geração promovida' : 'Teste de parâmetros'),
            subtitle: Text('Precisão: ${a is num ? '${(a * 100).toStringAsFixed(1)}%' : 'N/D'} · '
              'Latência: ${speed is num ? '${speed} µs' : 'N/D'} · '
              'RAM: ${memory is num ? '${memory} KB' : 'N/D'}'));
        }),
      ],
      const SizedBox(height: 8),
      Text('Leituras de recursos: ${resourceSamples.length}. '
        'Memória livre do aparelho não equivale ao consumo da geração.',
        style: const TextStyle(color: Color(0xFF9BA6BE), fontSize: 11)),
    ]);
  }
}

class _NovaAccuracyPainter extends CustomPainter {
  const _NovaAccuracyPainter(this.reports, this.accent);
  final List<Map<String, dynamic>> reports;
  final Color accent;
  @override
  void paint(Canvas canvas, Size size) {
    final values = reports.map((r) => r['accuracy'] ?? r['holdoutAfter'])
      .whereType<num>().map((v) => v.toDouble()).where((v) => v >= 0 && v <= 1)
      .toList();
    if (values.isEmpty) return;
    final grid = Paint()..color = Colors.white24..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final line = Paint()..color = accent..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1 ? size.width / 2 :
        i * size.width / (values.length - 1);
      final y = (1 - values[i]) * size.height;
      if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = accent);
    }
    canvas.drawPath(path, line);
  }
  @override
  bool shouldRepaint(covariant _NovaAccuracyPainter old) =>
    old.reports != reports || old.accent != accent;
}
