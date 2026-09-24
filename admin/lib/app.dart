import 'package:flutter/material.dart';

import 'core/constants/admin_strings.dart';
import 'core/theme/admin_theme.dart';
import 'features/auth/presentation/admin_auth_feature.dart';
import 'features/dashboard/presentation/admin_dashboard_feature.dart';
import 'features/places/presentation/admin_places_feature.dart';
import 'features/users/presentation/admin_users_feature.dart';

typedef FirebaseInitializer = Future<void> Function();

/// Limite de inicialização do painel.
///
/// O shell, as rotas protegidas e as leituras administrativas entram no ticket
/// de autenticação. Até lá, este widget garante que o Firebase esteja pronto
/// antes de exibir a fundação neutra do app.
class CompyAdminBootstrap extends StatefulWidget {
  const CompyAdminBootstrap({
    required this.initialize,
    super.key,
  });

  final FirebaseInitializer initialize;

  @override
  State<CompyAdminBootstrap> createState() => _CompyAdminBootstrapState();
}

class _CompyAdminBootstrapState extends State<CompyAdminBootstrap> {
  late final Future<void> _initialization = widget.initialize();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            title: AdminStrings.appTitle,
            theme: AdminTheme.light,
            home: const _AdminStartupScreen(
              title: AdminStrings.initializationErrorTitle,
              body: AdminStrings.initializationErrorBody,
              icon: Icons.cloud_off_outlined,
            ),
          );
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            title: AdminStrings.appTitle,
            theme: AdminTheme.light,
            home: const _AdminStartupScreen(
              title: AdminStrings.initializingTitle,
              body: AdminStrings.initializingBody,
              showProgress: true,
            ),
          );
        }

        return const CompyAdminApp();
      },
    );
  }
}

/// App neutro da fundação. Autorização e rotas administrativas são adicionadas
/// separadamente para evitar renderizar conteúdo antes do guard real existir.
class CompyAdminApp extends StatelessWidget {
  const CompyAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AdminStrings.appTitle,
      theme: AdminTheme.light,
      home: const _AdminFoundationScreen(),
    );
  }
}

class _AdminStartupScreen extends StatelessWidget {
  const _AdminStartupScreen({
    required this.title,
    required this.body,
    this.icon = Icons.admin_panel_settings_outlined,
    this.showProgress = false,
  });

  final String title;
  final String body;
  final IconData icon;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Semantics(
          liveRegion: true,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(icon, size: 48),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    body,
                    textAlign: TextAlign.center,
                  ),
                  if (showProgress) ...<Widget>[
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminFoundationScreen extends StatelessWidget {
  const _AdminFoundationScreen();

  @override
  Widget build(BuildContext context) {
    final modules = <String>[
      AdminAuthFeature.name,
      AdminDashboardFeature.name,
      AdminPlacesFeature.name,
      AdminUsersFeature.name,
    ];

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AdminStrings.foundationTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(AdminStrings.foundationBody),
                const SizedBox(height: 20),
                Text(
                  AdminStrings.foundationModulesLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final module in modules) Text('• $module'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
