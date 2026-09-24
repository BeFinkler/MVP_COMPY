import 'dart:async';

import 'package:compy_admin/app.dart';
import 'package:compy_admin/core/constants/admin_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('mostra carregamento até o Firebase estar inicializado',
      (tester) async {
    final completer = Completer<void>();

    await tester.pumpWidget(
      CompyAdminBootstrap(initialize: () => completer.future),
    );

    expect(find.text(AdminStrings.initializingTitle), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete();
    await tester.pumpAndSettle();

    expect(find.text(AdminStrings.foundationTitle), findsOneWidget);
    expect(find.text(AdminStrings.foundationBody), findsOneWidget);
  });

  testWidgets('mostra falha de inicialização sem renderizar o painel',
      (tester) async {
    await tester.pumpWidget(
      CompyAdminBootstrap(
        initialize: () =>
            Future<void>.error(StateError('Firebase indisponível')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AdminStrings.initializationErrorTitle), findsOneWidget);
    expect(find.text(AdminStrings.foundationTitle), findsNothing);
  });
}
