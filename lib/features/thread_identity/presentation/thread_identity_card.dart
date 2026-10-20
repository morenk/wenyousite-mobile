import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_sheet.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_ports.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_profile.dart';
import 'package:wenyousite_mobile/features/thread_identity/presentation/thread_identity_card_content.dart';
import 'package:wenyousite_mobile/features/thread_identity/presentation/thread_identity_reading_scope.dart';

Future<void> showThreadIdentityCard({
  required BuildContext context,
  required String threadId,
  required String userId,
  RpIdentity? historical,
  String? identityId,
  bool fromPost = false,
  String? roleLabel,
}) async {
  final readingScope = ThreadIdentityReadingScope.maybeOf(context);
  final targetId = historical?.id ?? identityId;
  final provider = targetId != null
      ? rpIdentityCardProvider((
          threadId: threadId,
          userId: userId,
          identityId: targetId,
        ))
      : threadIdentityCardProvider((threadId: threadId, userId: userId));
  // 每次打开重新校验当前角色绑定，不沿用另一个已打开卡片的投影。
  ProviderScope.containerOf(context, listen: false).invalidate(provider);
  final location = await showWenyouSheet<String>(
    context: context,
    builder: (context) => Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(provider);
        return WenyouSheetBody(
          title: '帖内身份',
          showHeader: false,
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
                  profile:
                      !ref
                          .watch(appCapabilitiesProvider)
                          .rpIdentityProfileSupported
                      ? null
                      : switch (value.profilePostStatus) {
                          IdentityProfilePostStatus.none => null,
                          IdentityProfilePostStatus.unavailable => const Text(
                            '资料暂不可用',
                          ),
                          IdentityProfilePostStatus.available =>
                            ThreadIdentityReadingScope(
                              threadId: threadId,
                              available: value.enabled,
                              ownerId: readingScope?.ownerId,
                              child:
                                  ref.watch(
                                    identityProfilePreviewBuilderProvider,
                                  )(
                                    threadId: threadId,
                                    postId: value.profilePostId!,
                                    onOpenPost: (location) =>
                                        Navigator.of(context).pop(location),
                                  ),
                            ),
                        },
                  onOpenAccount: () =>
                      Navigator.of(context).pop(AppRouteLocations.user(userId)),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('身份加载失败'),
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
  if (!context.mounted || location == null) return;
  await context.push(location);
}
