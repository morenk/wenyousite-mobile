import 'package:intl/intl.dart';

/// Formats recent content with a quiet relative label and older content with
/// a stable calendar date.
String formatWenyouRelativeTime(DateTime value, {DateTime? now}) {
  final localValue = value.toLocal();
  final reference = (now ?? DateTime.now()).toLocal();
  final difference = reference.difference(localValue);

  if (difference.isNegative || difference.inMinutes < 1) return '刚刚';
  if (difference.inHours < 1) return '${difference.inMinutes}分钟前';
  if (difference.inDays < 1) return '${difference.inHours}小时前';
  if (difference.inDays < 7) return '${difference.inDays}天前';
  return DateFormat(
    localValue.year == reference.year ? 'MM-dd' : 'yyyy-MM-dd',
  ).format(localValue);
}
