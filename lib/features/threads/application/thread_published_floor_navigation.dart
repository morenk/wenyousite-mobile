import 'package:flutter/foundation.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_detail_controller.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';

/// 发布已成功，之后的读取失败只重试定位，绝不再次提交帖子。
class ThreadPublishedFloorNavigation extends ChangeNotifier {
  PostItem? post;
  ApiFailure? failure;
  bool loading = false;
  bool ready = false;
  bool aligned = false;
  bool clearedAuthor = false;
  int _epoch = 0;
  bool _disposed = false;
  int get revision => _epoch;

  Future<void> locate({
    required PostItem saved,
    required ThreadDetailController controller,
    required ThreadFloorOrder order,
    required String? authorId,
    required bool Function() active,
  }) async {
    if (loading && post?.id == saved.id) return;
    final epoch = ++_epoch;
    post = saved;
    failure = null;
    loading = true;
    ready = false;
    aligned = false;
    clearedAuthor = false;
    notifyListeners();
    bool current() => !_disposed && epoch == _epoch && active();
    try {
      final result = await controller.locate(
        postId: saved.id,
        subthreadId: saved.subthreadId,
        order: order,
        authorId: authorId,
        active: current,
      );
      if (!current()) return;
      if (result == null) {
        throw const ApiFailure(userMessage: '定位失败，请重试。');
      }
      ready = true;
      clearedAuthor = result.clearedAuthor;
    } on Object catch (error) {
      if (!current()) return;
      failure = mapApplicationFailure(error, '定位失败，请重试。');
    } finally {
      if (!_disposed && epoch == _epoch) {
        loading = false;
        notifyListeners();
      }
    }
  }

  void didAlign() {
    if (!ready || aligned) return;
    aligned = true;
    notifyListeners();
  }

  /// 用户接管滚动时保留查看入口，但失效在途读取及自动对齐。
  void release() {
    if (post == null || aligned) return;
    _epoch++;
    loading = false;
    ready = false;
    notifyListeners();
  }

  void clear() {
    _epoch++;
    post = null;
    failure = null;
    loading = false;
    ready = false;
    aligned = false;
  }

  @override
  void dispose() {
    _disposed = true;
    clear();
    super.dispose();
  }
}
