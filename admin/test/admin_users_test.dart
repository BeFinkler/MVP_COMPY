import 'package:compy_admin/features/users/data/admin_users_repository.dart';
import 'package:compy_admin/features/users/presentation/admin_users_controller.dart';
import 'package:compy_admin/features/users/presentation/admin_users_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('contratos de pesquisa de Usuário', () {
    test('normaliza prefixo de Nome e converte Handle para @prefixo', () {
      final name = AdminUsersQueryPlan.fromSearch(
        AdminUserSearchType.name,
        '  JÚLIA  ',
      );
      final handle = AdminUsersQueryPlan.fromSearch(
        AdminUserSearchType.handle,
        '  @MaRiA  ',
      );

      expect(name.field, 'nameLower');
      expect(name.prefix, 'julia');
      expect(handle.field, 'handle');
      expect(handle.prefix, '@maria');
      expect(AdminUsersQueryPlan.pageSize, 20);
      expect(
        () => AdminUsersQueryPlan.fromSearch(AdminUserSearchType.uid, 'abc'),
        throwsArgumentError,
      );
    });

    test('mapeia somente campos públicos do perfil e whitelist Auth', () {
      final profile = AdminUserProfile.fromDocument('uid-1', <String, dynamic>{
        'id': 'forged-id',
        'name': 'Júlia',
        'handle': '@julia',
        'avatarUrl': 'https://example.test/avatar.png',
        'favoriteSports': <String>['corrida', 'corrida', 'futebol'],
        'email': 'must-not-be-profile-data@example.test',
        'private': <String, Object?>{'phone': 'private'},
        'passwordHash': 'never-model-this',
      });
      final auth = AdminUserAuthDetails.fromCallable(<String, Object?>{
        'uid': 'uid-1',
        'email': 'julia@example.test',
        'emailVerified': true,
        'providerIds': <String>['password'],
        'createdAt': '2026-01-02T03:04:05.000Z',
        'lastSignInAt': null,
        'disabled': false,
        'passwordHash': 'never-model-this',
        'refreshTokens': <String>['secret'],
      });

      expect(profile.uid, 'uid-1');
      expect(profile.favoriteSports, <String>['corrida', 'futebol']);
      expect(auth.email, 'julia@example.test');
      expect(auth.providerIds, <String>['password']);
      expect(auth.createdAt, DateTime.utc(2026, 1, 2, 3, 4, 5));
      expect(auth.disabled, isFalse);
    });

    test('Callables usam endpoints e payloads exatos aprovados', () async {
      final calls = <(String, Map<String, Object?>)>[];
      final client = AdminUsersCallableClient(
        invoker: (name, payload) async {
          calls.add((name, Map<String, Object?>.from(payload)));
          return const <String, Object?>{'items': <Object?>[]};
        },
      );

      await client.getAdminUserAuthDetails(uid: 'uid-1');
      await client.getAdminUserAuthDetails(email: ' PERSON@EXAMPLE.TEST ');
      await client.getAdminUsersAuthStatus(<String>['uid-1', 'uid-2']);

      expect(calls.map((call) => call.$1), <String>[
        'getAdminUserAuthDetails',
        'getAdminUserAuthDetails',
        'getAdminUsersAuthStatus',
      ]);
      expect(calls[0].$2, <String, Object?>{'uid': 'uid-1'});
      expect(calls[1].$2, <String, Object?>{'email': 'person@example.test'});
      expect(calls[2].$2, <String, Object?>{
        'uids': <String>['uid-1', 'uid-2'],
      });
      expect(
        () => client.getAdminUserAuthDetails(uid: 'uid-1', email: 'a@b.test'),
        throwsArgumentError,
      );
    });
  });

  group('AdminUsersController', () {
    test(
      'pagina com cursor e preserva cada estado Auth, inclusive falha',
      () async {
        final firstCursor = _Cursor('page-1');
        final repo = _FakeUsersRepository()
          ..pages.add(
            AdminUsersPageSnapshot(
              items: <AdminUserListItem>[
                _item('active', AdminUserAuthState.active),
                _item('suspended', AdminUserAuthState.suspended),
                _item('missing', AdminUserAuthState.notFound),
                _item('unavailable', AdminUserAuthState.unavailable),
              ],
              cursor: firstCursor,
              isFromCache: true,
            ),
          )
          ..pages.add(
            const AdminUsersPageSnapshot(
              items: <AdminUserListItem>[],
              cursor: null,
              isFromCache: false,
            ),
          );
        final controller = AdminUsersController(repo);

        await controller.search(AdminUserSearchType.name, ' Ju');
        expect(controller.state.items, hasLength(4));
        expect(controller.state.hasMore, isTrue);
        expect(controller.state.isFromCache, isTrue);
        expect(
          controller.state.items.map((item) => item.authState),
          <AdminUserAuthState>[
            AdminUserAuthState.active,
            AdminUserAuthState.suspended,
            AdminUserAuthState.notFound,
            AdminUserAuthState.unavailable,
          ],
        );

        await controller.loadNextPage();
        expect(repo.searchCalls, hasLength(2));
        expect(repo.searchCalls.last.after, same(firstCursor));
        expect(controller.state.items, hasLength(4));
        expect(controller.state.hasMore, isFalse);
        controller.dispose();
      },
    );

    test(
      'UID e e-mail usam apenas consulta exata, sem consulta de lista',
      () async {
        final result = _details('uid-1');
        final repo = _FakeUsersRepository()..exactResult = result;
        final controller = AdminUsersController(repo);

        final byUid = await controller.search(AdminUserSearchType.uid, 'uid-1');
        expect(byUid, same(result));
        final byEmail = await controller.search(
          AdminUserSearchType.email,
          'person@example.test',
        );
        expect(byEmail, same(result));
        expect(repo.exactCalls, <(AdminUserSearchType, String)>[
          (AdminUserSearchType.uid, 'uid-1'),
          (AdminUserSearchType.email, 'person@example.test'),
        ]);
        expect(repo.searchCalls, isEmpty);
        controller.dispose();
      },
    );

    test('consulta exata ausente gera vazio, não estado Auth ativo', () async {
      final repo = _FakeUsersRepository();
      final controller = AdminUsersController(repo);

      final result = await controller.search(
        AdminUserSearchType.email,
        'x@y.z',
      );

      expect(result, isNull);
      expect(controller.state.exactNotFound, isTrue);
      expect(controller.state.items, isEmpty);
      controller.dispose();
    });
  });

  testWidgets('lista oferece seletor explícito, busca por prefixo e estados', (
    tester,
  ) async {
    final repo = _FakeUsersRepository()
      ..pages.add(
        const AdminUsersPageSnapshot(
          items: <AdminUserListItem>[
            AdminUserListItem(
              profile: AdminUserProfile(
                uid: 'profile-1',
                name: 'Júlia',
                handle: '@julia',
                avatarUrl: '',
                favoriteSports: <String>['corrida'],
              ),
              authState: AdminUserAuthState.unavailable,
            ),
          ],
          cursor: null,
          isFromCache: true,
        ),
      );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AdminUsersPage(repository: repo)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Júlia'), findsOneWidget);
    expect(find.textContaining('Estado indisponível'), findsOneWidget);
    expect(find.textContaining('Exibindo dados em cache'), findsOneWidget);
    expect(find.text('UID'), findsNothing);

    await tester.tap(find.byType(DropdownButtonFormField<AdminUserSearchType>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Handle').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '@Ma');
    await tester.tap(find.widgetWithText(FilledButton, 'Buscar'));
    await tester.pumpAndSettle();

    expect(repo.searchCalls.last.type, AdminUserSearchType.handle);
    expect(repo.searchCalls.last.query, '@Ma');
  });

  testWidgets(
    'detalhe mostra Auth sem perfil e não oferece edição ou suspensão',
    (tester) async {
      final repo = _FakeUsersRepository();
      final details = AdminUserDetailsResult(
        uid: 'auth-only',
        profile: null,
        auth: const AdminUserAuthDetails(
          uid: 'auth-only',
          email: 'admin-target@example.test',
          emailVerified: true,
          providerIds: <String>['password'],
          createdAt: null,
          lastSignInAt: null,
          disabled: true,
        ),
        profileNotFound: true,
        profileUnavailable: false,
        profileFromCache: false,
        authNotFound: false,
        authUnavailable: false,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdminUserDetailsPage(
              uid: 'auth-only',
              repository: repo,
              initialDetails: details,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Perfil não encontrado'), findsOneWidget);
      expect(find.textContaining('admin-target@example.test'), findsOneWidget);
      expect(find.textContaining('Suspensa'), findsOneWidget);
      expect(find.textContaining('Provedores: password'), findsOneWidget);
      expect(find.textContaining('Suspender'), findsNothing);
      expect(find.textContaining('Editar'), findsNothing);
    },
  );

  testWidgets(
    'perfil sem Conta Auth é identificado sem oferecer ação de conta',
    (tester) async {
      final details = AdminUserDetailsResult(
        uid: 'profile-only',
        profile: const AdminUserProfile(
          uid: 'profile-only',
          name: 'Perfil legado',
          handle: '@legado',
          avatarUrl: '',
          favoriteSports: <String>['futebol'],
        ),
        auth: null,
        profileNotFound: false,
        profileUnavailable: false,
        profileFromCache: false,
        authNotFound: true,
        authUnavailable: false,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdminUserDetailsPage(
              uid: 'profile-only',
              repository: _FakeUsersRepository(),
              initialDetails: details,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Conta não encontrada'), findsOneWidget);
      expect(find.text('Perfil legado'), findsOneWidget);
      expect(find.textContaining('Futebol'), findsOneWidget);
      expect(find.textContaining('Reativar'), findsNothing);
      expect(find.textContaining('Suspender'), findsNothing);
    },
  );
}

AdminUserListItem _item(String uid, AdminUserAuthState state) =>
    AdminUserListItem(
      profile: AdminUserProfile(
        uid: uid,
        name: uid,
        handle: '@$uid',
        avatarUrl: '',
        favoriteSports: const <String>[],
      ),
      authState: state,
    );

AdminUserDetailsResult _details(String uid) => AdminUserDetailsResult(
  uid: uid,
  profile: null,
  auth: AdminUserAuthDetails(
    uid: uid,
    email: null,
    emailVerified: false,
    providerIds: const <String>[],
    createdAt: null,
    lastSignInAt: null,
    disabled: false,
  ),
  profileNotFound: true,
  profileUnavailable: false,
  profileFromCache: false,
  authNotFound: false,
  authUnavailable: false,
);

class _Cursor implements AdminUserCursor {
  const _Cursor(this.label);
  final String label;
}

class _SearchCall {
  const _SearchCall(this.type, this.query, this.after);
  final AdminUserSearchType type;
  final String query;
  final AdminUserCursor? after;
}

class _FakeUsersRepository implements AdminUsersRepository {
  final List<AdminUsersPageSnapshot> pages = <AdminUsersPageSnapshot>[];
  final List<_SearchCall> searchCalls = <_SearchCall>[];
  final List<(AdminUserSearchType, String)> exactCalls =
      <(AdminUserSearchType, String)>[];
  AdminUserDetailsResult? exactResult;
  AdminUserDetailsResult? detailResult;

  @override
  Future<AdminUserDetailsResult?> findExact(
    AdminUserSearchType type,
    String query,
  ) async {
    exactCalls.add((type, query));
    return exactResult;
  }

  @override
  Future<AdminUserDetailsResult> loadDetails(String uid) async =>
      detailResult ?? _details(uid);

  @override
  Future<AdminUsersPageSnapshot> searchProfiles(
    AdminUserSearchType type,
    String query, {
    AdminUserCursor? after,
  }) async {
    searchCalls.add(_SearchCall(type, query, after));
    if (pages.isEmpty) {
      return const AdminUsersPageSnapshot(
        items: <AdminUserListItem>[],
        cursor: null,
        isFromCache: false,
      );
    }
    return pages.removeAt(0);
  }
}
