import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/thread_category_catalog.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_avatar_button.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_invitation_controller.dart';

class ThreadInvitationPage extends ConsumerWidget {
  const ThreadInvitationPage({required this.token, super.key});

  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = threadInvitationAccessControllerProvider(token);
    final state = ref.watch(provider);
    return Scaffold(
      appBar: AppBar(title: const Text('私密主题邀请')),
      body: switch (state.phase) {
        ThreadInvitationAccessPhase.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        ThreadInvitationAccessPhase.failed => _InvitationFailure(
          failure: state.failure,
          onRetry: () async {
            await Future.wait([
              ref.read(provider.notifier).load(),
              ref
                  .read(threadCategoryCatalogControllerProvider.notifier)
                  .refresh(),
            ]);
          },
        ),
        ThreadInvitationAccessPhase.ready => _InvitationReady(
          token: token,
          state: state,
        ),
      },
    );
  }
}

class _InvitationReady extends ConsumerWidget {
  const _InvitationReady({required this.token, required this.state});

  final String token;
  final ThreadInvitationAccessState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preview = state.preview!;
    if (preview.alreadyJoined) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go(AppRouteLocations.thread(preview.threadId));
        }
      });
      return const SizedBox.shrink();
    }
    final category = ref
        .watch(threadCategoryCatalogControllerProvider)
        .resolve(preview.categorySlug);
    final tokens = context.wenyouTokens;
    return WenyouPageBody(
      maxWidth: 520,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WenyouPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const WenyouSectionHeader(
                  title: '有人邀请你加入私密主题',
                  subtitle: '加入后才能阅读主题内容；是否标记为玩家仍由主题管理者决定。',
                ),
                SizedBox(height: tokens.space20),
                Text(
                  preview.title,
                  key: const Key('thread-invite-preview-title'),
                  style: Theme.of(context).textTheme.wenyouPageTitle,
                ),
                SizedBox(height: tokens.space12),
                Wrap(
                  spacing: tokens.space8,
                  runSpacing: tokens.space8,
                  children: [
                    if (category != null)
                      _InviteFact(
                        icon: WenyouIconIds.contentFolderOpen,
                        label: category.label,
                      ),
                    _InviteFact(
                      icon: WenyouIconIds.actionReport,
                      label: preview.status.label,
                    ),
                    _InviteFact(
                      icon: WenyouIconIds.identityMembers,
                      label: '${preview.memberCount} 位参与人',
                    ),
                  ],
                ),
                SizedBox(height: tokens.space16),
                ListTile(
                  key: const Key('thread-invite-owner'),
                  contentPadding: EdgeInsets.zero,
                  leading: WenyouAvatar(username: preview.ownerName, size: 40),
                  title: Text('楼主 ${preview.ownerName}'),
                  subtitle: Text(
                    '${DateFormat('yyyy-MM-dd').format(preview.createdAt.toLocal())} 创建',
                  ),
                  trailing: const WenyouIcon(WenyouIconIds.navigationNext),
                  onTap: () =>
                      context.push(AppRouteLocations.user(preview.ownerId)),
                ),
              ],
            ),
          ),
          if (state.joinFailure != null) ...[
            SizedBox(height: tokens.space12),
            WenyouStatusBanner(
              key: const Key('thread-invite-join-failure'),
              tone: WenyouStatusTone.error,
              message: state.joinFailure!.userMessage,
              detail: wenyouFailureDetail(
                state.joinFailure,
                treatAsWrite: true,
              ),
              action: TextButton(
                key: const Key('thread-invite-dismiss-failure'),
                onPressed: state.isJoining
                    ? null
                    : () => ref
                          .read(
                            threadInvitationAccessControllerProvider(
                              token,
                            ).notifier,
                          )
                          .clearJoinFailure(),
                child: const Text('知道了'),
              ),
            ),
          ],
          SizedBox(height: tokens.space16),
          WenyouAsyncPrimaryButton(
            key: const Key('thread-invite-join'),
            label: '接受邀请并加入',
            loadingLabel: '正在加入私密主题',
            icon: WenyouIconIds.actionAdd,
            isLoading: state.isJoining,
            onPressed: state.isJoining ? null : () => _join(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _join(BuildContext context, WidgetRef ref) async {
    final result = await ref
        .read(threadInvitationAccessControllerProvider(token).notifier)
        .join();
    if (result == null || !context.mounted) return;
    showWenyouSnackBar(context, '已加入私密主题。');
    context.go(AppRouteLocations.thread(result.threadId));
  }
}

class _InviteFact extends StatelessWidget {
  const _InviteFact({required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.softPanel,
        borderRadius: BorderRadius.circular(tokens.radius12),
        border: Border.all(color: tokens.border),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space8,
          vertical: tokens.space4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            WenyouIcon(icon, size: 16),
            SizedBox(width: tokens.space4),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}

class _InvitationFailure extends StatelessWidget {
  const _InvitationFailure({required this.failure, required this.onRetry});

  final ApiFailure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final permanent =
        failure?.businessCode == 40408 ||
        failure?.httpStatus == 404 ||
        failure?.httpStatus == 403;
    return WenyouPageBody(
      maxWidth: 520,
      child: WenyouPanel(
        child: WenyouEmptyState(
          icon: permanent
              ? WenyouIconIds.actionUnlink
              : WenyouIconIds.statusOffline,
          title: permanent ? '邀请链接无效或已失效' : '邀请信息加载失败',
          message: permanent
              ? '请联系主题楼主获取新的私密邀请。'
              : failure?.userMessage ?? '请检查网络后重试。',
          detail: wenyouFailureDetail(failure),
          action: permanent
              ? OutlinedButton.icon(
                  key: const Key('thread-invite-back-home'),
                  onPressed: () => context.go(AppRouteLocations.home),
                  icon: const WenyouIcon(WenyouIconIds.navigationHome),
                  label: const Text('返回首页'),
                )
              : OutlinedButton.icon(
                  key: const Key('thread-invite-load-retry'),
                  onPressed: onRetry,
                  icon: const WenyouIcon(WenyouIconIds.actionRefresh),
                  label: const Text('重新加载'),
                ),
        ),
      ),
    );
  }
}
