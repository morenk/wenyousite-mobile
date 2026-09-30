import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/app_shell/application/clipboard_navigation_ports.dart';

/// 复制与提示共用同一状态，避免迟到的读取或弹窗选择覆盖更新的复制事件。
class ClipboardNavigationCoordinator {
  ClipboardNavigationCoordinator(this._gateway, this._store);

  final ClipboardNavigationGateway _gateway;
  final HandledClipboardNavigationStore _store;
  HandledClipboardNavigation? _handled;
  Future<void>? _load;
  Future<void> _copies = Future.value();
  Future<void> _writes = Future.value();
  int _revision = 0;
  int _handledRevision = 0;

  int get revision => _revision;
  HandledClipboardNavigation? get handled => _handled;

  static String fingerprint(String text) =>
      sha256.convert(utf8.encode(text.trim())).toString();

  static final _ownReceipt = RegExp(
    r'^android:own:([a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12})$',
  );
  static final _androidEvent = RegExp(
    r'^android:[1-9][0-9]*:([a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12})$',
  );

  /// 写入后瞬时失焦无法回读系统版本时，仅认领随机收据匹配的首次快照。
  /// 立刻升级为完整版本，不能永久按 marker 或链接文字屏蔽后续事件。
  Future<bool> resolveOwnReceipt(
    ClipboardNavigationSnapshot snapshot, {
    required int expectedRevision,
  }) async {
    if (expectedRevision != _revision) return false;
    final marker = _ownReceipt
        .firstMatch(_handled?.changeToken ?? '')
        ?.group(1);
    if (marker == null ||
        _androidEvent.firstMatch(snapshot.changeToken ?? '')?.group(1) !=
            marker ||
        _handled?.fingerprint != fingerprint(snapshot.text)) {
      return false;
    }
    await rememberIfCurrent(snapshot, expectedRevision: expectedRevision);
    return true;
  }

  Future<void> ready() async {
    await (_load ??= _loadHandled());
    // 等待期间可能又开始一次复制，必须读到当前队列尾部。
    Future<void> copies;
    do {
      copies = _copies;
      await copies;
    } while (!identical(copies, _copies));
  }

  Future<void> _loadHandled() async {
    final version = _handledRevision;
    try {
      final value = await _store.read();
      if (version == _handledRevision) _handled = value;
    } on Object {
      // 存储不可用时仍保留当前进程已成功复制/处理的事件。
    }
  }

  Future<void> copyLink(String text) {
    // 在原生写入返回前先使正在读取的剪贴板快照失效。
    _revision += 1;
    final operation = _copies.then((_) async {
      final token = await _gateway.writeText(text);
      await _remember(
        HandledClipboardNavigation(
          changeToken: token,
          fingerprint: fingerprint(text),
        ),
      );
    });
    // 一次写入失败不能阻断后续复制；调用者仍收到原始失败。
    _copies = operation.then<void>((_) {}, onError: (Object _) {});
    return operation;
  }

  Future<void> rememberIfCurrent(
    ClipboardNavigationSnapshot snapshot, {
    required int expectedRevision,
  }) async {
    if (expectedRevision != _revision) return;
    await _remember(
      HandledClipboardNavigation(
        changeToken: snapshot.changeToken,
        fingerprint: fingerprint(snapshot.text),
      ),
    );
  }

  Future<void> _remember(HandledClipboardNavigation value) {
    _handled = value;
    _handledRevision += 1;
    _revision += 1;
    // 先更新内存，再串行落盘；失败不撤销已成功的复制或困住弹窗。
    _writes = _writes.then((_) async {
      try {
        await _store.write(value);
      } on Object {
        // 下一次更新仍会继续写入。
      }
    });
    return _writes;
  }
}

final clipboardNavigationCoordinatorProvider =
    Provider<ClipboardNavigationCoordinator>(
      (ref) => ClipboardNavigationCoordinator(
        ref.watch(clipboardNavigationGatewayProvider),
        ref.watch(handledClipboardNavigationStoreProvider),
      ),
    );
