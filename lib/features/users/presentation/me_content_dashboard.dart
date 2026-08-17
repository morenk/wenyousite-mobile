import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_filter_controls.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/users/application/public_user_controller.dart';
import 'package:wenyousite_mobile/features/users/domain/public_user_models.dart';
import 'package:wenyousite_mobile/features/users/presentation/public_user_content.dart';

typedef MeUserMomentsBuilder =
    Widget Function(String userId, Future<void> Function() additionalRefresh);

enum MeContentTab { overview, moments, threads }

extension MeContentTabPresentation on MeContentTab {
  String get label => switch (this) {
    MeContentTab.overview => '概览',
    MeContentTab.moments => '动态',
    MeContentTab.threads => '帖子',
  };

  PublicUserContentTab? get publicUserTab => switch (this) {
    MeContentTab.overview => PublicUserContentTab.replies,
    MeContentTab.moments => null,
    MeContentTab.threads => PublicUserContentTab.created,
  };
}

enum _MeThreadTab { created, played }

extension on _MeThreadTab {
  String get label => switch (this) {
    _MeThreadTab.created => '创建的',
    _MeThreadTab.played => '参与的',
  };

  PublicUserContentTab get publicUserTab => switch (this) {
    _MeThreadTab.created => PublicUserContentTab.created,
    _MeThreadTab.played => PublicUserContentTab.played,
  };
}

class MeContentTabBody extends ConsumerStatefulWidget {
  const MeContentTabBody({
    required this.tab,
    required this.userId,
    required this.onRefreshChrome,
    required this.userMomentsBuilder,
    super.key,
  });

  final MeContentTab tab;
  final String userId;
  final Future<void> Function() onRefreshChrome;
  final MeUserMomentsBuilder? userMomentsBuilder;

  @override
  ConsumerState<MeContentTabBody> createState() => _MeContentTabBodyState();
}

class _MeContentTabBodyState extends ConsumerState<MeContentTabBody>
    with AutomaticKeepAliveClientMixin {
  var _threadTab = _MeThreadTab.created;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return switch (widget.tab) {
      MeContentTab.overview => _buildUserContent(
        context,
        PublicUserContentTab.replies,
      ),
      MeContentTab.moments =>
        widget.userMomentsBuilder?.call(
              widget.userId,
              widget.onRefreshChrome,
            ) ??
            _MeExternalContentFallback(
              title: '我的动态',
              message: '',
              onPressed: () => context.pushNamed(
                'user-moments',
                pathParameters: {'userId': widget.userId},
              ),
            ),
      MeContentTab.threads => _buildThreads(context),
    };
  }

  Widget _buildThreads(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            wenyouHorizontalPagePadding(context),
            tokens.space8,
            wenyouHorizontalPagePadding(context),
            0,
          ),
          child: WenyouConstrainedWidth(
            child: WenyouLineFilterBar<_MeThreadTab>(
              key: const Key('me-thread-filter'),
              keyPrefix: 'me-thread',
              semanticsLabel: '我的帖子',
              options: [
                for (final tab in _MeThreadTab.values)
                  WenyouFilterOption(value: tab, label: tab.label),
              ],
              selected: _threadTab,
              onSelected: (tab) {
                if (_threadTab == tab) return;
                setState(() => _threadTab = tab);
                ref
                    .read(
                      meUserContentControllerProvider(widget.userId).notifier,
                    )
                    .selectTab(tab.publicUserTab);
              },
            ),
          ),
        ),
        Expanded(child: _buildUserContent(context, _threadTab.publicUserTab)),
      ],
    );
  }

  Widget _buildUserContent(BuildContext context, PublicUserContentTab tab) {
    final provider = meUserContentControllerProvider(widget.userId);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    return RefreshIndicator(
      onRefresh: () =>
          Future.wait([widget.onRefreshChrome(), notifier.retryActive()]),
      child: ListView(
        key: PageStorageKey('me-${tab.name}-content'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          wenyouHorizontalPagePadding(context),
          context.wenyouTokens.space12,
          wenyouHorizontalPagePadding(context),
          112,
        ),
        children: [
          WenyouConstrainedWidth(
            child: PublicUserContentSectionView(
              tab: tab,
              state: state,
              isSelf: true,
              onRetry: notifier.retryActive,
              onLoadMore: notifier.loadMoreActive,
            ),
          ),
        ],
      ),
    );
  }
}

class _MeExternalContentFallback extends StatelessWidget {
  const _MeExternalContentFallback({
    required this.title,
    required this.message,
    required this.onPressed,
  });

  final String title;
  final String message;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(context.wenyouTokens.space16),
      children: [
        WenyouConstrainedWidth(
          child: WenyouPanel(
            child: WenyouEmptyState(
              icon: WenyouIconIds.navigationMoments,
              title: title,
              message: message,
              action: OutlinedButton(
                onPressed: onPressed,
                child: const Text('打开列表'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
