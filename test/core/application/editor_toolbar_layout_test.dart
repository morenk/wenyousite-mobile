import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/application/editor_toolbar_layout.dart';

void main() {
  const defaults = EditorToolbarLayout.defaults();
  final all = EditorTool.values.toSet();

  test('默认保留窄屏草稿行及宽屏提升顺序', () {
    for (final entry in {
      6: [
        EditorTool.heading,
        EditorTool.bold,
        EditorTool.italic,
        EditorTool.image,
      ],
      7: [
        EditorTool.heading,
        EditorTool.bold,
        EditorTool.italic,
        EditorTool.image,
        EditorTool.drafts,
      ],
      8: [
        EditorTool.heading,
        EditorTool.bold,
        EditorTool.italic,
        EditorTool.image,
        EditorTool.quote,
        EditorTool.drafts,
      ],
      12: [
        EditorTool.heading,
        EditorTool.bold,
        EditorTool.italic,
        EditorTool.image,
        EditorTool.quote,
        EditorTool.sticker,
        EditorTool.drafts,
      ],
    }.entries) {
      final resolved = defaults.resolve(
        slots: entry.key,
        available: all,
        showMore: true,
        showSubmit: true,
      );
      expect(resolved.primary, entry.value);
      expect(resolved.dedicatedDraft, entry.key == 6);
      expect(resolved.expanded.contains(EditorTool.horizontalRule), isTrue);
    }
  });

  test('跨组移动及同组重排保存精确顺序，不修改原布局', () {
    final moved = defaults
        .move(EditorTool.sticker, EditorToolbarGroup.primary, 0)
        .move(EditorTool.image, EditorToolbarGroup.expanded, 1);
    expect(moved.primary.first, EditorTool.sticker);
    expect(moved.expanded[1], EditorTool.image);
    expect(moved.isDefault, isFalse);
    expect(defaults.primary, EditorToolbarLayout.defaultPrimary);
    expect(() => moved.primary.add(EditorTool.image), throwsUnsupportedError);
  });

  test('自定义所有容量与能力过滤均无丢失、无重复且不改写用户意图', () {
    final layout = EditorToolbarLayout.custom(
      primary: EditorTool.values.reversed.toList(),
      expanded: [],
    );
    for (final available in [
      all,
      {EditorTool.heading, EditorTool.image, EditorTool.link},
      <EditorTool>{},
    ]) {
      for (var slots = 2; slots < 20; slots++) {
        for (final submit in [false, true]) {
          final resolved = layout.resolve(
            slots: slots,
            available: available,
            showMore: true,
            showSubmit: submit,
          );
          final visible = [...resolved.primary, ...resolved.expanded];
          expect(visible.toSet(), available);
          expect(visible.length, available.length);
          expect(visible, layout.primary.where(available.contains));
          expect(
            resolved.primary.length,
            lessThanOrEqualTo(slots - 1 - (submit ? 1 : 0)),
          );
        }
      }
    }
    expect(layout.primary, EditorTool.values.reversed);
  });

  test('溢出排在已指定展开项之前，两组各自顺序稳定，回宽屏复原', () {
    final layout = EditorToolbarLayout.custom(
      primary: [EditorTool.sticker, EditorTool.image, EditorTool.bold],
      expanded: [EditorTool.dice, EditorTool.link],
    );
    final narrow = layout.resolve(
      slots: 3,
      available: all,
      showMore: true,
      showSubmit: true,
    );
    expect(narrow.primary, [EditorTool.sticker]);
    expect(narrow.expanded.take(4), [
      EditorTool.image,
      EditorTool.bold,
      EditorTool.dice,
      EditorTool.link,
    ]);
    final wide = layout.resolve(
      slots: 12,
      available: all,
      showMore: true,
      showSubmit: true,
    );
    expect(wide.primary, layout.primary);
    expect(wide.expanded, layout.expanded);
  });

  test('版本校验、未知旧列表及重复ID安全规整，缺失能力追加展开栏', () {
    final layout = EditorToolbarLayout.fromJson({
      'version': 1,
      'primary': [
        'sticker',
        'sticker',
        'ordered-list',
        'bullet-list',
        'audio',
        1,
      ],
      'expanded': ['sticker', 'link', 'link'],
    });
    expect(layout.primary, [EditorTool.sticker]);
    expect(layout.expanded.first, EditorTool.link);
    expect({...layout.primary, ...layout.expanded}, all);
    for (final data in [
      null,
      [],
      {},
      {'version': 9},
      {'version': 1, 'primary': 'bad', 'expanded': []},
    ]) {
      expect(EditorToolbarLayout.fromJson(data).isDefault, isTrue);
    }
    expect(
      EditorToolbarLayout.defaultGroupForId(
        EditorToolbarLayout.reservedAudioId,
      ),
      EditorToolbarGroup.expanded,
    );
    expect(EditorTool.fromId('audio'), isNull);
    expect(EditorTool.values.any((tool) => tool.id.contains('list')), isFalse);
  });
}
