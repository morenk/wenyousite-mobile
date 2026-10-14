import 'package:flutter/foundation.dart';

import 'emoji_width_data.g.dart';

bool _licenseRegistered = false;

void registerEmojiWidthLicense() {
  if (_licenseRegistered) return;
  _licenseRegistered = true;
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks([
      'Unicode Emoji Data',
    ], unicodeEmojiLicense);
  });
}

/// 精确保留 Extended_Pictographic、区域指示符与组合键帽的双格语义。
bool containsDoubleCellEmoji(String grapheme) {
  for (final point in grapheme.runes) {
    if (point == 0x20e3 || (point >= 0x1f1e6 && point <= 0x1f1ff)) {
      return true;
    }
    var low = 0;
    var high = extendedPictographicRanges.length - 1;
    while (low <= high) {
      final middle = (low + high) ~/ 2;
      final (start, end) = extendedPictographicRanges[middle];
      if (point < start) {
        high = middle - 1;
      } else if (point > end) {
        low = middle + 1;
      } else {
        return true;
      }
    }
  }
  return false;
}
