import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/stickers/domain/sticker_models.dart';

Future<UserSticker?> showStickerPicker(BuildContext context) {
  return showModalBottomSheet<UserSticker>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const FractionallySizedBox(
      heightFactor: 0.68,
      child: _StickerPickerSheet(),
    ),
  );
}

class _StickerPickerSheet extends ConsumerStatefulWidget {
  const _StickerPickerSheet();

  @override
  ConsumerState<_StickerPickerSheet> createState() =>
      _StickerPickerSheetState();
}

class _StickerPickerSheetState extends ConsumerState<_StickerPickerSheet> {
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
              IconButton(
                key: const Key('sticker-picker-refresh'),
                onPressed: state.isBusy
                    ? null
                    : () => ref
                          .read(stickerCollectionControllerProvider.notifier)
                          .load(),
                tooltip: '刷新收藏',
                icon: const Icon(Icons.refresh_rounded),
              ),
              IconButton(
                key: const Key('sticker-picker-manage'),
                onPressed: () {
                  final router = GoRouter.of(context);
                  Navigator.pop(context);
                  router.pushNamed('me-stickers');
                },
                tooltip: '管理收藏',
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: tokens.space16),
          child: SegmentedButton<bool>(
            segments: [
              ButtonSegment(
                value: false,
                icon: const Icon(Icons.favorite_border_rounded),
                label: Text(
                  collection == null
                      ? '收藏'
                      : '收藏 ${collection.items.length}/${collection.limit}',
                ),
              ),
              const ButtonSegment(
                value: true,
                icon: Icon(Icons.history_rounded),
                label: Text('最近'),
              ),
            ],
            selected: {_recent},
            onSelectionChanged: (selection) {
              setState(() => _recent = selection.single);
            },
          ),
        ),
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
        SizedBox(height: tokens.space12),
        Expanded(child: _buildBody(context, state, shown)),
      ],
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
        icon: Icons.cloud_off_outlined,
        title: '表情收藏没有加载完成',
        message: state.failure?.userMessage ?? '请稍后重试。',
        action: OutlinedButton.icon(
          onPressed: () =>
              ref.read(stickerCollectionControllerProvider.notifier).load(),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('重新加载'),
        ),
      );
    }
    if (shown.isEmpty) {
      return WenyouEmptyState(
        icon: _recent
            ? Icons.history_toggle_off_rounded
            : Icons.add_reaction_outlined,
        title: _recent ? '还没有最近使用' : '还没有收藏表情',
        message: _recent ? '发送过的收藏表情会显示在这里。' : '可在“表情包”从相册添加，或收藏站内图片。',
      );
    }
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 600
        ? 8
        : width >= 400
        ? 5
        : 4;
    return GridView.builder(
      key: ValueKey(_recent ? 'sticker-recent-grid' : 'sticker-favorite-grid'),
      padding: EdgeInsets.fromLTRB(
        context.wenyouTokens.space16,
        0,
        context.wenyouTokens.space16,
        context.wenyouTokens.space24,
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
          onTap: () => Navigator.pop(context, sticker),
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
      child: Icon(Icons.image_outlined, color: tokens.mutedText),
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
                child: CachedNetworkImage(
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
                  child: Icon(
                    Icons.motion_photos_on_outlined,
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
    this.onInternalLink,
    this.onTapText,
    this.bodyFontSize = 17,
    this.bodyHeight = 1.8,
    super.key,
  });

  final String postId;
  final String data;
  final Map<String, String> diceLabels;
  final ValueChanged<Uri>? onInternalLink;
  final VoidCallback? onTapText;
  final double bodyFontSize;
  final double bodyHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(stickersEnabledProvider);
    final authenticated = ref.watch(
      sessionControllerProvider.select((session) => session.isAuthenticated),
    );
    return WenyouMarkdown(
      data: data,
      diceLabels: diceLabels,
      onInternalLink: onInternalLink,
      onTapText: onTapText,
      bodyFontSize: bodyFontSize,
      bodyHeight: bodyHeight,
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
                StickerImportStatus.processing => '图片正在处理，完成后会出现在收藏中。',
                StickerImportStatus.completed when result.alreadySaved =>
                  '已经收藏过这个表情。',
                StickerImportStatus.completed => '已添加到表情收藏。',
                StickerImportStatus.failed => '表情处理失败，请换一张图片。',
              };
            },
    );
  }
}
