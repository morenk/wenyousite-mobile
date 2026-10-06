import 'dart:async';

import 'package:wenyousite_mobile/features/app_shell/application/clipboard_navigation_ports.dart';

class FakeNavigationClipboard implements ClipboardNavigationGateway {
  String? text;
  String? token;
  bool readable = true;
  bool failWrite = false;
  String? writeReceipt;
  String? writtenEvent;
  int writes = 0;
  int reads = 0;
  Completer<String?>? pendingWrite;
  Completer<ClipboardNavigationSnapshot?>? pendingSnapshot;

  @override
  Future<String?> writeText(String value) async {
    writes += 1;
    if (failWrite) throw StateError('copy failed');
    text = value;
    token = writtenEvent ?? 'android:copy:$writes';
    return pendingWrite == null
        ? writeReceipt ?? token
        : await pendingWrite!.future;
  }

  @override
  Future<String?> readChangeToken() async => readable ? token : null;

  @override
  Future<ClipboardNavigationSnapshot?> readSnapshot() async {
    reads += 1;
    if (pendingSnapshot != null) return pendingSnapshot!.future;
    if (!readable || text == null) return null;
    return ClipboardNavigationSnapshot(text: text!, changeToken: token);
  }
}

class FakeNavigationStore implements HandledClipboardNavigationStore {
  HandledClipboardNavigation? value;
  final writes = <HandledClipboardNavigation>[];
  Completer<HandledClipboardNavigation?>? pendingRead;
  Completer<void>? pendingWrite;
  bool failWrite = false;

  @override
  Future<HandledClipboardNavigation?> read() async =>
      pendingRead == null ? value : await pendingRead!.future;

  @override
  Future<void> write(HandledClipboardNavigation next) async {
    writes.add(next);
    if (pendingWrite != null) await pendingWrite!.future;
    if (failWrite) throw StateError('storage unavailable');
    value = next;
  }
}
