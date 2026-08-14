// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_hidden_content_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminHiddenContentResponseDtoTargetTypeEnum
_$adminHiddenContentResponseDtoTargetTypeEnum_THREAD =
    const AdminHiddenContentResponseDtoTargetTypeEnum._('THREAD');
const AdminHiddenContentResponseDtoTargetTypeEnum
_$adminHiddenContentResponseDtoTargetTypeEnum_POST =
    const AdminHiddenContentResponseDtoTargetTypeEnum._('POST');
const AdminHiddenContentResponseDtoTargetTypeEnum
_$adminHiddenContentResponseDtoTargetTypeEnum_MOMENT =
    const AdminHiddenContentResponseDtoTargetTypeEnum._('MOMENT');
const AdminHiddenContentResponseDtoTargetTypeEnum
_$adminHiddenContentResponseDtoTargetTypeEnum_MOMENT_COMMENT =
    const AdminHiddenContentResponseDtoTargetTypeEnum._('MOMENT_COMMENT');
const AdminHiddenContentResponseDtoTargetTypeEnum
_$adminHiddenContentResponseDtoTargetTypeEnum_unknownDefaultOpenApi =
    const AdminHiddenContentResponseDtoTargetTypeEnum._(
      'unknownDefaultOpenApi',
    );

AdminHiddenContentResponseDtoTargetTypeEnum
_$adminHiddenContentResponseDtoTargetTypeEnumValueOf(String name) {
  switch (name) {
    case 'THREAD':
      return _$adminHiddenContentResponseDtoTargetTypeEnum_THREAD;
    case 'POST':
      return _$adminHiddenContentResponseDtoTargetTypeEnum_POST;
    case 'MOMENT':
      return _$adminHiddenContentResponseDtoTargetTypeEnum_MOMENT;
    case 'MOMENT_COMMENT':
      return _$adminHiddenContentResponseDtoTargetTypeEnum_MOMENT_COMMENT;
    case 'unknownDefaultOpenApi':
      return _$adminHiddenContentResponseDtoTargetTypeEnum_unknownDefaultOpenApi;
    default:
      return _$adminHiddenContentResponseDtoTargetTypeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminHiddenContentResponseDtoTargetTypeEnum>
_$adminHiddenContentResponseDtoTargetTypeEnumValues =
    BuiltSet<AdminHiddenContentResponseDtoTargetTypeEnum>(
      const <AdminHiddenContentResponseDtoTargetTypeEnum>[
        _$adminHiddenContentResponseDtoTargetTypeEnum_THREAD,
        _$adminHiddenContentResponseDtoTargetTypeEnum_POST,
        _$adminHiddenContentResponseDtoTargetTypeEnum_MOMENT,
        _$adminHiddenContentResponseDtoTargetTypeEnum_MOMENT_COMMENT,
        _$adminHiddenContentResponseDtoTargetTypeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminHiddenContentResponseDtoTargetTypeEnum>
_$adminHiddenContentResponseDtoTargetTypeEnumSerializer =
    _$AdminHiddenContentResponseDtoTargetTypeEnumSerializer();

class _$AdminHiddenContentResponseDtoTargetTypeEnumSerializer
    implements
        PrimitiveSerializer<AdminHiddenContentResponseDtoTargetTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'THREAD': 'THREAD',
    'POST': 'POST',
    'MOMENT': 'MOMENT',
    'MOMENT_COMMENT': 'MOMENT_COMMENT',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'THREAD': 'THREAD',
    'POST': 'POST',
    'MOMENT': 'MOMENT',
    'MOMENT_COMMENT': 'MOMENT_COMMENT',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    AdminHiddenContentResponseDtoTargetTypeEnum,
  ];
  @override
  final String wireName = 'AdminHiddenContentResponseDtoTargetTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminHiddenContentResponseDtoTargetTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminHiddenContentResponseDtoTargetTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminHiddenContentResponseDtoTargetTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminHiddenContentResponseDto extends AdminHiddenContentResponseDto {
  @override
  final AdminHiddenContentResponseDtoTargetTypeEnum targetType;
  @override
  final String targetId;
  @override
  final String summary;
  @override
  final AdminHiddenContentUserResponseDto author;
  @override
  final AdminHiddenContentUserResponseDto? moderator;
  @override
  final DateTime hiddenAt;
  @override
  final String? reason;
  @override
  final bool canRestore;
  @override
  final String? restoreBlockedReason;
  @override
  final String? threadId;
  @override
  final String? parentPostId;
  @override
  final String? momentId;
  @override
  final String? parentCommentId;

  factory _$AdminHiddenContentResponseDto([
    void Function(AdminHiddenContentResponseDtoBuilder)? updates,
  ]) => (AdminHiddenContentResponseDtoBuilder()..update(updates))._build();

  _$AdminHiddenContentResponseDto._({
    required this.targetType,
    required this.targetId,
    required this.summary,
    required this.author,
    this.moderator,
    required this.hiddenAt,
    this.reason,
    required this.canRestore,
    this.restoreBlockedReason,
    this.threadId,
    this.parentPostId,
    this.momentId,
    this.parentCommentId,
  }) : super._();
  @override
  AdminHiddenContentResponseDto rebuild(
    void Function(AdminHiddenContentResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminHiddenContentResponseDtoBuilder toBuilder() =>
      AdminHiddenContentResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminHiddenContentResponseDto &&
        targetType == other.targetType &&
        targetId == other.targetId &&
        summary == other.summary &&
        author == other.author &&
        moderator == other.moderator &&
        hiddenAt == other.hiddenAt &&
        reason == other.reason &&
        canRestore == other.canRestore &&
        restoreBlockedReason == other.restoreBlockedReason &&
        threadId == other.threadId &&
        parentPostId == other.parentPostId &&
        momentId == other.momentId &&
        parentCommentId == other.parentCommentId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, targetType.hashCode);
    _$hash = $jc(_$hash, targetId.hashCode);
    _$hash = $jc(_$hash, summary.hashCode);
    _$hash = $jc(_$hash, author.hashCode);
    _$hash = $jc(_$hash, moderator.hashCode);
    _$hash = $jc(_$hash, hiddenAt.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, canRestore.hashCode);
    _$hash = $jc(_$hash, restoreBlockedReason.hashCode);
    _$hash = $jc(_$hash, threadId.hashCode);
    _$hash = $jc(_$hash, parentPostId.hashCode);
    _$hash = $jc(_$hash, momentId.hashCode);
    _$hash = $jc(_$hash, parentCommentId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminHiddenContentResponseDto')
          ..add('targetType', targetType)
          ..add('targetId', targetId)
          ..add('summary', summary)
          ..add('author', author)
          ..add('moderator', moderator)
          ..add('hiddenAt', hiddenAt)
          ..add('reason', reason)
          ..add('canRestore', canRestore)
          ..add('restoreBlockedReason', restoreBlockedReason)
          ..add('threadId', threadId)
          ..add('parentPostId', parentPostId)
          ..add('momentId', momentId)
          ..add('parentCommentId', parentCommentId))
        .toString();
  }
}

class AdminHiddenContentResponseDtoBuilder
    implements
        Builder<
          AdminHiddenContentResponseDto,
          AdminHiddenContentResponseDtoBuilder
        > {
  _$AdminHiddenContentResponseDto? _$v;

  AdminHiddenContentResponseDtoTargetTypeEnum? _targetType;
  AdminHiddenContentResponseDtoTargetTypeEnum? get targetType =>
      _$this._targetType;
  set targetType(AdminHiddenContentResponseDtoTargetTypeEnum? targetType) =>
      _$this._targetType = targetType;

  String? _targetId;
  String? get targetId => _$this._targetId;
  set targetId(String? targetId) => _$this._targetId = targetId;

  String? _summary;
  String? get summary => _$this._summary;
  set summary(String? summary) => _$this._summary = summary;

  AdminHiddenContentUserResponseDtoBuilder? _author;
  AdminHiddenContentUserResponseDtoBuilder get author =>
      _$this._author ??= AdminHiddenContentUserResponseDtoBuilder();
  set author(AdminHiddenContentUserResponseDtoBuilder? author) =>
      _$this._author = author;

  AdminHiddenContentUserResponseDtoBuilder? _moderator;
  AdminHiddenContentUserResponseDtoBuilder get moderator =>
      _$this._moderator ??= AdminHiddenContentUserResponseDtoBuilder();
  set moderator(AdminHiddenContentUserResponseDtoBuilder? moderator) =>
      _$this._moderator = moderator;

  DateTime? _hiddenAt;
  DateTime? get hiddenAt => _$this._hiddenAt;
  set hiddenAt(DateTime? hiddenAt) => _$this._hiddenAt = hiddenAt;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  bool? _canRestore;
  bool? get canRestore => _$this._canRestore;
  set canRestore(bool? canRestore) => _$this._canRestore = canRestore;

  String? _restoreBlockedReason;
  String? get restoreBlockedReason => _$this._restoreBlockedReason;
  set restoreBlockedReason(String? restoreBlockedReason) =>
      _$this._restoreBlockedReason = restoreBlockedReason;

  String? _threadId;
  String? get threadId => _$this._threadId;
  set threadId(String? threadId) => _$this._threadId = threadId;

  String? _parentPostId;
  String? get parentPostId => _$this._parentPostId;
  set parentPostId(String? parentPostId) => _$this._parentPostId = parentPostId;

  String? _momentId;
  String? get momentId => _$this._momentId;
  set momentId(String? momentId) => _$this._momentId = momentId;

  String? _parentCommentId;
  String? get parentCommentId => _$this._parentCommentId;
  set parentCommentId(String? parentCommentId) =>
      _$this._parentCommentId = parentCommentId;

  AdminHiddenContentResponseDtoBuilder() {
    AdminHiddenContentResponseDto._defaults(this);
  }

  AdminHiddenContentResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _targetType = $v.targetType;
      _targetId = $v.targetId;
      _summary = $v.summary;
      _author = $v.author.toBuilder();
      _moderator = $v.moderator?.toBuilder();
      _hiddenAt = $v.hiddenAt;
      _reason = $v.reason;
      _canRestore = $v.canRestore;
      _restoreBlockedReason = $v.restoreBlockedReason;
      _threadId = $v.threadId;
      _parentPostId = $v.parentPostId;
      _momentId = $v.momentId;
      _parentCommentId = $v.parentCommentId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminHiddenContentResponseDto other) {
    _$v = other as _$AdminHiddenContentResponseDto;
  }

  @override
  void update(void Function(AdminHiddenContentResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminHiddenContentResponseDto build() => _build();

  _$AdminHiddenContentResponseDto _build() {
    _$AdminHiddenContentResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$AdminHiddenContentResponseDto._(
            targetType: BuiltValueNullFieldError.checkNotNull(
              targetType,
              r'AdminHiddenContentResponseDto',
              'targetType',
            ),
            targetId: BuiltValueNullFieldError.checkNotNull(
              targetId,
              r'AdminHiddenContentResponseDto',
              'targetId',
            ),
            summary: BuiltValueNullFieldError.checkNotNull(
              summary,
              r'AdminHiddenContentResponseDto',
              'summary',
            ),
            author: author.build(),
            moderator: _moderator?.build(),
            hiddenAt: BuiltValueNullFieldError.checkNotNull(
              hiddenAt,
              r'AdminHiddenContentResponseDto',
              'hiddenAt',
            ),
            reason: reason,
            canRestore: BuiltValueNullFieldError.checkNotNull(
              canRestore,
              r'AdminHiddenContentResponseDto',
              'canRestore',
            ),
            restoreBlockedReason: restoreBlockedReason,
            threadId: threadId,
            parentPostId: parentPostId,
            momentId: momentId,
            parentCommentId: parentCommentId,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'author';
        author.build();
        _$failedField = 'moderator';
        _moderator?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AdminHiddenContentResponseDto',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
