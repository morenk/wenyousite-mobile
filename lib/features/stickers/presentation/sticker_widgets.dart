import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_filter_controls.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/stickers/domain/sticker_models.dart';

Future<UserSticker?> showStickerPicker(BuildContext context) {
  final router = GoRouter.of(context);
  return showModalBottomSheet<UserSticker>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => FractionallySizedBox(
      heightFactor: 0.68,
      child: StickerPickerPanel(
        onSelected: (sticker) => Navigator.pop(sheetContext, sticker),
        onManage: () {
          Navigator.pop(sheetContext);
          router.pushNamed('me-stickers');
        },
      ),
    ),
  );
}

class StickerPickerPanel extends ConsumerStatefulWidget {
  const StickerPickerPanel({
    required this.onSelected,
    required this.onManage,
    this.compact = false,
    super.key,
  });

  final ValueChanged<UserSticker> onSelected;
  final VoidCallback onManage;
  final bool compact;

  @override
  ConsumerState<StickerPickerPanel> createState() => _StickerPickerPanelState();
}

class _StickerPickerPanelState extends ConsumerState<StickerPickerPanel> {
  var _recent = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stickerCollectionControllerProvider);
    final collection = state.collection;
    final shown = _recent
        ? collection?.recent ?? const <UserSticker>[]
        : collection?.items ?? const <UserSticker>[];
    final tokens = context.wenyouTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.compact)
          Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.space8,
              tokens.space8,
              tokens.space4,
              0,
            ),
            child: Row(
              children: [
                Expanded(child: _buildTabs(collection, compact: true)),
                _buildRefreshButton(state),
                _buildManageButton(),
              ],
            ),
          )
        else ...[
          Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.space16,
              0,
              tokens.space8,
              tokens.space8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '选择表情',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _buildRefreshButton(state),
                _buildManageButton(),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.space16),
            child: _buildTabs(collection),
          ),
        ],
        if (collection?.pendingImports.isNotEmpty ?? false)
          Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.space16,
              tokens.space8,
              tokens.space16,
              0,
            ),
            child: Text(
              '正在处理 ${collection!.pendingImports.length} 个表情…',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        SizedBox(height: widget.compact ? tokens.space8 : tokens.space12),
        Expanded(child: _buildBody(context, state, shown)),
      ],
    );
  }

  Widget _buildTabs(StickerCollection? collection, {bool compact = false}) {
    return WenyouContentTabs<bool>(
      key: const Key('sticker-picker-tabs'),
      keyPrefix: 'sticker-picker',
      semanticsLabel: '表情收藏栏目',
      placement: WenyouTabPlacement.embedded,
      options: [
        WenyouFilterOption(
          value: false,
          keyValue: 'saved',
          label: collection == null
              ? '收藏'
              : compact
              ? '收藏 ${collection.items.length}'
              : '收藏 ${collection.items.length}/${collection.limit}',
        ),
        const WenyouFilterOption(value: true, keyValue: 'recent', label: '最近'),
      ],
      selected: _recent,
      onSelected: (value) => setState(() => _recent = value),
    );
  }

  Widget _buildRefreshButton(StickerCollectionState state) {
    return IconButton(
      key: const Key('sticker-picker-refresh'),
      onPressed: state.isBusy
          ? null
          : () => ref.read(stickerCollectionControllerProvider.notifier).load(),
      tooltip: '刷新收藏',
      icon: const WenyouIcon(WenyouIconIds.actionRefresh),
    );
  }

  Widget _buildManageButton() {
    return IconButton(
      key: const Key('sticker-picker-manage'),
      onPressed: widget.onManage,
      tooltip: '管理收藏',
      icon: const WenyouIcon(WenyouIconIds.actionSettings),
    );
  }

  Widget _buildBody(
    BuildContext context,
    StickerCollectionState state,
    List<UserSticker> shown,
  ) {
    if (state.phase == StickerCollectionPhase.loading &&
        state.collection == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.phase == StickerCollectionPhase.failed) {
      return WenyouEmptyState(
        icon: WenyouIconIds.statusOffline,
        title: '表情收藏加载失败',
        message: state.failure?.userMessage ?? '请稍后重试。',
        action: OutlinedButton.icon(
          onPressed: () =>
              ref.read(stickerCollectionControllerProvider.notifier).load(),
          icon: const WenyouIcon(WenyouIconIds.actionRefresh),
          label: const Text('重新加载'),
        ),
      );
    }
    if (shown.isEmpty) {
      return WenyouEmptyState(
        icon: _recent
            ? WenyouIconIds.statusHistory
            : WenyouIconIds.actionAddReaction,
        title: _recent ? '还没有最近使用' : '还没有收藏表情',
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 600
            ? 8
            : width >= 400
            ? 5
            : 4;
        final horizontalPadding = widget.compact
            ? context.wenyouTokens.space8
            : context.wenyouTokens.space16;
        return GridView.builder(
          key: ValueKey(
            _recent ? 'sticker-recent-grid' : 'sticker-favorite-grid',
          ),
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            0,
            horizontalPadding,
            widget.compact
                ? context.wenyouTokens.space8
                : context.wenyouTokens.space24,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: context.wenyouTokens.space8,
            mainAxisSpacing: context.wenyouTokens.space8,
          ),
          itemCount: shown.length,
          itemBuilder: (context, index) {
            final sticker = shown[index];
            return StickerTile(
              sticker: sticker,
              onTap: () => widget.onSelected(sticker),
            );
          },
        );
      },
    );
  }
}

class StickerTile extends StatelessWidget {
  const StickerTile({
    required this.sticker,
    this.onTap,
    this.trailing,
    super.key,
  });

  final UserSticker sticker;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final fallback = ColoredBox(
      color: tokens.softPanel,
      child: WenyouIcon(WenyouIconIds.actionImage, color: tokens.mutedText),
    );
    return Semantics(
      button: onTap != null,
      label: sticker.asset.animated ? '动态收藏表情' : '收藏表情',
      child: Material(
        color: tokens.softPanel,
        borderRadius: BorderRadius.circular(tokens.radius12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Padding(
                padding: EdgeInsets.all(tokens.space8),
                child: WenyouCachedImage(
                  imageUrl: sticker.asset.thumbnailUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, _) => fallback,
                  errorWidget: (_, _, _) => fallback,
                ),
              ),
              if (sticker.asset.animated)
                Positioned(
                  left: tokens.space4,
                  bottom: tokens.space4,
                  child: WenyouIcon(
                    WenyouIconIds.contentMoment,
                    size: 18,
                    color: tokens.focus,
                  ),
                ),
              if (trailing != null)
                Positioned(
                  right: tokens.space4,
                  top: tokens.space4,
                  child: trailing!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class StickerPostMarkdown extends ConsumerWidget {
  const StickerPostMarkdown({
    required this.postId,
    required this.data,
    this.diceLabels = const {},
    this.diceSemantics = const {},
    this.diceDetails = const {},
    this.onInternalLink,
    this.onTapText,
    this.onLongPressNonText,
    this.bodyFontSize = 17,
    this.bodyHeight = 1.8,
    this.enablePlainTextFastPath = true,
    this.diagnosticRenderKey,
    super.key,
  });

  final String postId;
  final String data;
  final Map<String, String> diceLabels;
  final Map<String, String> diceSemantics;
  final Map<String, WenyouDiceRollDetail> diceDetails;
  final ValueChanged<Uri>? onInternalLink;
  final VoidCallback? onTapText;
  final VoidCallback? onLongPressNonText;
  final double bodyFontSize;
  final double bodyHeight;
  final bool enablePlainTextFastPath;
  final GlobalKey? diagnosticRenderKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(stickersEnabledProvider);
    final authenticated = ref.watch(
      sessionControllerProvider.select((session) => session.isAuthenticated),
    );
    return WenyouMarkdown(
      data: data,
      diceLabels: diceLabels,
      diceSemantics: diceSemantics,
      diceDetails: diceDetails,
      onInternalLink: onInternalLink,
      onTapText: onTapText,
      onLongPressNonText: onLongPressNonText,
      bodyFontSize: bodyFontSize,
      bodyHeight: bodyHeight,
      enablePlainTextFastPath: enablePlainTextFastPath,
      diagnosticRenderKey: diagnosticRenderKey,
      onSaveImage: !enabled || !authenticated
          ? null
          : (uri) async {
              final notifier = ref.read(
                stickerCollectionControllerProvider.notifier,
              );
              final result = await notifier.importPostImage(
                postId: postId,
                imageUrl: uri.toString(),
              );
              if (result == null) {
                final failure = ref
                    .read(stickerCollectionControllerProvider)
                    .transientFailure;
                throw failure ?? const ApiFailure(userMessage: '收藏表情失败，请稍后重试。');
              }
              return switch (result.status) {
                StickerImportStatus.processing => '图片处理中…',
                StickerImportStatus.completed when result.alreadySaved =>
                  '已经收藏过这个表情。',
                StickerImportStatus.completed => '已添加到表情收藏。',
                StickerImportStatus.failed => '表情处理失败，请换一张图片。',
              };
            },
    );
  }
}
