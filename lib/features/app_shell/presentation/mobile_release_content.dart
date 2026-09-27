import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_settings_body.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_release_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_release.dart';

class MobileReleaseContent extends StatelessWidget {
  const MobileReleaseContent({required this.release, super.key});

  final MobileRelease release;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          release.summary,
          style: Theme.of(context).textTheme.wenyouCompactBody,
        ),
        for (var index = 0; index < release.items.length; index++) ...[
          SizedBox(height: tokens.space12),
          // 纯文本不会执行 Markdown、HTML 或把任意 URL 变成安装入口。
          Text(
            '${index + 1}. ${release.items[index]}',
            style: Theme.of(context).textTheme.wenyouCompactBody,
          ),
        ],
      ],
    );
  }
}

class MobileReleaseSection extends ConsumerWidget {
  const MobileReleaseSection({
    required this.target,
    this.onVisible,
    this.preloadedRelease,
    super.key,
  });

  final MobileReleaseTarget target;
  final VoidCallback? onVisible;
  final MobileRelease? preloadedRelease;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preloaded = preloadedRelease;
    if (preloaded != null && preloaded.target == target) {
      return _VisibleRelease(release: preloaded, onVisible: onVisible);
    }
    final release = ref.watch(mobileReleaseProvider(target));
    return release.when(
      skipLoadingOnRefresh: false,
      loading: () => const WenyouDetailSkeleton(label: '正在加载更新说明'),
      error: (error, stack) => WenyouSettingsFailure(
        message: '更新说明加载失败',
        onRetry: () => ref.invalidate(mobileReleaseProvider(target)),
      ),
      data: (value) => value == null
          ? WenyouStatusBanner(
              message: '此版本暂无更新说明',
              action: TextButton(
                onPressed: () => ref.invalidate(mobileReleaseProvider(target)),
                child: const Text('重试'),
              ),
            )
          : _VisibleRelease(release: value, onVisible: onVisible),
    );
  }
}

class _VisibleRelease extends StatefulWidget {
  const _VisibleRelease({required this.release, this.onVisible});
  final MobileRelease release;
  final VoidCallback? onVisible;

  @override
  State<_VisibleRelease> createState() => _VisibleReleaseState();
}

class _VisibleReleaseState extends State<_VisibleRelease> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onVisible?.call();
    });
    return MobileReleaseContent(release: widget.release);
  }
}
