import 'dart:async';

import 'package:wenyousite_mobile/core/application/thread_font_preference.dart';

class TestThreadFontStore implements ThreadFontPreferenceStore {
  ThreadFontPreference saved = ThreadFontPreference.standard;
  bool failRead = false;
  bool failWrite = false;
  Completer<void>? pending;
  final writes = <ThreadFontPreference>[];

  @override
  Future<ThreadFontPreference> read() async {
    if (failRead) throw StateError('read failed');
    return saved;
  }

  @override
  Future<void> write(ThreadFontPreference preference) async {
    writes.add(preference);
    if (pending case final completion?) await completion.future;
    if (failWrite) throw StateError('write failed');
    saved = preference;
  }
}
