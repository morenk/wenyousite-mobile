import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/foundation_test_fonts.dart';
import 'moment_pages_compose_upload_cases.dart';
import 'moment_pages_feed_bookmarks_cases.dart';
import 'moment_pages_layout_cases.dart';
import 'moment_pages_recovery_media_cases.dart';

void main() {
  setUpAll(loadFoundationTestFonts);
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (_) async => Directory.systemTemp.path,
        );
  });
  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
  });
  registerMomentPagesFeedBookmarksCases();
  registerMomentPagesComposeUploadCases();
  registerMomentPagesRecoveryMediaCases();
  registerMomentPagesLayoutCases();
}
