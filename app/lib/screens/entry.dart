import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data.dart';
import '../shell.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// CSS `radial-gradient(circle at X Y, a, b stop)` sized to the farthest corner.
Gradient _radial(Size size, Alignment center, Color from, Color to, double stop) {
  final cx = (center.x + 1) / 2 * size.width;
  final cy = (center.y + 1) / 2 * size.height;
  final far = [
    Offset(cx, cy).distance,
    Offset(size.width - cx, cy).distance,
    Offset(cx, size.height - cy).distance,
    Offset(size.width - cx, size.height - cy).distance,
  ].reduce(math.max);
  final shortest = math.max(1.0, size.shortestSide);
  return RadialGradient(center: center, radius: far / shortest, colors: [from, to], stops: [0, stop]);
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int step = 1;
  String role = '';
  final List<String> interests = [];
  String institution = '';
  String goal = 'Course learning';

  static const roles = [
    'Law Student',
    'Pre-Bar / Legal Practice Training Student',
    'Legal Professional / Researcher',
    'Lecturer / Institution',
    'Other',
  ];
  static const interestOptions = ['Case law', 'Legislation', 'Study materials', 'Past questions', 'Legal directory'];

  void _continue() {
    if (step < 3) {
      setState(() => step++);
    } else {
      context.go('/auth?mode=create');
    }
  }

  Widget _heading(String eyebrow, String title, String copy) {
    final bp = Bp.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Eyebrow(eyebrow),
      const SizedBox(height: 9),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Text(title, style: serif(bp.le520 ? 2 : 2.4, height: 1.1)),
      ),
      const SizedBox(height: 12),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 590),
        child: Text(copy, style: sans(.78, color: C.muted, height: 1.6)),
      ),
      const SizedBox(height: 27),
    ]);
  }

  Widget _choice(String label, bool selected, VoidCallback onTap, {bool compact = false}) {
    final bp = Bp.of(context);
    return Hover(
      onTap: onTap,
      builder: (context, hovered) => Container(
        constraints: BoxConstraints(minHeight: compact ? 54 : (bp.le520 ? 58 : 70)),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: hovered || selected ? const Color(0xFFFAF4E6) : Colors.white,
          border: Border.all(color: hovered || selected ? C.gold : C.line),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(children: [
          if (!compact) ...[const Icon(LucideIcons.userRound, size: 17, color: C.gold), const SizedBox(width: 11)],
          Expanded(child: Text(label, style: sans(.67))),
          if (selected) ...[const SizedBox(width: 11), const Icon(LucideIcons.check, size: 15, color: C.green)],
        ]),
      ),
    );
  }

  Widget _step() {
    final bp = Bp.of(context);
    final cols = bp.le520 ? 1 : 2;
    switch (step) {
      case 1:
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _heading('Welcome to MMRA', 'Set up your legal workspace.',
              'Choose the context that best fits your work. You can change this later in Settings.'),
          GridCols(
            cols: cols,
            gap: 8,
            children: [for (final item in roles) _choice(item, role == item, () => setState(() => role = item))],
          ),
          const SizedBox(height: 25),
        ]);
      case 2:
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _heading('Study context', 'Choose your current focus.',
              'Institution is optional. The list comes from the supplied October 2026 research report and should be checked against current GLC and GTEC records.'),
          FormStack(gap: 14, children: [
            FieldLabel('Study goal',
                child: WaSelect(
                  value: goal,
                  radius: 8,
                  verticalPadding: 15,
                  size: 1,
                  options: plainOptions(['Course learning', 'Exam preparation', 'Legal research', 'Continuing reference']),
                  onChanged: (v) => setState(() => goal = v ?? goal),
                )),
            FieldLabel('Institution, if relevant',
                child: WaSelect(
                  value: institution,
                  radius: 8,
                  verticalPadding: 15,
                  size: 1,
                  options: [
                    ('', 'Prefer not to say / not applicable'),
                    for (final item in accreditedInstitutions) (item.name, item.name),
                  ],
                  onChanged: (v) => setState(() => institution = v ?? ''),
                )),
          ]),
          const SizedBox(height: 24),
          const NoteStrip(
            icon: LucideIcons.circleAlert,
            text: 'Interim list stated at October 2026. Verify present accreditation directly with the regulators.',
            fg: Color(0xFF715925),
            bg: Color(0xFFFAF1D9),
            border: Color(0xFFDEC98C),
          ),
        ]);
      default:
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _heading('Your library', 'What would you like close at hand?',
              'Choose any areas you want MMRA to prioritize. These preferences can be changed later.'),
          GridCols(
            cols: cols,
            gap: 8,
            children: [
              for (final item in interestOptions)
                _choice(item, interests.contains(item),
                    () => setState(() => interests.contains(item) ? interests.remove(item) : interests.add(item)),
                    compact: true),
            ],
          ),
          const SizedBox(height: 25),
          NoteStrip(
            icon: LucideIcons.check,
            text: '',
            fg: const Color(0xFF315F47),
            bg: const Color(0xFFEDF6F0),
            border: const Color(0xFFC5DDCE),
            padding: const EdgeInsets.all(14),
            gap: 10,
            iconSize: 16,
            textWidget: Text.rich(TextSpan(children: [
              TextSpan(text: role, style: sans(.62, weight: FontWeight.w700, color: const Color(0xFF315F47))),
              TextSpan(
                text: ' · $goal${institution.isNotEmpty ? ' · $institution' : ''}',
                style: sans(.62, color: const Color(0xFF315F47)),
              ),
            ])),
          ),
        ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bp = Bp.of(context);
    final size = MediaQuery.sizeOf(context);
    return Material(
      child: Container(
        decoration: BoxDecoration(
          gradient: _radial(size, Alignment.topCenter, const Color(0xFF30291A), C.black, .48),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(bp.le520 ? 14 : 22),
          child: Column(children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: SizedBox(
                height: 55,
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Brand(color: Colors.white),
                  TextLink('Skip setup', to: '/auth?mode=create', style: sans(.68, color: const Color(0xFFC5BDA9))),
                ]),
              ),
            ),
            Container(
              constraints: const BoxConstraints(maxWidth: 720),
              margin: EdgeInsets.symmetric(vertical: bp.le520 ? 30 : 60),
              padding: bp.le520 ? const EdgeInsets.symmetric(vertical: 25, horizontal: 19) : const EdgeInsets.all(42),
              decoration: BoxDecoration(
                color: C.paper,
                border: Border.all(color: const Color(0xFF4A412F)),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Color(0x59000000), blurRadius: 100, offset: Offset(0, 30))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [
                  Text('Step $step of 3', style: sans(.61, color: C.muted)),
                  const SizedBox(width: 15),
                  Expanded(child: WaProgress(step * 33.33)),
                ]),
                const SizedBox(height: 40),
                _step(),
                Container(
                  margin: EdgeInsets.only(top: 28, left: bp.le520 ? -4 : -10, right: bp.le520 ? -4 : -10),
                  padding: EdgeInsets.fromLTRB(bp.le520 ? 4 : 10, 16, bp.le520 ? 4 : 10, 8),
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: C.line))),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    WaButton(
                      step == 1 ? 'Back to MMRA' : 'Back',
                      kind: BtnKind.quiet,
                      leading: LucideIcons.arrowLeft,
                      padH: bp.le520 ? 12 : 16,
                      onTap: () => step == 1 ? openLanding(context) : setState(() => step--),
                    ),
                    const SizedBox(width: 12),
                    WaButton(
                      step == 3 ? 'Create account' : 'Continue',
                      trailing: LucideIcons.arrowRight,
                      disabled: step == 1 && role.isEmpty,
                      minWidth: bp.le520 ? 130 : 150,
                      padH: bp.le520 ? 12 : 16,
                      shadow: const [BoxShadow(color: Color(0x24000000), blurRadius: 20, offset: Offset(0, 7))],
                      onTap: _continue,
                    ),
                  ]),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 35),
                  padding: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: C.line))),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(LucideIcons.lockKeyhole, size: 15, color: C.gold),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'MMRA uses study activity to show your progress and continue where you left off. Prototype data is not submitted to a backend.',
                        style: sans(.59, color: C.muted, height: 1.5),
                      ),
                    ),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.mode});
  final String mode;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();

  bool get create => widget.mode != 'signin';

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) context.go('/');
  }

  Widget _iconInput({required IconData icon, required String hint, required FormFieldValidator<String> validator, bool obscure = false, Iterable<String>? autofill, TextInputType? type}) {
    return FocusWithin(
      builder: (context, focused) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: focused ? const [BoxShadow(color: C.focusRing, spreadRadius: 3)] : null,
        ),
        child: WaTextField(
          hint: hint,
          obscure: obscure,
          validator: validator,
          autofillHints: autofill,
          keyboardType: type,
          radius: 8,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          prefix: Padding(
            padding: const EdgeInsets.only(left: 12, right: 9),
            child: Icon(icon, size: 16, color: C.gold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bp = Bp.of(context);
    final size = MediaQuery.sizeOf(context);
    final h1Size = math.min(rem(3.2), math.max(rem(2.1), size.width * .04));

    final brand = Builder(builder: (context) {
      final area = Size(bp.le768 ? size.width : size.width * 85 / 200, bp.le768 ? 230 : size.height);
      return Container(
        constraints: BoxConstraints(minHeight: bp.le768 ? 230 : size.height),
        padding: EdgeInsets.all(bp.le768 ? 35 : size.width * .1),
        decoration: BoxDecoration(
          gradient: _radial(area, const Alignment(-.6, -.6), const Color(0xFF3B311D), C.black, .58),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Brand(color: Colors.white),
            SizedBox(height: bp.le768 ? 25 : 55),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: bp.le768 ? 520 : 420),
              child: Text(
                'Find the authority. Understand the principle. Practise the application.',
                style: serif(bp.le768 ? 1.5 : 2.1, color: const Color(0xFFD0C8B8), height: 1.25),
              ),
            ),
            SizedBox(height: bp.le768 ? 22 : 35),
            TextLink(
              'Return to landing page',
              onTap: () => openLanding(context),
              leading: LucideIcons.arrowLeft,
              iconSize: 14,
              gap: 7,
              style: sans(.65, color: const Color(0xFFB7AE9D)),
            ),
          ],
        ),
      );
    });

    Widget tab(String label, String mode) {
      final active = widget.mode == mode || (mode == 'create' && create);
      return Hover(
        onTap: () => context.go('/auth?mode=$mode'),
        builder: (context, _) => Container(
          constraints: const BoxConstraints(minHeight: 44),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: active ? C.gold : Colors.transparent, width: 2)),
          ),
          child: Text(label, style: sans(.68, weight: FontWeight.w700, color: active ? C.ink : C.muted)),
        ),
      );
    }

    final card = Container(
      color: C.paper,
      constraints: BoxConstraints(minHeight: bp.le768 ? 0 : size.height),
      padding: bp.le768
          ? const EdgeInsets.symmetric(vertical: 45, horizontal: 28)
          : EdgeInsets.all(math.min(110, math.max(35, size.width * .08))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(create ? 'Start your three-month access' : 'Welcome back'),
          const SizedBox(height: 9),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Text(
              create ? 'Create your MMRA account.' : 'Sign in to your workspace.',
              style: serif(h1Size / 16, height: 1.08),
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              create
                  ? 'Continue into the interactive prototype. No backend account will be created.'
                  : 'Prototype sign-in accepts any validly formatted email and password.',
              style: sans(.76, color: C.muted, height: 1.6),
            ),
          ),
          const SizedBox(height: 25),
          Container(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: C.line))),
            child: Row(children: [tab('Create account', 'create'), const SizedBox(width: 20), tab('Sign in', 'signin')]),
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 530),
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: FormStack(children: [
                  if (create)
                    FieldLabel('Full name',
                        child: WaTextField(hint: 'Your name', validator: requiredValidator, autofillHints: const [AutofillHints.name])),
                  FieldLabel('Email address',
                      child: _iconInput(
                        icon: LucideIcons.mail,
                        hint: 'you@example.com',
                        type: TextInputType.emailAddress,
                        autofill: const [AutofillHints.email],
                        validator: (v) {
                          final value = v?.trim() ?? '';
                          if (value.isEmpty) return 'Please fill out this field.';
                          if (!RegExp(r'^[^@\s]+@[^@\s]+$').hasMatch(value)) return 'Please include an "@" in the email address.';
                          return null;
                        },
                      )),
                  FieldLabel('Password',
                      child: _iconInput(
                        icon: LucideIcons.keyRound,
                        hint: 'At least 8 characters',
                        obscure: true,
                        autofill: [create ? AutofillHints.newPassword : AutofillHints.password],
                        validator: (v) {
                          final value = v ?? '';
                          if (value.isEmpty) return 'Please fill out this field.';
                          if (value.length < 8) return 'Please use at least 8 characters.';
                          return null;
                        },
                      )),
                  if (create)
                    FormField<bool>(
                      initialValue: false,
                      validator: (v) => v == true ? null : 'Please tick this box if you want to proceed.',
                      builder: (field) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: Checkbox(
                              value: field.value,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              onChanged: (v) => field.didChange(v),
                            ),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => field.didChange(!(field.value ?? false)),
                              child: Text('I agree to the prototype Terms and Privacy notice.', style: sans(.64, height: 1.5)),
                            ),
                          ),
                        ]),
                        if (field.hasError) ...[
                          const SizedBox(height: 4),
                          Text(field.errorText!, style: sans(.58, color: C.red)),
                        ],
                      ]),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: WaButton(
                      create ? 'Create account and enter MMRA' : 'Sign in',
                      trailing: LucideIcons.arrowRight,
                      fullWidth: true,
                      onTap: _submit,
                    ),
                  ),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 22),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 530),
            child: NoteStrip(
              icon: LucideIcons.shieldCheck,
              iconColor: C.gold,
              text: 'Authentication is simulated locally for this prototype. Credentials are not sent or stored.',
              fg: C.muted,
              bg: const Color(0xFFF3F0E8),
              size: .58,
            ),
          ),
        ],
      ),
    );

    return Material(
      color: C.black,
      child: SingleChildScrollView(
        child: bp.le768
            ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [brand, card])
            : IntrinsicHeight(
                child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Expanded(flex: 85, child: brand),
                  Expanded(flex: 115, child: card),
                ]),
              ),
      ),
    );
  }
}
