import 'dart:async';

import 'package:flutter/foundation.dart';

/// 只负责可见性和停稳计时；形变由滑块自己的动画完成，不驱动正文重建。
class ReadingScrollVisibility extends ChangeNotifier {
  ReadingScrollVisibility({
    required this.expandedHold,
    required this.collapseDuration,
    required this.collapsedHold,
    required this.slowReadHold,
  });

  final Duration expandedHold;
  final Duration collapseDuration;
  final Duration collapsedHold;
  final Duration slowReadHold;
  Timer? _timer;
  bool _enabled = false;
  bool _scrolling = false;
  bool _pressed = false;
  bool _focused = false;
  bool _accessible = false;
  bool _visible = false;
  bool _expanded = false;
  int _resetRevision = 0;

  bool get visible => _enabled && _visible;
  bool get expanded => _enabled && _expanded;
  int get resetRevision => _resetRevision;
  bool get _held => _scrolling || _pressed || _focused || _accessible;

  void configure({required bool enabled, required bool accessible}) {
    if (_enabled == enabled && _accessible == accessible) return;
    _enabled = enabled;
    _accessible = accessible;
    if (!enabled) {
      reset();
    } else if (accessible) {
      _showExpanded();
    } else {
      _waitForIdle();
    }
  }

  void setFocused(bool focused) {
    if (_focused == focused) return;
    _focused = focused;
    if (focused && _enabled) {
      _showExpanded();
    } else {
      _waitForIdle();
    }
  }

  void setPressed(bool pressed) {
    _pressed = pressed;
    if (pressed) {
      _timer?.cancel();
    } else {
      _waitForIdle();
    }
  }

  void setScrolling(bool scrolling) {
    _scrolling = scrolling;
    if (scrolling) {
      _timer?.cancel();
    } else {
      _waitForIdle();
    }
  }

  void showScroll({required bool fast}) {
    if (!_enabled) return;
    _timer?.cancel();
    _visible = true;
    if (fast) _expanded = true;
    notifyListeners();
    _waitForIdle();
  }

  void _showExpanded() {
    _timer?.cancel();
    _visible = _expanded = true;
    notifyListeners();
  }

  void _waitForIdle() {
    _timer?.cancel();
    if (!_enabled || !_visible || _held) return;
    _timer = Timer(_expanded ? expandedHold : slowReadHold, () {
      if (_expanded) {
        _expanded = false;
        notifyListeners();
        _timer = Timer(collapseDuration + collapsedHold, _hide);
      } else {
        _hide();
      }
    });
  }

  void _hide() {
    _visible = false;
    notifyListeners();
  }

  /// 换页、取消等立即丢弃旧动作；无障碍模式在新范围重新提供入口。
  void reset() {
    _timer?.cancel();
    _scrolling = _pressed = _focused = false;
    _visible = _expanded = _enabled && _accessible;
    _resetRevision++;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
