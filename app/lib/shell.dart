import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'state.dart';
import 'theme.dart';
import 'widgets/common.dart';

/// `Brand`: logo tile + MMRA wordmark, linking to the landing page.
class Brand extends StatelessWidget {
  const Brand({super.key, this.color = const Color(0xFFEEE9DC)});
  final Color color;

  @override
  Widget build(BuildContext context) => Semantics(
        link: true,
        label: 'MMRA landing page',
        child: Hover(
          onTap: () => openLanding(context),
          builder: (context, _) => Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 34,
              height: 34,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7)),
              child: Image.asset('assets/mmra-logo.png', fit: BoxFit.contain),
            ),
            const SizedBox(width: 10),
            Text('MMRA', style: serif(1, weight: FontWeight.w600, color: color, lsEm: .12)),
          ]),
        ),
      );
}

class _NavEntry {
  const _NavEntry(this.to, this.label, {this.icon, this.end = false});
  final String to;
  final String label;
  final IconData? icon;
  final bool end;
}

class _NavGroup {
  const _NavGroup(this.label, this.icon, this.links);
  final String label;
  final IconData icon;
  final List<_NavEntry> links;
}

const _primaryNav = [
  _NavEntry('/', 'Overview', icon: LucideIcons.house, end: true),
  _NavEntry('/search', 'Global search', icon: LucideIcons.search),
];

const _navGroups = [
  _NavGroup('Legal research', LucideIcons.scale, [
    _NavEntry('/cases', 'Cases & judgments'),
    _NavEntry('/briefs', 'Case briefs'),
    _NavEntry('/resources', 'Articles & commentary'),
  ]),
  _NavGroup('Ghana legal library', LucideIcons.library, [
    _NavEntry('/library', 'Constitution & Acts'),
    _NavEntry('/library?type=Bills', 'Bills'),
    _NavEntry('/library?type=Instruments', 'L.I. · C.I. · E.I.'),
  ]),
  _NavGroup('Courses & study', LucideIcons.graduationCap, [
    _NavEntry('/courses', 'My courses'),
    _NavEntry('/practice', 'Past questions'),
    _NavEntry('/planner', 'Study planner'),
  ]),
  _NavGroup('Directories', LucideIcons.building2, [
    _NavEntry('/directory/courts', 'Courts'),
    _NavEntry('/directory/judges', 'Judicial profiles'),
    _NavEntry('/directory/firms', 'Law firms'),
  ]),
];

const _bottomNav = [
  _NavEntry('/saved', 'Reading list', icon: LucideIcons.bookmark),
  _NavEntry('/account', 'Account & subscription', icon: LucideIcons.userRound),
  _NavEntry('/help', 'Help & feedback', icon: LucideIcons.circleHelp),
];

/// React Router `NavLink` matching: pathname only, prefix match unless `end`.
bool _isActive(_NavEntry entry, String path) {
  final target = Uri.parse(entry.to).path;
  if (entry.end || target == '/') return path == target;
  return path == target || path.startsWith('$target/');
}

class Sidebar extends StatefulWidget {
  const Sidebar({super.key, required this.width, required this.path, required this.drawerMode, required this.onClose});
  final double width;
  final String path;
  final bool drawerMode;
  final VoidCallback onClose;

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  final List<String> _expanded = ['Legal research'];

  void _go(String to) {
    widget.onClose();
    context.go(to);
  }

  Widget _mainLink(_NavEntry entry) {
    final active = _isActive(entry, widget.path);
    return Hover(
      onTap: () => _go(entry.to),
      builder: (context, hovered) {
        final on = active || hovered;
        final fg = on ? const Color(0xFFFFFAF0) : const Color(0xFFABA69A);
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: on ? const Color(0xFF22201A) : Colors.transparent,
              border: active ? const Border(left: BorderSide(color: C.goldLight, width: 2)) : null,
            ),
            child: Row(children: [
              Icon(entry.icon, size: 17, color: fg),
              const SizedBox(width: 11),
              Expanded(child: Text(entry.label, style: sans(.78, color: fg))),
            ]),
          ),
        );
      },
    );
  }

  Widget _group(_NavGroup group) {
    final open = _expanded.contains(group.label);
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Semantics(
          button: true,
          expanded: open,
          child: Hover(
            onTap: () => setState(() => open ? _expanded.remove(group.label) : _expanded.add(group.label)),
            builder: (context, hovered) {
              final fg = hovered ? const Color(0xFFFFFAF0) : const Color(0xFFABA69A);
              return Container(
                constraints: const BoxConstraints(minHeight: 44),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: hovered ? const Color(0xFF22201A) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  Icon(group.icon, size: 17, color: fg),
                  const SizedBox(width: 11),
                  Expanded(child: Text(group.label, style: sans(.78, color: fg))),
                  const SizedBox(width: 11),
                  Icon(LucideIcons.chevronDown, size: 14, color: fg),
                ]),
              );
            },
          ),
        ),
        if (open)
          Container(
            margin: const EdgeInsets.only(top: 3, left: 36),
            padding: const EdgeInsets.only(left: 13),
            decoration: const BoxDecoration(border: Border(left: BorderSide(color: Color(0xFF373329)))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (var i = 0; i < group.links.length; i++) ...[
                if (i > 0) const SizedBox(height: 2),
                Hover(
                  onTap: () => _go(group.links[i].to),
                  builder: (context, hovered) {
                    final active = _isActive(group.links[i], widget.path);
                    return Container(
                      constraints: const BoxConstraints(minHeight: 34),
                      alignment: Alignment.centerLeft,
                      child: Text(group.links[i].label,
                          style: sans(.7, color: active || hovered ? C.goldLight : const Color(0xFF8F8A7F))),
                    );
                  },
                ),
              ],
            ]),
          ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      decoration: const BoxDecoration(
        color: C.black,
        border: Border(right: BorderSide(color: Color(0xFF2C2922))),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF2C2922)))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Brand(),
            if (widget.drawerMode) IconBtn(LucideIcons.x, onTap: widget.onClose, semanticLabel: 'Close navigation'),
          ]),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (var i = 0; i < _primaryNav.length; i++) ...[
                if (i > 0) const SizedBox(height: 4),
                _mainLink(_primaryNav[i]),
              ],
              for (final group in _navGroups) _group(group),
              Container(
                margin: const EdgeInsets.only(top: 22),
                padding: const EdgeInsets.only(top: 16),
                decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF2C2922)))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  for (var i = 0; i < _bottomNav.length; i++) ...[
                    if (i > 0) const SizedBox(height: 4),
                    _mainLink(_bottomNav[i]),
                  ],
                ]),
              ),
            ]),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(14),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1A16),
            border: Border.all(color: const Color(0xFF312D25)),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(LucideIcons.sparkles, size: 16, color: C.goldLight),
            const SizedBox(width: 10),
            Expanded(
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: 'Interactive prototype\n', style: sans(.63, weight: FontWeight.w700, color: const Color(0xFFEEE9DC), height: 1.5)),
                  TextSpan(text: 'Changes are stored only for this visit.', style: sans(.63, color: const Color(0xFFA8A295), height: 1.5)),
                ]),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class GlobalSearch extends StatefulWidget {
  const GlobalSearch({super.key, this.compact = false});
  final bool compact;

  @override
  State<GlobalSearch> createState() => _GlobalSearchState();
}

class _GlobalSearchState extends State<GlobalSearch> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String value) => context.go('/search?q=${Uri.encodeComponent(value)}');

  @override
  Widget build(BuildContext context) {
    return FocusWithin(
      builder: (context, focused) => Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color: C.bg,
          border: Border.all(color: focused ? C.gold : C.line),
          borderRadius: BorderRadius.circular(9),
          boxShadow: focused ? const [BoxShadow(color: C.focusRing, spreadRadius: 3)] : null,
        ),
        child: Row(children: [
          const Icon(LucideIcons.search, size: 17, color: C.muted),
          const SizedBox(width: 10),
          Expanded(
            child: BareInput(
              controller: _controller,
              hint: 'Search cases, legislation, topics, or resources',
              onSubmitted: _submit,
              height: 44,
              size: .78,
              semanticLabel: 'Search MMRA',
            ),
          ),
          if (!widget.compact) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
              decoration: BoxDecoration(
                color: C.paper,
                border: Border.all(color: C.line),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('⌘ K', style: mono(.6, color: C.muted)),
            ),
          ],
        ]),
      ),
    );
  }
}

class _Profile extends StatelessWidget {
  const _Profile();

  @override
  Widget build(BuildContext context) {
    final bp = Bp.of(context);
    return Padding(
      padding: EdgeInsets.only(left: bp.le768 ? 0 : 6),
      child: Hover(
        onTap: () => context.go('/account'),
        builder: (context, hovered) => Container(
          constraints: const BoxConstraints(minHeight: 46),
          padding: bp.le768 ? EdgeInsets.zero : const EdgeInsets.fromLTRB(4, 3, 7, 3),
          decoration: BoxDecoration(
            color: hovered ? C.paper2 : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: bp.le520 ? 38 : 36,
              height: bp.le520 ? 38 : 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: C.goldLight, borderRadius: BorderRadius.circular(8)),
              child: Text('AK', style: sans(.7, weight: FontWeight.w700, color: const Color(0xFF111111))),
            ),
            if (!bp.le768) ...[
              const SizedBox(width: 10),
              Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Akua K.', style: sans(.7, weight: FontWeight.w700)),
                Text('Prototype account', style: sans(.57, color: C.muted)),
              ]),
              const SizedBox(width: 10),
              const Icon(LucideIcons.chevronDown, size: 14, color: C.muted),
            ],
          ]),
        ),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.path, required this.child});
  final String path;
  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _drawer = false;

  @override
  Widget build(BuildContext context) {
    final bp = Bp.of(context);
    final drawerMode = bp.le1024;
    final sidebarWidth = bp.le1180 ? 230.0 : 264.0;
    final gap = bp.le768 ? 10.0 : 20.0;
    void close() => setState(() => _drawer = false);

    final sidebar = Sidebar(width: sidebarWidth, path: widget.path, drawerMode: drawerMode, onClose: close);

    final topbar = Container(
      height: bp.le768 ? 68 : 76,
      padding: EdgeInsets.symmetric(horizontal: bp.le350 ? 10 : (bp.le768 ? 16 : 32)),
      decoration: const BoxDecoration(
        color: Color(0xEBFFFDFA),
        border: Border(bottom: BorderSide(color: C.line)),
      ),
      child: Row(children: [
        if (drawerMode) ...[
          IconBtn(LucideIcons.menu, onTap: () => setState(() => _drawer = true), semanticLabel: 'Open navigation'),
          SizedBox(width: gap),
        ],
        if (bp.le768)
          Expanded(child: GlobalSearch(compact: bp.le768))
        else ...[
          SizedBox(width: math.min(620, bp.width * .54), child: const GlobalSearch()),
          const Spacer(),
        ],
        SizedBox(width: gap),
        Row(mainAxisSize: MainAxisSize.min, children: [
          if (!bp.le768) ...[
            IconBtn(LucideIcons.circleHelp, onTap: () => context.go('/help'), semanticLabel: 'Help'),
            const SizedBox(width: 7),
            IconBtn(
              LucideIcons.bell,
              dot: true,
              semanticLabel: 'Notifications',
              onTap: () => AppScope.read(context).showToast('No new notifications in this prototype.'),
            ),
            const SizedBox(width: 7),
          ],
          const _Profile(),
        ]),
      ]),
    );

    return Material(
      color: C.bg,
      child: Stack(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (!drawerMode) sidebar,
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              topbar,
              Expanded(child: ClipRect(child: widget.child)),
            ]),
          ),
        ]),
        if (drawerMode && _drawer)
          Positioned.fill(
            child: Semantics(
              button: true,
              label: 'Close navigation',
              child: GestureDetector(onTap: close, child: Container(color: const Color(0x75000000))),
            ),
          ),
        if (drawerMode)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.ease,
            top: 0,
            bottom: 0,
            left: _drawer ? 0 : -sidebarWidth - 1,
            width: sidebarWidth,
            child: sidebar,
          ),
      ]),
    );
  }
}
