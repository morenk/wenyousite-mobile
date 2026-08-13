import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/widgets/content_image_viewer_page.dart';

List<EmbedBuilder> wenyouEditorEmbedBuilders() => const [
  _MentionEmbedBuilder(),
  _DiceEmbedBuilder(),
  _StickerEmbedBuilder(),
  _ImageEmbedBuilder(),
  _CompatibilityEmbedBuilder(),
  _HorizontalRuleEmbedBuilder(),
];

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
  String toPlainText(Embed node) {
    final data = node.value.data;
    return data is Map ? data['label']?.toString() ?? '@用户' : '@用户';
  }

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final payload = _payload(embedContext);
    return _AtomicNode(
      icon: Icons.alternate_email_rounded,
      label: payload?['label']?.toString() ?? '@用户',
      semanticLabel: '提及 ${payload?['label'] ?? '用户'}',
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
    return data is Map ? data['notation']?.toString() ?? '骰子' : '骰子';
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
    final style = embedContext.textStyle.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Semantics(
      key: const Key('editor-dice-inline'),
      label: '待掷骰子 $notation',
      child: Text(
        notation,
        style: style,
        strutStyle: StrutStyle.fromTextStyle(style, forceStrutHeight: true),
      ),
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
        icon: Icons.sentiment_satisfied_alt_rounded,
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
          errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined),
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
  String toPlainText(Embed node) => '[图片]';

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final payload = _payload(embedContext);
    final url = payload?['url']?.toString();
    final alt = payload?['alt']?.toString().trim();
    final label = alt == null || alt.isEmpty || alt == '图片'
        ? '查看正文图片原图'
        : '查看正文图片原图：$alt';
    if (url == null) {
      return const _UnavailableImage(message: '图片节点不完整');
    }
    return Semantics(
      button: true,
      image: true,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(context.wenyouTokens.radius12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (_) => ContentImageViewerPage(url: url, alt: alt ?? ''),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(context.wenyouTokens.radius12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 120, maxHeight: 320),
            child: Image.network(
              url,
              width: double.infinity,
              fit: BoxFit.contain,
              frameBuilder: (context, child, frame, _) =>
                  frame == null ? const _ImageLoadingPlaceholder() : child,
              errorBuilder: (_, _, _) =>
                  const _UnavailableImage(message: '图片加载失败，轻触后可在大图页重试'),
            ),
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
      message: '此节点来自未知或损坏协议，保存时会保留原文',
      child: _AtomicNode(
        icon: Icons.lock_outline_rounded,
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
    return Semantics(
      label: '分隔线',
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.wenyouTokens.space8),
        child: const Divider(),
      ),
    );
  }
}

class _AtomicNode extends StatelessWidget {
  const _AtomicNode({
    required this.icon,
    required this.label,
    required this.semanticLabel,
    this.warning = false,
  });

  final IconData icon;
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
            Icon(icon, size: 16),
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
          const Icon(Icons.broken_image_outlined),
          SizedBox(height: context.wenyouTokens.space8),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
