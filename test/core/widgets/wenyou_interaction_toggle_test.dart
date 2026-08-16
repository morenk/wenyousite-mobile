import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_interaction_toggle.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('选中互动使用 Foundation 语义色、实心资产与最小点按区', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Center(
            child: WenyouInteractionToggle(
              key: Key('like'),
              kind: WenyouInteractionKind.like,
              selected: true,
              semanticLabel: '取消点赞',
              onPressed: _noop,
            ),
          ),
        ),
      ),
    );

    final context = tester.element(find.byKey(const Key('like')));
    final tokens = context.wenyouTokens;
    expect(
      tester.getSize(find.byKey(const Key('like'))).width,
      greaterThanOrEqualTo(48),
    );
    expect(
      tester.getSize(find.byKey(const Key('like'))).height,
      greaterThanOrEqualTo(48),
    );
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(
      tester
          .widget<Material>(
            find.descendant(
              of: find.byKey(const Key('like')),
              matching: find.byType(Material),
            ),
          )
          .color,
      tokens.likeSoft,
    );
    final semantics = tester.getSemantics(find.byKey(const Key('like')));
    expect(semantics.label, '取消点赞');
    expect(
      semantics.getSemanticsData().flagsCollection.isToggled,
      Tristate.isTrue,
    );
  });

  testWidgets('只读互动保持中性且不暴露按钮语义', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: WenyouInteractionToggle(
            key: Key('read-only-bookmark'),
            kind: WenyouInteractionKind.bookmark,
            selected: true,
            interactive: false,
            semanticLabel: '收藏状态',
          ),
        ),
      ),
    );

    expect(find.byType(SvgPicture), findsOneWidget);
    expect(
      tester
          .widget<Material>(
            find.descendant(
              of: find.byKey(const Key('read-only-bookmark')),
              matching: find.byType(Material),
            ),
          )
          .color,
      Colors.transparent,
    );
    final semantics = tester.getSemantics(
      find.byKey(const Key('read-only-bookmark')),
    );
    expect(semantics.getSemanticsData().flagsCollection.isButton, isFalse);
    expect(
      semantics.getSemanticsData().flagsCollection.isToggled,
      Tristate.none,
    );
    expect(
      semantics.getSemanticsData().hasAction(SemanticsAction.tap),
      isFalse,
    );
  });

  testWidgets('提交中保留选中图标并阻止重复点击', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: WenyouInteractionToggle(
            key: const Key('pending'),
            kind: WenyouInteractionKind.bookmark,
            selected: true,
            pending: true,
            semanticLabel: '收藏中',
            onPressed: () => taps += 1,
          ),
        ),
      ),
    );

    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byKey(const Key('pending')));
    expect(taps, 0);
  });
}

void _noop() {}
