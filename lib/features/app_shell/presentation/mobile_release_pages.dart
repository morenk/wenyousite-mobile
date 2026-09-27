import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_settings_body.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_release_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_release.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/mobile_release_content.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/mobile_update_actions.dart';

class MobileReleaseHistoryPage extends ConsumerWidget {
  const MobileReleaseHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return const _UnavailablePage();
    }
    final history = ref.watch(mobileReleaseHistoryProvider);
    final controller = ref.read(mobileReleaseHistoryProvider.notifier);
    final installed = ref.watch(installedAppInfoProvider).valueOrNull;
    return WenyouSettingsTypography(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('更新说明'),
          actions: [
            IconButton(
              tooltip: '刷新',
              onPressed: history.loading ? null : controller.refresh,
              icon: const WenyouIcon(WenyouIconIds.actionRefresh),
            ),
          ],
        ),
        body: WenyouSettingsBody(
          children: [
            if (installed != null)
              Text(
                '当前版本 ${installed.version}+${installed.build}',
                style: Theme.of(context).textTheme.wenyouCaption,
              ),
            if (history.loading && history.items.isEmpty)
              const WenyouDetailSkeleton(label: '正在加载更新说明')
            else ...[
              if (!history.loading &&
                  !history.failed &&
                  history.nextCursor == null &&
                  installed != null &&
                  !history.items.any(
                    (release) => release.isInstalled(installed),
                  ))
                const Text('当前版本暂无更新说明'),
              if (history.items.isEmpty && !history.failed)
                const WenyouEmptyState(
                  icon: WenyouIconIds.actionUpdate,
                  title: '暂无版本历史',
                ),
              for (final release in history.items)
                WenyouPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          '${release.target.version}+${release.target.build}',
                          style: Theme.of(
                            context,
                          ).textTheme.wenyouSubsectionTitle,
                        ),
                      ),
                      if (installed != null && release.isInstalled(installed))
                        const Text('当前版本'),
                      SizedBox(height: context.wenyouTokens.space8),
                      Text(
                        release.summary,
                        style: Theme.of(context).textTheme.wenyouBody,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.push(
                            AppRouteLocations.mobileRelease(
                              build: release.target.build,
                              version: release.target.version,
                            ),
                          ),
                          child: const Text('查看更新'),
                        ),
                      ),
                    ],
                  ),
                ),
              if (history.failed)
                WenyouSettingsFailure(
                  message: '更新说明加载失败',
                  onRetry: history.loadMoreFailed
                      ? controller.loadMore
                      : controller.refresh,
                )
              else if (history.nextCursor != null && !history.loading)
                WenyouAsyncButton(
                  label: '加载更多',
                  isLoading: history.loadingMore,
                  onPressed: controller.loadMore,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class MobileReleaseDetailPage extends ConsumerWidget {
  const MobileReleaseDetailPage({required this.target, super.key});

  final MobileReleaseTarget target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return const _UnavailablePage();
    }
    final availability = ref.watch(availableMobileReleaseUpdateProvider);
    final update = availability.valueOrNull;
    final canUpdate =
        !availability.hasError &&
        update != null &&
        target.platform == update.platform &&
        target.build == update.targetBuild &&
        target.version == update.targetVersion;
    return WenyouSettingsTypography(
      child: Scaffold(
        appBar: AppBar(title: const Text('更新说明')),
        body: WenyouSettingsBody(
          children: [
            Text(
              '${target.version}+${target.build}',
              style: Theme.of(context).textTheme.wenyouSectionTitle,
            ),
            WenyouPanel(child: MobileReleaseSection(target: target)),
            if (availability.hasError)
              WenyouSettingsFailure(
                message: '检查更新失败',
                onRetry: () =>
                    ref.invalidate(availableMobileReleaseUpdateProvider),
              ),
            if (canUpdate) MobileUpdateActions(update: update),
          ],
        ),
      ),
    );
  }
}

class _UnavailablePage extends StatelessWidget {
  const _UnavailablePage();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('更新说明')),
    body: const WenyouSettingsBody(
      children: [
        WenyouEmptyState(
          icon: WenyouIconIds.actionUpdate,
          title: '当前平台暂不提供更新说明',
        ),
      ],
    ),
  );
}
