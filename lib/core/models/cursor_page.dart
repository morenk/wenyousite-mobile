class CursorPage<T> {
  const CursorPage({required this.items, required this.hasMore, this.cursor});

  final List<T> items;
  final String? cursor;
  final bool hasMore;

  CursorPage<T> append(CursorPage<T> next, {Object? Function(T item)? idOf}) {
    if (idOf == null) {
      return CursorPage<T>(
        items: [...items, ...next.items],
        cursor: next.cursor,
        hasMore: next.hasMore,
      );
    }
    final seen = items.map(idOf).toSet();
    return CursorPage<T>(
      items: [...items, ...next.items.where((item) => seen.add(idOf(item)))],
      cursor: next.cursor,
      hasMore: next.hasMore,
    );
  }
}
