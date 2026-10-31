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
  ({int? number, String? id, S scope, bool returning})? _pendingTarget;
  Future<DiscussionLocatedTarget?>? _pending;
  bool Function()? _pendingActive;

  String? targetId;
  double? targetOffset;
  int revision = 0;
  bool get canReturn => _previous != null;

  void forgetPrevious() => _previous = null;

  Future<bool> jump(int number, bool Function() active) async =>
      (await _navigate(
        number: number,
        scope: currentScope(),
        active: active,
      ))?.clearedAuthor ??
      false;

  /// 发布、最新发言和外部坐标共用数字跳转的请求代次与返回书签。
  Future<DiscussionLocatedTarget?> goToPost(
    String postId, {
    S? scope,
    required bool Function() active,
    bool rememberPrevious = true,
  }) => _navigate(
    postId: postId,
    scope: scope ?? currentScope(),
    active: active,
    rememberPrevious: rememberPrevious,
  );

  Future<void> returnToPrevious() async {
    final previous = _previous;
    if (previous == null) return;
    await _navigate(
      postId: previous.bookmark.id,
      scope: previous.scope,
      active: () => !_disposed,
      restore: previous.bookmark,
    );
  }

  Future<DiscussionLocatedTarget?> _navigate({
    int? number,
    String? postId,
    required S scope,
    required bool Function() active,
    bool rememberPrevious = true,
    ReadingBookmark? restore,
  }) {
    if (_disposed || !active()) return Future.value();
    final key = (
      number: number,
      id: postId,
      scope: scope,
      returning: restore != null,
    );
    if (_pending != null &&
        _pendingTarget == key &&
        _pendingActive?.call() == true) {
      return _pending!;
    }
    final epoch = ++_epoch;
    final bookmark = rememberPrevious ? reading.captureBookmark() : null;
    final previousScope = currentScope();
    bool isActive() => !_disposed && epoch == _epoch && active();
    _pendingTarget = key;
    _pendingActive = isActive;
    return _pending = () async {
      try {
        final target = await locate(
          number: number,
          postId: postId,
          scope: scope,
          active: isActive,
        );
        if (!isActive() || target == null) return null;
        if (restore != null) {
          _previous = null;
        } else if (rememberPrevious) {
          _previous = bookmark == null
              ? null
              : (bookmark: bookmark, scope: previousScope);
        }
        targetId = target.id;
        targetOffset = restore?.offset;
        revision++;
        notifyListeners();
        return target;
      } on Object {
        if (!isActive()) return null;
        rethrow;
      } finally {
        if (epoch == _epoch) {
          _pending = null;
          _pendingTarget = null;
          _pendingActive = null;
        }
      }
    }();
  }

  void cancelTarget() {
    _epoch++;
    _pending = null;
    _pendingTarget = null;
    _pendingActive = null;
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
