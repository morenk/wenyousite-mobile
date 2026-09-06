import 'package:flutter_test/flutter_test.dart';

import '../../support/foundation_test_fonts.dart';
import 'editor_toolbar_capabilities_alignment_cases.dart';
import 'editor_toolbar_commands_selection_cases.dart';
import 'editor_toolbar_dice_cases.dart';

void main() {
  setUpAll(loadFoundationTestFonts);
  registerEditorToolbarCommandsSelectionCases();
  registerEditorToolbarDiceCases();
  registerEditorToolbarCapabilitiesAlignmentCases();
}
