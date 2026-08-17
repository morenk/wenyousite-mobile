import 'package:wenyousite_foundation/wenyousite_foundation.dart';

/// Keeps the app-facing helper while delegating the shared 72-hour rule to
/// Foundation.
String formatWenyouRelativeTime(DateTime value, {DateTime? now}) {
  return formatWenyouTime(value, reference: now);
}
