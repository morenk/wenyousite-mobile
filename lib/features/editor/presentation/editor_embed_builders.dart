import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/navigation/internal_reference.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_body_divider.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_dice_node.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_inline_text_elements.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_internal_reference_text.dart';

List<EmbedBuilder> wenyouEditorEmbedBuilders() => const [
  _InternalReferenceEmbedBuilder(),
  _MentionEmbedBuilder(),
  _DiceEmbedBuilder(),
  _StickerEmbedBuilder(),
  _ImageEmbedBuilder(),
  _CompatibilityEmbedBuilder(),
  _HorizontalRuleEmbedBuilder(),
];

class _InternalReferenceEmbedBuilder extends EmbedBuilder {
  const _InternalReferenceEmbedBuilder();

  @override
  String get key => MarkdownDeltaCodec.internalReferenceEmbed;

  @override
  bool get expanded => false;

  @override
  WidgetSpan buildWidgetSpan(Widget widget) => WidgetSpan(
    alignment: PlaceholderAlignment.baseline,
    baseline: TextBaseline.alphabetic,
    child: widget,
  );

  @override
  String toPlainText(Embed node) {
    return _internalReferenceDisplayLabel(node.value.data);
  }

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final label = _internalReferenceDisplayLabel(embedContext.node.value.data);
    return Semantics(
      key: const Key('editor-internal-reference'),
      label: '站内传送门：$label',
      excludeSemantics: true,
      child: WenyouInternalReferenceSurface(
        label: label,
        style: embedContext.textStyle,
      ),
    );
  }
}

String _internalReferenceDisplayLabel(Object? data) {
  if (data is! Map) return internalReferenceDefaultLabel;
  final label = data['label']?.toString() ?? internalReferenceDefaultLabel;
  final location = data['location']?.toString();
  final reference = location == null ? null : parseInternalReference(location);
  if (reference == null) return label;
  return resolveInternalReferenceLabel(label: label, reference: reference);
}

Map<String, dynamic>? _payload(EmbedContext context) {
  final data = context.node.value.data;
  return data is Map ? Map<String, dynamic>.from(data) : null;
}

class _MentionEmbedBuilder extends EmbedBuilder {
  const _MentionEmbedBuilder();

  @override
  String get key => MarkdownDeltaCodec.mentionEmbed;

  @override
  bool get expanded => false;

  @override
  WidgetSpan buildWidgetSpan(Widget widget) => WidgetSpan(
    alignment: PlaceholderAlignment.baseline,
    baseline: TextBaseline.alphabetic,
    child: widget,
  );

  @override
  String toPlainText(Embed node) {
    final data = node.value.data;
    return data is Map ? data['label']?.toString() ?? '@用户' : '@用户';
  }

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final payload = _payload(embedContext);
    return Semantics(
      key: const Key('editor-mention'),
      label: '提及 ${payload?['label'] ?? '用户'}',
      excludeSemantics: true,
      child: WenyouMentionSurface(
        label: payload?['label']?.toString() ?? '@用户',
        style: embedContext.textStyle,
      ),
    );
  }
}

class _DiceEmbedBuilder extends EmbedBuilder {
  const _DiceEmbedBuilder();

  @override
  String get key => MarkdownDeltaCodec.diceEmbed;

  @override
  bool get expanded => false;

  @override
  String toPlainText(Embed node) {
    final data = node.value.data;
    final notation = data is Map ? data['notation']?.toString() : null;
    return notation == null ? '骰子' : '$notation = ?';
  }

  @override
  WidgetSpan buildWidgetSpan(Widget widget) => WidgetSpan(
    alignment: PlaceholderAlignment.baseline,
    baseline: TextBaseline.alphabetic,
    child: widget,
  );

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final notation = _payload(embedContext)?['notation']?.toString() ?? '骰子';
    return WenyouDiceNode(
      key: const Key('editor-dice-inline'),
      label: '$notation = ?',
      semanticLabel: '骰子 $notation，待掷',
      settled: false,
      style: embedContext.textStyle,
    );
  }
}

class _StickerEmbedBuilder extends EmbedBuilder {
  const _StickerEmbedBuilder();

  @override
  String get key => MarkdownDeltaCodec.stickerEmbed;

  @override
  bool get expanded => false;

  @override
  String toPlainText(Embed node) => '[表情]';

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final payload = _payload(embedContext);
    final url = payload?['url']?.toString();
    if (url == null) {
      return const _AtomicNode(
        icon: WenyouIconIds.actionAddReaction,
        label: '表情不可用',
        semanticLabel: '表情不可用',
      );
    }
    return Semantics(
      image: true,
      label: payload?['alt']?.toString() ?? '收藏表情',
      child: SizedBox.square(
        dimension: 48,
        child: Image.network(
          url,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) =>
              const WenyouIcon(WenyouIconIds.statusImageUnavailable),
        ),
      ),
    );
  }
}

class _ImageEmbedBuilder extends EmbedBuilder {
  const _ImageEmbedBuilder();

  @override
  String get key => MarkdownDeltaCodec.imageEmbed;

  @override
  bool get expanded => false;

  @override
  String toPlainText(Embed node) => '[图片]';

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final payload = _payload(embedContext);
    final url = payload?['url']?.toString();
    final alt = payload?['alt']?.toString().trim();
    final label = alt == null || alt.isEmpty || alt == '图片'
        ? '正文图片'
        : '正文图片：$alt';
    if (url == null) {
      return const _UnavailableImage(message: '图片加载失败');
    }
    return Semantics(
      image: true,
      label: label,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.wenyouTokens.radius12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 120, maxHeight: 320),
          child: Image.network(
            url,
            fit: BoxFit.contain,
            frameBuilder: (context, child, frame, _) =>
                frame == null ? const _ImageLoadingPlaceholder() : child,
            errorBuilder: (_, _, _) =>
                const _UnavailableImage(message: '图片加载失败'),
          ),
        ),
      ),
    );
  }
}

class _CompatibilityEmbedBuilder extends EmbedBuilder {
  const _CompatibilityEmbedBuilder();

  @override
  String get key => MarkdownDeltaCodec.compatibilityEmbed;

  @override
  bool get expanded => false;

  @override
  String toPlainText(Embed node) => '[兼容内容]';

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    return const Tooltip(
      message: '这段内容暂时无法编辑，保存时会原样保留',
      child: _AtomicNode(
        icon: WenyouIconIds.actionLock,
        label: '只读兼容内容',
        semanticLabel: '只读兼容内容，原文会被保留',
        warning: true,
      ),
    );
  }
}

class _HorizontalRuleEmbedBuilder extends EmbedBuilder {
  const _HorizontalRuleEmbedBuilder();

  @override
  String get key => MarkdownDeltaCodec.horizontalRuleEmbed;

  @override
  String toPlainText(Embed node) => '分隔线';

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    return WenyouBodyDivider(fontSize: embedContext.textStyle.fontSize ?? 17);
  }
}

class _AtomicNode extends StatelessWidget {
  const _AtomicNode({
    required this.icon,
    required this.label,
    required this.semanticLabel,
    this.warning = false,
  });

  final String icon;
  final String label;
  final String semanticLabel;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: semanticLabel,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space8,
          vertical: tokens.space4,
        ),
        decoration: BoxDecoration(
          color: warning ? scheme.errorContainer : tokens.accentedBackground,
          border: Border.all(color: warning ? scheme.error : tokens.border),
          borderRadius: BorderRadius.circular(tokens.radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            WenyouIcon(icon, size: 16),
            SizedBox(width: tokens.space4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ImageLoadingPlaceholder extends StatelessWidget {
  const _ImageLoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.wenyouTokens.softPanel,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _UnavailableImage extends StatelessWidget {
  const _UnavailableImage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 120),
      color: context.wenyouTokens.softPanel,
      padding: EdgeInsets.all(context.wenyouTokens.space16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const WenyouIcon(WenyouIconIds.statusImageUnavailable),
          SizedBox(height: context.wenyouTokens.space8),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
