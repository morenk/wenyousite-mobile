import 'package:flutter_test/flutter_test.dart';

import '../../support/foundation_test_fonts.dart';
import 'thread_compose_page_layout_drafts_cases.dart';
import 'thread_compose_page_publishing_media_cases.dart';

void main() {
  setUpAll(loadFoundationTestFonts);
  registerThreadComposePagePublishingMediaCases();
  registerThreadComposePageLayoutDraftsCases();
}
