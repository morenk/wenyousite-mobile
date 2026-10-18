/// 共享附件等待与编码边界，不拥有业务提交、身份、幂等键或草稿清理。
Future<void> withPreparedEditorPublish({
  required Future<bool> Function() waitForReady,
  required int Function() generation,
  required bool Function(int intent) isIntentCurrent,
  required bool Function() isActive,
  required Future<bool> Function() flush,
  required Future<void> Function() onNotReady,
  required Future<void> Function() submit,
  required void Function() finishWaiting,
}) async {
  try {
    final readiness = waitForReady();
    // waitForReady 建立本次意图后立刻捕获，不能等附件完成才读取新意图。
    final intent = generation();
    final ready = await readiness;
    if (!isActive()) return;
    if (!ready) {
      await onNotReady();
      return;
    }
    if (!isIntentCurrent(intent)) return;
    if (!await flush() || !isActive() || !isIntentCurrent(intent)) return;
    finishWaiting();
    await submit();
  } finally {
    finishWaiting();
  }
}
