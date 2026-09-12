import 'package:flutter_test/flutter_test.dart';

import '../../support/deterministic_test_fonts.dart';
import 'thread_detail_page_management_clipboard_cases.dart';
import 'thread_detail_page_reading_filters_cases.dart';
import 'thread_detail_page_reading_layout_cases.dart';
import 'thread_detail_page_session_navigation_cases.dart';
import 'thread_detail_page_subthread_navigation_cases.dart';
import 'thread_detail_page_target_paging_cases.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  registerThreadDetailPageReadingFiltersCases();
  registerThreadDetailPageReadingLayoutCases();
  registerThreadDetailPageSubthreadNavigationCases();
  registerThreadDetailPageTargetPagingCases();
  registerThreadDetailPageSessionNavigationCases();
  registerThreadDetailPageManagementClipboardCases();
}
