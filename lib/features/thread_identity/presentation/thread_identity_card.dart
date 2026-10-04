import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_sheet.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_ports.dart';
import 'package:wenyousite_mobile/features/thread_identity/presentation/thread_identity_card_content.dart';

Future<void> showThreadIdentityCard({
  required BuildContext context,
  required String threadId,
  required String userId,
  RpIdentity? historical,
  bool fromPost = false,
  String? roleLabel,
  ValueChanged<ThreadIdentityState>? onMention,
  VoidCallback? onOnlyThisUser,
}) async {
  final action =
      await showWenyouSheet<({String action, ThreadIdentityState value})>(
        context: context,
        builder: (context) => Consumer(
          builder: (context, ref, _) {
            final provider = threadIdentityCardProvider((
              threadId: threadId,
              userId: userId,
            ));
            final state = ref.watch(provider);
            return WenyouSheetBody(
              title: '帖内身份',
              slivers: [
                SliverToBoxAdapter(
                  child: state.when(
                    skipLoadingOnRefresh: false,
                    data: (value) => ThreadIdentityCardContent(
                      accountName: value.accountName,
                      accountAvatarUrl: value.accountAvatarUrl,
                      identityEnabled: value.enabled,
                      fromPost: fromPost,
                      historicalName: historical?.nickname,
                      historicalAvatarUrl: historical?.avatarUrl,
                      currentName: value.display?.nickname,
                      currentAvatarUrl: value.display?.avatarUrl,
                      roleLabel: roleLabel,
                      onOpenAccount: () => Navigator.of(
                        context,
                      ).pop((action: 'account', value: value)),
                      onMention: onMention == null
                          ? null
                          : () => Navigator.of(
                              context,
                            ).pop((action: 'mention', value: value)),
                      onOnlyThisUser: onOnlyThisUser == null
                          ? null
                          : () => Navigator.of(
                              context,
                            ).pop((action: 'filter', value: value)),
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, _) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('身份加载失败，可能已无权查看。'),
                        TextButton(
                          onPressed: () => ref.invalidate(provider),
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
  if (!context.mounted || action == null) return;
  switch (action.action) {
    case 'account':
      await context.push(AppRouteLocations.user(userId));
    case 'mention':
      onMention?.call(action.value);
    case 'filter':
      onOnlyThisUser?.call();
  }
}
