import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class DirectoryPage extends StatefulWidget {
  const DirectoryPage({super.key, required this.type});
  final String type;

  @override
  State<DirectoryPage> createState() => _DirectoryPageState();
}

class _DirectoryPageState extends State<DirectoryPage> {
  static const _titles = {'courts': 'Courts directory', 'judges': 'Judicial profiles', 'firms': 'Law firm directory'};
  int _selected = 0;

  String get _type => _titles.containsKey(widget.type) ? widget.type : 'courts';

  @override
  Widget build(BuildContext context) {
    final bp = Bp.of(context);
    final type = _type;
    final records = directoryRecords[type]!;
    final selected = records[_selected.clamp(0, records.length - 1)];
    final isFirm = type == 'firms';
    final listIcon = switch (type) { 'courts' => LucideIcons.building2, 'judges' => LucideIcons.gavel, _ => LucideIcons.users };
    final portraitIcon = switch (type) { 'courts' => LucideIcons.building2, 'judges' => LucideIcons.userRound, _ => LucideIcons.users };

    final search = Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.fromLTRB(15, 8, 8, 8),
      decoration: BoxDecoration(color: C.paper, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(9)),
      child: Row(children: [
        const Icon(LucideIcons.search, size: 17, color: C.gold),
        const SizedBox(width: 10),
        Expanded(
          child: BareInput(
            height: 37,
            semanticLabel: 'Search $type',
            hint: 'Search ${isFirm ? 'by chambers name or location' : 'verified $type'}',
          ),
        ),
        const SizedBox(width: 10),
        const FilterButton('Filters'),
      ]),
    );

    final list = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (var i = 0; i < records.length; i++) ...[
        if (i > 0) const SizedBox(height: 7),
        Hover(
          onTap: () => setState(() => _selected = i),
          builder: (context, _) {
            final active = records[i].id == selected.id;
            return Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: C.paper,
                border: Border.all(color: active ? C.gold : C.line),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Stack(children: [
                Container(
                  constraints: const BoxConstraints(minHeight: 90),
                  padding: const EdgeInsets.all(15),
                  child: Row(children: [
                    ResultIcon(listIcon),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(records[i].title, style: sans(.7, weight: FontWeight.w700)),
                        const SizedBox(height: 5),
                        Text(records[i].subtitle, style: sans(.59, color: C.muted)),
                      ]),
                    ),
                    const SizedBox(width: 13),
                    const Icon(LucideIcons.chevronRight, size: 14, color: C.muted),
                  ]),
                ),
                if (active) const Positioned(left: 0, top: 0, bottom: 0, child: SizedBox(width: 3, child: ColoredBox(color: C.gold))),
              ]),
            );
          },
        ),
      ],
    ]);

    final chamber = chambers[0];
    final detail = Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: C.paper, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(color: Color(0xFFF3ECDC), shape: BoxShape.circle),
          child: Icon(portraitIcon, size: 32, color: C.gold),
        ),
        const SizedBox(height: 18),
        DemoBadge(isFirm ? 'Supplied chambers spreadsheet' : 'Verification required'),
        const SizedBox(height: 13),
        Text(selected.title, style: serif(1.5)),
        const SizedBox(height: 6),
        Text(selected.subtitle, style: sans(.7, color: C.muted, height: 1.65)),
        SourceNotice(compact: true, icon: LucideIcons.shieldCheck, title: 'Source-aware record', text: selected.detail),
        const SizedBox(height: 14),
        if (isFirm) ...[
          DlRow('Postal address', chamber.postalAddress),
          DlRow('Phone', chamber.phone),
          DlRow('Email', chamber.email),
          DlRow('Website', '',
              valueWidget: TextLink('Open website', onTap: () => openExternal(chamber.website), style: sans(.61))),
          DlRow('Source', chamber.source),
        ] else ...[
          const DlRow('Public source', 'Not supplied'),
          const DlRow('Last checked', 'Not available'),
          const DlRow('Contact details', 'Not available'),
        ],
        const SizedBox(height: 14),
        const WaButton('Report a record issue',
            kind: BtnKind.secondary, leading: LucideIcons.messageSquareWarning, to: '/help?report=directory'),
      ]),
    );

    return WaPage(children: [
      Breadcrumbs([('Overview', '/'), ('Directories', null), (_titles[type]!, null)]),
      PageHeader(
        eyebrow: 'Source-aware directory',
        title: _titles[type]!,
        description: isFirm
            ? 'The supplied spreadsheet contains one complete chambers record. It is shown with source context and is not presented as an exhaustive register.'
            : 'Illustrative layout only. No contacts, biographies, locations, affiliations, or exhaustive coverage are claimed.',
      ),
      search,
      if (bp.le768)
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [list, const SizedBox(height: 10), detail])
      else
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(flex: 90, child: Align(alignment: Alignment.topCenter, child: list)),
            const SizedBox(width: 10),
            Expanded(flex: 110, child: detail),
          ]),
        ),
    ]);
  }
}

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  static const _tabs = ['Account', 'Study preferences', 'Privacy & security', 'Accessibility', 'Subscription'];
  String _tab = 'Account';
  bool _reduceMotion = false;
  bool _comfortable = true;

  Widget _settingRow(String title, String copy, {Widget? trailing}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: C.line))),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: sans(.7, weight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(copy, style: sans(.62, color: C.muted, height: 1.65)),
            ]),
          ),
          if (trailing != null) ...[const SizedBox(width: 30), trailing],
        ]),
      );

  Widget _switch(bool value, ValueChanged<bool> onChanged) => SizedBox(
        width: 39,
        height: 22,
        child: Transform.scale(
          scale: 1.15,
          child: Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            activeColor: C.gold,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
      );

  Widget _tabContent() {
    final app = AppScope.read(context);
    switch (_tab) {
      case 'Account':
        return FormStack(children: [
          const FieldLabel('Display name', child: WaTextField(initialValue: 'Akua K.')),
          FieldLabel('Role',
              child: WaSelect(
                options: plainOptions(const [
                  'Law Student',
                  'Pre-Bar / Legal Practice Training Student',
                  'Legal Professional / Researcher',
                  'Lecturer / Institution',
                  'Other',
                ]),
                value: 'Law Student',
              )),
          FitLeft(child: WaButton('Save changes', onTap: () => app.showToast('Account changes saved for this visit.'))),
        ]);
      case 'Study preferences':
        return FormStack(children: [
          FieldLabel('Current focus',
              child: WaSelect(
                  options: plainOptions(const ['Course learning', 'Exam preparation', 'Legal research', 'Continuing reference']))),
          FieldLabel('Institution, if relevant',
              child: WaSelect(options: [
                ('', 'Not applicable / prefer not to say'),
                for (final institution in accreditedInstitutions) (institution.name, institution.name),
              ])),
          Text(
            'Institution list from the supplied report, stated at October 2026. Verify current accreditation with GLC and GTEC.',
            style: sans(.67, color: C.muted, height: 1.65),
          ),
          FitLeft(child: WaButton('Save preferences', onTap: () => app.showToast('Study preferences saved for this visit.'))),
        ]);
      case 'Privacy & security':
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _settingRow('Private study activity', 'Your reading progress, notes, and practice activity are private by default.'),
          _settingRow('Prototype storage', 'Changes exist only during this browser visit. No backend account is connected.'),
        ]);
      default:
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _settingRow('Reduce motion', 'Your system preference is respected automatically.',
              trailing: _switch(_reduceMotion, (v) => setState(() => _reduceMotion = v))),
          _settingRow('Comfortable reading size', 'Legal text uses a larger base size and focused measure.',
              trailing: _switch(_comfortable, (v) => setState(() => _comfortable = v))),
        ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bp = Bp.of(context);

    Widget tabButton(String item) {
      final active = _tab == item;
      return Hover(
        onTap: () => setState(() => _tab = item),
        builder: (context, _) => Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: active ? C.paper2 : Colors.transparent, borderRadius: BorderRadius.circular(7)),
          child: Row(
            mainAxisSize: bp.le768 ? MainAxisSize.min : MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item, style: sans(.64, weight: active ? FontWeight.w700 : FontWeight.w400, color: active ? C.ink : C.muted)),
              Icon(LucideIcons.chevronRight, size: 13, color: active ? C.ink : C.muted),
            ],
          ),
        ),
      );
    }

    final aside = Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(color: C.paper, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(10)),
      child: bp.le768
          ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [for (final t in _tabs) tabButton(t)]))
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final t in _tabs) tabButton(t)]),
    );

    final section = Panel(
      minHeight: 500,
      padding: const EdgeInsets.all(30),
      child: _tab == 'Subscription'
          ? const SubscriptionPanel()
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Eyebrow(_tab),
              const SizedBox(height: 8),
              Text(_tab, style: serif(1.45)),
              const SizedBox(height: 24),
              KeyedSubtree(key: ValueKey(_tab), child: _tabContent()),
            ]),
    );

    return WaPage(children: [
      const Breadcrumbs([('Overview', '/'), ('Account & subscription', null)]),
      const PageHeader(
        eyebrow: 'Account',
        title: 'Your workspace and plan.',
        description: 'Pricing, payment methods, renewal terms, and cancellation terms remain placeholders until confirmed.',
      ),
      if (bp.le768)
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [aside, const SizedBox(height: 12), section])
      else
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 225, child: aside),
          const SizedBox(width: 12),
          Expanded(child: section),
        ]),
    ]);
  }
}

class SubscriptionPanel extends StatelessWidget {
  const SubscriptionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final bp = Bp.of(context);
    Widget plan(String tag, String title, String price, String copy, String button) => Container(
          constraints: BoxConstraints(minHeight: bp.le1180 ? 210 : 265),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: C.bg, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(9)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(tag, style: mono(.55, color: C.gold)),
            const SizedBox(height: 16),
            Text(title, style: serif(1.1)),
            const SizedBox(height: 9),
            Text(price, style: serif(1.25)),
            Text(copy, style: sans(.61, color: C.muted, height: 1.65)),
            const Spacer(),
            WaButton(button, kind: BtnKind.secondary, disabled: true, fullWidth: true),
          ]),
        );

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Eyebrow('Subscription'),
      const SizedBox(height: 8),
      Text('Choose a plan when terms are confirmed.', style: serif(1.45)),
      const SizedBox(height: 24),
      Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF1D9),
          border: Border.all(color: const Color(0xFFDEC98C)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(LucideIcons.clock3, size: 17, color: Color(0xFF6F551C)),
          const SizedBox(width: 11),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Prototype subscription status: pending',
                  style: sans(.66, weight: FontWeight.w700, color: const Color(0xFF6F551C))),
              const SizedBox(height: 3),
              Text('No payment method, renewal date, or billing history is connected.',
                  style: sans(.6, color: C.muted, height: 1.65)),
            ]),
          ),
        ]),
      ),
      GridCols(cols: bp.le1180 ? 1 : 3, gap: 8, children: [
        plan('FREE ACCESS', '3 months', 'GH₵ 0', 'Current brief concept. Final terms not supplied.', 'Prototype plan'),
        plan('MONTHLY', 'Monthly access', 'GH₵ [X]', 'Price and payment terms are not supplied.', 'Not yet available'),
        plan('YEARLY', 'Yearly access', 'GH₵ [X]', 'No savings or renewal terms are claimed.', 'Not yet available'),
      ]),
      Text('Payment methods will appear only after an actual integration is confirmed.',
          style: sans(.67, color: C.muted, height: 1.65)),
    ]);
  }
}

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  static const _topics = [
    'How source labels work',
    'Saving to your reading list',
    'Using the study planner',
    'Understanding legal status labels',
  ];
  int _open = 0;
  bool _reported = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final bp = Bp.of(context);

    final topics = Panel(
      padding: const EdgeInsets.all(26),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Help topics', style: serif(1.25)),
        for (var i = 0; i < _topics.length; i++)
          Container(
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: C.line))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Semantics(
                expanded: _open == i,
                button: true,
                child: Hover(
                  onTap: () => setState(() => _open = _open == i ? -1 : i),
                  builder: (context, _) => Container(
                    constraints: const BoxConstraints(minHeight: 58),
                    color: Colors.transparent,
                    child: Row(children: [
                      Expanded(child: Text(_topics[i], style: sans(.66))),
                      const Icon(LucideIcons.chevronDown, size: 15, color: C.ink),
                    ]),
                  ),
                ),
              ),
              if (_open == i)
                Padding(
                  padding: const EdgeInsets.only(bottom: 17),
                  child: Text(
                    'MMRA distinguishes primary law, editorial explanation, study resources, and external sources. Always check the underlying authority and available source metadata.',
                    style: sans(.63, color: C.muted, height: 1.55),
                  ),
                ),
            ]),
          ),
      ]),
    );

    final report = Panel(
      padding: const EdgeInsets.all(26),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Eyebrow('Report content'),
        Text('Report a citation or metadata issue', style: serif(1.25)),
        if (_reported)
          ReportSuccess(
            copy: 'No backend is connected, so this report was not transmitted. The confirmation demonstrates the intended product state.',
            action: WaButton('Submit another', kind: BtnKind.secondary, onTap: () => setState(() => _reported = false)),
          )
        else
          Form(
            key: _formKey,
            child: FormStack(children: [
              FieldLabel('Issue category',
                  child: WaSelect(
                    options: [
                      ('', 'Choose a category'),
                      ...plainOptions(const ['Citation', 'Legal status', 'Source link', 'Directory record', 'Other metadata']),
                    ],
                    validator: requiredValidator,
                  )),
              const FieldLabel('Reference link or item',
                  child: WaTextField(hint: 'Paste an MMRA link or enter a title', validator: requiredValidator)),
              const FieldLabel('What should we check?',
                  child: WaTextField(
                    hint: 'Describe the possible issue without including private or sensitive information.',
                    multiline: true,
                    validator: requiredValidator,
                  )),
              FitLeft(
                child: WaButton('Submit prototype report', onTap: () {
                  if (_formKey.currentState!.validate()) setState(() => _reported = true);
                }),
              ),
            ]),
          ),
      ]),
    );

    return WaPage(children: [
      const Breadcrumbs([('Overview', '/'), ('Help & feedback', null)]),
      const PageHeader(
        eyebrow: 'Help & feedback',
        title: 'Find help or flag a source issue.',
        description: 'Prototype submissions are confirmed locally and are not sent to a support backend.',
      ),
      if (bp.le768)
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [topics, const SizedBox(height: 10), report])
      else
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(flex: 80, child: topics),
            const SizedBox(width: 10),
            Expanded(flex: 120, child: report),
          ]),
        ),
      const SizedBox(height: 35),
      Text('Product states', style: serif(1.3)),
      GridCols(
        cols: bp.le768 ? 1 : (bp.le1024 ? 2 : 3),
        children: const [
          StateCard(
            vertical: true,
            icon: LucideIcons.refreshCw,
            title: 'Network error',
            copy: 'We could not load this content. Check your connection and try again.',
            action: WaButton('Retry', kind: BtnKind.secondary),
          ),
          StateCard(
            vertical: true,
            icon: LucideIcons.lockKeyhole,
            title: 'Restricted resource',
            copy: 'This material is unavailable under the current access conditions.',
          ),
          StateCard(
            vertical: true,
            icon: LucideIcons.circleAlert,
            title: 'Status not verified',
            copy: 'Check the official source before relying on this legal-status record.',
          ),
        ],
      ),
    ]);
  }
}
