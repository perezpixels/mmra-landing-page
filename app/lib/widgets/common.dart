import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';

/// Where the React landing page lives relative to this app's host.
const landingUrl = String.fromEnvironment('LANDING_URL', defaultValue: '/');

/// The landing page is a separate site on web; the future mobile app has no
/// landing, so it falls back to onboarding.
void openLanding(BuildContext context) {
  if (kIsWeb) {
    launchUrl(Uri.base.resolve(landingUrl), webOnlyWindowName: '_self');
  } else {
    context.go('/onboarding');
  }
}

void openExternal(String url) {
  launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication, webOnlyWindowName: '_blank');
}

/// Tracks pointer hover and handles taps, like a CSS `:hover` target.
class Hover extends StatefulWidget {
  const Hover({super.key, required this.builder, this.onTap, this.enabled = true});

  final Widget Function(BuildContext context, bool hovered) builder;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  State<Hover> createState() => _HoverState();
}

class _HoverState extends State<Hover> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final clickable = widget.onTap != null && widget.enabled;
    return MouseRegion(
      cursor: clickable ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: clickable ? widget.onTap : null,
        child: widget.builder(context, _hovered && widget.enabled),
      ),
    );
  }
}

/// Tracks focus of any descendant, like CSS `:focus-within`.
class FocusWithin extends StatefulWidget {
  const FocusWithin({super.key, required this.builder});
  final Widget Function(BuildContext context, bool focused) builder;

  @override
  State<FocusWithin> createState() => _FocusWithinState();
}

class _FocusWithinState extends State<FocusWithin> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) => Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onFocusChange: (value) => setState(() => _focused = value),
        child: widget.builder(context, _focused),
      );
}

/// Makes descendant [WaButton]s stretch to full width (`width: 100%` rules).
class ButtonExpandScope extends InheritedWidget {
  const ButtonExpandScope({super.key, required this.expand, required super.child});
  final bool expand;

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ButtonExpandScope>()?.expand ?? false;

  @override
  bool updateShouldNotify(ButtonExpandScope oldWidget) => expand != oldWidget.expand;
}

enum BtnKind { primary, secondary, quiet, danger }

/// `.wa-button` — used for both buttons and button-styled links (`to`).
class WaButton extends StatelessWidget {
  const WaButton(
    this.label, {
    super.key,
    this.kind = BtnKind.primary,
    this.onTap,
    this.to,
    this.leading,
    this.trailing,
    this.disabled = false,
    this.background,
    this.foreground,
    this.minWidth,
    this.shadow,
    this.padH = 16,
    this.fullWidth,
  });

  final String label;
  final BtnKind kind;
  final VoidCallback? onTap;
  final String? to;
  final IconData? leading;
  final IconData? trailing;
  final bool disabled;
  final Color? background;
  final Color? foreground;
  final double? minWidth;
  final List<BoxShadow>? shadow;
  final double padH;
  final bool? fullWidth;

  @override
  Widget build(BuildContext context) {
    final expand = fullWidth ?? ButtonExpandScope.of(context);
    final action = onTap ?? (to != null ? () => context.go(to!) : null);
    final button = Opacity(
      opacity: disabled ? .45 : 1,
      child: Hover(
        enabled: !disabled,
        onTap: action,
        builder: (context, hovered) {
          Color bg;
          Color fg;
          Color border = Colors.transparent;
          switch (kind) {
            case BtnKind.primary:
              bg = background ?? (hovered ? const Color(0xFF2A2822) : C.black);
              fg = foreground ?? Colors.white;
            case BtnKind.secondary:
              bg = background ?? C.paper;
              fg = foreground ?? C.ink;
              border = hovered ? C.gold : C.line;
            case BtnKind.quiet:
              bg = background ?? Colors.transparent;
              fg = foreground ?? C.muted;
            case BtnKind.danger:
              bg = background ?? C.red;
              fg = foreground ?? Colors.white;
          }
          final lift = hovered && kind == BtnKind.primary;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.translationValues(0, lift ? -1 : 0, 0),
            constraints: BoxConstraints(minHeight: 42, minWidth: minWidth ?? 0),
            padding: EdgeInsets.symmetric(horizontal: padH),
            decoration: BoxDecoration(
              color: bg,
              border: Border.all(color: border),
              borderRadius: BorderRadius.circular(8),
              boxShadow: shadow,
            ),
            child: Row(
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leading != null) ...[Icon(leading, size: 15, color: fg), const SizedBox(width: 8)],
                if (expand)
                  Flexible(
                    child: Text(label, textAlign: TextAlign.center, style: sans(.71, weight: FontWeight.w700, color: fg)),
                  )
                else
                  Text(label, style: sans(.71, weight: FontWeight.w700, color: fg)),
                if (trailing != null) ...[const SizedBox(width: 8), Icon(trailing, size: 15, color: fg)],
              ],
            ),
          );
        },
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Plain text link with optional hover colour and icons.
class TextLink extends StatelessWidget {
  const TextLink(
    this.text, {
    super.key,
    this.to,
    this.onTap,
    required this.style,
    this.hoverColor,
    this.leading,
    this.trailing,
    this.iconSize = 24,
    this.gap = 6,
  });

  final String text;
  final String? to;
  final VoidCallback? onTap;
  final TextStyle style;
  final Color? hoverColor;
  final IconData? leading;
  final IconData? trailing;
  final double iconSize;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Hover(
      onTap: onTap ?? (to != null ? () => context.go(to!) : null),
      builder: (context, hovered) {
        final color = hovered && hoverColor != null ? hoverColor! : style.color;
        final label = Text(text, style: style.copyWith(color: color));
        if (leading == null && trailing == null) return label;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[Icon(leading, size: iconSize, color: color), SizedBox(width: gap)],
            label,
            if (trailing != null) ...[SizedBox(width: gap), Icon(trailing, size: iconSize, color: color)],
          ],
        );
      },
    );
  }
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color = C.gold});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: sans(.61, weight: FontWeight.w700, color: color, lsEm: .13));
}

class DemoBadge extends StatelessWidget {
  const DemoBadge(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 9),
        decoration: BoxDecoration(
          color: const Color(0xFFF4EAD1),
          border: Border.all(color: const Color(0xFFDCC793)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(text, style: sans(.59, weight: FontWeight.w600, color: const Color(0xFF765B22))),
      );
}

/// Small bordered tag (`.wa-unverified`, `.wa-bill-label`).
class StatusTag extends StatelessWidget {
  const StatusTag(this.text, {super.key, this.icon, this.bill = false});
  final String text;
  final IconData? icon;
  final bool bill;

  @override
  Widget build(BuildContext context) {
    final fg = bill ? const Color(0xFF8A4038) : const Color(0xFF805F1D);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 7),
      decoration: BoxDecoration(
        color: bill ? const Color(0xFFF9EBE8) : const Color(0xFFFBF1D7),
        border: Border.all(color: bill ? const Color(0xFFE6C1BC) : const Color(0xFFDFC989)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 11, color: fg), const SizedBox(width: 5)],
        Text(text, style: sans(.55, weight: FontWeight.w700, color: fg)),
      ]),
    );
  }
}

class SourceLabel extends StatelessWidget {
  const SourceLabel(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    final (fg, bg, border) = switch (label) {
      'Editorial brief' => (const Color(0xFF775D22), const Color(0xFFF7EFD9), const Color(0xFFDDCA98)),
      'Study resource' => (const Color(0xFF5D517C), const Color(0xFFF1EEF8), const Color(0xFFD8D0E7)),
      'External source' => (C.muted, C.paper2, C.line),
      _ => (C.blue, const Color(0xFFEDF4F7), const Color(0xFFCBDDE5)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 7),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(LucideIcons.fileCheck2, size: 11, color: fg),
        const SizedBox(width: 5),
        Text(label, style: sans(.54, weight: FontWeight.w700, color: fg)),
      ]),
    );
  }
}

class SaveButton extends StatelessWidget {
  const SaveButton(this.item, {super.key, this.label = false, this.expand = false});
  final ResearchItem item;
  final bool label;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final active = app.isSaved(item.id);
    final fg = active ? const Color(0xFF6D531D) : C.muted;
    return Semantics(
      button: true,
      label: active ? 'Remove ${item.title} from reading list' : 'Save ${item.title} to reading list',
      child: Hover(
        onTap: () => app.toggleSaved(item.id, item.title),
        builder: (context, _) => Container(
          width: label ? (expand ? double.infinity : null) : 39,
          height: 39,
          padding: label ? const EdgeInsets.symmetric(horizontal: 13) : null,
          decoration: BoxDecoration(
            color: active ? const Color(0xFFF4EAD1) : Colors.transparent,
            border: Border.all(color: active ? const Color(0xFFD6BD80) : C.line),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(active ? LucideIcons.bookmarkCheck : LucideIcons.bookmark, size: 16, color: fg),
              if (label) ...[
                const SizedBox(width: 7),
                Text(active ? 'Saved' : 'Save', style: sans(.65, color: fg)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class WaProgress extends StatelessWidget {
  const WaProgress(this.value, {super.key, this.track = const Color(0xFFE8E3D8)});
  final double value;
  final Color track;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: (value / 100).clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 400),
      builder: (context, v, _) => Container(
        height: 5,
        decoration: BoxDecoration(color: track, borderRadius: BorderRadius.circular(99)),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: v,
          heightFactor: 1,
          child: Container(
            decoration: BoxDecoration(color: C.gold, borderRadius: BorderRadius.circular(99)),
          ),
        ),
      ),
    );
  }
}

typedef Crumb = (String label, String? to);

class Breadcrumbs extends StatelessWidget {
  const Breadcrumbs(this.items, {super.key});
  final List<Crumb> items;

  @override
  Widget build(BuildContext context) {
    final style = sans(.67, color: C.muted);
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 3,
        runSpacing: 3,
        children: [
          for (var i = 0; i < items.length; i++)
            Row(mainAxisSize: MainAxisSize.min, children: [
              if (i > 0) ...[const Icon(LucideIcons.chevronRight, size: 12, color: C.muted), const SizedBox(width: 3)],
              if (items[i].$2 != null)
                TextLink(items[i].$1, to: items[i].$2, style: style, hoverColor: C.gold)
              else
                Text(items[i].$1, style: sans(.67, weight: FontWeight.w500)),
            ]),
        ],
      ),
    );
  }
}

/// `h1` of page and document headers.
class PageTitle extends StatelessWidget {
  const PageTitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    final size = titleSize(context);
    return Text(text, style: serif(size / 16, height: 1.08, lsEm: -.035));
  }
}

class PageHeader extends StatelessWidget {
  const PageHeader({super.key, this.eyebrow, required this.title, required this.description, this.action});
  final String? eyebrow;
  final String title;
  final String description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final bp = Bp.of(context);
    final left = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 780),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (eyebrow != null) Eyebrow(eyebrow!),
        const SizedBox(height: 7),
        PageTitle(title),
        const SizedBox(height: 9),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Text(description, style: sans(.86, color: C.muted, height: 1.65)),
        ),
      ]),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: bp.le768
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              left,
              if (action != null) ...[
                const SizedBox(height: 32),
                SizedBox(width: double.infinity, child: ButtonExpandScope(expand: true, child: Align(alignment: Alignment.centerLeft, child: action!))),
              ],
            ])
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: left),
                if (action != null) ...[const SizedBox(width: 32), action!],
              ],
            ),
    );
  }
}

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding = EdgeInsets.zero, this.minHeight = 0, this.color = C.paper, this.borderColor = C.line, this.radius = 12});
  final Widget child;
  final EdgeInsets padding;
  final double minHeight;
  final Color color;
  final Color borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
        constraints: BoxConstraints(minHeight: minHeight),
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: child,
      );
}

/// `.wa-panel-title`
class PanelTitle extends StatelessWidget {
  const PanelTitle(this.title, {super.key, this.trailing, this.size = 1.15});
  final String title;
  final Widget? trailing;
  final double size;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 17),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(title, style: serif(size))),
            if (trailing != null) ...[const SizedBox(width: 18), trailing!],
          ],
        ),
      );
}

class SourceNotice extends StatelessWidget {
  const SourceNotice({super.key, required this.icon, required this.title, required this.text, this.warning = false, this.compact = false, this.margin});
  final IconData icon;
  final String title;
  final String text;
  final bool warning;
  final bool compact;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final fg = warning ? const Color(0xFF725820) : const Color(0xFF294F63);
    return Container(
      margin: margin ?? (compact ? const EdgeInsets.only(top: 17) : const EdgeInsets.symmetric(vertical: 18)),
      padding: compact ? const EdgeInsets.all(13) : const EdgeInsets.symmetric(vertical: 15, horizontal: 17),
      decoration: BoxDecoration(
        color: warning ? const Color(0xFFFBF4DF) : const Color(0xFFEEF5F7),
        border: Border.all(color: warning ? const Color(0xFFDFCC99) : const Color(0xFFCADDE4)),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 18, color: fg),
        const SizedBox(width: 13),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: sans(.69, weight: FontWeight.w700, color: fg)),
            const SizedBox(height: 3),
            Text(text, style: sans(.64, color: fg, height: 1.5)),
          ]),
        ),
      ]),
    );
  }
}

/// Info strip with icon, bold line and paragraph (`.wa-help-panel` and friends).
class InfoStrip extends StatelessWidget {
  const InfoStrip({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
    required this.fg,
    required this.bg,
    required this.border,
    this.iconColor,
    this.textColor,
    this.titleSize = .69,
    this.textSize = .62,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    this.margin = EdgeInsets.zero,
    this.gap = 12,
    this.iconSize = 18,
    this.radius = 8,
  });

  final IconData icon;
  final String title;
  final String text;
  final Color fg;
  final Color bg;
  final Color border;
  final Color? iconColor;
  final Color? textColor;
  final double titleSize;
  final double textSize;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double gap;
  final double iconSize;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(color: bg, border: Border.all(color: border), borderRadius: BorderRadius.circular(radius)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: iconSize, color: iconColor ?? fg),
          SizedBox(width: gap),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: sans(titleSize, weight: FontWeight.w700, color: fg)),
              const SizedBox(height: 3),
              Text(text, style: sans(textSize, color: textColor ?? fg, height: 1.65)),
            ]),
          ),
        ]),
      );
}

/// Single-line caution strip (`.wa-report-caution`, `.wa-question-note`, ...).
class NoteStrip extends StatelessWidget {
  const NoteStrip({
    super.key,
    required this.icon,
    required this.text,
    required this.fg,
    required this.bg,
    this.border,
    this.iconColor,
    this.size = .59,
    this.padding = const EdgeInsets.all(12),
    this.gap = 9,
    this.iconSize = 15,
    this.radius = 8,
    this.textWidget,
  });

  final IconData icon;
  final String text;
  final Color fg;
  final Color bg;
  final Color? border;
  final Color? iconColor;
  final double size;
  final EdgeInsets padding;
  final double gap;
  final double iconSize;
  final double radius;
  final Widget? textWidget;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: bg,
          border: border != null ? Border.all(color: border!) : null,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: iconSize, color: iconColor ?? fg),
          SizedBox(width: gap),
          Expanded(child: textWidget ?? Text(text, style: sans(size, color: fg, height: 1.5))),
        ]),
      );
}

class ResultIcon extends StatelessWidget {
  const ResultIcon(this.icon, {super.key});
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(color: const Color(0xFFF1EAD9), borderRadius: BorderRadius.circular(9)),
        child: Icon(icon, size: 18, color: C.gold),
      );
}

String resultRoute(ResearchItem item) => switch (item.kind) {
      'Case' => '/cases/${illustrativeCase.id}',
      'Brief' => '/briefs/${item.id}',
      'Legislation' => '/library/${item.id}',
      'Course' => '/courses/contract',
      _ => '/practice',
    };

IconData resultIcon(ResearchItem item) => switch (item.kind) {
      'Case' => LucideIcons.scale,
      'Legislation' => LucideIcons.fileText,
      'Past question' => LucideIcons.fileQuestion,
      _ => LucideIcons.bookOpen,
    };

class ResultRow extends StatelessWidget {
  const ResultRow(this.item, {super.key, this.comfortable = false});
  final ResearchItem item;
  final bool comfortable;

  @override
  Widget build(BuildContext context) {
    final bp = Bp.of(context);
    Widget metaChip(String text) => Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 7),
          decoration: BoxDecoration(color: C.paper2, borderRadius: BorderRadius.circular(4)),
          child: Text(text, style: sans(.56, color: C.muted)),
        );
    return Hover(
      builder: (context, hovered) => Container(
        constraints: BoxConstraints(minHeight: comfortable ? 225 : 0),
        padding: EdgeInsets.all(comfortable ? 32 : (bp.le520 ? 17 : 22)),
        decoration: BoxDecoration(
          color: C.paper,
          border: Border.all(color: hovered ? const Color(0xFFC9B77F) : C.line),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!bp.le520) ...[ResultIcon(resultIcon(item)), const SizedBox(width: 17)],
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(spacing: 7, runSpacing: 7, crossAxisAlignment: WrapCrossAlignment.center, children: [
                SourceLabel(item.label),
                Text(item.kind, style: sans(.58, color: C.muted)),
              ]),
              const SizedBox(height: 10),
              TextLink(item.title, to: resultRoute(item), style: serif(1.1)),
              const SizedBox(height: 5),
              Text(item.reference, style: mono(.67, color: const Color(0xFF705820))),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 770),
                child: Text(item.excerpt, style: sans(.71, color: C.muted, height: 1.6)),
              ),
              const SizedBox(height: 10),
              if (bp.le520)
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  metaChip(item.meta),
                  const SizedBox(height: 6),
                  metaChip(item.topic),
                ])
              else
                Wrap(spacing: 6, runSpacing: 6, children: [metaChip(item.meta), metaChip(item.topic)]),
            ]),
          ),
          const SizedBox(width: 17),
          SaveButton(item),
        ]),
      ),
    );
  }
}

class ResultsList extends StatelessWidget {
  const ResultsList(this.items, {super.key, this.comfortable = false});
  final List<ResearchItem> items;
  final bool comfortable;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            ResultRow(items[i], comfortable: comfortable),
          ],
        ],
      );
}

class FilterButton extends StatelessWidget {
  const FilterButton(this.label, {super.key, this.count, this.onTap});
  final String label;
  final int? count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Hover(
        onTap: onTap ?? () {},
        builder: (context, _) => Container(
          constraints: const BoxConstraints(minHeight: 38),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: C.paper,
            border: Border.all(color: C.line),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(LucideIcons.filter, size: 14, color: C.ink),
            const SizedBox(width: 7),
            Text(label, style: sans(.66)),
            if (count != null) ...[
              const SizedBox(width: 7),
              Container(
                constraints: const BoxConstraints(minWidth: 18),
                height: 18,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: C.black, shape: BoxShape.circle),
                child: Text('$count', style: sans(.55, color: Colors.white)),
              ),
            ],
          ]),
        ),
      );
}

/// `.wa-filter-bar` row; scrolls horizontally on narrow screens.
class FilterBarFrame extends StatelessWidget {
  const FilterBarFrame({super.key, required this.children, this.marginTop = 15, this.trailing});
  final List<Widget> children;
  final double marginTop;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final bp = Bp.of(context);
    final row = Row(
      mainAxisSize: bp.le520 ? MainAxisSize.min : MainAxisSize.max,
      children: [
        for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(width: 8), children[i]],
        if (trailing != null) ...[
          if (bp.le520) const SizedBox(width: 8) else const Spacer(),
          trailing!,
        ],
      ],
    );
    return Container(
      margin: EdgeInsets.only(top: marginTop, bottom: 15),
      constraints: const BoxConstraints(minHeight: 66),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: C.line))),
      alignment: Alignment.centerLeft,
      child: bp.le520 ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: row) : row,
    );
  }
}

class FilterChipsBar extends StatelessWidget {
  const FilterChipsBar({super.key, required this.active, required this.onChanged});
  final List<String> active;
  final ValueChanged<List<String>> onChanged;

  static const options = ['Cases', 'Legislation', 'Briefs', 'Courses', 'Past questions'];

  @override
  Widget build(BuildContext context) {
    return FilterBarFrame(
      trailing: active.isNotEmpty
          ? TextLink('Reset all', onTap: () => onChanged([]), style: sans(.63, color: C.gold))
          : null,
      children: [
        FilterButton('Filters', count: active.length),
        for (final item in options)
          Hover(
            onTap: () => onChanged(active.contains(item) ? (List.of(active)..remove(item)) : [...active, item]),
            builder: (context, _) {
              final on = active.contains(item);
              final fg = on ? const Color(0xFF6C5119) : C.muted;
              return Container(
                constraints: const BoxConstraints(minHeight: 34),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: on ? const Color(0xFFF3EAD4) : Colors.transparent,
                  border: Border.all(color: on ? const Color(0xFFD6BF87) : C.line),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(item, style: sans(.61, color: fg)),
                  if (on) ...[const SizedBox(width: 5), Icon(LucideIcons.x, size: 12, color: fg)],
                ]),
              );
            },
          ),
      ],
    );
  }
}

class ViewToggle extends StatelessWidget {
  const ViewToggle({super.key, required this.options, required this.active, this.onChanged});
  final List<(String, IconData)> options;
  final String active;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: C.paper2, borderRadius: BorderRadius.circular(7)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Hover(
              onTap: () => onChanged?.call(options[i].$1),
              builder: (context, _) {
                final on = options[i].$1 == active;
                final fg = on ? C.ink : C.muted;
                return Container(
                  constraints: const BoxConstraints(minHeight: 31),
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  decoration: BoxDecoration(
                    color: on ? C.paper : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: on ? const [BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 1))] : null,
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(options[i].$2, size: 12, color: fg),
                    const SizedBox(width: 5),
                    Text(options[i].$1, style: sans(.57, color: fg)),
                  ]),
                );
              },
            ),
          ],
        ]),
      );
}

/// Equal-height CSS grid made of rows (`grid-template-columns`).
class GridCols extends StatelessWidget {
  const GridCols({super.key, required this.cols, required this.children, this.gap = 10, this.rowGap, this.flex, this.stretch = true});
  final int cols;
  final List<Widget> children;
  final double gap;
  final double? rowGap;
  final List<int>? flex;
  final bool stretch;

  @override
  Widget build(BuildContext context) {
    final vGap = rowGap ?? gap;
    if (cols <= 1) {
      // Tight heights so cards can push content down (`margin: auto`).
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(height: vGap),
          stretch
              ? IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(child: children[i])]))
              : children[i],
        ],
      ]);
    }
    final rows = <Widget>[];
    for (var start = 0; start < children.length; start += cols) {
      final cells = children.sublist(start, math.min(start + cols, children.length));
      final row = Row(
        crossAxisAlignment: stretch ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < cols; i++) ...[
            if (i > 0) SizedBox(width: gap),
            Expanded(flex: flex != null ? flex![i] : 1, child: i < cells.length ? cells[i] : const SizedBox()),
          ],
        ],
      );
      if (rows.isNotEmpty) rows.add(SizedBox(height: vGap));
      rows.add(stretch ? IntrinsicHeight(child: row) : row);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
  }
}

/// `.wa-page` container: centred column inside the scrolling main area.
class WaPage extends StatelessWidget {
  const WaPage({super.key, required this.children, this.reader = false});
  final List<Widget> children;
  final bool reader;

  @override
  Widget build(BuildContext context) {
    final bp = Bp.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      double width;
      if (bp.le350) {
        width = w - 20;
      } else if (bp.le768) {
        width = w - 28;
      } else if (bp.le1180) {
        width = math.min(w - 40, 1240);
      } else {
        width = math.min(w - 64, reader ? 1340 : 1240);
      }
      return SingleChildScrollView(
        padding: EdgeInsets.only(top: bp.le768 ? 25 : 35, bottom: 72),
        child: Center(
          child: SizedBox(
            width: math.max(width, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
          ),
        ),
      );
    });
  }
}

Color get placeholderColor => C.ink.withValues(alpha: .5);

/// Borderless input used inside search frames.
class BareInput extends StatelessWidget {
  const BareInput({super.key, this.controller, this.hint, this.onSubmitted, this.onChanged, this.height = 42, this.size = 1, this.semanticLabel});
  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final double height;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: Center(
          child: Semantics(
            label: semanticLabel,
            textField: true,
            child: TextField(
              controller: controller,
              onSubmitted: onSubmitted,
              onChanged: onChanged,
              style: sans(size),
              cursorHeight: rem(size) * 1.2,
              decoration: InputDecoration.collapsed(
                hintText: hint,
                hintStyle: sans(size, color: placeholderColor),
              ),
            ),
          ),
        ),
      );
}

/// Search frame (`.wa-search-page-field`, `.wa-hero-search`, `.wa-directory-search`).
class SearchFrame extends StatelessWidget {
  const SearchFrame({
    super.key,
    required this.input,
    this.button,
    this.iconSize = 20,
    this.padding = const EdgeInsets.fromLTRB(17, 8, 8, 8),
    this.radius = 10,
    this.borderColor = C.line,
    this.shadow,
    this.gap = 12,
    this.wrapButton = false,
  });

  final Widget input;
  final Widget? button;
  final double iconSize;
  final EdgeInsets padding;
  final double radius;
  final Color borderColor;
  final List<BoxShadow>? shadow;
  final double gap;
  final bool wrapButton;

  @override
  Widget build(BuildContext context) {
    final head = Row(children: [
      Icon(LucideIcons.search, size: iconSize, color: C.gold),
      SizedBox(width: gap),
      Expanded(child: input),
      if (button != null && !wrapButton) ...[SizedBox(width: gap), button!],
    ]);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: C.paper,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadow,
      ),
      child: wrapButton && button != null
          ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              head,
              SizedBox(height: gap),
              ButtonExpandScope(expand: true, child: button!),
            ])
          : head,
    );
  }
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.label, {super.key, required this.child, this.size = .64});
  final String label;
  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: sans(size, weight: FontWeight.w700)),
          const SizedBox(height: 7),
          child,
        ],
      );
}

InputDecoration fieldDecoration({String? hint, double radius = 7, double size = .69, Widget? prefix, EdgeInsets? padding, Color fill = Colors.white}) {
  OutlineInputBorder border(Color c, [double w = 1]) =>
      OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: BorderSide(color: c, width: w));
  return InputDecoration(
    hintText: hint,
    hintStyle: sans(size, color: placeholderColor),
    isDense: true,
    filled: true,
    fillColor: fill,
    prefixIcon: prefix,
    prefixIconConstraints: const BoxConstraints(minWidth: 37, minHeight: 20),
    contentPadding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    enabledBorder: border(C.line),
    disabledBorder: border(C.line),
    focusedBorder: border(C.gold),
    errorBorder: border(C.red),
    focusedErrorBorder: border(C.red),
    errorStyle: sans(.58, color: C.red),
  );
}

String? requiredValidator(String? value) =>
    (value == null || value.trim().isEmpty) ? 'Please fill out this field.' : null;

class WaTextField extends StatelessWidget {
  const WaTextField({
    super.key,
    this.controller,
    this.hint,
    this.validator,
    this.obscure = false,
    this.multiline = false,
    this.minLines = 5,
    this.readOnly = false,
    this.initialValue,
    this.keyboardType,
    this.autofillHints,
    this.prefix,
    this.fill = Colors.white,
    this.radius = 7,
    this.size = .69,
    this.padding,
    this.onChanged,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final bool obscure;
  final bool multiline;
  final int minLines;
  final bool readOnly;
  final String? initialValue;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final Widget? prefix;
  final Color fill;
  final double radius;
  final double size;
  final EdgeInsets? padding;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        initialValue: controller == null ? initialValue : null,
        validator: validator,
        obscureText: obscure,
        readOnly: readOnly,
        enabled: enabled,
        keyboardType: multiline ? TextInputType.multiline : keyboardType,
        autofillHints: autofillHints,
        minLines: multiline ? minLines : 1,
        maxLines: multiline ? null : 1,
        onChanged: onChanged,
        style: sans(size, height: multiline ? 1.4 : null),
        decoration: fieldDecoration(
          hint: hint,
          radius: radius,
          size: size,
          prefix: prefix,
          fill: fill,
          padding: padding ?? (multiline ? const EdgeInsets.all(12) : null),
        ),
      );
}

class WaSelect extends StatelessWidget {
  const WaSelect({
    super.key,
    required this.options,
    this.value,
    this.onChanged,
    this.validator,
    this.radius = 7,
    this.size = .69,
    this.verticalPadding = 12,
    this.fill = Colors.white,
  });

  /// (value, label) pairs.
  final List<(String, String)> options;
  final String? value;
  final ValueChanged<String?>? onChanged;
  final FormFieldValidator<String>? validator;
  final double radius;
  final double size;
  final double verticalPadding;
  final Color fill;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
        initialValue: value ?? options.first.$1,
        isExpanded: true,
        isDense: true,
        validator: validator,
        onChanged: onChanged ?? (_) {},
        icon: const Icon(LucideIcons.chevronDown, size: 15, color: C.ink),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        style: sans(size),
        decoration: fieldDecoration(
          radius: radius,
          size: size,
          fill: fill,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: verticalPadding),
        ),
        items: [
          for (final (v, label) in options)
            DropdownMenuItem(value: v, child: Text(label, overflow: TextOverflow.ellipsis, style: sans(size))),
        ],
      );
}

List<(String, String)> plainOptions(List<String> values) => [for (final v in values) (v, v)];

/// `.wa-icon-button`
class IconBtn extends StatelessWidget {
  const IconBtn(this.icon, {super.key, this.onTap, this.dot = false, this.semanticLabel});
  final IconData icon;
  final VoidCallback? onTap;
  final bool dot;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: semanticLabel,
        child: Hover(
          onTap: onTap,
          builder: (context, hovered) => Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: hovered ? C.paper2 : Colors.transparent,
              border: Border.all(color: C.line),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Stack(children: [
              Center(child: Icon(icon, size: 18, color: hovered ? C.ink : C.muted)),
              if (dot)
                Positioned(
                  right: 9,
                  top: 8,
                  child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: C.gold, shape: BoxShape.circle)),
                ),
            ]),
          ),
        ),
      );
}

/// `dl > div` row in record panels.
class DlRow extends StatelessWidget {
  const DlRow(this.term, this.value, {super.key, this.valueWidget});
  final String term;
  final String value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: C.line))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(term, style: sans(.61, color: C.muted)),
          const SizedBox(width: 14),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: valueWidget ?? Text(value, textAlign: TextAlign.right, style: sans(.61)),
            ),
          ),
        ]),
      );
}

class CompleteMark extends StatelessWidget {
  const CompleteMark({super.key});

  @override
  Widget build(BuildContext context) => Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(color: C.green, shape: BoxShape.circle),
        child: const Icon(LucideIcons.check, size: 20, color: Colors.white),
      );
}

/// `.wa-card-actions`: row, or full-width stack on small phones.
class CardActions extends StatelessWidget {
  const CardActions({super.key, required this.children, this.top = 22});
  final List<Widget> children;
  final double top;

  @override
  Widget build(BuildContext context) {
    final bp = Bp.of(context);
    return Padding(
      padding: EdgeInsets.only(top: top),
      child: bp.le520
          ? ButtonExpandScope(
              expand: true,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(height: 15), children[i]],
              ]),
            )
          : Wrap(spacing: 15, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: children),
    );
  }
}

/// Icon + text + chevron link row (`.wa-related-panel > a`, `.wa-topic-links > a`).
class LinkRow extends StatelessWidget {
  const LinkRow({
    super.key,
    required this.icon,
    required this.to,
    required this.body,
    this.iconSize = 16,
    this.chevronSize = 13,
    this.gap = 8,
    this.padding = 13,
    this.showChevron = true,
  });

  final IconData icon;
  final String to;
  final Widget body;
  final double iconSize;
  final double chevronSize;
  final double gap;
  final double padding;
  final bool showChevron;

  @override
  Widget build(BuildContext context) => Hover(
        onTap: () => context.go(to),
        builder: (context, _) => Container(
          padding: EdgeInsets.symmetric(vertical: padding),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: C.line))),
          child: Row(children: [
            Icon(icon, size: iconSize, color: C.gold),
            SizedBox(width: gap),
            Expanded(child: body),
            if (showChevron) ...[SizedBox(width: gap), Icon(LucideIcons.chevronRight, size: chevronSize, color: C.muted)],
          ]),
        ),
      );
}

/// Dashed rounded border (`border: 1px dashed`).
class DashedBox extends StatelessWidget {
  const DashedBox({super.key, required this.child, this.color = const Color(0xFFCFC8BB), this.radius = 11, this.fill = C.paper});
  final Widget child;
  final Color color;
  final double radius;
  final Color fill;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _DashedPainter(color: color, radius: radius, fill: fill),
        child: child,
      );
}

class _DashedPainter extends CustomPainter {
  _DashedPainter({required this.color, required this.radius, required this.fill});
  final Color color;
  final double radius;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    canvas.drawRRect(rrect, Paint()..color = fill);
    final path = Path()..addRRect(rrect.deflate(.5));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final ui.PathMetric metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, math.min(d + 3, metric.length)), paint);
        d += 6;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedPainter old) => old.color != color || old.radius != radius || old.fill != fill;
}

class StateCard extends StatelessWidget {
  const StateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.copy,
    this.action,
    this.loading = false,
    this.vertical = false,
    this.copyStyle,
  });

  final IconData icon;
  final String title;
  final String copy;
  final Widget? action;
  final bool loading;

  /// Cards inside `.wa-state-grid` stack vertically and centre their text.
  final bool vertical;
  final TextStyle? copyStyle;

  @override
  Widget build(BuildContext context) {
    final bp = Bp.of(context);
    Widget iconCircle = Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(color: Color(0xFFF4EDDD), shape: BoxShape.circle),
      child: Icon(icon, size: 21, color: C.gold),
    );
    if (loading) iconCircle = Spin(child: iconCircle);
    final text = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: vertical ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(title, textAlign: vertical ? TextAlign.center : TextAlign.start, style: serif(1.05)),
        const SizedBox(height: 7),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Text(copy,
              textAlign: vertical ? TextAlign.center : TextAlign.start,
              style: copyStyle ?? sans(.67, color: C.muted, height: 1.55)),
        ),
        const SizedBox(height: 14),
        ?action,
      ],
    );
    return DashedBox(
      child: Container(
        constraints: BoxConstraints(minHeight: vertical ? (bp.le768 ? 220 : 280) : 210),
        padding: const EdgeInsets.all(28),
        alignment: Alignment.center,
        child: vertical
            ? Column(mainAxisSize: MainAxisSize.min, children: [iconCircle, const SizedBox(height: 17), text])
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                iconCircle,
                const SizedBox(width: 17),
                Flexible(child: text),
              ]),
      ),
    );
  }
}

class Spin extends StatefulWidget {
  const Spin({super.key, required this.child});
  final Widget child;

  @override
  State<Spin> createState() => _SpinState();
}

class _SpinState extends State<Spin> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RotationTransition(turns: _c, child: widget.child);
}

/// Scrolls to a section registered under [key] (in-page `#anchor` links).
void scrollToKey(GlobalKey key) {
  final ctx = key.currentContext;
  if (ctx != null) {
    Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
  }
}

/// Modal backdrop used by `.wa-modal-backdrop`.
Future<T?> showWaModal<T>(BuildContext context, {required WidgetBuilder builder, bool dismissible = false}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: 'Close',
    barrierColor: const Color(0xB811100D),
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (context, _, _) => BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Material(type: MaterialType.transparency, child: builder(context)),
          ),
        ),
      ),
    ),
  );
}

/// `.wa-modal` card.
class ModalCard extends StatelessWidget {
  const ModalCard({super.key, required this.eyebrow, required this.title, required this.child, required this.onClose});
  final String eyebrow;
  final String title;
  final Widget child;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: C.paper,
            border: Border.all(color: C.line),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Color(0x38000000), blurRadius: 80, offset: Offset(0, 25))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Eyebrow(eyebrow),
                    const SizedBox(height: 6),
                    Text(title, style: serif(1.4)),
                  ]),
                ),
                const SizedBox(width: 20),
                IconBtn(LucideIcons.x, onTap: onClose, semanticLabel: 'Close'),
              ]),
            ),
            child,
          ]),
        ),
      );
}

/// "Prototype report recorded." confirmation (`.wa-report-success`).
class ReportSuccess extends StatelessWidget {
  const ReportSuccess({super.key, required this.copy, required this.action});
  final String copy;
  final Widget action;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 25),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CompleteMark(),
          const SizedBox(height: 15),
          Text('Prototype report recorded.', style: serif(1.2)),
          const SizedBox(height: 8),
          Text(copy, style: sans(.67, color: C.muted, height: 1.65)),
          action,
        ]),
      );
}

/// Vertical stack with a fixed gap (`.wa-form-stack`, gap 15).
class FormStack extends StatelessWidget {
  const FormStack({super.key, required this.children, this.gap = 15});
  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[if (i > 0) SizedBox(height: gap), children[i]],
        ],
      );
}

/// Left-aligned, intrinsic-width wrapper (`width: fit-content`).
class FitLeft extends StatelessWidget {
  const FitLeft({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Align(alignment: Alignment.centerLeft, child: child);
}
