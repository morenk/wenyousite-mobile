/// 原生注册的进程级追加账本。目录发布、页面销毁和缓存淘汰不改变它。
/// 记录的是交给引擎的输入上界，不代表原生内存或 RSS，失败也不退额。
class TextFontNativeLedger {
  static const hardMaximumInputBytes = 64 * 1024 * 1024;
  static const hardMaximumKeys = 1024;

  int _maximumInputBytes = hardMaximumInputBytes;
  int _maximumKeys = hardMaximumKeys;
  int _chargedInputBytes = 0;
  final _attempts = <({String hash, String family}), int>{};
  final _loaded = <({String hash, String family})>{};
  final _familyHashes = <String, String>{};
  final _hashLengths = <String, int>{};

  int get maximumInputBytes => _maximumInputBytes;
  int get maximumKeys => _maximumKeys;
  int get chargedInputBytes => _chargedInputBytes;
  int get attemptedCount => _attempts.length;
  int get loadedCount => _loaded.length;

  /// 已校验策略只能收紧，恢复默认或回滚目录不能重新放宽进程额度。
  /// 新上限低于已用量时保留历史占用，停止新的注册尝试。
  void tighten({required int maximumInputBytes, required int maximumKeys}) {
    if (maximumInputBytes < 0 || maximumKeys < 0) {
      throw ArgumentError('原生注册上限不能为负数');
    }
    if (maximumInputBytes < _maximumInputBytes) {
      _maximumInputBytes = maximumInputBytes;
    }
    if (maximumKeys < _maximumKeys) _maximumKeys = maximumKeys;
  }

  bool attempted({required String hash, required String family}) =>
      _attempts.containsKey((hash: hash, family: family));

  bool loaded({required String hash, required String family}) =>
      _loaded.contains((hash: hash, family: family));

  /// 调用方先验证资产 SHA、长度、许可和当前版本状态，再同步预留，
  /// 随后才调用 FontLoader；两步之间不能 await，失败键也不能再次进入。
  /// 同一字节注册到不同 family 可能重复分配，因此每个键独立计费。
  bool beginNativeAttempt({
    required String hash,
    required String family,
    required int inputBytes,
  }) {
    if (!canAttempt(hash: hash, family: family, inputBytes: inputBytes)) {
      return false;
    }
    _record(hash, family, inputBytes);
    return true;
  }

  bool canAttempt({
    required String hash,
    required String family,
    required int inputBytes,
  }) {
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(hash) ||
        family.isEmpty ||
        inputBytes <= 0) {
      return false;
    }
    final key = (hash: hash, family: family);
    if (_attempts.containsKey(key) ||
        (_familyHashes.containsKey(family) && _familyHashes[family] != hash) ||
        (_hashLengths.containsKey(hash) && _hashLengths[hash] != inputBytes) ||
        _attempts.length >= _maximumKeys ||
        inputBytes > _maximumInputBytes - _chargedInputBytes) {
      return false;
    }
    return true;
  }

  void _record(String hash, String family, int inputBytes) {
    _attempts[(hash: hash, family: family)] = inputBytes;
    _familyHashes[family] = hash;
    _hashLengths[hash] = inputBytes;
    _chargedInputBytes += inputBytes;
  }

  /// 只从同一引擎的旧运行对象迁移，不能从服务器或磁盘导入注册状态。
  /// 历史占用超过新上限仍真实记账，后续 begin 会拒绝新增。
  void importEngineAttempt({
    required String hash,
    required String family,
    required int inputBytes,
    required bool succeeded,
  }) {
    final key = (hash: hash, family: family);
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(hash) ||
        family.isEmpty ||
        inputBytes <= 0 ||
        (_familyHashes[family] != null && _familyHashes[family] != hash) ||
        (_hashLengths[hash] != null && _hashLengths[hash] != inputBytes)) {
      throw StateError('旧引擎注册记录冲突');
    }
    if (!_attempts.containsKey(key)) _record(hash, family, inputBytes);
    if (succeeded) _loaded.add(key);
  }

  /// 仅 FontLoader 成功后标记可用；未调用或失败均保持已计费不可重试。
  void completeNativeAttempt({required String hash, required String family}) {
    final key = (hash: hash, family: family);
    if (!_attempts.containsKey(key)) throw StateError('原生注册未预留');
    _loaded.add(key);
  }
}
