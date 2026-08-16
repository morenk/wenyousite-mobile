import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/social/presentation/bookmark_list_page.dart';
import 'package:wenyousite_mobile/features/users/application/public_user_controller.dart';
import 'package:wenyousite_mobile/features/users/domain/public_user_models.dart';
import 'package:wenyousite_mobile/features/users/presentation/public_user_content.dart';

typedef MeUserMomentsBuilder =
    Widget Function(String userId, Future<void> Function() additionalRefresh);
typedef MeMomentBookmarksBuilder =
    Widget Function(Future<void> Function() additionalRefresh);

enum MeContentTab { created, played, replies, moments, bookmarks }

extension MeContentTabPresentation on MeContentTab {
  String get label => switch (this) {
    MeContentTab.created => '创建',
    MeContentTab.played => '参与',
    MeContentTab.replies => '回复',
    MeContentTab.moments => '动态',
    MeContentTab.bookmarks => '收藏',
  };

  PublicUserContentTab? get publicUserTab => switch (this) {
    MeContentTab.created => PublicUserContentTab.created,
    MeContentTab.played => PublicUserContentTab.played,
    MeContentTab.replies => PublicUserContentTab.replies,
    MeContentTab.moments || MeContentTab.bookmarks => null,
  };
}

class MeContentTabBody extends ConsumerStatefulWidget {
  const MeContentTabBody({
    required this.tab,
    required this.userId,
    required this.onRefreshChrome,
    required this.userMomentsBuilder,
    required this.momentBookmarksBuilder,
    super.key,
  });

  final MeContentTab tab;
  final String userId;
  final Future<void> Function() onRefreshChrome;
  final MeUserMomentsBuilder? userMomentsBuilder;
  final MeMomentBookmarksBuilder? momentBookmarksBuilder;

  @override
  ConsumerState<MeContentTabBody> createState() => _MeContentTabBodyState();
}

class _MeContentTabBodyState extends ConsumerState<MeContentTabBody>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return switch (widget.tab) {
      MeContentTab.created ||
      MeContentTab.played ||
      MeContentTab.replies => _buildUserContent(context),
      MeContentTab.moments =>
        widget.userMomentsBuilder?.call(
              widget.userId,
              widget.onRefreshChrome,
            ) ??
            _MeExternalContentFallback(
              title: '我的动态',
              message: '打开动态列表查看已发布内容。',
              onPressed: () => context.pushNamed(
                'user-moments',
                pathParameters: {'userId': widget.userId},
              ),
            ),
      MeContentTab.bookmarks => _MeBookmarksView(
        additionalRefresh: widget.onRefreshChrome,
        momentBookmarksBuilder: widget.momentBookmarksBuilder,
      ),
    };
  }

  Widget _buildUserContent(BuildContext context) {
    final provider = meUserContentControllerProvider(widget.userId);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    final tab = widget.tab.publicUserTab!;
    return RefreshIndicator(
      onRefresh: () =>
          Future.wait([widget.onRefreshChrome(), notifier.retryActive()]),
      child: ListView(
        key: PageStorageKey('me-${widget.tab.name}-content'),
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

class _MeBookmarksView extends StatelessWidget {
  const _MeBookmarksView({
    required this.additionalRefresh,
    required this.momentBookmarksBuilder,
  });

  final Future<void> Function() additionalRefresh;
  final MeMomentBookmarksBuilder? momentBookmarksBuilder;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: '主题帖'),
              Tab(text: '动态'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                BookmarkListView(additionalRefresh: additionalRefresh),
                momentBookmarksBuilder?.call(additionalRefresh) ??
                    _MeExternalContentFallback(
                      title: '动态收藏',
                      message: '打开动态收藏列表查看已收藏内容。',
                      onPressed: () => context.pushNamed('moment-bookmarks'),
                    ),
              ],
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
