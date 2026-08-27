import 'package:wenyousite_mobile/core/network/api_failure.dart';

class MomentResponseContractValidator {
  const MomentResponseContractValidator();

  void validatePage(int limit) {
    if (limit < 1 || limit > 50) {
      throw const ApiFailure(userMessage: '更多内容加载失败，请重新加载。');
    }
  }

  String? pageCursor(String? cursor, bool hasMore) {
    final safe = optionalText(cursor);
    if (hasMore && safe == null) {
      throw const ApiFailure(userMessage: '列表位置已失效，请刷新。');
    }
    return safe;
  }

  void validateUnique(Iterable<String> ids, String label) {
    final list = ids.toList(growable: false);
    if (list.toSet().length != list.length) {
      violation('MOMENT_DUPLICATE_RESPONSE_ITEM');
    }
  }

  String requiredText(String value, String label) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      violation('MOMENT_REQUIRED_TEXT_MISSING');
    }
    return normalized;
  }

  String? optionalText(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  String requiredHttpUri(String value, String label) {
    return _safeHttpUri(value, label).toString();
  }

  String? optionalHttpUri(String? value, String label) {
    final normalized = optionalText(value);
    return normalized == null
        ? null
        : _safeHttpUri(normalized, label).toString();
  }

  Uri _safeHttpUri(String value, String label) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      violation('MOMENT_UNSAFE_URL');
    }
    return uri;
  }

  int positiveInteger(num value, String label) {
    final integer = value.toInt();
    if (!value.isFinite || integer != value || integer < 1) {
      violation('MOMENT_INVALID_POSITIVE_INTEGER');
    }
    return integer;
  }

  int nonNegativeInteger(num value, String label) {
    final integer = value.toInt();
    if (!value.isFinite || integer != value || integer < 0) {
      violation('MOMENT_INVALID_NON_NEGATIVE_INTEGER');
    }
    return integer;
  }

  int? optionalPositiveInteger(num? value, String label) {
    return value == null ? null : positiveInteger(value, label);
  }

  Never violation(
    String diagnosticCode, {
    String userMessage = '动态加载失败，请重新加载。',
  }) {
    throw ApiFailure.contractViolation(
      userMessage: userMessage,
      diagnosticCode: diagnosticCode,
    );
  }
}
