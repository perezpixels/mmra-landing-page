import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/common.dart';

const _question =
    'A supplier agrees to deliver goods for an event. After an unforeseen order, the event cannot proceed. Identify the relevant issues and explain how you would structure your analysis.';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bp = Bp.of(context);
    return WaPage(children: [
      const Breadcrumbs([('Overview', '/'), ('Courses & study', null)]),
      const PageHeader(
        eyebrow: 'Courses & study',
        title: 'Build understanding from source to application.',
        description: 'Course pathways are illustrative and do not imply a shared syllabus across institutions.',
        action: WaButton('Open study planner', kind: BtnKind.secondary, leading: LucideIcons.calendarDays, to: '/planner'),
      ),
      GridCols(
        cols: bp.le520 ? 1 : (bp.le1024 ? 2 : 3),
        children: [
          for (var i = 0; i < courses.length; i++) _CourseCard(courses[i], i),
        ],
      ),
    ]);
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard(this.course, this.index);
  final Course course;
  final int index;

  @override
  Widget build(BuildContext context) {
    final small = sans(.54, color: C.muted);
    return Hover(
      onTap: () => context.go('/courses/${course.id}'),
      builder: (context, hovered) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, hovered ? -3 : 0, 0),
        constraints: const BoxConstraints(minHeight: 260),
        padding: const EdgeInsets.all(23),
        decoration: BoxDecoration(
          color: C.paper,
          border: Border.all(color: hovered ? C.gold : C.line),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text((index + 1).toString().padLeft(2, '0'), style: mono(.6, color: C.gold)),
          ),
          const SizedBox(height: 25),
          const Icon(LucideIcons.bookOpen, size: 25, color: C.gold),
          const SizedBox(height: 15),
          Text(course.title, style: serif(1.25)),
          const SizedBox(height: 5),
          Text('${course.topics} illustrative topics', style: sans(.62, color: C.muted, height: 1.65)),
          const SizedBox(height: 22),
          const Spacer(),
          WaProgress(course.progress.toDouble()),
          const SizedBox(height: 9),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${course.progress}% demo progress', style: small),
            const SizedBox(width: 10),
            Expanded(child: Text('Next: ${course.next}', textAlign: TextAlign.right, style: small)),
          ]),
        ]),
      ),
    );
  }
}

class CourseDetailPage extends StatelessWidget {
  const CourseDetailPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final bp = Bp.of(context);
    final app = AppScope.read(context);
    final course = courses.firstWhere((item) => item.id == id, orElse: () => courses[0]);
    final heroLabel = sans(.6, color: const Color(0xFF9D978B));
    final heroValue = serif(1.2, color: Colors.white);

    Widget cell(List<Widget> children, {required bool last}) => Container(
          constraints: BoxConstraints(minHeight: bp.le768 ? 110 : 145),
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            border: last
                ? null
                : bp.le768
                    ? const Border(bottom: BorderSide(color: Color(0xFF343027)))
                    : const Border(right: BorderSide(color: Color(0xFF343027))),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(height: 8), children[i]],
            ],
          ),
        );

    final cells = [
      cell([
        Text('Course progress', style: heroLabel),
        Text('${course.progress}%', style: heroValue),
        WaProgress(course.progress.toDouble(), track: const Color(0xFF343027)),
      ], last: false),
      cell([
        Text('Next topic', style: heroLabel),
        Text(course.next, style: heroValue),
        FitLeft(
          child: TextLink('Continue topic', to: '/topics/frustration', trailing: LucideIcons.arrowRight, style: sans(.63, color: C.goldLight)),
        ),
      ], last: false),
      cell([
        Text('Syllabus mapping', style: heroLabel),
        Text('Not supplied', style: heroValue),
        Text('No institution assumed', style: heroLabel),
      ], last: true),
    ];

    const topics = ['Formation and agreement', 'Terms and interpretation', 'Frustration of contract', 'Remedies', 'Third-party rights'];

    return WaPage(children: [
      Breadcrumbs([('Courses', '/courses'), (course.title, null)]),
      PageHeader(
        eyebrow: 'Course pathway · illustrative',
        title: course.title,
        description: 'Learn → Read authority → Study brief → Practise → Review.',
        action: WaButton('Add to study plan', leading: LucideIcons.plus, onTap: () {
          app.addPlan(type: 'Review a topic', title: course.next, date: 'Tomorrow', duration: '30 min');
        }),
      ),
      Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: C.dark, borderRadius: BorderRadius.circular(11)),
        child: bp.le768
            ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: cells)
            : IntrinsicHeight(
                child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final c in cells) Expanded(child: c)]),
              ),
      ),
      const SizedBox(height: 14),
      Panel(
        padding: const EdgeInsets.all(25),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const PanelTitle('Topics', trailing: DemoBadge('Illustrative sequence')),
          for (var i = 0; i < topics.length; i++)
            Hover(
              onTap: () => context.go('/topics/frustration'),
              builder: (context, _) {
                final complete = i < 2;
                final current = i == 2;
                return Container(
                  constraints: const BoxConstraints(minHeight: 72),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: C.line))),
                  child: Row(children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: complete ? C.green : (current ? C.goldLight : C.paper2),
                      ),
                      child: complete
                          ? const Icon(LucideIcons.check, size: 13, color: Colors.white)
                          : Text((i + 1).toString().padLeft(2, '0'),
                              style: mono(.58, color: current ? const Color(0xFF5F4818) : C.muted)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(topics[i], style: sans(.7, weight: FontWeight.w700)),
                        const SizedBox(height: 3),
                        Text(current ? 'Case · legal text · practice question' : 'Illustrative topic outline',
                            style: sans(.57, color: C.muted)),
                      ]),
                    ),
                    const SizedBox(width: 14),
                    const Icon(LucideIcons.chevronRight, size: 14, color: C.muted),
                  ]),
                );
              },
            ),
        ]),
      ),
    ]);
  }
}

class TopicPage extends StatelessWidget {
  const TopicPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bp = Bp.of(context);
    final app = AppScope.read(context);
    const steps = [
      ('01', 'Learn', 'Read the topic outline'),
      ('02', 'Authority', 'Open the illustrative case'),
      ('03', 'Legislation', 'Check connected legal text'),
      ('04', 'Practise', 'Attempt a problem question'),
      ('05', 'Review', 'Use feedback to revise'),
    ];

    Widget step(int index) {
      final (number, title, copy) = steps[index];
      final active = index == 0;
      return Container(
        width: bp.le768 ? 160 : null,
        constraints: const BoxConstraints(minHeight: 105),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFAF2DE) : null,
          border: Border(
            top: active ? const BorderSide(color: C.gold, width: 3) : BorderSide.none,
            right: index == steps.length - 1 ? BorderSide.none : const BorderSide(color: C.line),
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(number, style: mono(.55, color: C.gold)),
          const SizedBox(height: 5),
          const Spacer(),
          Text(title, style: sans(.68, weight: FontWeight.w700)),
          const SizedBox(height: 5),
          Text(copy, style: sans(.53, color: C.muted)),
        ]),
      );
    }

    final path = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: C.paper, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(10)),
      child: bp.le768
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: IntrinsicHeight(
                child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (var i = 0; i < steps.length; i++) step(i)]),
              ),
            )
          : IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                for (var i = 0; i < steps.length; i++) Expanded(child: step(i)),
              ]),
            ),
    );

    final body = sans(.74, color: C.muted, height: 1.7);
    final outline = Panel(
      padding: const EdgeInsets.all(25),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Eyebrow('Topic outline'),
        const SizedBox(height: 9),
        Text('When performance changes after formation', style: serif(1.35)),
        const SizedBox(height: 12),
        Text('This illustrative outline shows how educational explanation can be placed beside, but clearly distinguished from, primary legal sources.',
            style: body),
        const SizedBox(height: 25),
        Text('Key questions', style: serif(.95)),
        for (final item in [
          'Was there a supervening event?',
          'Did the agreement allocate the relevant risk?',
          'How did the event affect the promised performance?',
        ])
          Text(item, style: body),
        const SourceNotice(
          compact: true,
          icon: LucideIcons.fileCheck2,
          title: 'Study resource',
          text: 'Explanations require editorial review and source references before publication.',
        ),
      ]),
    );

    Widget material(IconData icon, String to, String label, String title, String note) => LinkRow(
          icon: icon,
          to: to,
          iconSize: 24,
          chevronSize: 14,
          gap: 13,
          padding: 15,
          showChevron: !bp.le520,
          body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SourceLabel(label),
            const SizedBox(height: 5),
            Text(title, style: sans(.68, weight: FontWeight.w700)),
            const SizedBox(height: 5),
            Text(note, style: mono(.57, color: C.muted)),
          ]),
        );

    final links = Panel(
      padding: const EdgeInsets.all(25),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Connected materials', style: serif(1.15)),
        material(LucideIcons.scale, '/cases/${illustrativeCase.id}', 'Primary source', illustrativeCase.title, illustrativeCase.reference),
        material(LucideIcons.fileText, '/library/${legislation[0].id}', 'Primary source', legislation[0].title, legislation[0].reference),
        material(LucideIcons.fileQuestion, '/practice', 'Study resource', 'Illustrative problem question', 'Practise application'),
      ]),
    );

    return WaPage(children: [
      const Breadcrumbs([('Courses', '/courses'), ('Law of Contract', '/courses/contract'), ('Frustration of contract', null)]),
      PageHeader(
        eyebrow: 'Topic · illustrative',
        title: 'Frustration of contract',
        description: 'Move from explanation to authority, then apply the principle in practice.',
        action: WaButton('Add to revision', kind: BtnKind.secondary, leading: LucideIcons.plus, onTap: () {
          app.addPlan(type: 'Review a topic', title: 'Frustration of contract', date: 'Tomorrow', duration: '30 min');
        }),
      ),
      path,
      const SizedBox(height: 13),
      GridCols(cols: bp.le768 ? 1 : 2, flex: const [115, 85], children: [outline, links]),
    ]);
  }
}

class PracticePage extends StatefulWidget {
  const PracticePage({super.key});

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  bool _started = false;
  bool _submitted = false;
  final _answer = TextEditingController();

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  Widget _browser() {
    final bp = Bp.of(context);
    const categories = ['All questions', 'LLB / University', 'Pre-Bar', 'Legal Practice Training'];
    Widget category(int index) {
      final active = index == 0;
      return Hover(
        onTap: () {},
        builder: (context, _) => Container(
          constraints: BoxConstraints(minHeight: 42, minWidth: bp.le768 ? 145 : 0),
          padding: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            color: active ? C.paper2 : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, mainAxisSize: bp.le768 ? MainAxisSize.min : MainAxisSize.max, children: [
            Text(categories[index],
                style: sans(.62, weight: active ? FontWeight.w600 : FontWeight.w400, color: active ? C.ink : C.muted)),
            const SizedBox(width: 10),
            Text(index == 0 ? '1' : '0', style: sans(.62, color: C.muted)),
          ]),
        ),
      );
    }

    final aside = Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(color: C.paper, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(10)),
      child: bp.le768
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [for (var i = 0; i < categories.length; i++) category(i)]),
            )
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
                child: Text('Category', style: sans(.66, weight: FontWeight.w700)),
              ),
              for (var i = 0; i < categories.length; i++) category(i),
            ]),
    );

    final meta = sans(.61, color: C.muted);
    final card = Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: C.paper, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(11)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
          const SourceLabel('Study resource'),
          Text('Illustrative · provenance not supplied', style: sans(.57, color: C.muted)),
        ]),
        const SizedBox(height: 18),
        Text('Problem question: unforeseen event and performance', style: serif(1.4)),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: Text(_question, style: reading(.9, color: C.muted, height: 1.75)),
        ),
        const SizedBox(height: 18),
        Wrap(spacing: 15, runSpacing: 8, children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(LucideIcons.clock3, size: 14, color: C.muted),
            const SizedBox(width: 5),
            Text('Suggested: 25 minutes', style: meta),
          ]),
          Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(LucideIcons.fileText, size: 14, color: C.muted),
            const SizedBox(width: 5),
            Text('Problem question', style: meta),
          ]),
        ]),
        const SizedBox(height: 18),
        WaButton('Start practice', trailing: LucideIcons.arrowRight, onTap: () => setState(() => _started = true)),
      ]),
    );

    final section = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const FilterBarFrame(marginTop: 0, children: [FilterButton('Course: Contract'), FilterButton('Topic: Frustration')]),
      card,
    ]);

    return bp.le768
        ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [aside, const SizedBox(height: 14), section])
        : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 220, child: aside),
            const SizedBox(width: 14),
            Expanded(child: section),
          ]);
  }

  Widget _session() {
    final bp = Bp.of(context);
    final app = AppScope.read(context);
    final words = _answer.text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

    final title = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Eyebrow('Illustrative practice'),
      const SizedBox(height: 6),
      Text('Frustration problem question', style: serif(2)),
    ]);
    final untimed = Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(LucideIcons.clock3, size: 15, color: C.muted),
      const SizedBox(width: 7),
      Text('Untimed prototype', style: sans(.64, color: C.muted)),
    ]);

    final question = Panel(
      radius: 12,
      padding: const EdgeInsets.all(27),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Question 1 of 1', style: mono(.59, color: C.gold)),
        const SizedBox(height: 15),
        Text('Problem question', style: serif(1)),
        const SizedBox(height: 15),
        Text(_question, style: reading(.92, color: C.muted, height: 1.75)),
        const SizedBox(height: 20),
        const NoteStrip(
          icon: LucideIcons.circleAlert,
          text: 'This question is created only to demonstrate interface behaviour. It is not a verified past paper.',
          fg: Color(0xFF715925),
          bg: Color(0xFFF7F0DD),
          gap: 8,
          radius: 7,
        ),
      ]),
    );

    final answer = Container(
      padding: const EdgeInsets.all(27),
      decoration: BoxDecoration(color: C.paper, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(11)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Your answer', style: sans(.7, weight: FontWeight.w700)),
        const SizedBox(height: 11),
        FocusWithin(
          builder: (context, focused) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: focused ? const [BoxShadow(color: C.focusRing, spreadRadius: 3)] : null,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: bp.le520 ? 260 : 310),
              child: TextField(
                controller: _answer,
                enabled: !_submitted,
                minLines: bp.le520 ? 8 : 10,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                onChanged: (_) => setState(() {}),
                style: sans(1, height: 1.65, color: _submitted ? C.muted : C.ink),
                decoration: fieldDecoration(
                  hint: 'Structure your response using issues, relevant rule, application, and conclusion…',
                  radius: 8,
                  size: 1,
                  fill: C.bg,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('$words words', style: sans(.61, color: C.muted)),
          if (!_submitted)
            WaButton(
              'Submit for demo feedback',
              disabled: _answer.text.trim().length < 20,
              onTap: () {
                setState(() => _submitted = true);
                app.setCompletedPractice(true);
              },
            )
          else
            Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(LucideIcons.check, size: 15, color: C.green),
              const SizedBox(width: 6),
              Text('Attempt submitted', style: sans(.61, weight: FontWeight.w700, color: C.green)),
            ]),
        ]),
      ]),
    );

    Widget feedbackCard(String title, String copy) => Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: const Color(0xA6FFFFFF),
            border: Border.all(color: const Color(0xFFC9DFD4)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: sans(.68, weight: FontWeight.w700)),
            Text(copy, style: sans(.63, color: C.muted, height: 1.55)),
          ]),
        );

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: bp.le520
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [title, const SizedBox(height: 12), untimed])
            : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Flexible(child: title), untimed]),
      ),
      if (bp.le768)
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [question, const SizedBox(height: 10), answer])
      else
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(flex: 85, child: question),
            const SizedBox(width: 10),
            Expanded(flex: 115, child: answer),
          ]),
        ),
      if (_submitted)
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: EdgeInsets.all(bp.le520 ? 21 : 30),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF6F1),
            border: Border.all(color: const Color(0xFFB9D7C8)),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              const CompleteMark(),
              const SizedBox(width: 15),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Eyebrow('Demo feedback'),
                  const SizedBox(height: 4),
                  Text('Review the structure, then return to the authority.', style: serif(1.35)),
                ]),
              ),
            ]),
            const SizedBox(height: 20),
            GridCols(cols: bp.le1024 ? 1 : 3, gap: 8, children: [
              feedbackCard('Issues', 'Identify formation, the supervening event, allocation of risk, effect on performance, and potential consequences.'),
              feedbackCard('Source discipline', 'Support each legal proposition with a verified authority. No score is calculated for this free-text prototype.'),
              feedbackCard('Next revision step', 'Return to the topic and compare your structure with the connected sources.'),
            ]),
            CardActions(children: [
              const WaButton('Review topic', to: '/topics/frustration'),
              WaButton('Open case brief', kind: BtnKind.secondary, to: '/cases/${illustrativeCase.id}'),
              WaButton('Add to revision', kind: BtnKind.quiet, onTap: () {
                app.addPlan(type: 'Review a topic', title: 'Frustration of contract', date: 'Tomorrow', duration: '20 min');
              }),
            ]),
          ]),
        ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (!_started) {
      return WaPage(children: [
        const Breadcrumbs([('Overview', '/'), ('Past questions & practice', null)]),
        const PageHeader(
          eyebrow: 'Past questions',
          title: 'Practise with clear provenance.',
          description: 'This question is illustrative. No institution, exam session, model answer, or marking guide is claimed.',
        ),
        _browser(),
      ]);
    }
    return WaPage(children: [
      const Breadcrumbs([('Past questions', '/practice'), ('Practice attempt', null)]),
      _session(),
    ]);
  }
}
