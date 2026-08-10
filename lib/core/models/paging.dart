List<T> mergeUniqueBy<T, K>(
  Iterable<T> existing,
  Iterable<T> incoming, {
  required K Function(T item) keyOf,
}) {
  final keys = <K>{};
  final merged = <T>[];
  for (final item in [...existing, ...incoming]) {
    if (keys.add(keyOf(item))) merged.add(item);
  }
  return List.unmodifiable(merged);
}
