import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/common.dart';

const _readerText = Color(0xFF4B4943);

TextStyle readerParagraph(BuildContext context) =>
    reading(Bp.of(context).le520 ? .95 : 1.02, color: _readerText, height: 1.85);

TextStyle get readerLead => reading(1.14, color: _readerText, height: 1.85);

/// `.wa-results-head`
class ResultsHead extends StatelessWidget {
  const ResultsHead({super.key, required this.title, required this.subtitle, this.trailing, this.top = 26});
  final String title;
  final String subtitle;
  final Widget? trailing;
  final double top;

  @override
  Widget build(BuildContext context) {
    final bp = Bp.of(context);
    final text = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: serif(1.25)),
      const SizedBox(height: 3),
      Text(subtitle, style: sans(.66, color: C.muted, height: 1.65)),
    ]);
    return Padding(
      padding: EdgeInsets.only(top: top, bottom: 13),
      child: bp.le520
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [text, if (trailing != null) ...[const SizedBox(height: 20), trailing!]])
          : Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(child: text),
              if (trailing != null) ...[const SizedBox(width: 20), trailing!],
            ]),
    );
  }
}

/// `.wa-document-header`
class DocumentHeader extends StatelessWidget {
  const DocumentHeader({super.key, required this.labels, required this.title, required this.reference, required this.meta, required this.actions});
  final List<Widget> labels;
  final String title;
  final String reference;
  final String meta;

  /// Built with `expand` so actions can stretch on small screens.
  final List<Widget> Function(bool expand) actions;

  @override
  Widget build(BuildContext context) {
    final bp = Bp.of(context);
    final left = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 850),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 7, runSpacing: 7, crossAxisAlignment: WrapCrossAlignment.center, children: labels),
        const SizedBox(height: 7),
        PageTitle(title),
        const SizedBox(height: 9),
        Text(reference, style: mono(.67, color: const Color(0xFF705820))),
        const SizedBox(height: 8),
        Text(meta, style: sans(.72, color: C.muted, height: 1.65)),
      ]),
    );
    Widget actionsRow;
    if (bp.le350) {
      final items = actions(true);
      actionsRow = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        for (var i = 0; i < items.length; i++) ...[if (i > 0) const SizedBox(height: 8), items[i]],
      ]);
    } else if (bp.le768) {
      final items = actions(true);
      actionsRow = Row(children: [
        for (var i = 0; i < items.length; i++) ...[if (i > 0) const SizedBox(width: 8), Expanded(child: items[i])],
      ]);
    } else {
      final items = actions(false);
      actionsRow = Row(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 0; i < items.length; i++) ...[if (i > 0) const SizedBox(width: 8), items[i]],
      ]);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 23),
      child: bp.le768
          ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [left, const SizedBox(height: 30), actionsRow])
          : Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Flexible(child: left),
              const SizedBox(width: 30),
              actionsRow,
            ]),
    );
  }
}

class TocEntry {
  const TocEntry(this.label, this.target);
  final String label;
  final GlobalKey target;
}

class Toc extends StatelessWidget {
  const Toc({super.key, required this.title, required this.entries});
  final String title;
  final List<TocEntry> entries;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(title, style: sans(.65, weight: FontWeight.w700)),
        const SizedBox(height: 10),
        for (final entry in entries) ...[
          const SizedBox(height: 4),
          Hover(
            onTap: () => scrollToKey(entry.target),
            builder: (context, hovered) => Container(
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 9),
              decoration: BoxDecoration(border: Border(left: BorderSide(color: hovered ? C.gold : C.line))),
              child: Text(entry.label, style: sans(.62, color: hovered ? C.gold : C.muted)),
            ),
          ),
        ],
      ]);
}

/// `.wa-reader-layout`: TOC | reader | related panel.
class ReaderLayout extends StatelessWidget {
  const ReaderLayout({super.key, required this.toc, required this.article, required this.related});
  final Widget toc;
  final Widget article;
  final Widget related;

  @override
  Widget build(BuildContext context) {
    final bp = Bp.of(context);
    Widget body;
    if (bp.le768) {
      body = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [article, const SizedBox(height: 12), related]);
    } else if (bp.le1024) {
      body = Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: article),
        const SizedBox(width: 20),
        SizedBox(width: 240, child: related),
      ]);
    } else if (bp.le1180) {
      body = Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 135, child: toc),
        const SizedBox(width: 20),
        Expanded(child: article),
        const SizedBox(width: 20),
        SizedBox(width: 220, child: related),
      ]);
    } else {
      body = Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 170, child: toc),
        const SizedBox(width: 35),
        Flexible(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 730), child: article)),
        const SizedBox(width: 35),
        SizedBox(width: 250, child: related),
      ]);
    }
    return Padding(padding: const EdgeInsets.only(top: 35), child: body);
  }
}

class ReaderSection {
  const ReaderSection(this.children, {this.key});
  final List<Widget> children;
  final GlobalKey? key;
}

/// `.wa-legal-reader` article with bordered sections.
class LegalReader extends StatelessWidget {
  const LegalReader({super.key, required this.sections});
  final List<ReaderSection> sections;

  @override
  Widget build(BuildContext context) {
    final bp = Bp.of(context);
    final padding = bp.le350
        ? const EdgeInsets.symmetric(vertical: 22, horizontal: 15)
        : bp.le520
            ? const EdgeInsets.symmetric(vertical: 25, horizontal: 20)
            : bp.le1180
                ? const EdgeInsets.all(35)
                : const EdgeInsets.symmetric(vertical: 42, horizontal: 55);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: C.paper,
        border: Border.all(color: C.line),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Color(0x0A261F13), blurRadius: 30, offset: Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        for (var i = 0; i < sections.length; i++)
          Container(
            key: sections[i].key,
            padding: EdgeInsets.only(top: i == 0 ? 0 : 30, bottom: 30),
            decoration: i == sections.length - 1
                ? null
                : const BoxDecoration(border: Border(bottom: BorderSide(color: C.line))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: sections[i].children),
          ),
      ]),
    );
  }
}

/// `h2` inside the legal reader (margin 7 0 14).
Widget readerHeading(String text) => Padding(
      padding: const EdgeInsets.only(top: 7, bottom: 14),
      child: Text(text, style: serif(1.45)),
    );

class RelatedPanel extends StatelessWidget {
  const RelatedPanel({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: C.paper,
          border: Border.all(color: C.line),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
      );
}

Widget relatedHeading(String text) => Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 16),
      child: Text(text, style: serif(1)),
    );

Widget relatedLink(IconData icon, String to, String title, String note) => LinkRow(
      icon: icon,
      to: to,
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: sans(.64, weight: FontWeight.w700)),
        const SizedBox(height: 3),
        Text(note, style: sans(.55, color: C.muted)),
      ]),
    );

Widget recordList(List<Widget> rows) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
    );

class CasesLibraryPage extends StatefulWidget {
  const CasesLibraryPage({super.key});

  @override
  State<CasesLibraryPage> createState() => _CasesLibraryPageState();
}

class _CasesLibraryPageState extends State<CasesLibraryPage> {
  String _view = 'Compact';

  @override
  Widget build(BuildContext context) {
    return WaPage(children: [
      const Breadcrumbs([('Overview', '/'), ('Legal research', null), ('Cases & judgments', null)]),
      const PageHeader(
        eyebrow: 'Primary legal sources',
        title: 'Cases & judgments',
        description: 'Search and inspect court decisions, citations, source metadata, and the available judgment text.',
        action: WaButton('Open case briefs', kind: BtnKind.secondary, leading: LucideIcons.bookOpen, to: '/briefs'),
      ),
      SearchFrame(
        input: const BareInput(
          hint: 'Search by case name, citation, court, judge, or legal topic',
          height: 41,
          semanticLabel: 'Search cases and judgments',
        ),
        button: WaButton('Search cases', onTap: () {}),
      ),
      FilterBarFrame(
        trailing: ViewToggle(
          options: const [('Compact', LucideIcons.layoutList), ('Comfortable', LucideIcons.bookOpen)],
          active: _view,
          onChanged: (value) => setState(() => _view = value),
        ),
        children: const [
          FilterButton('Court'),
          FilterButton('Decision year'),
          FilterButton('Judge'),
          FilterButton('Subject'),
        ],
      ),
      const SourceNotice(
        icon: LucideIcons.scale,
        title: 'Authority-first module',
        text: 'Records here represent primary legal sources. Editorial summaries are kept in the separate Case Briefs module.',
        margin: EdgeInsets.only(top: 3, bottom: 18),
      ),
      ResultsList(const [illustrativeCase], comfortable: _view == 'Comfortable'),
    ]);
  }
}

class BriefsLibraryPage extends StatelessWidget {
  const BriefsLibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bp = Bp.of(context);
    final brief = researchItems.firstWhere((item) => item.kind == 'Brief');
    const explainerFg = Color(0xFF67531F);

    final structure = Wrap(
      alignment: bp.le520 ? WrapAlignment.start : WrapAlignment.end,
      spacing: 5,
      runSpacing: 5,
      children: [
        for (final item in ['Facts', 'Issues', 'Holding', 'Ratio', 'Principles', 'Disposition'])
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 7),
            decoration: BoxDecoration(
              color: const Color(0x99FFFFFF),
              border: Border.all(color: const Color(0xFFDEC990)),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(item, style: sans(.53, color: const Color(0xFF705820))),
          ),
      ],
    );
    final explainerText = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Editorial, not primary law', style: sans(.69, weight: FontWeight.w700, color: explainerFg)),
      const SizedBox(height: 3),
      Text('Every brief is visually separated from the judgment and should link back to the underlying authority.',
          style: sans(.61, color: C.muted, height: 1.65)),
    ]);

    Widget section(String label, String value) => Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(color: C.paper2, borderRadius: BorderRadius.circular(7)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: mono(.52, color: C.gold)),
            const SizedBox(height: 6),
            Text(value, style: sans(.62, weight: FontWeight.w700)),
          ]),
        );

    final card = Container(
      padding: const EdgeInsets.all(27),
      decoration: BoxDecoration(color: C.paper, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(11)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 7, runSpacing: 7, crossAxisAlignment: WrapCrossAlignment.center, children: [
          const SourceLabel('Editorial brief'),
          Text('Last reviewed [date]', style: sans(.58, color: C.muted)),
        ]),
        const SizedBox(height: 18),
        Text(brief.title, style: serif(1.4)),
        const SizedBox(height: 7),
        Text(brief.reference, style: mono(.65, color: const Color(0xFF705820))),
        Text(brief.excerpt, style: sans(.72, color: C.muted, height: 1.65)),
        const SizedBox(height: 20),
        GridCols(cols: bp.le520 ? 1 : 2, gap: 8, children: [
          section('ISSUE', 'Effect of a supervening event'),
          section('PRINCIPLE', 'Verify against the full judgment'),
        ]),
        CardActions(children: [
          WaButton('Read structured brief', trailing: LucideIcons.arrowRight, to: '/briefs/${brief.id}'),
          SaveButton(brief, label: true, expand: bp.le520),
        ]),
      ]),
    );

    return WaPage(children: [
      const Breadcrumbs([('Overview', '/'), ('Legal research', null), ('Case briefs', null)]),
      const PageHeader(
        eyebrow: 'Editorial legal content',
        title: 'Case briefs',
        description: 'Understand facts, issues, holding, reasoning, principles, and disposition before checking the full authority.',
        action: WaButton('Open cases & judgments', kind: BtnKind.secondary, leading: LucideIcons.scale, to: '/cases'),
      ),
      SearchFrame(
        input: const BareInput(
          hint: 'Search briefs by course, topic, case, court, or principle',
          height: 41,
          semanticLabel: 'Search editorial case briefs',
        ),
        button: WaButton('Search briefs', onTap: () {}),
      ),
      Container(
        margin: const EdgeInsets.only(top: 16, bottom: 22),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7EFD9),
          border: Border.all(color: const Color(0xFFDDCA98)),
          borderRadius: BorderRadius.circular(9),
        ),
        child: bp.le520
            ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [
                  const Icon(LucideIcons.fileCheck2, size: 20, color: explainerFg),
                  const SizedBox(width: 15),
                  Expanded(child: explainerText),
                ]),
                const SizedBox(height: 15),
                structure,
              ])
            : Row(children: [
                const Icon(LucideIcons.fileCheck2, size: 20, color: explainerFg),
                const SizedBox(width: 15),
                Expanded(child: explainerText),
                const SizedBox(width: 15),
                ConstrainedBox(constraints: const BoxConstraints(maxWidth: 360), child: structure),
              ]),
      ),
      GridCols(cols: bp.le768 ? 1 : 2, flex: const [115, 85], children: [
        card,
        const StateCard(
          icon: LucideIcons.bookOpen,
          title: 'More briefs will appear here',
          copy: 'No additional verified or editor-reviewed briefs were supplied for this prototype.',
        ),
      ]),
    ]);
  }
}

class CaseDetailPage extends StatefulWidget {
  const CaseDetailPage({super.key, required this.briefModule});
  final bool briefModule;

  @override
  State<CaseDetailPage> createState() => _CaseDetailPageState();
}

class _CaseDetailPageState extends State<CaseDetailPage> {
  late String _tab = widget.briefModule ? 'brief' : 'judgment';
  final Map<String, GlobalKey> _keys = {};

  GlobalKey _key(String id) => _keys.putIfAbsent(id, GlobalKey.new);

  static const _briefToc = ['At a glance', 'Material facts', 'Issues', 'Decision', 'Reasoning', 'Legal principles', 'Disposition'];
  static const _briefSections = [
    ('Material facts', '[Illustrative facts] An unforeseen event affected performance of an agreement after formation.'),
    ('Issues', 'Whether the supervening event changed the obligation in a way recognised by the relevant legal principle.'),
    ('Decision', '[Illustrative holding] The prototype does not state a real court decision.'),
    ('Reasoning', 'The reasoning area separates the ratio from background commentary and links each proposition to the source passage when verified.'),
    ('Legal principles', 'A principle card would state the proposition narrowly, with citation and source context.'),
    ('Disposition', '[Order or disposition not supplied].'),
  ];

  String _slug(String text) => text.toLowerCase().replaceAll(' ', '-');

  Widget _tabButton(String id, String label, String chip) {
    final active = _tab == id;
    final fg = active ? C.ink : C.muted;
    return Semantics(
      selected: active,
      button: true,
      child: Hover(
        onTap: () => setState(() => _tab = id),
        builder: (context, _) => Container(
          constraints: const BoxConstraints(minHeight: 47),
          padding: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: active ? C.gold : Colors.transparent, width: 2)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(label, style: sans(.72, color: fg)),
            const SizedBox(width: 7),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
              decoration: BoxDecoration(color: C.paper2, borderRadius: BorderRadius.circular(4)),
              child: Text(chip, style: sans(.51, color: fg)),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _briefLayout() {
    final p = readerParagraph(context);
    return ReaderLayout(
      toc: Toc(title: 'On this page', entries: [for (final item in _briefToc) TocEntry(item, _key(_slug(item)))]),
      article: LegalReader(sections: [
        ReaderSection(key: _key('at-a-glance'), [
          const Eyebrow('At a glance'),
          readerHeading('Editorial case brief'),
          Text('This demonstration shows how a structured brief can help a reader orient themselves before checking the underlying authority.', style: p),
        ]),
        for (final (title, copy) in _briefSections)
          ReaderSection(key: _key(_slug(title)), [
            readerHeading(title),
            Text(copy, style: p),
            if (title == 'Legal principles')
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 22),
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 22),
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F0DF),
                  border: Border(left: BorderSide(color: C.gold, width: 3)),
                ),
                child: Text(
                  'Illustrative editorial explanation. Verify every proposition against the underlying judgment.',
                  style: reading(.9, color: const Color(0xFF5E4B23), height: 1.75),
                ),
              ),
          ]),
      ]),
      related: RelatedPanel(children: [
        const Eyebrow('Connected research'),
        relatedHeading('Follow the authority trail'),
        relatedLink(LucideIcons.fileText, '/library/${legislation[0].id}', legislation[0].title, legislation[0].reference),
        relatedLink(LucideIcons.graduationCap, '/courses/contract', 'Law of Contract', 'Frustration topic'),
        relatedLink(LucideIcons.fileQuestion, '/practice', 'Practice application', 'Illustrative problem'),
      ]),
    );
  }

  Widget _judgmentLayout() {
    final p = readerParagraph(context);
    return ReaderLayout(
      toc: Toc(title: 'Document sections', entries: [
        TocEntry('Source information', _key('judgment-intro')),
        TocEntry('Illustrative text', _key('judgment-body')),
      ]),
      article: LegalReader(sections: [
        ReaderSection(key: _key('judgment-intro'), [
          const Eyebrow('Primary source view'),
          readerHeading('Full judgment reader'),
          Text(
            'A licensed or publicly available judgment would be shown in this focused reading column with source metadata, paragraph navigation, and linked references.',
            style: readerLead,
          ),
        ]),
        ReaderSection(key: _key('judgment-body'), [
          readerHeading('Source text unavailable in prototype'),
          Text('The original judgment text has not been supplied. MMRA does not fabricate or reconstruct the authority.', style: p),
          SizedBox(
            width: double.infinity,
            child: StateCard(
              icon: LucideIcons.lockKeyhole,
              title: 'Source unavailable',
              copy: 'Add a verified or licensed source record before publishing full text.',
              copyStyle: reading(.67, color: _readerText, height: 1.55),
            ),
          ),
        ]),
      ]),
      related: RelatedPanel(children: [
        const FitLeft(child: SourceLabel('Primary source')),
        relatedHeading('Source details'),
        recordList(const [
          DlRow('Origin', 'Not supplied'),
          DlRow('Date checked', 'Not available'),
          DlRow('Access', 'Restricted in prototype'),
        ]),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bp = Bp.of(context);
    final module = widget.briefModule ? '/briefs' : '/cases';
    return WaPage(reader: true, children: [
      Breadcrumbs([
        ('Legal research', module),
        (widget.briefModule ? 'Case briefs' : 'Cases & judgments', module),
        (illustrativeCase.title, null),
      ]),
      DocumentHeader(
        labels: [
          SourceLabel(_tab == 'brief' ? 'Editorial brief' : 'Primary source'),
          const StatusTag('Illustrative record', icon: LucideIcons.circleAlert),
        ],
        title: illustrativeCase.title,
        reference: illustrativeCase.reference,
        meta: illustrativeCase.meta,
        actions: (expand) => [
          SaveButton(illustrativeCase, label: true, expand: expand),
          WaButton(
            'Copy citation',
            kind: BtnKind.secondary,
            fullWidth: expand,
            onTap: () => Clipboard.setData(ClipboardData(text: illustrativeCase.reference)),
          ),
        ],
      ),
      const SourceNotice(
        icon: LucideIcons.shieldCheck,
        title: 'Check the underlying authority.',
        text: 'This illustrative record is not verified legal content. The brief is editorial and does not replace the full judgment.',
      ),
      Container(
        margin: const EdgeInsets.only(top: 7),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: C.line))),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _tabButton('brief', 'Case brief', 'Editorial'),
            const SizedBox(width: 24),
            _tabButton('judgment', 'Full judgment', 'Primary source'),
          ]),
        ),
      ),
      if (_tab == 'brief') _briefLayout() else _judgmentLayout(),
      Container(
        margin: const EdgeInsets.only(top: 25),
        padding: const EdgeInsets.only(top: 20),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: C.line))),
        child: Flex(
          direction: bp.le520 ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: bp.le520 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextLink(
              'Report a citation or metadata issue',
              leading: LucideIcons.messageSquareWarning,
              iconSize: 14,
              gap: 7,
              style: sans(.62, color: C.muted),
              hoverColor: C.red,
              onTap: () => showReportDialog(context, illustrativeCase.title),
            ),
            if (bp.le520) const SizedBox(height: 12),
            Text('Personal notes are private in this prototype.', style: sans(.59, color: C.muted)),
          ],
        ),
      ),
    ]);
  }
}

void showReportDialog(BuildContext context, String item) {
  showWaModal(context, dismissible: true, builder: (_) => _ReportDialog(item: item));
}

class _ReportDialog extends StatefulWidget {
  const _ReportDialog({required this.item});
  final String item;

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    void close() => Navigator.of(context).pop();
    return ModalCard(
      eyebrow: 'Source quality',
      title: 'Report an issue',
      onClose: close,
      child: _sent
          ? ReportSuccess(
              copy: 'This demonstration does not send data to a backend.',
              action: FitLeft(child: WaButton('Done', onTap: close)),
            )
          : Form(
              key: _formKey,
              child: FormStack(children: [
                FieldLabel('Item', child: WaTextField(initialValue: widget.item, readOnly: true)),
                FieldLabel('Issue category',
                    child: WaSelect(options: plainOptions(['Citation or reference', 'Source metadata', 'Editorial content']))),
                FieldLabel('Details',
                    child: WaTextField(multiline: true, hint: 'What should the editorial team check?', validator: requiredValidator)),
                FitLeft(
                  child: WaButton('Submit prototype report', onTap: () {
                    if (_formKey.currentState?.validate() ?? false) setState(() => _sent = true);
                  }),
                ),
              ]),
            ),
    );
  }
}

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key, this.type});
  final String? type;

  @override
  Widget build(BuildContext context) {
    final bp = Bp.of(context);
    final instrument = RegExp(r'L\.I\.|C\.I\.|E\.I\.');
    final filtered = type == 'Bills'
        ? legislation.where((item) => item.reference.startsWith('Bill')).toList()
        : type == 'Instruments'
            ? legislation.where((item) => instrument.hasMatch(item.reference)).toList()
            : legislation;
    const types = [
      ('Constitution', 'Foundational text', LucideIcons.scale),
      ('Acts', 'Enacted legislation', LucideIcons.fileCheck2),
      ('Bills', 'Proposed, not enacted', LucideIcons.fileText),
      ('L.I.', 'Legislative instruments', LucideIcons.library),
      ('C.I.', 'Constitutional instruments', LucideIcons.library),
      ('E.I.', 'Executive instruments', LucideIcons.library),
    ];
    final cols = bp.le350 ? 1 : (bp.le768 ? 2 : (bp.le1180 ? 3 : 6));

    return WaPage(children: [
      const Breadcrumbs([('Overview', '/'), ('Ghana legal library', null)]),
      const PageHeader(
        eyebrow: 'Primary legal materials',
        title: 'Ghana legal library',
        description: 'Browse illustrative legal-text records by distinct document type. Verify source and status before relying on any record.',
      ),
      GridCols(cols: cols, gap: 8, children: [
        for (final (title, copy, icon) in types)
          Container(
            constraints: const BoxConstraints(minHeight: 118),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: C.paper, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(9)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(icon, size: 19, color: C.gold),
              const Spacer(),
              Text(title, style: serif(.9)),
              const SizedBox(height: 4),
              Text(copy, style: sans(.54, color: C.muted)),
            ]),
          ),
      ]),
      const InfoStrip(
        icon: LucideIcons.circleHelp,
        iconColor: C.gold,
        title: 'Acts, Bills, and instruments are different.',
        text: 'An Act is enacted legislation. A Bill is a proposal and is not law in force. L.I., C.I., and E.I. are kept as distinct instrument types.',
        fg: Color(0xFF4F4530),
        textColor: C.muted,
        bg: Color(0xFFF4EFE3),
        border: Color(0xFFDDD2B7),
        margin: EdgeInsets.only(top: 15, bottom: 27),
      ),
      ResultsHead(
        top: 0,
        title: type ?? 'Legal texts',
        subtitle: 'Illustrative records · legal status not verified',
        trailing: const FilterButton('Year & status'),
      ),
      ResultsList(filtered),
    ]);
  }
}

class LegalTextPage extends StatefulWidget {
  const LegalTextPage({super.key, required this.id});
  final String id;

  @override
  State<LegalTextPage> createState() => _LegalTextPageState();
}

class _LegalTextPageState extends State<LegalTextPage> {
  final _sectionQuery = TextEditingController();
  final _partKey = GlobalKey();
  final _sectionKey = GlobalKey();
  final _recordKey = GlobalKey();

  @override
  void dispose() {
    _sectionQuery.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = legislation.firstWhere((record) => record.id == widget.id, orElse: () => legislation[0]);
    final isBill = item.reference.startsWith('Bill');
    final p = readerParagraph(context);

    return WaPage(reader: true, children: [
      Breadcrumbs([('Legal library', '/library'), (item.title, null)]),
      DocumentHeader(
        labels: [
          const SourceLabel('Primary source'),
          StatusTag(isBill ? 'Proposed legislation — not enacted law' : 'Legal status not verified', bill: isBill),
        ],
        title: item.title,
        reference: item.reference,
        meta: item.meta,
        actions: (expand) => [
          SaveButton(item, label: true, expand: expand),
          WaButton(
            'Copy reference',
            kind: BtnKind.secondary,
            fullWidth: expand,
            onTap: () {
              Clipboard.setData(ClipboardData(text: item.reference));
              AppScope.read(context).showToast('Reference copied.');
            },
          ),
        ],
      ),
      const SourceNotice(
        warning: true,
        icon: LucideIcons.circleAlert,
        title: 'Check source and current status.',
        text: 'No official source, commencement date, amendment history, or currentness data has been supplied for this illustrative record.',
      ),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(color: C.paper, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          const Icon(LucideIcons.search, size: 16, color: C.gold),
          const SizedBox(width: 9),
          Expanded(
            child: BareInput(
              controller: _sectionQuery,
              hint: 'Search within this document',
              height: 35,
              onChanged: (_) => setState(() {}),
              semanticLabel: 'Search within document',
            ),
          ),
          const SizedBox(width: 9),
          Text(_sectionQuery.text.isNotEmpty ? '0 verified matches' : 'Section search', style: sans(.58, color: C.muted)),
        ]),
      ),
      ReaderLayout(
        toc: Toc(title: 'Table of contents', entries: [
          TocEntry('Part I · [Heading]', _partKey),
          TocEntry('Section [X]', _sectionKey),
          TocEntry('Source record', _recordKey),
        ]),
        article: LegalReader(sections: [
          ReaderSection(key: _partKey, [
            const Eyebrow('Part I'),
            readerHeading('[Verified heading required]'),
            Text('Full legal text is not included because no verified or licensed source document has been supplied.', style: readerLead),
          ]),
          ReaderSection(key: _sectionKey, [
            readerHeading('Section [X] · [Heading]'),
            Text('[Primary source text will appear here when an authorized source record is connected.]', style: p),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 22),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: C.paper2, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(8)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(LucideIcons.lockKeyhole, size: 18, color: C.muted),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Text unavailable', style: sans(.7, weight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('This prototype does not create or imply access to unsupplied source content.',
                        style: sans(.65, color: _readerText, height: 1.5)),
                  ]),
                ),
              ]),
            ),
          ]),
        ]),
        related: KeyedSubtree(
          key: _recordKey,
          child: RelatedPanel(children: [
            const Eyebrow('Document record'),
            recordList([
              DlRow('Document type', isBill ? 'Bill' : item.reference.split(' ')[0]),
              const DlRow('Issuing authority', 'Not available'),
              const DlRow('Effective date', 'Not available'),
              const DlRow('Official source', 'Not supplied'),
            ]),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text('Related, illustrative', style: serif(1)),
            ),
            relatedLink(LucideIcons.scale, '/cases/${illustrativeCase.id}', illustrativeCase.title, 'Relationship not verified'),
          ]),
        ),
      ),
    ]);
  }
}
