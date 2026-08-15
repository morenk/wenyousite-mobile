class WenyouAmountValidationException implements Exception {
  const WenyouAmountValidationException(this.userMessage);

  final String userMessage;
}

abstract final class WenyouAmount {
  static final RegExp _nonNegativeInteger = RegExp(r'^(?:0|[1-9]\d*)$');
  static final RegExp _tipInteger = RegExp(r'^(?:[2-9]|[1-9]\d+)$');
  static const String maximum = '9223372036854775807';

  static String requireNonNegative(String value, String field) {
    if (!_nonNegativeInteger.hasMatch(value)) {
      throw WenyouAmountValidationException('$field不是有效的温油整数，请重新加载。');
    }
    return value;
  }

  static String normalizeTip(String value) {
    final normalized = value.trim();
    if (!_tipInteger.hasMatch(normalized) || _exceedsMaximum(normalized)) {
      throw const WenyouAmountValidationException('最低投入 2 升，且只能填写可用范围内的整数。');
    }
    return normalized;
  }

  static String format(String value) {
    final safe = requireNonNegative(value, '温油金额');
    final firstGroupLength = safe.length % 3;
    final buffer = StringBuffer();
    var index = 0;
    if (firstGroupLength != 0) {
      buffer.write(safe.substring(0, firstGroupLength));
      index = firstGroupLength;
    }
    while (index < safe.length) {
      if (buffer.isNotEmpty) buffer.write(',');
      buffer.write(safe.substring(index, index + 3));
      index += 3;
    }
    return buffer.toString();
  }

  static bool _exceedsMaximum(String value) {
    return value.length > maximum.length ||
        (value.length == maximum.length && value.compareTo(maximum) > 0);
  }
}

class WalletSummary {
  const WalletSummary({
    required this.balance,
    required this.receivedTipTotal,
    required this.receivedTipCount,
  });

  final String balance;
  final String receivedTipTotal;
  final int receivedTipCount;
}

class WalletProgression {
  const WalletProgression({
    required this.level,
    required this.experience,
    required this.currentLevelExperience,
    this.nextLevelExperience,
  });

  final int level;
  final int experience;
  final int currentLevelExperience;
  final int? nextLevelExperience;
}

class DailyCheckInResult {
  const DailyCheckInResult({
    required this.claimedNow,
    required this.date,
    required this.rewardAmount,
    required this.experienceAwarded,
    required this.balance,
    required this.progression,
  });

  final bool claimedNow;
  final String date;
  final String rewardAmount;
  final int experienceAwarded;
  final String balance;
  final WalletProgression progression;
}

enum WalletTransactionType { dailyCheckIn, tip }

enum WalletTransactionDirection { income, expense }

enum WalletTargetType { thread, user, moment, none }

class WalletCounterparty {
  const WalletCounterparty({
    required this.id,
    required this.username,
    required this.level,
    this.avatarUrl,
  });

  final String id;
  final String username;
  final int level;
  final String? avatarUrl;
}

class WalletTransactionTarget {
  const WalletTransactionTarget({required this.type, this.id, this.title});

  final WalletTargetType type;
  final String? id;
  final String? title;
}

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.type,
    required this.direction,
    required this.amount,
    required this.grossAmount,
    required this.recipientAmount,
    required this.platformAmount,
    required this.balanceAfter,
    required this.target,
    required this.createdAt,
    this.counterparty,
  });

  final String id;
  final WalletTransactionType type;
  final WalletTransactionDirection direction;
  final String amount;
  final String grossAmount;
  final String recipientAmount;
  final String platformAmount;
  final String balanceAfter;
  final WalletCounterparty? counterparty;
  final WalletTransactionTarget target;
  final DateTime createdAt;
}

enum TipTargetType { thread, user, moment }

class TipTarget {
  const TipTarget.thread({required this.id, required this.recipientUserId})
    : type = TipTargetType.thread;

  const TipTarget.user({required this.id})
    : type = TipTargetType.user,
      recipientUserId = id;

  const TipTarget.moment({required this.id, required this.recipientUserId})
    : type = TipTargetType.moment;

  final TipTargetType type;
  final String id;
  final String recipientUserId;

  @override
  bool operator ==(Object other) {
    return other is TipTarget &&
        other.type == type &&
        other.id == id &&
        other.recipientUserId == recipientUserId;
  }

  @override
  int get hashCode => Object.hash(type, id, recipientUserId);
}

class TipResult {
  const TipResult({
    required this.transactionId,
    required this.grossAmount,
    required this.recipientAmount,
    required this.platformAmount,
    required this.balance,
    required this.recipientTipTotal,
    required this.recipientTipCount,
    this.threadTipTotal,
    this.momentTipTotal,
  });

  final String transactionId;
  final String grossAmount;
  final String recipientAmount;
  final String platformAmount;
  final String balance;
  final String? threadTipTotal;
  final String? momentTipTotal;
  final String recipientTipTotal;
  final int recipientTipCount;
}
