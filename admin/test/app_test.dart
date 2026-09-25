import 'dart:async';

import 'package:compy_admin/app.dart';
import 'package:compy_admin/core/constants/admin_strings.dart';
import 'package:compy_admin/core/routing/admin_router.dart';
import 'package:compy_admin/core/shell/admin_shell.dart';
import 'package:compy_admin/features/auth/presentation/admin_auth_feature.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('guard protege deep links e mantém apenas as rotas públicas abertas', () {
    expect(
      redirectForAdminRoute(
        location: '/users/a-user',
        accessState: AdminAccessState.signedOut,
      ),
      '/login',
    );
    expect(
      redirectForAdminRoute(
        location: '/places/new',
        accessState: AdminAccessState.unauthorized,
      ),
      '/unauthorized',
    );
    expect(
      redirectForAdminRoute(
        location: '/login',
        accessState: AdminAccessState.authorized,
      ),
      '/dashboard',
    );
    expect(
      redirectForAdminRoute(
        location: '/unauthorized',
        accessState: AdminAccessState.unauthorized,
      ),
      isNull,
    );
  });

  test('breakpoint do shell separa sidebar permanente e recolhível', () {
    expect(usesDesktopAdminNavigation(839), isFalse);
    expect(usesDesktopAdminNavigation(840), isTrue);
  });

  test('sessão sem todos os requisitos administrativos é encerrada', () async {
    final gateway = _FakeAdminAuthGateway(
      candidate: const AdminAuthCandidate(
        uid: 'not-admin',
        email: 'person@example.com',
        emailVerified: true,
        providerIds: <String>{'password'},
        claims: <String, Object?>{},
      ),
    );
    final controller = AdminAuthController(gateway);

    await controller.start();

    expect(gateway.usedSessionPersistence, isTrue);
    expect(gateway.signOutCalls, 1);
    expect(controller.state, AdminAccessState.unauthorized);
    expect(controller.session, isNull);
    controller.dispose();
  });

  testWidgets('mostra carregamento até Firebase e autorização estarem resolvidos',
      (tester) async {
    final initialization = Completer<void>();
    final authorization = Completer<AdminAuthCandidate?>();

    await tester.pumpWidget(
      CompyAdminBootstrap(
        initialize: () => initialization.future,
        authGatewayFactory: () => _FakeAdminAuthGateway(
          candidateFuture: authorization.future,
        ),
      ),
    );

    expect(find.text(AdminStrings.initializingTitle), findsOneWidget);
    initialization.complete();
    await tester.pump();
    expect(find.text(AdminStrings.authorizationLoadingTitle), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    authorization.complete(null);
    await tester.pumpAndSettle();
    expect(find.text(AdminStrings.loginTitle), findsOneWidget);
  });

  testWidgets('login usa somente e-mail e senha e libera o shell autorizado',
      (tester) async {
    final gateway = _FakeAdminAuthGateway(candidate: null)
      ..candidateAfterLogin = const AdminAuthCandidate(
        uid: 'admin-uid',
        email: 'admin@compy.app',
        emailVerified: true,
        providerIds: <String>{'password'},
        claims: <String, Object?>{'admin': true},
      );

    await tester.pumpWidget(CompyAdminApp(authGateway: gateway));
    await tester.pumpAndSettle();

    expect(find.text(AdminStrings.loginTitle), findsOneWidget);
    expect(find.textContaining('Google'), findsNothing);
    await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), ' admin@compy.app ');
    await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), 'secret');
    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.pumpAndSettle();

    expect(gateway.lastLoginEmail, 'admin@compy.app');
    expect(gateway.lastLoginPassword, 'secret');
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.byTooltip('Sair'), findsOneWidget);
  });

  testWidgets('deep link de usuário usa o mesmo guard no shell desktop',
      (tester) async {
    final authorizedGateway = _FakeAdminAuthGateway(candidate: _authorizedCandidate);
    await tester.pumpWidget(
      CompyAdminApp(
        authGateway: authorizedGateway,
        initialLocation: '/users/a-user',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Detalhes do Usuário'), findsOneWidget);
    expect(find.byTooltip('Sair'), findsOneWidget);
  });

  testWidgets('tela não autorizada oferece retorno ao login com foco acessível',
      (tester) async {
    final gateway = _FakeAdminAuthGateway(
      candidate: const AdminAuthCandidate(
        uid: 'unverified-admin',
        email: 'admin@compy.app',
        emailVerified: false,
        providerIds: <String>{'password'},
        claims: <String, Object?>{'admin': true},
      ),
    );

    await tester.pumpWidget(CompyAdminApp(authGateway: gateway));
    await tester.pumpAndSettle();

    expect(find.text(AdminStrings.unauthorizedTitle), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    expect(find.widgetWithText(FilledButton, 'Voltar ao login'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Voltar ao login'));
    await tester.pumpAndSettle();
    expect(find.text(AdminStrings.loginTitle), findsOneWidget);
  });
}

const _authorizedCandidate = AdminAuthCandidate(
  uid: 'admin-uid',
  email: 'admin@compy.app',
  emailVerified: true,
  providerIds: <String>{'password'},
  claims: <String, Object?>{'admin': true},
);

class _FakeAdminAuthGateway implements AdminAuthGateway {
  _FakeAdminAuthGateway({this.candidate, this.candidateFuture});

  AdminAuthCandidate? candidate;
  Future<AdminAuthCandidate?>? candidateFuture;
  AdminAuthCandidate? candidateAfterLogin;
  bool usedSessionPersistence = false;
  int signOutCalls = 0;
  String? lastLoginEmail;
  String? lastLoginPassword;

  @override
  Stream<void> get authStateChanges => const Stream<void>.empty();

  @override
  Future<AdminAuthCandidate?> refreshCurrentSession() async =>
      candidateFuture == null ? candidate : candidateFuture!;

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    lastLoginEmail = email;
    lastLoginPassword = password;
    candidate = candidateAfterLogin;
    candidateFuture = null;
  }

  @override
  Future<void> signOut() async {
    signOutCalls += 1;
    candidate = null;
  }

  @override
  Future<void> useSessionPersistence() async {
    usedSessionPersistence = true;
  }
}
