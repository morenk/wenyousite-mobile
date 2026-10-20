import 'package:wenyousite_mobile/core/network/api_failure.dart';

/// 普通单向列表共用请求完成边界；游标、写锁和刷新策略仍由业务拥有。
Future<void> loadCursorPage<T>({
  required Future<T> Function() fetch,
  required bool Function() isCurrent,
  required void Function(T page) onPage,
  required Future<void> Function() onInvalidCursor,
  required ApiFailure Function(Object error) mapFailure,
  required void Function(ApiFailure failure) onFailure,
}) async {
  try {
    final page = await fetch();
    if (!isCurrent()) return;
    onPage(page);
  } on Object catch (error) {
    if (!isCurrent()) return;
    final failure = error is ApiFailure ? error : mapFailure(error);
    if (failure.isInvalidCursor) {
      await onInvalidCursor();
      return;
    }
    onFailure(failure);
  }
}
