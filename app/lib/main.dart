import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'router.dart';
import 'state.dart';
import 'theme.dart';

void main() {
  usePathUrlStrategy();
  runApp(const MmraApp());
}

class MmraApp extends StatefulWidget {
  const MmraApp({super.key});

  @override
  State<MmraApp> createState() => _MmraAppState();
}

class _MmraAppState extends State<MmraApp> {
  final AppState _state = AppState();
  final GoRouter _router = buildRouter();

  @override
  void dispose() {
    _state.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScope(
        state: _state,
        child: MaterialApp.router(
          title: 'MMRA',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(),
          routerConfig: _router,
          builder: (context, child) => Stack(children: [
            if (child != null) Positioned.fill(child: child),
            const _Toast(),
          ]),
        ),
      );
}

class _Toast extends StatelessWidget {
  const _Toast();

  @override
  Widget build(BuildContext context) {
    final toast = AppScope.of(context).toast;
    if (toast.isEmpty) return const SizedBox.shrink();
    final bp = Bp.of(context);
    final card = Semantics(
      liveRegion: true,
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52, maxWidth: 390),
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
          decoration: BoxDecoration(
            color: C.dark,
            border: Border.all(color: const Color(0xFF413B2F)),
            borderRadius: BorderRadius.circular(9),
            boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 40, offset: Offset(0, 15))],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(LucideIcons.check, size: 16, color: C.goldLight),
            const SizedBox(width: 9),
            Flexible(child: Text(toast, style: sans(.68, color: Colors.white, height: 1.5))),
          ]),
        ),
      ),
    );
    return bp.le520
        ? Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 390),
                child: SizedBox(width: double.infinity, child: card),
              ),
            ),
          )
        : Positioned(right: 22, bottom: 22, child: card);
  }
}
