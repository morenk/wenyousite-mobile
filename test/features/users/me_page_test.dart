import 'package:flutter_test/flutter_test.dart';

import '../../support/foundation_test_fonts.dart';
import 'me_page_dashboard_profile_cases.dart';
import 'me_page_media_lifecycle_cases.dart';
import 'me_page_settings_layout_cases.dart';

void main() {
  setUpAll(loadFoundationTestFonts);
  registerMePageDashboardProfileCases();
  registerMePageMediaLifecycleCases();
  registerMePageSettingsLayoutCases();
}
