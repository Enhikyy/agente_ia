import 'package:flutter/material.dart';

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
    required this.plugins, required this.onPlugin, required this.onResearch});
  final NovaAppearance appearance;
  final int generation, concepts, experiences, responseMs;
  final Duration age;
  final String status;
  final List<Map<String, dynamic>> messages;
  final TextEditingController input;
  final ScrollController scroll;
  final ValueChanged<String> onSend;
  final VoidCallback onImport, onBackup, onEvolve, onAppearance, onResearch;
  final bool isReading;
  final List<String> plugins;
  final ValueChanged<String> onPlugin;

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
      border: Border.all(color: Colors.white.withValues(alpha: .065))),
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
              decoration: BoxDecoration(color: accent.withValues(alpha: .16),
                borderRadius: BorderRadius.circular(13)),
              child: Icon(widget.appearance.avatarIcon, color: accent)),
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
          _home(accent), _chat(accent), _plugins(accent), _settings(accent),
        ])),
        bottomNavigationBar: NavigationBar(
          backgroundColor: const Color(0xFF101626),
          selectedIndex: page, indicatorColor: accent.withValues(alpha: .19),
          onDestinationSelected: (i) => setState(() => page = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.space_dashboard_outlined),
              selectedIcon: Icon(Icons.space_dashboard_rounded), label: 'Painel'),
            NavigationDestination(icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble_rounded), label: 'Chat'),
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
          decoration: BoxDecoration(color: accent.withValues(alpha: .15),
            borderRadius: BorderRadius.circular(17)),
          child: Icon(widget.appearance.avatarIcon, color: accent, size: 29)),
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
      FilledButton.icon(onPressed: widget.onEvolve,
        icon: const Icon(Icons.auto_awesome_rounded),
        label: const Text('Testar nova geração')),
      const SizedBox(height: 8),
      OutlinedButton.icon(onPressed: widget.onResearch,
        icon: const Icon(Icons.public_rounded),
        label: const Text('Pesquisa na web — status')),
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
              color: user ? accent.withValues(alpha: .24) : surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: user ?
                accent.withValues(alpha: .35) : Colors.white10)),
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

  Widget _plugins(Color accent) => ListView(
    padding: const EdgeInsets.all(18), children: [
      const Text('Plugins', style: TextStyle(fontSize: 25,
        fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      const Text('Ferramentas locais reais. Downloads e execução de código '
        'externo ainda não estão habilitados.',
        style: TextStyle(color: subtle)),
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
      panel(const Text('Catálogo externo: indisponível nesta versão. '
        'A instalação futura exigirá confirmação e verificação de segurança.',
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
          ChoiceChip(label: Icon([
            Icons.hub_rounded, Icons.auto_awesome_rounded,
            Icons.psychology_rounded, Icons.blur_on_rounded][i]),
            selected: widget.appearance.avatar == i,
            onSelected: (_) {
              setState(() => widget.appearance.avatar = i);
              widget.onAppearance();
            }))),
        const SizedBox(height: 10),
        const Text('O ícone da tela inicial do Android é fixo nesta versão.',
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
      OutlinedButton.icon(onPressed: widget.onBackup,
        icon: const Icon(Icons.backup_outlined),
        label: const Text('Salvar backup local')),
    ]);
}
