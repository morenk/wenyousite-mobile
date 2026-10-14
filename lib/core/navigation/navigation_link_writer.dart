import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 显式「复制链接」入口；应用装配层接入复制事件记账。
typedef NavigationLinkWriter = Future<void> Function(String text);

final navigationLinkWriterProvider = Provider<NavigationLinkWriter>(
  (ref) =>
      (text) => Clipboard.setData(ClipboardData(text: text)),
);
