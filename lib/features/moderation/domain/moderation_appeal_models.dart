class AppealCredential {
  const AppealCredential({required this.token, required this.expiresAt});

  final String token;
  final DateTime expiresAt;

  bool get isExpired => !expiresAt.isAfter(DateTime.now().toUtc());
}

enum ModerationAppealStatus { pending, upheld, overturned, unknown }

class ModerationAppealSummary {
  const ModerationAppealSummary({
    required this.id,
    required this.statement,
    required this.status,
    required this.createdAt,
    this.handledNote,
    this.handledAt,
  });

  final String id;
  final String statement;
  final ModerationAppealStatus status;
  final DateTime createdAt;
  final String? handledNote;
  final DateTime? handledAt;

  String get statusLabel => switch (status) {
    ModerationAppealStatus.pending => '待复核',
    ModerationAppealStatus.upheld => '维持决定',
    ModerationAppealStatus.overturned => '已撤销决定',
    ModerationAppealStatus.unknown => '状态未知',
  };
}

class ModerationDecision {
  const ModerationDecision({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.action,
    required this.policyCode,
    required this.publicExplanation,
    required this.active,
    required this.createdAt,
    this.appeal,
  });

  final String id;
  final String targetType;
  final String targetId;
  final String action;
  final String policyCode;
  final String publicExplanation;
  final bool active;
  final DateTime createdAt;
  final ModerationAppealSummary? appeal;

  String get actionLabel => switch (action) {
    'HIDE_CONTENT' => '隐藏内容',
    'SUSPEND_USER' => '暂停账号',
    'BAN_USER' => '封禁账号',
    _ => '治理处置',
  };

  String get targetTypeLabel => switch (targetType) {
    'USER' => '账号',
    'THREAD' => '主题帖',
    'POST' => '帖子',
    'MOMENT' => '动态',
    'MOMENT_COMMENT' => '动态评论',
    'DIRECT_MESSAGE' => '私聊消息',
    _ => '内容',
  };
}
