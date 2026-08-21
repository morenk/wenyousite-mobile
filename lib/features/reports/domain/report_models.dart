enum ReportTargetType {
  user,
  thread,
  post,
  moment,
  momentComment,
  directMessage,
}

class ReportInputValidationException implements Exception {
  const ReportInputValidationException(this.userMessage);

  final String userMessage;
}

class ReportTarget {
  const ReportTarget._(this.type, this.id);

  const ReportTarget.user(String id) : this._(ReportTargetType.user, id);

  const ReportTarget.thread(String id) : this._(ReportTargetType.thread, id);

  const ReportTarget.post(String id) : this._(ReportTargetType.post, id);

  const ReportTarget.moment(String id) : this._(ReportTargetType.moment, id);

  const ReportTarget.momentComment(String id)
    : this._(ReportTargetType.momentComment, id);

  const ReportTarget.directMessage(String id)
    : this._(ReportTargetType.directMessage, id);

  final ReportTargetType type;
  final String id;

  @override
  bool operator ==(Object other) {
    return other is ReportTarget && other.type == type && other.id == id;
  }

  @override
  int get hashCode => Object.hash(type, id);
}

enum ReportReason {
  spam('垃圾广告'),
  harassment('骚扰或恶意攻击'),
  hateOrThreats('仇恨言论或威胁'),
  sexualContent('色情内容'),
  violentContent('暴力内容'),
  personalInformation('泄露个人信息'),
  impersonationOrFraud('冒充或诈骗'),
  intellectualProperty('侵犯知识产权'),
  illegalContent('违法违规内容'),
  other('其他原因');

  const ReportReason(this.label);

  final String label;

  bool get requiresDetails => this == ReportReason.other;
}

class ReportInput {
  const ReportInput({required this.target, required this.reason, this.details});

  final ReportTarget target;
  final ReportReason reason;
  final String? details;

  ReportInput normalized() {
    final targetId = target.id.trim();
    if (targetId.isEmpty) {
      throw const ReportInputValidationException('举报目标无效，请重新打开页面。');
    }
    final normalizedDetails = details?.trim();
    if (reason.requiresDetails &&
        (normalizedDetails == null || normalizedDetails.isEmpty)) {
      throw const ReportInputValidationException('选择其他原因时，请填写补充说明。');
    }
    if (normalizedDetails != null && normalizedDetails.length > 1000) {
      throw const ReportInputValidationException('补充说明不能超过 1000 字。');
    }
    return ReportInput(
      target: ReportTarget._(target.type, targetId),
      reason: reason,
      details: normalizedDetails == null || normalizedDetails.isEmpty
          ? null
          : normalizedDetails,
    );
  }
}

class ReportResult {
  const ReportResult({
    required this.id,
    required this.target,
    required this.reason,
    required this.createdAt,
  });

  final String id;
  final ReportTarget target;
  final ReportReason reason;
  final DateTime createdAt;
}
