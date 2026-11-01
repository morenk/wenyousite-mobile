import 'dart:io';
import 'package:wenyousite_mobile/core/media/media_display.dart';
import 'package:wenyousite_mobile/core/models/discussion_window.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';
import '../test/features/threads/thread_detail_page_detail_repository.dart';

/// 仅合成数据；不创建应用会话，也不委托真实 repository。
class ReadingProfileRepository
    extends ThreadDetailPageTestFakeThreadDetailRepository {
  ReadingProfileRepository(this.imageOrigin) : super(detail: _detail);
  final String imageOrigin;
  final requests = <Map<String, Object>>[];
  var slow = false;
  var offline = false;
  int active = 0;
  int maximumActive = 0;
  static const count = 1200;
  static const author = ThreadAuthorModel(
    id: 'synthetic-user',
    username: '合成读者',
    level: 1,
  );
  static final date = DateTime.utc(2026, 1, 1);
  static final _detail = ThreadDetailModel(
    id: 'thread-1',
    title: '离线千层阅读基准',
    owner: author,
    status: ThreadDetailStatus.recruiting,
    isPrivate: false,
    isPinned: false,
    viewCount: 1,
    likeCount: 0,
    tipTotal: '0',
    memberCount: 1,
    playerCount: 1,
    postCount: count,
    tags: const [],
    defaultSubthreadId: 'synthetic',
    subthreads: const [
      ThreadSubthreadModel(
        id: 'synthetic',
        title: '合成讨论',
        sortOrder: 0,
        postCount: count,
        postingPolicyLabel: '只读基准',
        body: ThreadBodyModel(markdown: '此页面只包含设备本地合成数据。'),
      ),
    ],
    createdAt: date,
    updatedAt: date,
  );

  ThreadFloorModel floor(int number) {
    final long = number % 9 == 0;
    final image = number % 5 == 0;
    final url = '$imageOrigin/$number.png';
    final body = List.generate(
      long ? 80 : 2,
      (p) =>
          '**第 $number 层，第 $p 段**：这是用于离线测量的合成正文。'
          '阅读者在长短楼层之间翻阅，图片迟到和字号变化应保留原来的文字位置。'
          '测试覆盖上下翻页、跳转与返回，不包含任何真实帖子。',
    ).join('\n\n');
    return ThreadFloorModel(
      id: '$number',
      floorNumber: number,
      author: author,
      body: ThreadBodyModel(
        markdown: '$body${image ? '\n\n![合成图片]($url)' : ''}',
        mediaDisplays: image
            ? {
                url: MediaDisplay(
                  url: url,
                  width: 2560,
                  height: 1920,
                  bytes: 0,
                  animated: false,
                  frameCount: 1,
                  durationMs: 0,
                  loopCount: 0,
                ),
              }
            : const {},
      ),
      createdAt: date,
      isDeleted: false,
      replyCount: 0,
      replies: const [],
    );
  }

  @override
  Future<DiscussionWindow<ThreadFloorModel>> fetchFloorWindow({
    required String subthreadId,
    int? number,
    String? postId,
    String? cursor,
    int limit = 20,
    ThreadFloorOrder order = ThreadFloorOrder.oldest,
    String? authorId,
  }) async {
    final watch = Stopwatch()..start();
    active++;
    if (active > maximumActive) maximumActive = active;
    final target = number ?? (postId == null ? null : int.parse(postId));
    final start = cursor != null
        ? int.parse(cursor)
        : ((target ?? 11) - 10).clamp(1, count - 19);
    final failed = offline;
    try {
      await Future<void>.delayed(Duration(milliseconds: slow ? 900 : 120));
      if (failed) {
        throw const ApiFailure(
          source: FailureSource.network,
          reason: FailureReason.offline,
        );
      }
      final end = (start + 20).clamp(1, count + 1);
      return DiscussionWindow(
        items: [for (var i = start; i < end; i++) floor(i)],
        total: count,
        maxNumber: count,
        targetId: target?.toString(),
        targetNumber: target,
        beforeCursor: start > 1 ? '${(start - 20).clamp(1, count)}' : null,
        afterCursor: end <= count ? '$end' : null,
      );
    } finally {
      active--;
      requests.add({
        'target': target != null,
        'start': start,
        'ms': watch.elapsedMilliseconds,
        'offline': failed,
      });
    }
  }

  @override
  Future<ThreadPostTargetModel> fetchPostTarget(String postId) async =>
      ThreadPostTargetModel(
        requestedPostId: postId,
        threadId: 'thread-1',
        subthreadId: 'synthetic',
        floor: floor(int.parse(postId)),
      );
}

/// 即使 fixture 漏了某个 provider，也禁止发起设备外请求。
class ReadingLoopbackOnly extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      _LoopbackClient(super.createHttpClient(context));
}

class _LoopbackClient implements HttpClient {
  _LoopbackClient(this.inner);
  final HttpClient inner;
  @override
  set autoUncompress(bool value) => inner.autoUncompress = value;
  @override
  set connectionTimeout(Duration? value) => inner.connectionTimeout = value;
  @override
  set idleTimeout(Duration value) => inner.idleTimeout = value;
  @override
  set userAgent(String? value) => inner.userAgent = value;
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) {
    if (url.host != '127.0.0.1' || method != 'GET') {
      throw StateError('离线基准拒绝外部请求：${url.host}');
    }
    return inner.openUrl(method, url);
  }

  @override
  void close({bool force = false}) => inner.close(force: force);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
