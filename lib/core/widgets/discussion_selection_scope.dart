import 'package:flutter/widgets.dart';

/// 正文选区存在时冻结分页与裁剪；只保留正在选择的正文状态。
class DiscussionSelectionController extends ChangeNotifier {
  final _owners = <Object>{};
  bool _disposed = false;
  bool get active => _owners.isNotEmpty;
  void update(Object owner, bool selected) {
    if (_disposed) return;
    final changed = selected ? _owners.add(owner) : _owners.remove(owner);
    if (changed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class DiscussionSelectionScope extends InheritedWidget {
  const DiscussionSelectionScope({
    required this.controller,
    required super.child,
    super.key,
  });
  final DiscussionSelectionController controller;
  static DiscussionSelectionController? of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<DiscussionSelectionScope>()
      ?.controller;
  @override
  bool updateShouldNotify(DiscussionSelectionScope oldWidget) =>
      oldWidget.controller != controller;
}
