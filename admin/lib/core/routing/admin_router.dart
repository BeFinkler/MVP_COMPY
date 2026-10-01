import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/admin_auth_feature.dart';
import '../../features/auth/presentation/admin_auth_screens.dart';
import '../../features/dashboard/data/admin_dashboard_repository.dart';
import '../../features/dashboard/presentation/admin_dashboard_page.dart';
import '../../features/places/data/admin_places_repository.dart';
import '../../features/places/presentation/admin_places_page.dart';
import '../../features/users/data/admin_users_repository.dart';
import '../../features/users/presentation/admin_users_pages.dart';
import '../shell/admin_shell.dart';

const _publicRoutes = <String>{'/login', '/unauthorized'};

/// Decisão pura para testar redirecionamentos e deep links sem Firebase.
String? redirectForAdminRoute({
  required String location,
  required AdminAccessState accessState,
}) {
  final isPublicRoute = _publicRoutes.contains(location);

  return switch (accessState) {
    AdminAccessState.authorized => isPublicRoute ? '/dashboard' : null,
    AdminAccessState.unauthorized =>
      location == '/unauthorized' ? null : '/unauthorized',
    AdminAccessState.signedOut ||
    AdminAccessState.loading => isPublicRoute ? null : '/login',
  };
}

GoRouter createAdminRouter({
  required AdminAuthController authController,
  String? initialLocation,
  AdminDashboardRepository? dashboardRepository,
  AdminPlacesRepository? placesRepository,
  AdminUsersRepository? usersRepository,
}) {
  return GoRouter(
    initialLocation: initialLocation ?? '/dashboard',
    refreshListenable: authController,
    redirect: (context, state) => redirectForAdminRoute(
      location: state.uri.path,
      accessState: authController.state,
    ),
    routes: <RouteBase>[
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            AdminLoginScreen(controller: authController),
      ),
      GoRoute(
        path: '/unauthorized',
        builder: (context, state) =>
            AdminUnauthorizedScreen(controller: authController),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => AdminShell(
          controller: authController,
          location: state.uri.path,
          child: AdminDashboardPage(repository: dashboardRepository),
        ),
      ),
      GoRoute(
        path: '/places',
        builder: (context, state) {
          final initialStatus =
              state.uri.queryParameters['status'] == 'inactive'
              ? AdminPlaceStatusFilter.inactive
              : AdminPlaceStatusFilter.all;
          return AdminShell(
            controller: authController,
            location: state.uri.path,
            child: AdminPlacesPage(
              repository: placesRepository,
              initialStatus: initialStatus,
            ),
          );
        },
      ),
      GoRoute(
        path: '/places/new',
        builder: (context, state) => AdminShell(
          controller: authController,
          location: state.uri.path,
          child: const AdminRoutePlaceholder(
            title: 'Cadastrar Local Esportivo',
          ),
        ),
      ),
      GoRoute(
        path: '/places/:id',
        builder: (context, state) => AdminShell(
          controller: authController,
          location: state.uri.path,
          child: const AdminRoutePlaceholder(
            title: 'Detalhes do Local Esportivo',
          ),
        ),
      ),
      GoRoute(
        path: '/users',
        builder: (context, state) => AdminShell(
          controller: authController,
          location: state.uri.path,
          child: AdminUsersPage(repository: usersRepository),
        ),
      ),
      GoRoute(
        path: '/users/:uid',
        builder: (context, state) {
          final uid = state.pathParameters['uid']!;
          final extra = state.extra;
          return AdminShell(
            controller: authController,
            location: state.uri.path,
            child: AdminUserDetailsPage(
              uid: uid,
              repository: usersRepository,
              initialDetails: extra is AdminUserDetailsResult ? extra : null,
            ),
          );
        },
      ),
    ],
  );
}
