import 'package:flutter_test/flutter_test.dart';

import '../../support/deterministic_test_fonts.dart';
import 'post_replies_page_composer_media_cases.dart';
import 'post_replies_page_loading_writes_cases.dart';
import 'post_replies_page_scrolling_lifecycle_cases.dart';
import 'post_replies_page_session_editing_cases.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  registerPostRepliesPageLoadingWritesCases();
  registerPostRepliesPageSessionEditingCases();
  registerPostRepliesPageComposerMediaCases();
  registerPostRepliesPageScrollingLifecycleCases();
}
