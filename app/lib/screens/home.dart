import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/common.dart';

void _goSearch(BuildContext context, String query) =>
    context.go('/search?q=${Uri.encodeComponent(query)}');

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Widget _quickAction(String to, String label, IconData icon) {
    final bp = Bp.of(context);
    return Hover(
      onTap: () => context.go(to),
      builder: (context, hovered) => Transform.translate(
        offset: Offset(0, hovered ? -2 : 0),
        child: Container(
          constraints: BoxConstraints(minHeight: bp.le520 ? 58 : 66),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: C.paper,
            border: Border.all(color: hovered ? C.gold : C.line),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            Icon(icon, size: 18, color: C.gold),
            const SizedBox(width: 11),
            Expanded(child: Text(label, style: sans(.7, weight: FontWeight.w600))),
            const SizedBox(width: 11),
            const Icon(LucideIcons.arrowRight, size: 13, color: C.muted),
          ]),
        ),
      ),
    );
  }

  Widget _metric(String label, String value, String note, {double? progress}) => Container(
        constraints: const BoxConstraints(minHeight: 142),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: C.paper,
          border: Border.all(color: C.line),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(label, style: sans(.65, color: C.muted)),
          const SizedBox(height: 12),
          Text(value, style: serif(1.55)),
          const Spacer(),
          if (progress != null) WaProgress(progress),
          const SizedBox(height: 9),
          Text(note, style: sans(.57, color: C.muted)),
        ]),
      );

  Widget _miniRow(ResearchItem item) {
    final to = item.kind == 'Legislation' ? '/library/${item.id}' : '/cases/${illustrativeCase.id}';
    return Hover(
      onTap: () => context.go(to),
      builder: (context, _) => Container(
        constraints: const BoxConstraints(minHeight: 69),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: C.line))),
        child: Row(children: [
          Expanded(
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SourceLabel(item.label),
              const SizedBox(width: 9),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: sans(.7, weight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 3),
                  Text(item.reference, style: mono(.58, color: C.muted)),
                ]),
              ),
            ]),
          ),
          const SizedBox(width: 12),
          const Icon(LucideIcons.chevronRight, size: 15, color: C.muted),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final bp = Bp.of(context);
    final completed = app.plan.where((item) => item.done).length;
    final fourCols = bp.le520 ? 1 : (bp.le1024 ? 2 : 4);
    final panelMin = bp.le768 ? 0.0 : 310.0;
    void submit() => _goSearch(context, _query.text);

    return WaPage(children: [
      const PageHeader(
        eyebrow: 'Overview',
        title: 'Good morning, Akua.',
        description: 'Pick up your research or continue the next step in your study plan.',
        action: DemoBadge('Illustrative activity'),
      ),
      SearchFrame(
        input: BareInput(
          controller: _query,
          hint: 'Search cases, legislation, legal topics, or resources',
          onSubmitted: (_) => submit(),
          semanticLabel: 'Search MMRA',
        ),
        button: WaButton('Search MMRA', onTap: submit),
        iconSize: 21,
        padding: const EdgeInsets.fromLTRB(18, 8, 8, 8),
        radius: 12,
        borderColor: const Color(0xFFC9C1AF),
        shadow: const [BoxShadow(color: Color(0x12261F13), blurRadius: 35, offset: Offset(0, 10))],
        wrapButton: bp.le768,
      ),
      const SizedBox(height: 16),
      GridCols(cols: fourCols, children: [
        _quickAction('/cases', 'Search cases', LucideIcons.scale),
        _quickAction('/library', 'Browse legislation', LucideIcons.library),
        _quickAction('/courses/contract', 'Continue studying', LucideIcons.bookOpen),
        _quickAction('/practice', 'Practise questions', LucideIcons.fileQuestion),
      ]),
      const SizedBox(height: 30),
      GridCols(cols: fourCols, children: [
        _metric('Reading progress', '42%', 'Law of Contract · demo data', progress: 42),
        _metric('Plan completed', '$completed / ${app.plan.length}', 'Updates from planner activity',
            progress: app.plan.isEmpty ? 0 : completed / app.plan.length * 100),
        _metric('Practice', app.completedPractice ? '1 reviewed' : 'Not started',
            app.completedPractice ? 'Feedback available' : 'Try an illustrative question'),
        _metric('Revision queue', app.completedPractice ? '1 topic' : 'Empty', 'Based only on completed practice'),
      ]),
      const SizedBox(height: 10),
      GridCols(cols: bp.le768 ? 1 : 2, children: [
        Panel(
          color: C.dark,
          borderColor: C.dark,
          padding: const EdgeInsets.all(25),
          minHeight: panelMin,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Eyebrow('Continue where you left off'),
                  const SizedBox(height: 8),
                  Text('Frustration of contract', style: serif(1.65, color: Colors.white)),
                ]),
              ),
              const SizedBox(width: 18),
              const Icon(LucideIcons.bookOpen, size: 29, color: C.goldLight),
            ]),
            Text('Law of Contract · Authority and case brief', style: sans(1, color: const Color(0xFFAAA498), height: 1.65)),
            const WaProgress(42, track: Color(0xFF343128)),
            CardActions(children: [
              WaButton(
                'Continue reading',
                trailing: LucideIcons.arrowRight,
                to: '/cases/${illustrativeCase.id}',
                background: C.goldLight,
                foreground: const Color(0xFF111111),
              ),
              TextLink('View course', to: '/courses/contract', style: sans(.67, color: C.goldLight)),
            ]),
          ]),
        ),
        Panel(
          padding: const EdgeInsets.all(25),
          minHeight: panelMin,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            PanelTitle("Today's plan", trailing: TextLink('Open planner', to: '/planner', style: sans(.65, color: C.gold))),
            for (final item in app.plan.where((item) => item.date == 'Today')) PlanRow(item, compact: true),
          ]),
        ),
        Panel(
          padding: const EdgeInsets.all(25),
          minHeight: panelMin,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            PanelTitle('Recently viewed', trailing: TextLink('Reading list', to: '/saved', style: sans(.65, color: C.gold))),
            for (final item in researchItems.take(3)) _miniRow(item),
          ]),
        ),
        Panel(
          padding: const EdgeInsets.all(25),
          minHeight: panelMin,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const PanelTitle('Recommended next', trailing: DemoBadge('Illustrative')),
            Container(
              padding: const EdgeInsets.only(top: 23),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: C.line))),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const ResultIcon(LucideIcons.fileQuestion),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Practice · Frustration', style: sans(1)),
                    const SizedBox(height: 8),
                    Text('Apply the principle to a problem question', style: serif(1.1)),
                    const SizedBox(height: 8),
                    Text('Review a worked feedback structure after submitting your response.',
                        style: sans(.72, color: C.muted, height: 1.65)),
                    TextLink('Start practice', to: '/practice', trailing: LucideIcons.arrowRight, style: sans(.67, color: C.gold)),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
      ]),
    ]);
  }
}

class PlanRow extends StatelessWidget {
  const PlanRow(this.item, {super.key, this.compact = false});
  final PlanItem item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.read(context);
    final bp = Bp.of(context);
    final check = Semantics(
      button: true,
      label: item.done ? 'Mark ${item.title} incomplete' : 'Mark ${item.title} complete',
      child: Hover(
        onTap: () => app.togglePlan(item.id),
        builder: (context, _) => Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            color: item.done ? C.green : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: item.done ? C.green : const Color(0xFFC9C3B7)),
          ),
          child: item.done ? const Icon(LucideIcons.check, size: 12, color: Colors.white) : null,
        ),
      ),
    );
    final text = Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Text(item.title,
          style: sans(.68,
              weight: FontWeight.w700,
              color: item.done ? C.muted : C.ink,
              decoration: item.done ? TextDecoration.lineThrough : null)),
      const SizedBox(height: 3),
      Text('${item.type} · ${item.duration}', style: sans(.56, color: C.muted)),
    ]);
    final time = Text(item.date, style: sans(.56, color: C.muted));
    final more = Semantics(
      button: true,
      label: 'Options for ${item.title}',
      child: Hover(
        onTap: () {},
        builder: (context, _) => const SizedBox(
          width: 34,
          height: 34,
          child: Icon(LucideIcons.ellipsis, size: 17, color: C.muted),
        ),
      ),
    );
    return Container(
      constraints: BoxConstraints(minHeight: compact ? 64 : 70),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: C.line))),
      child: Row(children: [
        check,
        const SizedBox(width: 12),
        if (bp.le520)
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              text,
              const SizedBox(height: 3),
              time,
            ]),
          )
        else ...[
          Expanded(child: text),
          const SizedBox(width: 12),
          time,
        ],
        const SizedBox(width: 12),
        more,
      ]),
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.query, this.type});
  final String query;
  final String? type;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final _draft = TextEditingController(text: widget.query);
  late List<String> _filters = widget.type != null ? [widget.type!] : [];

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  void _submit() {
    final draft = _draft.text;
    context.go(draft.isNotEmpty ? '/search?q=${Uri.encodeComponent(draft)}' : '/search');
  }

  static String _typeName(ResearchItem item) => switch (item.kind) {
        'Case' => 'Cases',
        'Legislation' => 'Legislation',
        'Brief' => 'Briefs',
        'Course' => 'Courses',
        _ => 'Past questions',
      };

  @override
  Widget build(BuildContext context) {
    final bp = Bp.of(context);
    final query = widget.query;
    final q = query.toLowerCase();
    final results = researchItems.where((item) {
      final matchesQuery = query.isEmpty ||
          '${item.title} ${item.topic} ${item.reference}'.toLowerCase().contains(q) ||
          q.contains('frustration');
      return matchesQuery && (_filters.isEmpty || _filters.contains(_typeName(item)));
    }).toList();

    final resultsTitle = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('${results.length} illustrative results', style: serif(1.25)),
      const SizedBox(height: 3),
      Text('Searching all available prototype records for “$query”', style: sans(.66, color: C.muted, height: 1.65)),
    ]);
    final sort = SizedBox(
      width: 140,
      child: WaSelect(
        options: plainOptions(['Most relevant', 'Newest first', 'Alphabetical']),
        fill: C.paper,
        size: .64,
        verticalPadding: 11,
      ),
    );

    return WaPage(children: [
      const Breadcrumbs([('Overview', '/'), ('Search', null)]),
      const PageHeader(
        eyebrow: 'Legal research',
        title: 'Search MMRA',
        description: 'Search illustrative cases, legal texts, briefs, study resources, and questions.',
      ),
      SearchFrame(
        input: BareInput(
          controller: _draft,
          hint: 'Try “frustration of contract”',
          height: 41,
          onSubmitted: (_) => _submit(),
          semanticLabel: 'Search cases and legal materials',
        ),
        button: WaButton('Search', onTap: _submit),
      ),
      if (query.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 18),
          child: DashedBox(
            color: C.line,
            radius: 12,
            child: Container(
              constraints: const BoxConstraints(minHeight: 240),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(20),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(LucideIcons.history, size: 31, color: C.gold),
                const SizedBox(width: 18),
                Flexible(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    Text('Begin with a title, citation, or legal topic.', style: serif(1.2)),
                    const SizedBox(height: 7),
                    Text('Try an illustrative query to explore the connected research workflow.',
                        style: sans(.72, color: C.muted, height: 1.65)),
                    const SizedBox(height: 12),
                    TextLink(
                      'Use “frustration of contract”',
                      style: sans(.68, color: C.gold),
                      onTap: () {
                        _draft.text = 'frustration of contract';
                        _goSearch(context, 'frustration of contract');
                      },
                    ),
                  ]),
                ),
              ]),
            ),
          ),
        )
      else ...[
        FilterChipsBar(active: _filters, onChanged: (value) => setState(() => _filters = value)),
        Padding(
          padding: const EdgeInsets.only(top: 26 - 15, bottom: 13),
          child: bp.le520
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [resultsTitle, const SizedBox(height: 20), sort])
              : Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Expanded(child: resultsTitle), const SizedBox(width: 20), sort]),
        ),
        if (results.isNotEmpty)
          ResultsList(results)
        else
          StateCard(
            icon: LucideIcons.search,
            title: 'No matching records',
            copy: 'Try a broader phrase, remove a filter, or search by content type.',
            action: WaButton('Clear search', kind: BtnKind.secondary, onTap: () {
              setState(() => _filters = []);
              _draft.clear();
              context.go('/search');
            }),
          ),
      ],
    ]);
  }
}

class PlannerPage extends StatelessWidget {
  const PlannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final bp = Bp.of(context);

    final week = Panel(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const PanelTitle('This week',
            trailing: ViewToggle(options: [('List', LucideIcons.layoutList), ('Calendar', LucideIcons.calendarDays)], active: 'List')),
        for (final item in app.plan) PlanRow(item),
      ]),
    );
    final revision = Panel(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Eyebrow('Revision queue'),
        const SizedBox(height: 8),
        Text('Topics to revisit', style: serif(1.2)),
        const SizedBox(height: 8),
        Text('Topics appear here only after actual practice activity in this visit.', style: sans(.65, color: C.muted, height: 1.65)),
        Container(
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: C.paper2, borderRadius: BorderRadius.circular(8)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(LucideIcons.refreshCw, size: 17, color: C.gold),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Frustration of contract', style: sans(.64, weight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Review after practice', style: sans(.54, color: C.muted)),
              ]),
            ),
            const SizedBox(width: 10),
            TextLink('Open', to: '/topics/frustration', style: sans(.58, color: C.gold)),
          ]),
        ),
      ]),
    );

    return WaPage(children: [
      const Breadcrumbs([('Overview', '/'), ('Study planner', null)]),
      PageHeader(
        eyebrow: 'Study planner',
        title: 'Plan the next useful step.',
        description: 'Keep the routine light. Complete, reschedule, or recover without penalty.',
        action: WaButton('Add study session', leading: LucideIcons.plus, onTap: () {
          showWaModal(context, builder: (_) => const _AddSessionModal());
        }),
      ),
      if (bp.le768)
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [week, const SizedBox(height: 10), revision])
      else
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(child: week),
            const SizedBox(width: 10),
            SizedBox(width: 330, child: revision),
          ]),
        ),
    ]);
  }
}

class _AddSessionModal extends StatefulWidget {
  const _AddSessionModal();

  @override
  State<_AddSessionModal> createState() => _AddSessionModalState();
}

class _AddSessionModalState extends State<_AddSessionModal> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  String _type = 'Read a case';
  String _date = 'Today';
  String _duration = '20 min';

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    AppScope.read(context).addPlan(type: _type, title: _title.text, date: _date, duration: _duration);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bp = Bp.of(context);
    final when = FieldLabel('When',
        child: WaSelect(
          value: _date,
          options: plainOptions(['Today', 'Tomorrow', 'Later this week']),
          onChanged: (v) => _date = v ?? _date,
        ));
    final duration = FieldLabel('Duration',
        child: WaSelect(
          value: _duration,
          options: plainOptions(['20 min', '30 min', '45 min']),
          onChanged: (v) => _duration = v ?? _duration,
        ));
    return ModalCard(
      eyebrow: 'New session',
      title: 'Add to your plan',
      onClose: () => Navigator.of(context).pop(),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          FieldLabel('Task type',
              child: WaSelect(
                value: _type,
                options: plainOptions(['Read a case', 'Review legislation', 'Attempt a question', 'Review a topic']),
                onChanged: (v) => _type = v ?? _type,
              )),
          FieldLabel('Topic or resource',
              child: WaTextField(controller: _title, hint: 'e.g. Frustration of contract', validator: requiredValidator)),
          if (bp.le520)
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [when, const SizedBox(height: 10), duration])
          else
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: when),
              const SizedBox(width: 10),
              Expanded(child: duration),
            ]),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              WaButton('Cancel', kind: BtnKind.quiet, onTap: () => Navigator.of(context).pop()),
              const SizedBox(width: 7),
              WaButton('Add session', onTap: _submit),
            ]),
          ),
        ]),
      ),
    );
  }
}

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final items = [
      ...researchItems.where((item) => app.isSaved(item.id)),
      ...legislation.where((item) => app.isSaved(item.id) && !researchItems.any((r) => r.id == item.id)),
    ];
    return WaPage(children: [
      const Breadcrumbs([('Overview', '/'), ('Reading list', null)]),
      const PageHeader(
        eyebrow: 'Private workspace',
        title: 'Your reading list',
        description: 'Saved items and personal study activity are private in this prototype.',
      ),
      if (items.isNotEmpty)
        ResultsList(items)
      else
        const StateCard(
          icon: LucideIcons.bookmark,
          title: 'Your reading list is empty',
          copy: 'Save a case, legal text, brief, resource, or question to find it here.',
          action: WaButton('Explore illustrative records', to: '/search?q=frustration'),
        ),
    ]);
  }
}

class ResourcesPage extends StatelessWidget {
  const ResourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bp = Bp.of(context);
    return WaPage(children: [
      const Breadcrumbs([('Overview', '/'), ('Resources', null)]),
      const PageHeader(
        eyebrow: 'Resources',
        title: 'Articles, guides, and authorized learning materials.',
        description: 'Access and rights must be known before a resource is made available.',
      ),
      GridCols(cols: bp.le768 ? 1 : (bp.le1024 ? 2 : 3), children: [
        const StateCard(
          vertical: true,
          icon: LucideIcons.folderOpen,
          title: 'No authorized resources supplied',
          copy: 'Books, slides, and course materials will appear only when access rights and provenance are known.',
        ),
        StateCard(
          vertical: true,
          icon: LucideIcons.circleAlert,
          title: 'External source unavailable',
          copy: 'A broken or unavailable external source should offer a retry or reporting path.',
          action: WaButton('Report source', kind: BtnKind.secondary, onTap: () {}),
        ),
        const StateCard(
          vertical: true,
          icon: LucideIcons.refreshCw,
          title: 'Loading resources',
          copy: 'Skeletons will preserve layout while real metadata is fetched.',
          loading: true,
        ),
      ]),
    ]);
  }
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) => const WaPage(children: [
        StateCard(
          icon: LucideIcons.circleAlert,
          title: 'This page is not available',
          copy: 'The link may be outdated or outside the current prototype scope.',
          action: WaButton('Return to overview', to: '/'),
        ),
      ]);
}
