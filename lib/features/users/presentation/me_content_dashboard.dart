import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/users/application/public_user_controller.dart';
import 'package:wenyousite_mobile/features/users/domain/public_user_models.dart';
import 'package:wenyousite_mobile/features/users/presentation/public_user_content.dart';
import 'package:wenyousite_mobile/features/users/presentation/user_activity_summary_panel.dart';

typedef MeUserMomentsBuilder = Widget Function(String userId);

typedef MeUserMomentsRefresher = Future<void> Function(String userId);

class MeUserMomentsIntegration {
  const MeUserMomentsIntegration({
    required this.builder,
    required this.refresh,
  });

  final MeUserMomentsBuilder builder;
  final MeUserMomentsRefresher refresh;
}

enum MeContentTab { overview, moments, createdThreads, playedThreads }

extension MeContentTabPresentation on MeContentTab {
  String get label => switch (this) {
    MeContentTab.overview => '概览',
    MeContentTab.moments => '动态',
    MeContentTab.createdThreads => '创建',
    MeContentTab.playedThreads => '参与',
  };

  PublicUserContentTab? get publicUserTab => switch (this) {
    MeContentTab.overview => PublicUserContentTab.replies,
    MeContentTab.moments => null,
    MeContentTab.createdThreads => PublicUserContentTab.created,
    MeContentTab.playedThreads => PublicUserContentTab.played,
  };
}

class MeContentTabBody extends ConsumerStatefulWidget {
  const MeContentTabBody({
    required this.tab,
    required this.userId,
    required this.userMomentsBuilder,
    super.key,
  });

  final MeContentTab tab;
  final String userId;
  final MeUserMomentsBuilder? userMomentsBuilder;

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
      MeContentTab.overview => _buildUserContent(
        context,
        PublicUserContentTab.replies,
      ),
      MeContentTab.moments =>
        widget.userMomentsBuilder?.call(widget.userId) ??
            _MeExternalContentFallback(
              title: '我的动态',
              onPressed: () => context.pushNamed(
                'user-moments',
                pathParameters: {'userId': widget.userId},
              ),
            ),
      MeContentTab.createdThreads => _buildUserContent(
        context,
        PublicUserContentTab.created,
      ),
      MeContentTab.playedThreads => _buildUserContent(
        context,
        PublicUserContentTab.played,
      ),
    };
  }

  Widget _buildUserContent(BuildContext context, PublicUserContentTab tab) {
    final provider = meUserContentControllerProvider(widget.userId);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    final isOverview = widget.tab == MeContentTab.overview;
    return ListView(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isOverview) ...[
                UserActivitySummaryPanel(
                  key: const Key('me-activity-summary'),
                  keyPrefix: 'me-activity',
                  state: state,
                  onRetry: notifier.retryActivitySummary,
                ),
                SizedBox(height: context.wenyouTokens.space20),
                const WenyouSectionHeader(title: '最近回复'),
                SizedBox(height: context.wenyouTokens.space8),
              ],
              PublicUserContentSectionView(
                tab: tab,
                state: state,
                isSelf: true,
                onRetry: notifier.retryActive,
                onLoadMore: notifier.loadMoreActive,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MeExternalContentFallback extends StatelessWidget {
  const _MeExternalContentFallback({
    required this.title,
    required this.onPressed,
  });

  final String title;
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
