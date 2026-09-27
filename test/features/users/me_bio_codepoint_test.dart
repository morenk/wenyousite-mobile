import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/users/presentation/me_page.dart';

import 'me_page_test_support.dart';

void main() {
  testWidgets('简介可见计数按trim后的码点计算组合emoji', (tester) async {
    await _pump(tester);
    await tester.enterText(find.byKey(_bioKey), ' 👨‍👩‍👧‍👦 ');
    await tester.pump();
    expect(find.text('7/255'), findsOneWidget);
  });

  testWidgets('简介255码点可提交，256码点保留输入且不请求', (tester) async {
    final repository = await _pump(tester);
    final boundary = '${'👨‍👩‍👧‍👦' * 36}abc';
    await tester.enterText(find.byKey(_bioKey), boundary);
    await tester.pump();
    await tester.tap(find.byKey(const Key('me-settings-save')));
    await tester.pumpAndSettle();
    expect(repository.updateCalls, 1);
    expect(repository.lastPatch?.bio, boundary);

    await tester.enterText(find.byKey(_bioKey), '${boundary}d');
    await tester.pump();
    await tester.tap(find.byKey(const Key('me-settings-save')));
    await tester.pumpAndSettle();
    expect(repository.updateCalls, 1);
    expect(find.text('简介最多 255 个字符'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(find.byKey(_bioKey)).controller!.text,
      '${boundary}d',
    );
    expect(find.text('256/255'), findsOneWidget);
  });
}

const _bioKey = Key('me-bio-field');

Future<MePageTestFakeMeProfileRepository> _pump(WidgetTester tester) async {
  final repository = MePageTestFakeMeProfileRepository();
  final container = await mePageTestAuthenticatedContainer(repository);
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(theme: AppTheme.light, home: const MeEditPage()),
    ),
  );
  await tester.pumpAndSettle();
  return repository;
}
