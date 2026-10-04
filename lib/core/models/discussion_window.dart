/// 一次读取的连续讨论片段；编号是永久标识，不是筛选后的序号。
class DiscussionWindow<T> {
  const DiscussionWindow({
    required this.items,
    required this.total,
    required this.maxNumber,
    this.pinnedItems = const [],
    this.targetId,
    this.targetNumber,
    this.beforeCursor,
    this.afterCursor,
  });

  final List<T> items;
  final List<T> pinnedItems;
  final int total;
  final int maxNumber;
  final String? targetId;
  final int? targetNumber;
  final String? beforeCursor;
  final String? afterCursor;
}

/// 最多保留 120 条正文。页边界保留各自的游标，裁剪后仍能反向读取。
class DiscussionWindowBuffer<T> {
  DiscussionWindowBuffer(DiscussionWindow<T> first)
    : pages = List.unmodifiable([first]),
      maxNumber = first.maxNumber,
      total = first.total;

  DiscussionWindowBuffer._(this.pages, this.maxNumber, this.total);

  static const maximumItems = 120;
  final List<DiscussionWindow<T>> pages;

  List<T> get items => List.unmodifiable(pages.expand((page) => page.items));
  String? get beforeCursor => pages.first.beforeCursor;
  String? get afterCursor => pages.last.afterCursor;
  final int maxNumber;
  final int total;

  DiscussionWindowBuffer<T> removeWhere(bool Function(T) remove) {
    final removedCount = items.where(remove).length;
    return DiscussionWindowBuffer._(
      List.unmodifiable([
        for (final page in pages)
          DiscussionWindow<T>(
            items: List.unmodifiable(page.items.where((item) => !remove(item))),
            total: (total - removedCount).clamp(0, total),
            maxNumber: maxNumber,
            beforeCursor: page.beforeCursor,
            afterCursor: page.afterCursor,
          ),
      ]),
      maxNumber,
      (total - removedCount).clamp(0, total),
    );
  }

  DiscussionWindowBuffer<T> extend(
    DiscussionWindow<T> page, {
    required bool before,
    required String Function(T) idOf,
    String? visibleId,
  }) {
    final knownIds = items.map(idOf).toSet();
    final unique = page.items.where((item) => !knownIds.contains(idOf(item)));
    final normalized = DiscussionWindow<T>(
      items: List.unmodifiable(unique),
      total: page.total,
      maxNumber: page.maxNumber,
      targetId: page.targetId,
      targetNumber: page.targetNumber,
      beforeCursor: page.beforeCursor,
      afterCursor: page.afterCursor,
    );
    final next = before ? [normalized, ...pages] : [...pages, normalized];
    while (next.fold(0, (sum, value) => sum + value.items.length) >
        maximumItems) {
      final removed = before ? next.last : next.first;
      if (visibleId != null &&
          removed.items.any((item) => idOf(item) == visibleId)) {
        // 请求期间读者已经折返，不能用迟到分页挤掉正在阅读的内容。
        return this;
      }
      before ? next.removeLast() : next.removeAt(0);
    }
    // 空页不保留为无限增长的元数据；边界游标仍由实际返回值更新。
    if (normalized.items.isEmpty) {
      if (before) {
        next.removeAt(0);
        final first = next.first;
        next[0] = DiscussionWindow<T>(
          items: first.items,
          total: page.total,
          maxNumber: page.maxNumber,
          beforeCursor: page.beforeCursor,
          afterCursor: first.afterCursor,
        );
      } else {
        next.removeLast();
        final last = next.last;
        next[next.length - 1] = DiscussionWindow<T>(
          items: last.items,
          total: page.total,
          maxNumber: page.maxNumber,
          beforeCursor: last.beforeCursor,
          afterCursor: page.afterCursor,
        );
      }
    }
    return DiscussionWindowBuffer._(
      List.unmodifiable(next),
      page.maxNumber,
      page.total,
    );
  }
}
