import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/users/application/public_user_controller.dart';
import 'package:wenyousite_mobile/features/users/domain/public_user_models.dart';
import 'package:wenyousite_mobile/features/users/presentation/public_user_content.dart';

class PublicUserPage extends ConsumerWidget {
  const PublicUserPage({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = publicUserControllerProvider(userId);
    final state = ref.watch(provider);
    return Scaffold(
      appBar: AppBar(title: const Text('用户主页')),
      body: switch (state.phase) {
        PublicUserPhase.loading => const _UserLoadingState(),
        PublicUserPhase.failed => _UserFailureState(
          notFound: state.failure?.httpStatus == 404,
          message: state.failure?.userMessage,
          requestId: state.failure?.requestId,
          onRetry: () => ref.read(provider.notifier).load(),
        ),
        PublicUserPhase.ready => RefreshIndicator(
          onRefresh: () => ref.read(provider.notifier).load(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: _pagePadding(context),
            children: [
              if (state.profile!.isDeactivated)
                const WenyouPanel(
                  child: WenyouEmptyState(
                    icon: Icons.person_off_outlined,
                    title: '已注销用户',
                    message: '该账号已经注销，公开资料不再展示。',
                  ),
                )
              else ...[
                _UserProfileContent(profile: state.profile!),
                SizedBox(height: context.wenyouTokens.space12),
                PublicUserContentArea(userId: userId, state: state),
              ],
            ],
          ),
        ),
      },
    );
  }

  EdgeInsets _pagePadding(BuildContext context) {
    final tokens = context.wenyouTokens;
    final horizontal = MediaQuery.sizeOf(context).width <= 400
        ? tokens.space12
        : tokens.space24;
    return EdgeInsets.fromLTRB(
      horizontal,
      tokens.space16,
      horizontal,
      tokens.space32,
    );
  }
}

class _UserProfileContent extends StatelessWidget {
  const _UserProfileContent({required this.profile});

  final PublicUserProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Column(
      children: [
        WenyouPanel(
          child: Column(
            children: [
              _ProfileAvatar(profile: profile),
              SizedBox(height: tokens.space16),
              Text(
                profile.username,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: tokens.space8),
              _ProfilePill(
                icon: Icons.auto_awesome_outlined,
                label: 'Lv.${profile.level}',
              ),
              if (profile.bio != null) ...[
                SizedBox(height: tokens.space16),
                Text(
                  profile.bio!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              if (profile.createdAt != null) ...[
                SizedBox(height: tokens.space12),
                Text(
                  '${DateFormat('yyyy-MM-dd').format(profile.createdAt!)} 加入温油站',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: tokens.space12),
        WenyouPanel(
          padding: EdgeInsets.all(tokens.space16),
          child: Row(
            children: [
              Expanded(
                child: _ProfileStat(
                  label: '关注',
                  value: '${profile.followingCount}',
                ),
              ),
              SizedBox(
                height: tokens.minimumTouchTarget,
                child: const VerticalDivider(),
              ),
              Expanded(
                child: _ProfileStat(
                  label: '粉丝',
                  value: '${profile.followerCount}',
                ),
              ),
              SizedBox(
                height: tokens.minimumTouchTarget,
                child: const VerticalDivider(),
              ),
              Expanded(
                child: _ProfileStat(
                  label: '收到加油',
                  value: '${profile.receivedTipTotal}L',
                ),
              ),
            ],
          ),
        ),
        if (profile.isFollowing ||
            profile.isFollowedBy ||
            profile.isBlocked ||
            profile.isBlockedBy) ...[
          SizedBox(height: tokens.space12),
          WenyouPanel(
            padding: EdgeInsets.all(tokens.space16),
            child: Wrap(
              spacing: tokens.space8,
              runSpacing: tokens.space8,
              children: [
                if (profile.isFollowing)
                  const _ProfilePill(
                    icon: Icons.check_circle_outline_rounded,
                    label: '已关注',
                  ),
                if (profile.isFollowedBy)
                  const _ProfilePill(
                    icon: Icons.people_outline_rounded,
                    label: '关注了你',
                  ),
                if (profile.isBlocked)
                  const _ProfilePill(icon: Icons.block_rounded, label: '已拉黑'),
                if (profile.isBlockedBy)
                  const _ProfilePill(
                    icon: Icons.visibility_off_outlined,
                    label: '互动受限',
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.profile});

  final PublicUserProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final fallback = ColoredBox(
      color: tokens.softPanel,
      child: Icon(Icons.person_rounded, size: 44, color: tokens.mutedText),
    );
    return Semantics(
      image: true,
      label: '${profile.username} 的头像',
      child: ClipOval(
        child: SizedBox.square(
          dimension: 88,
          child: profile.avatarUrl == null
              ? fallback
              : CachedNetworkImage(
                  imageUrl: profile.avatarUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => fallback,
                  errorWidget: (_, _, _) => fallback,
                ),
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: tokens.space4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ProfilePill extends StatelessWidget {
  const _ProfilePill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.accentedBackground,
        border: Border.all(color: tokens.border),
        borderRadius: BorderRadius.circular(tokens.radiusPill),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space8,
          vertical: tokens.space4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: tokens.focus),
            SizedBox(width: tokens.space4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _UserLoadingState extends StatelessWidget {
  const _UserLoadingState();

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.space24),
        child: const CircularProgressIndicator(),
      ),
    );
  }
}

class _UserFailureState extends StatelessWidget {
  const _UserFailureState({
    required this.notFound,
    required this.message,
    required this.requestId,
    required this.onRetry,
  });

  final bool notFound;
  final String? message;
  final String? requestId;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return WenyouPageBody(
      maxWidth: 600,
      child: WenyouPanel(
        child: WenyouEmptyState(
          icon: notFound ? Icons.person_off_outlined : Icons.cloud_off_outlined,
          title: notFound ? '用户不存在' : '用户资料没有加载完成',
          message: notFound ? '该用户可能已经注销，或账号不存在。' : (message ?? '请稍后重试。'),
          detail: requestId == null ? null : '请求 ID：$requestId',
          action: OutlinedButton.icon(
            key: const Key('public-user-retry'),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('重新加载'),
          ),
        ),
      ),
    );
  }
}
