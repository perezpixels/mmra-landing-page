import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'screens/account.dart';
import 'screens/entry.dart';
import 'screens/home.dart';
import 'screens/research.dart';
import 'screens/study.dart';
import 'shell.dart';

/// Routes mirror `src/app/routes.tsx`; the web build is served under `/app/`,
/// so `/` here is `/app` in the browser.
GoRouter buildRouter() {
  Page<void> page(GoRouterState state, Widget child) =>
      NoTransitionPage<void>(key: state.pageKey, child: child);

  GoRoute route(String path, Widget Function(GoRouterState state) builder) => GoRoute(
        path: path,
        pageBuilder: (context, state) => page(state, builder(state)),
      );

  return GoRouter(
    initialLocation: kIsWeb ? null : '/onboarding',
    errorBuilder: (context, state) => AppShell(path: state.uri.path, child: const NotFoundPage()),
    routes: [
      route('/onboarding', (_) => const OnboardingPage()),
      route('/auth', (state) => AuthPage(mode: state.uri.queryParameters['mode'] ?? 'signup')),
      ShellRoute(
        pageBuilder: (context, state, child) => page(state, AppShell(path: state.uri.path, child: child)),
        routes: [
          route('/', (_) => const OverviewPage()),
          route('/search', (state) => SearchPage(
                key: ValueKey(state.uri.toString()),
                query: state.uri.queryParameters['q'] ?? '',
                type: state.uri.queryParameters['type'],
              )),
          route('/cases', (_) => const CasesLibraryPage()),
          route('/cases/:id', (state) => CaseDetailPage(key: ValueKey(state.uri.path), briefModule: false)),
          route('/briefs', (_) => const BriefsLibraryPage()),
          route('/briefs/:id', (state) => CaseDetailPage(key: ValueKey(state.uri.path), briefModule: true)),
          route('/library', (state) => LibraryPage(key: ValueKey(state.uri.toString()), type: state.uri.queryParameters['type'])),
          route('/library/:id', (state) => LegalTextPage(key: ValueKey(state.uri.path), id: state.pathParameters['id']!)),
          route('/courses', (_) => const CoursesPage()),
          route('/courses/:id', (state) => CourseDetailPage(id: state.pathParameters['id']!)),
          route('/topics/:id', (_) => const TopicPage()),
          route('/practice', (_) => const PracticePage()),
          route('/planner', (_) => const PlannerPage()),
          route('/saved', (_) => const SavedPage()),
          route('/resources', (_) => const ResourcesPage()),
          route('/directory/:type', (state) {
            final type = state.pathParameters['type']!;
            return DirectoryPage(key: ValueKey(type), type: type);
          }),
          route('/account', (_) => const AccountPage()),
          route('/help', (_) => const HelpPage()),
        ],
      ),
    ],
  );
}
