import 'package:flutter/foundation.dart';
import 'package:wenyousite_mobile/core/widgets/reading_quick_scroll.dart';

typedef DiscussionLocatedTarget = ({String id, bool clearedAuthor});
typedef DiscussionLocator<S> =
    Future<DiscussionLocatedTarget?> Function({
      int? number,
      String? postId,
      required S scope,
      required bool Function() active,
    });

/// 页面内一次跳转与一次返回，不保存到磁盘或跨页面共享。
class DiscussionNavigation<S> extends ChangeNotifier {
  DiscussionNavigation({
    required this.reading,
    required this.currentScope,
    required this.locate,
  });

  final ReadingQuickScrollController reading;
  final S Function() currentScope;
  final DiscussionLocator<S> locate;
  ({ReadingBookmark bookmark, S scope})? _previous;
  var _epoch = 0;
  var _disposed = false;

  String? targetId;
  double? targetOffset;
  int revision = 0;
  bool get canReturn => _previous != null;

  void forgetPrevious() => _previous = null;

  Future<bool> jump(int number, bool Function() active) async {
    final epoch = ++_epoch;
    final bookmark = reading.captureBookmark();
    final scope = currentScope();
    bool isActive() => !_disposed && epoch == _epoch && active();
    final target = await locate(number: number, scope: scope, active: isActive);
    if (!isActive() || target == null) return false;
    _previous = bookmark == null ? null : (bookmark: bookmark, scope: scope);
    targetId = target.id;
    targetOffset = null;
    revision++;
    notifyListeners();
    return target.clearedAuthor;
  }

  Future<void> returnToPrevious() async {
    final previous = _previous;
    if (previous == null) return;
    final epoch = ++_epoch;
    bool isActive() => !_disposed && epoch == _epoch;
    DiscussionLocatedTarget? target;
    try {
      target = await locate(
        postId: previous.bookmark.id,
        scope: previous.scope,
        active: isActive,
      );
    } on Object {
      if (!isActive()) return;
      rethrow;
    }
    if (!isActive() || target == null) return;
    targetId = target.id;
    targetOffset = previous.bookmark.offset;
    _previous = null;
    revision++;
    notifyListeners();
  }

  void cancelTarget() {
    _epoch++;
    targetId = null;
    targetOffset = null;
  }

  void clear() {
    cancelTarget();
    _previous = null;
  }

  @override
  void dispose() {
    _disposed = true;
    clear();
    super.dispose();
  }
}
