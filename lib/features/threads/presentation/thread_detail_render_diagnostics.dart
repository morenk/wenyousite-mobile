import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:wenyousite_mobile/core/diagnostics/debug_diagnostic_console.dart';
import 'package:wenyousite_mobile/core/diagnostics/debug_render_geometry.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/posts/application/post_render_diagnostics.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_detail_controller.dart';

/// Reports one sanitized terminal render result per selected subthread.
///
/// This coordinator deliberately owns the post-frame scheduling so the detail
/// page stays focused on composing the screen and its interaction callbacks.
class ThreadDetailRenderDiagnosticCoordinator {
  final _stopwatch = Stopwatch()..start();
  final _reportedSignatures = <String>{};

  void schedule({
    required BuildContext context,
    required ThreadDetailState state,
    required PostRenderDiagnostics diagnostics,
    required GlobalKey scrollViewportKey,
    required bool Function() isMounted,
  }) {
    if (state.phase == ThreadDetailPhase.loading) return;
    final failure = state.failure;
    final signature = switch (state.phase) {
      ThreadDetailPhase.loading => 'loading',
      ThreadDetailPhase.failed =>
        'failed:${failure?.businessCode ?? failure?.httpStatus ?? 'unknown'}',
      ThreadDetailPhase.ready =>
        'ready:${state.selectedSubthreadId ?? 'without-subthread'}',
    };
    if (!_reportedSignatures.add(signature)) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isMounted()) return;
      final media = MediaQuery.of(context);
      final availableHeight = (media.size.height - media.viewInsets.bottom)
          .clamp(0.0, double.infinity);
      final fetchSucceeded = state.phase == ThreadDetailPhase.ready;
      final viewportObject = scrollViewportKey.currentContext
          ?.findRenderObject();
      final viewportSize = viewportObject is RenderBox && viewportObject.hasSize
          ? viewportObject.size
          : Size.zero;
      final layoutSucceeded = viewportSize.width > 0 && viewportSize.height > 0;
      final succeeded = fetchSucceeded && layoutSucceeded;
      final stage = !fetchSucceeded
          ? PostRenderFailureStage.fetch
          : layoutSucceeded
          ? null
          : PostRenderFailureStage.layout;
      unawaited(
        diagnostics.record(
          PostRenderDiagnosticEvent(
            succeeded: succeeded,
            fetchSucceeded: fetchSucceeded,
            contentType: _contentType(state),
            contentBlockCount: _contentBlockCount(state),
            containerWidth: fetchSucceeded
                ? viewportSize.width
                : media.size.width,
            containerHeight: fetchSucceeded
                ? viewportSize.height
                : availableHeight,
            keyboardInset: media.viewInsets.bottom,
            duration: _stopwatch.elapsed,
            failureStage: stage,
            errorCode: !fetchSucceeded
                ? _diagnosticErrorCode(failure)
                : layoutSucceeded
                ? null
                : 'zero_scroll_viewport',
          ),
        ),
      );
    });
  }
}

/// Captures the real route subtree geometry at stable points after loading.
///
/// MediaQuery can remain correct while a route subtree is clipped, translated
/// or constrained incorrectly. These fixed-name probes distinguish that case
/// from a compositor failing to paint correctly positioned render objects.
class ThreadDetailRenderGeometryProbe {
  final routeKey = GlobalKey(debugLabel: 'thread-detail-route-probe');
  final scaffoldKey = GlobalKey(debugLabel: 'thread-detail-scaffold-probe');
  final appBarKey = GlobalKey(debugLabel: 'thread-detail-app-bar-probe');
  final scrollViewportKey = GlobalKey(
    debugLabel: 'thread-detail-scroll-viewport-probe',
  );
  final overviewKey = GlobalKey(debugLabel: 'thread-detail-overview-probe');
  final bodyKey = GlobalKey(debugLabel: 'thread-detail-body-probe');
  final markdownKey = GlobalKey(debugLabel: 'thread-detail-markdown-probe');
  final bottomBarKey = GlobalKey(debugLabel: 'thread-detail-bottom-bar-probe');

  final _timers = <Timer>[];
  String? _scheduledSignature;
  var _disposed = false;

  void schedule({
    required BuildContext context,
    required ThreadDetailState state,
    required ScrollController scrollController,
    required bool Function() isMounted,
  }) {
    if (!kDebugMode || state.phase != ThreadDetailPhase.ready) return;
    final signature = state.selectedSubthreadId ?? 'without-subthread';
    if (_scheduledSignature == signature) return;
    _scheduledSignature = signature;
    _cancelTimers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _record(
        sample: 'post_frame',
        context: context,
        scrollController: scrollController,
        isMounted: isMounted,
      );
    });
    for (final entry in const <(Duration, String)>[
      (Duration(milliseconds: 750), 'after_750ms'),
      (Duration(milliseconds: 2500), 'after_2500ms'),
    ]) {
      _timers.add(
        Timer(entry.$1, () {
          _record(
            sample: entry.$2,
            context: context,
            scrollController: scrollController,
            isMounted: isMounted,
          );
        }),
      );
    }
  }

  void dispose() {
    _disposed = true;
    _cancelTimers();
  }

  void _record({
    required String sample,
    required BuildContext context,
    required ScrollController scrollController,
    required bool Function() isMounted,
  }) {
    if (_disposed || !isMounted() || !context.mounted) return;
    DebugDiagnosticBuffer.instance.record('thread_render_geometry', {
      'event': 'thread_detail_render_geometry',
      'sample': sample,
      'rendererVariant': wenyouRendererVariant,
      ...buildDebugRenderGeometrySnapshot(
        context: context,
        targets: {
          'route': routeKey,
          'scaffold': scaffoldKey,
          'appBar': appBarKey,
          'scrollViewport': scrollViewportKey,
          'overview': overviewKey,
          'body': bodyKey,
          'markdown': markdownKey,
          'bottomBar': bottomBarKey,
        },
        scrollController: scrollController,
      ),
    });
  }

  void _cancelTimers() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }
}

int _contentBlockCount(ThreadDetailState state) {
  if (state.phase != ThreadDetailPhase.ready) return 0;
  var count = 0;
  if (state.selectedSubthread?.body?.markdown.trim().isNotEmpty == true) {
    count += 1;
  }
  for (final floor in state.floors) {
    if (!floor.isDeleted && floor.body.markdown.trim().isNotEmpty) count += 1;
    count += floor.replies.where((reply) {
      return !reply.isDeleted && reply.body.markdown.trim().isNotEmpty;
    }).length;
  }
  return count;
}

String _contentType(ThreadDetailState state) {
  if (state.phase != ThreadDetailPhase.ready) return 'unknown';
  final markdown = <String>[
    if (state.selectedSubthread?.body case final body?) body.markdown,
    for (final floor in state.floors) ...[
      floor.body.markdown,
      for (final reply in floor.replies) reply.body.markdown,
    ],
  ];
  if (markdown.any((value) => value.contains('!['))) return 'media_markdown';
  if (markdown.any((value) => _richMarkdownMarker.hasMatch(value))) {
    return 'rich_markdown';
  }
  return 'plain_text';
}

String? _diagnosticErrorCode(ApiFailure? failure) {
  if (failure?.businessCode case final code?) return 'business_$code';
  if (failure?.httpStatus case final status?) return 'http_$status';
  return failure == null ? null : 'unknown_fetch_failure';
}

final _richMarkdownMarker = RegExp(r'[\\`*_{}\[\]()#>+\-.!|~@<>&:]');
