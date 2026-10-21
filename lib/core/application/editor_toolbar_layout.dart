import 'package:flutter/foundation.dart';

enum EditorTool {
  heading('heading', '正文样式'),
  bold('bold', '粗体'),
  italic('italic', '斜体'),
  image('image', '图片'),
  audio('audio', '音频'),
  quote('quote', '引用'),
  sticker('sticker', '表情包'),
  drafts('drafts', '正文草稿'),
  alignCenter('align-center', '居中'),
  alignRight('align-right', '右对齐'),
  link('link', '链接'),
  inlineCode('inline-code', '行内代码'),
  horizontalRule('horizontal-rule', '分隔线'),
  dice('dice', '骰子'),
  strike('strike', '删除线');

  const EditorTool(this.id, this.label);
  final String id;
  final String label;

  static EditorTool? fromId(Object? id) {
    for (final tool in values) {
      if (tool.id == id) return tool;
    }
    return null;
  }
}

enum EditorToolbarGroup { primary, expanded }

@immutable
class EditorToolbarLayout {
  const EditorToolbarLayout.defaults()
    : primary = defaultPrimary,
      expanded = defaultExpanded,
      isDefault = true;

  EditorToolbarLayout.custom({
    required List<EditorTool> primary,
    required List<EditorTool> expanded,
  }) : primary = List.unmodifiable(primary.toSet()),
       expanded = List.unmodifiable({
         ...expanded.where((tool) => !primary.contains(tool)),
         ...EditorTool.values.where(
           (tool) => !primary.contains(tool) && !expanded.contains(tool),
         ),
       }),
       isDefault = false;

  static const defaultPrimary = [
    EditorTool.heading,
    EditorTool.bold,
    EditorTool.italic,
    EditorTool.image,
    EditorTool.quote,
    EditorTool.sticker,
    EditorTool.drafts,
  ];
  static const defaultExpanded = [
    EditorTool.audio,
    EditorTool.alignCenter,
    EditorTool.alignRight,
    EditorTool.link,
    EditorTool.inlineCode,
    EditorTool.horizontalRule,
    EditorTool.dice,
    EditorTool.strike,
  ];

  // 保留早期预留 ID，旧布局新增音频时归入展开栏。
  static const reservedAudioId = 'audio';
  static EditorToolbarGroup defaultGroupForId(String id) =>
      defaultPrimary.any((tool) => tool.id == id)
      ? EditorToolbarGroup.primary
      : EditorToolbarGroup.expanded;

  final List<EditorTool> primary;
  final List<EditorTool> expanded;
  final bool isDefault;

  List<EditorTool> toolsIn(EditorToolbarGroup group) =>
      group == EditorToolbarGroup.primary ? primary : expanded;

  EditorToolbarLayout move(
    EditorTool tool,
    EditorToolbarGroup target,
    int index,
  ) {
    final nextPrimary = primary.where((item) => item != tool).toList();
    final nextExpanded = expanded.where((item) => item != tool).toList();
    final destination = target == EditorToolbarGroup.primary
        ? nextPrimary
        : nextExpanded;
    destination.insert(index.clamp(0, destination.length), tool);
    return EditorToolbarLayout.custom(
      primary: nextPrimary,
      expanded: nextExpanded,
    );
  }

  Map<String, Object> toJson() => {
    'version': 1,
    'primary': primary.map((tool) => tool.id).toList(),
    'expanded': expanded.map((tool) => tool.id).toList(),
  };

  static EditorToolbarLayout fromJson(Object? value) {
    if (value is! Map ||
        value['version'] != 1 ||
        value['primary'] is! List ||
        value['expanded'] is! List) {
      return const EditorToolbarLayout.defaults();
    }
    List<EditorTool> read(Object? raw) => [
      for (final id in raw! as List) ?EditorTool.fromId(id),
    ];
    return EditorToolbarLayout.custom(
      primary: read(value['primary']),
      expanded: read(value['expanded']),
    );
  }

  ResolvedEditorToolbarLayout resolve({
    required int slots,
    required Set<EditorTool> available,
    required bool showMore,
    required bool showSubmit,
  }) {
    final capacity = (slots - (showMore ? 1 : 0) - (showSubmit ? 1 : 0)).clamp(
      0,
      EditorTool.values.length,
    );
    if (!isDefault) {
      final requested = primary.where(available.contains).toList();
      return ResolvedEditorToolbarLayout(
        primary: requested.take(capacity).toList(),
        expanded: [
          ...requested.skip(capacity),
          ...expanded.where(available.contains),
        ],
      );
    }

    // 未自定义时保留原有主栏、草稿独占行与宽屏提升规则。
    final core = defaultPrimary.take(4).where(available.contains).toList();
    final hasDraft = available.contains(EditorTool.drafts);
    final draftInline = hasDraft && capacity > core.length;
    final displayedCore = core.take(capacity).toList();
    final promotionSlots = (capacity - core.length - (draftInline ? 1 : 0))
        .clamp(0, 2);
    final promoted = [
      EditorTool.quote,
      EditorTool.sticker,
    ].where(available.contains).take(promotionSlots).toList();
    final displayedPrimary = [
      ...displayedCore,
      ...promoted,
      if (draftInline) EditorTool.drafts,
    ];
    return ResolvedEditorToolbarLayout(
      primary: displayedPrimary,
      expanded: [
        ...core.skip(displayedCore.length),
        ...[
          EditorTool.audio,
          EditorTool.alignCenter,
          EditorTool.alignRight,
          EditorTool.link,
          EditorTool.inlineCode,
          EditorTool.quote,
          EditorTool.horizontalRule,
          EditorTool.dice,
          EditorTool.sticker,
          EditorTool.strike,
        ].where(
          (tool) =>
              available.contains(tool) && !displayedPrimary.contains(tool),
        ),
      ],
      dedicatedDraft: hasDraft && !draftInline,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is EditorToolbarLayout &&
      isDefault == other.isDefault &&
      listEquals(primary, other.primary) &&
      listEquals(expanded, other.expanded);

  @override
  int get hashCode =>
      Object.hash(isDefault, Object.hashAll(primary), Object.hashAll(expanded));
}

class ResolvedEditorToolbarLayout {
  const ResolvedEditorToolbarLayout({
    required this.primary,
    required this.expanded,
    this.dedicatedDraft = false,
  });

  final List<EditorTool> primary;
  final List<EditorTool> expanded;
  final bool dedicatedDraft;
}
