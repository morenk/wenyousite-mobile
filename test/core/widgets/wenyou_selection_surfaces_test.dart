import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_author_picker.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_avatar_button.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_filter_controls.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_selection_menu.dart';

import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);

  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      _testWithShadows('选项菜单 ${dark ? 'dark' : 'light'} ${scale}x 长文字可读且不溢出', (
        tester,
      ) async {
        _viewport(tester, scale == 2 ? 320 : 360);
        int? selected;
        await tester.pumpWidget(
          _app(
            dark: dark,
            scale: scale,
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: WenyouDropdownFilter<int>(
                  key: const Key('selector'),
                  tooltip: '选择主题状态',
                  appearance: WenyouDropdownFilterAppearance.quiet,
                  selected: 0,
                  options: const [
                    WenyouFilterOption(value: 0, label: '全部状态', keyValue: 0),
                    WenyouFilterOption(value: 1, label: '招募中', keyValue: 1),
                    WenyouFilterOption(value: 2, label: '已停招', keyValue: 2),
                    WenyouFilterOption(
                      value: 3,
                      label: '一个需要完整阅读的很长选项名称',
                      keyValue: 3,
                    ),
                  ],
                  optionKeyPrefix: 'choice',
                  onSelected: (value) => selected = value,
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.byKey(const Key('selector')));
        await tester.pumpAndSettle();
        expect(find.byType(BottomSheet), findsNothing);
        expect(tester.takeException(), isNull);
        final first = find.byKey(const Key('choice-0'));
        expect(
          tester.getTopLeft(first).dy,
          greaterThan(
            tester.getBottomLeft(find.byKey(const Key('selector'))).dy,
          ),
        );
        final semantics = tester.ensureSemantics();
        expect(
          tester.getSemantics(
            find.descendant(
              of: first,
              matching: find.byType(WenyouSelectionRow),
            ),
          ),
          matchesSemantics(
            isSelected: true,
            isButton: true,
            hasEnabledState: true,
            isEnabled: true,
            isFocusable: true,
            hasTapAction: true,
            hasFocusAction: true,
            hasSelectedState: true,
            label: '全部状态',
            textDirection: TextDirection.ltr,
          ),
        );
        semantics.dispose();
        await expectLater(
          find.byType(Overlay).first,
          matchesGoldenFile(
            'goldens/selection_menu_${dark ? 'dark' : 'light'}_${scale.toInt()}x.png',
          ),
        );
        await tester.ensureVisible(find.byKey(const Key('choice-3')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('choice-3')));
        await tester.pumpAndSettle();
        expect(selected, 3);
        expect(find.byType(PopupMenuItem<int>), findsNothing);
      });
    }
  }

  _testWithShadows('取消、重选、空选项与禁用均不触发选择', (tester) async {
    var calls = 0;
    Future<void> build({bool enabled = true, bool empty = false}) =>
        tester.pumpWidget(
          _app(
            child: WenyouDropdownFilter<int>(
              key: const Key('selector'),
              tooltip: '筛选',
              selected: 0,
              enabled: enabled,
              options: empty
                  ? []
                  : const [WenyouFilterOption(value: 0, label: '已选项')],
              onSelected: (_) => calls++,
            ),
          ),
        );
    await build();
    await tester.tap(find.byKey(const Key('selector')));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(calls, 0);
    await tester.tap(find.byKey(const Key('selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('已选项').last);
    await tester.pumpAndSettle();
    expect(calls, 0);
    await build(enabled: false);
    await tester.tap(find.byKey(const Key('selector')));
    await tester.pumpAndSettle();
    expect(find.byType(PopupMenuItem<int>), findsNothing);
    await build(empty: true);
    await tester.tap(find.byKey(const Key('selector')));
    await tester.pumpAndSettle();
    expect(find.byType(PopupMenuItem<int>), findsNothing);
  });

  _testWithShadows('表单选择保留校验、修改、重置和禁用语义', (tester) async {
    final key = GlobalKey<FormState>();
    final values = <int?>[];
    await tester.pumpWidget(
      _app(
        child: Form(
          key: key,
          child: WenyouDropdownFormField<int>(
            key: const Key('field'),
            decoration: const InputDecoration(labelText: '发帖权限'),
            options: const [WenyouFilterOption(value: 1, label: '所有玩家')],
            onChanged: values.add,
            validator: (value) => value == null ? '请选择发帖权限' : null,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
        ),
      ),
    );
    expect(key.currentState!.validate(), isFalse);
    await tester.pumpAndSettle();
    expect(find.text('请选择发帖权限'), findsOneWidget);
    await tester.tap(find.byKey(const Key('field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('所有玩家'));
    await tester.pumpAndSettle();
    expect(values, [1]);
    expect(key.currentState!.validate(), isTrue);
    key.currentState!.reset();
    await tester.pumpAndSettle();
    expect(find.text('所有玩家'), findsNothing);
    expect(values, [1, null]);
  });

  _testWithShadows('表单接收外部回填值，禁用时无法打开', (tester) async {
    Future<void> build(int initialValue, bool enabled) => tester.pumpWidget(
      _app(
        child: WenyouDropdownFormField<int>(
          key: const Key('field'),
          initialValue: initialValue,
          options: const [
            WenyouFilterOption(value: 1, label: '开放发言'),
            WenyouFilterOption(value: 2, label: '仅玩家'),
          ],
          onChanged: enabled ? (_) {} : null,
        ),
      ),
    );
    await build(1, true);
    expect(find.text('开放发言'), findsOneWidget);
    await build(2, false);
    expect(find.text('仅玩家'), findsOneWidget);
    expect(find.text('开放发言'), findsNothing);
    await tester.tap(find.byKey(const Key('field')));
    await tester.pumpAndSettle();
    expect(find.byType(PopupMenuItem<int>), findsNothing);
  });

  for (final dark in [false, true]) {
    _testWithShadows('作者抽屉 ${dark ? 'dark' : 'light'} 展示头像、身份与所有人', (
      tester,
    ) async {
      _viewport(tester, 360);
      WenyouAuthorSelection? result;
      await tester.pumpWidget(
        _authorApp(
          dark: dark,
          selectedId: 'user-1',
          onResult: (value) => result = value,
          authors: const [
            WenyouDiscussionAuthorOption(
              id: 'user-1',
              label: '星海旅人',
              supportingLabel: '楼主',
            ),
            WenyouDiscussionAuthorOption(
              id: 'user-2',
              label: '下一位接力者',
              supportingLabel: '协作者',
            ),
            WenyouDiscussionAuthorOption(
              id: 'user-3',
              label: '向着远方航行的人',
              supportingLabel: '玩家',
            ),
          ],
        ),
      );
      await tester.tap(find.text('选择作者'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byType(WenyouAvatar), findsNWidgets(3));
      expect(find.text('星'), findsOneWidget);
      expect(find.text('楼主'), findsOneWidget);
      for (final avatar in tester.widgetList<WenyouAvatar>(
        find.byType(WenyouAvatar),
      )) {
        expect(avatar.size, 40);
      }
      await expectLater(
        find.byType(Overlay).first,
        matchesGoldenFile(
          'goldens/author_picker_${dark ? 'dark' : 'light'}_360.png',
        ),
      );
      await tester.tap(find.byKey(const ValueKey('discussion-author-all')));
      await tester.pumpAndSettle();
      expect(result, isNotNull);
      expect(result!.authorId, isNull);
      expect(find.byType(BottomSheet), findsNothing);
    });
  }

  _testWithShadows('作者目录头像传给共享图片，点击头像只选择作者', (tester) async {
    _viewport(tester, 360);
    WenyouAuthorSelection? result;
    await tester.pumpWidget(
      _authorApp(
        selectedId: null,
        authors: const [
          WenyouDiscussionAuthorOption(
            id: 'with-avatar',
            label: '有头像的作者',
            supportingLabel: '玩家',
            avatarUrl: 'https://cdn.example.com/author-avatar.webp',
          ),
        ],
        onResult: (value) => result = value,
      ),
    );
    await tester.tap(find.text('选择作者'));
    await tester.pumpAndSettle();
    final image = tester.widget<WenyouCachedImage>(
      find.byType(WenyouCachedImage),
    );
    expect(image.imageUrl, 'https://cdn.example.com/author-avatar.webp');
    final fallback = image.errorWidget!(
      tester.element(find.byType(WenyouCachedImage)),
      image.imageUrl,
      StateError('图片不可用'),
    );
    await tester.tap(find.byType(WenyouAvatar));
    await tester.pumpAndSettle();
    expect(result?.authorId, 'with-avatar');
    expect(find.byType(BottomSheet), findsNothing);
    await tester.pumpWidget(_app(child: fallback));
    await tester.pumpAndSettle();
    expect(find.text('有'), findsOneWidget);
  });

  _testWithShadows('长作者名单两倍字号打开定位选中项，取消保留原选择', (tester) async {
    _viewport(tester, 320);
    var completed = false;
    WenyouAuthorSelection? result;
    await tester.pumpWidget(
      _authorApp(
        scale: 2,
        selectedId: 'user-35',
        authors: List.generate(
          40,
          (index) => WenyouDiscussionAuthorOption(
            id: 'user-$index',
            label: '第 $index 位长名字作者',
            supportingLabel: '协作者',
          ),
        ),
        onResult: (value) {
          completed = true;
          result = value;
        },
      ),
    );
    await tester.tap(find.text('选择作者'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('discussion-author-user-35')).hitTestable(),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('关闭作者筛选'));
    await tester.pumpAndSettle();
    expect(completed, isTrue);
    expect(result, isNull);
  });
}

void _viewport(WidgetTester tester, double width) {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _app({required Widget child, bool dark = false, double scale = 1}) =>
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: dark ? AppTheme.dark : AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: Scaffold(body: SafeArea(child: child)),
    );

Widget _authorApp({
  required List<WenyouDiscussionAuthorOption> authors,
  required String? selectedId,
  required ValueChanged<WenyouAuthorSelection?> onResult,
  bool dark = false,
  double scale = 1,
}) => _app(
  dark: dark,
  scale: scale,
  child: Builder(
    builder: (context) => Center(
      child: TextButton(
        onPressed: () async => onResult(
          await showWenyouAuthorPicker(
            context: context,
            authors: authors,
            selectedId: selectedId,
            allAuthorsLabel: '所有人',
          ),
        ),
        child: const Text('选择作者'),
      ),
    ),
  ),
);

void _testWithShadows(
  String description,
  Future<void> Function(WidgetTester) body,
) {
  testWidgets(description, (tester) async {
    final previous = debugDisableShadows;
    debugDisableShadows = false;
    try {
      await body(tester);
    } finally {
      debugDisableShadows = previous;
    }
  });
}
