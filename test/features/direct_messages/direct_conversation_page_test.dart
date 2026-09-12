import 'package:flutter_test/flutter_test.dart';

import '../../support/deterministic_test_fonts.dart';
import 'direct_conversation_page_golden_cases.dart';
import 'direct_conversation_page_scrolling_input_cases.dart';
import 'direct_conversation_page_sending_media_cases.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  registerDirectConversationPageSendingMediaCases();
  registerDirectConversationPageScrollingInputCases();
  registerDirectConversationPageGoldenCases();
}
