import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_visible_playback.dart';

/// 切换到静态组件会卸载动画监听，失败在本次图片生命周期内只允许用户重试。
class MomentPlaybackImage extends StatefulWidget {
  const MomentPlaybackImage({
    required this.previewUrls,
    required this.animationUrl,
    required this.allowPlayback,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.semanticLabel = '图片',
    this.foregroundColor,
    super.key,
  });
  final List<String> previewUrls;
  final String? animationUrl;
  final bool allowPlayback;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String semanticLabel;
  final Color? foregroundColor;

  @override
  State<MomentPlaybackImage> createState() => _MomentPlaybackImageState();
}

class _MomentPlaybackImageState extends State<MomentPlaybackImage> {
  bool _failed = false;
  bool _retrying = false;
  int _attempt = 0;

  Object get _failureId => ('moment-animation-failure', widget.animationUrl);

  bool get _hasFailed {
    final stored = PageStorage.maybeOf(
      context,
    )?.readState(context, identifier: _failureId);
    return stored is bool ? stored : _failed;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final stored = PageStorage.maybeOf(
      context,
    )?.readState(context, identifier: _failureId);
    if (stored is bool) _failed = stored;
  }

  void _setFailed(bool failed) {
    PageStorage.maybeOf(
      context,
    )?.writeState(context, failed, identifier: _failureId);
    setState(() => _failed = failed);
  }

  @override
  void didUpdateWidget(covariant MomentPlaybackImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationUrl != widget.animationUrl) {
      _failed =
          PageStorage.maybeOf(
            context,
          )?.readState(context, identifier: _failureId) ==
          true;
      _attempt++;
    }
  }

  Widget _preview() => widget.previewUrls.isEmpty
      ? _status(false)
      : WenyouCachedImage(
          imageUrl: widget.previewUrls.first,
          fallbackImageUrls: widget.previewUrls.skip(1).toList(),
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          placeholder: (_, _) => _status(true),
          errorWidget: (_, _, _) => _status(false),
        );

  Widget _status(bool loading) => Center(
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WenyouIcon(
              loading
                  ? WenyouIconIds.actionImage
                  : WenyouIconIds.statusImageUnavailable,
              color: widget.foregroundColor,
            ),
            Text(
              '${widget.semanticLabel}${loading ? '加载中' : '加载失败'}',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.wenyouCaption.copyWith(color: widget.foregroundColor),
            ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => WenyouVisiblePlayback(
    enabled: widget.allowPlayback && widget.animationUrl != null,
    builder: (context, playing) => SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (!playing || _hasFailed)
            _preview()
          else
            WenyouCachedImage(
              key: ValueKey('${widget.animationUrl}:$_attempt'),
              imageUrl: widget.animationUrl!,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              placeholder: (_, _) => _preview(),
              errorWidget: (_, _, _) {
                final attempt = _attempt;
                scheduleMicrotask(() {
                  if (mounted && !_hasFailed && _attempt == attempt) {
                    _setFailed(true);
                  }
                });
                return _preview();
              },
            ),
          if (_hasFailed && playing)
            TextButton(
              onPressed: _retrying
                  ? null
                  : () async {
                      final retryUrl = widget.animationUrl!;
                      final generation = _attempt;
                      setState(() => _retrying = true);
                      try {
                        await WenyouCachedImage.evictFromCache(retryUrl);
                        if (!mounted ||
                            widget.animationUrl != retryUrl ||
                            _attempt != generation) {
                          return;
                        }
                        _attempt++;
                        _setFailed(false);
                      } on Object {
                        // 本地缓存无法释放时保留失败提示，允许用户再次重试。
                        if (mounted &&
                            widget.animationUrl == retryUrl &&
                            _attempt == generation) {
                          _setFailed(true);
                        }
                      } finally {
                        if (mounted) setState(() => _retrying = false);
                      }
                    },
              child: const Text('重试播放'),
            ),
        ],
      ),
    ),
  );
}
