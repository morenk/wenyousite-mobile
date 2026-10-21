/// 详情底栏专用短计数；完整值仍由操作的无障碍语义提供。
String formatCompactActionCount(int count) {
  if (count < 1000) return '$count';
  if (count >= 1000000000000000) {
    final digits = count.toString();
    return '${digits[0]}e${digits.length - 1}';
  }
  const units = [
    (1000000000000, 't'),
    (1000000000, 'b'),
    (1000000, 'm'),
    (1000, 'k'),
  ];
  for (final (divisor, suffix) in units) {
    if (count < divisor) continue;
    final whole = count ~/ divisor;
    final decimal = (count % divisor) ~/ (divisor ~/ 10);
    return whole < 10 && decimal != 0
        ? '$whole.$decimal$suffix'
        : '$whole$suffix';
  }
  return '$count';
}
