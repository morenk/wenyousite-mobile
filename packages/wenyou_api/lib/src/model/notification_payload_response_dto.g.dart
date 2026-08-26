// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_payload_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const NotificationPayloadResponseDtoSchemaVersionEnum
_$notificationPayloadResponseDtoSchemaVersionEnum_n1 =
    const NotificationPayloadResponseDtoSchemaVersionEnum._('n1');
const NotificationPayloadResponseDtoSchemaVersionEnum
_$notificationPayloadResponseDtoSchemaVersionEnum_unknownDefaultOpenApi =
    const NotificationPayloadResponseDtoSchemaVersionEnum._(
      'unknownDefaultOpenApi',
    );

NotificationPayloadResponseDtoSchemaVersionEnum
_$notificationPayloadResponseDtoSchemaVersionEnumValueOf(String name) {
  switch (name) {
    case 'n1':
      return _$notificationPayloadResponseDtoSchemaVersionEnum_n1;
    case 'unknownDefaultOpenApi':
      return _$notificationPayloadResponseDtoSchemaVersionEnum_unknownDefaultOpenApi;
    default:
      return _$notificationPayloadResponseDtoSchemaVersionEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<NotificationPayloadResponseDtoSchemaVersionEnum>
_$notificationPayloadResponseDtoSchemaVersionEnumValues =
    BuiltSet<NotificationPayloadResponseDtoSchemaVersionEnum>(
      const <NotificationPayloadResponseDtoSchemaVersionEnum>[
        _$notificationPayloadResponseDtoSchemaVersionEnum_n1,
        _$notificationPayloadResponseDtoSchemaVersionEnum_unknownDefaultOpenApi,
      ],
    );

const NotificationPayloadResponseDtoOldRoleEnum
_$notificationPayloadResponseDtoOldRoleEnum_COLLABORATOR =
    const NotificationPayloadResponseDtoOldRoleEnum._('COLLABORATOR');
const NotificationPayloadResponseDtoOldRoleEnum
_$notificationPayloadResponseDtoOldRoleEnum_PARTICIPANT =
    const NotificationPayloadResponseDtoOldRoleEnum._('PARTICIPANT');
const NotificationPayloadResponseDtoOldRoleEnum
_$notificationPayloadResponseDtoOldRoleEnum_unknownDefaultOpenApi =
    const NotificationPayloadResponseDtoOldRoleEnum._('unknownDefaultOpenApi');

NotificationPayloadResponseDtoOldRoleEnum
_$notificationPayloadResponseDtoOldRoleEnumValueOf(String name) {
  switch (name) {
    case 'COLLABORATOR':
      return _$notificationPayloadResponseDtoOldRoleEnum_COLLABORATOR;
    case 'PARTICIPANT':
      return _$notificationPayloadResponseDtoOldRoleEnum_PARTICIPANT;
    case 'unknownDefaultOpenApi':
      return _$notificationPayloadResponseDtoOldRoleEnum_unknownDefaultOpenApi;
    default:
      return _$notificationPayloadResponseDtoOldRoleEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<NotificationPayloadResponseDtoOldRoleEnum>
_$notificationPayloadResponseDtoOldRoleEnumValues =
    BuiltSet<NotificationPayloadResponseDtoOldRoleEnum>(
      const <NotificationPayloadResponseDtoOldRoleEnum>[
        _$notificationPayloadResponseDtoOldRoleEnum_COLLABORATOR,
        _$notificationPayloadResponseDtoOldRoleEnum_PARTICIPANT,
        _$notificationPayloadResponseDtoOldRoleEnum_unknownDefaultOpenApi,
      ],
    );

const NotificationPayloadResponseDtoNewRoleEnum
_$notificationPayloadResponseDtoNewRoleEnum_COLLABORATOR =
    const NotificationPayloadResponseDtoNewRoleEnum._('COLLABORATOR');
const NotificationPayloadResponseDtoNewRoleEnum
_$notificationPayloadResponseDtoNewRoleEnum_PARTICIPANT =
    const NotificationPayloadResponseDtoNewRoleEnum._('PARTICIPANT');
const NotificationPayloadResponseDtoNewRoleEnum
_$notificationPayloadResponseDtoNewRoleEnum_unknownDefaultOpenApi =
    const NotificationPayloadResponseDtoNewRoleEnum._('unknownDefaultOpenApi');

NotificationPayloadResponseDtoNewRoleEnum
_$notificationPayloadResponseDtoNewRoleEnumValueOf(String name) {
  switch (name) {
    case 'COLLABORATOR':
      return _$notificationPayloadResponseDtoNewRoleEnum_COLLABORATOR;
    case 'PARTICIPANT':
      return _$notificationPayloadResponseDtoNewRoleEnum_PARTICIPANT;
    case 'unknownDefaultOpenApi':
      return _$notificationPayloadResponseDtoNewRoleEnum_unknownDefaultOpenApi;
    default:
      return _$notificationPayloadResponseDtoNewRoleEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<NotificationPayloadResponseDtoNewRoleEnum>
_$notificationPayloadResponseDtoNewRoleEnumValues =
    BuiltSet<NotificationPayloadResponseDtoNewRoleEnum>(
      const <NotificationPayloadResponseDtoNewRoleEnum>[
        _$notificationPayloadResponseDtoNewRoleEnum_COLLABORATOR,
        _$notificationPayloadResponseDtoNewRoleEnum_PARTICIPANT,
        _$notificationPayloadResponseDtoNewRoleEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<NotificationPayloadResponseDtoSchemaVersionEnum>
_$notificationPayloadResponseDtoSchemaVersionEnumSerializer =
    _$NotificationPayloadResponseDtoSchemaVersionEnumSerializer();
Serializer<NotificationPayloadResponseDtoOldRoleEnum>
_$notificationPayloadResponseDtoOldRoleEnumSerializer =
    _$NotificationPayloadResponseDtoOldRoleEnumSerializer();
Serializer<NotificationPayloadResponseDtoNewRoleEnum>
_$notificationPayloadResponseDtoNewRoleEnumSerializer =
    _$NotificationPayloadResponseDtoNewRoleEnumSerializer();

class _$NotificationPayloadResponseDtoSchemaVersionEnumSerializer
    implements
        PrimitiveSerializer<NotificationPayloadResponseDtoSchemaVersionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'n1': '1',
    'unknownDefaultOpenApi': '11184809',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    '1': 'n1',
    '11184809': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    NotificationPayloadResponseDtoSchemaVersionEnum,
  ];
  @override
  final String wireName = 'NotificationPayloadResponseDtoSchemaVersionEnum';

  @override
  Object serialize(
    Serializers serializers,
    NotificationPayloadResponseDtoSchemaVersionEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  NotificationPayloadResponseDtoSchemaVersionEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => NotificationPayloadResponseDtoSchemaVersionEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$NotificationPayloadResponseDtoOldRoleEnumSerializer
    implements PrimitiveSerializer<NotificationPayloadResponseDtoOldRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'COLLABORATOR': 'COLLABORATOR',
    'PARTICIPANT': 'PARTICIPANT',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'COLLABORATOR': 'COLLABORATOR',
    'PARTICIPANT': 'PARTICIPANT',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    NotificationPayloadResponseDtoOldRoleEnum,
  ];
  @override
  final String wireName = 'NotificationPayloadResponseDtoOldRoleEnum';

  @override
  Object serialize(
    Serializers serializers,
    NotificationPayloadResponseDtoOldRoleEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  NotificationPayloadResponseDtoOldRoleEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => NotificationPayloadResponseDtoOldRoleEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$NotificationPayloadResponseDtoNewRoleEnumSerializer
    implements PrimitiveSerializer<NotificationPayloadResponseDtoNewRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'COLLABORATOR': 'COLLABORATOR',
    'PARTICIPANT': 'PARTICIPANT',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'COLLABORATOR': 'COLLABORATOR',
    'PARTICIPANT': 'PARTICIPANT',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    NotificationPayloadResponseDtoNewRoleEnum,
  ];
  @override
  final String wireName = 'NotificationPayloadResponseDtoNewRoleEnum';

  @override
  Object serialize(
    Serializers serializers,
    NotificationPayloadResponseDtoNewRoleEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  NotificationPayloadResponseDtoNewRoleEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => NotificationPayloadResponseDtoNewRoleEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$NotificationPayloadResponseDto extends NotificationPayloadResponseDto {
  @override
  final NotificationPayloadResponseDtoSchemaVersionEnum schemaVersion;
  @override
  final String? action;
  @override
  final String? actorId;
  @override
  final String? actorName;
  @override
  final String? replyTargetUserId;
  @override
  final String? replyTargetName;
  @override
  final String? preview;
  @override
  final String? subthreadTitle;
  @override
  final String? threadTitle;
  @override
  final String? threadId;
  @override
  final NotificationPayloadResponseDtoOldRoleEnum? oldRole;
  @override
  final NotificationPayloadResponseDtoNewRoleEnum? newRole;
  @override
  final String? momentTitle;
  @override
  final num? totalCount;
  @override
  final BuiltList<NotificationLikerResponseDto>? likers;
  @override
  final String? grossAmount;
  @override
  final String? recipientAmount;
  @override
  final String? platformAmount;
  @override
  final num? previousLevel;
  @override
  final num? level;
  @override
  final num? experience;

  factory _$NotificationPayloadResponseDto([
    void Function(NotificationPayloadResponseDtoBuilder)? updates,
  ]) => (NotificationPayloadResponseDtoBuilder()..update(updates))._build();

  _$NotificationPayloadResponseDto._({
    required this.schemaVersion,
    this.action,
    this.actorId,
    this.actorName,
    this.replyTargetUserId,
    this.replyTargetName,
    this.preview,
    this.subthreadTitle,
    this.threadTitle,
    this.threadId,
    this.oldRole,
    this.newRole,
    this.momentTitle,
    this.totalCount,
    this.likers,
    this.grossAmount,
    this.recipientAmount,
    this.platformAmount,
    this.previousLevel,
    this.level,
    this.experience,
  }) : super._();
  @override
  NotificationPayloadResponseDto rebuild(
    void Function(NotificationPayloadResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  NotificationPayloadResponseDtoBuilder toBuilder() =>
      NotificationPayloadResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationPayloadResponseDto &&
        schemaVersion == other.schemaVersion &&
        action == other.action &&
        actorId == other.actorId &&
        actorName == other.actorName &&
        replyTargetUserId == other.replyTargetUserId &&
        replyTargetName == other.replyTargetName &&
        preview == other.preview &&
        subthreadTitle == other.subthreadTitle &&
        threadTitle == other.threadTitle &&
        threadId == other.threadId &&
        oldRole == other.oldRole &&
        newRole == other.newRole &&
        momentTitle == other.momentTitle &&
        totalCount == other.totalCount &&
        likers == other.likers &&
        grossAmount == other.grossAmount &&
        recipientAmount == other.recipientAmount &&
        platformAmount == other.platformAmount &&
        previousLevel == other.previousLevel &&
        level == other.level &&
        experience == other.experience;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, schemaVersion.hashCode);
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, actorId.hashCode);
    _$hash = $jc(_$hash, actorName.hashCode);
    _$hash = $jc(_$hash, replyTargetUserId.hashCode);
    _$hash = $jc(_$hash, replyTargetName.hashCode);
    _$hash = $jc(_$hash, preview.hashCode);
    _$hash = $jc(_$hash, subthreadTitle.hashCode);
    _$hash = $jc(_$hash, threadTitle.hashCode);
    _$hash = $jc(_$hash, threadId.hashCode);
    _$hash = $jc(_$hash, oldRole.hashCode);
    _$hash = $jc(_$hash, newRole.hashCode);
    _$hash = $jc(_$hash, momentTitle.hashCode);
    _$hash = $jc(_$hash, totalCount.hashCode);
    _$hash = $jc(_$hash, likers.hashCode);
    _$hash = $jc(_$hash, grossAmount.hashCode);
    _$hash = $jc(_$hash, recipientAmount.hashCode);
    _$hash = $jc(_$hash, platformAmount.hashCode);
    _$hash = $jc(_$hash, previousLevel.hashCode);
    _$hash = $jc(_$hash, level.hashCode);
    _$hash = $jc(_$hash, experience.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NotificationPayloadResponseDto')
          ..add('schemaVersion', schemaVersion)
          ..add('action', action)
          ..add('actorId', actorId)
          ..add('actorName', actorName)
          ..add('replyTargetUserId', replyTargetUserId)
          ..add('replyTargetName', replyTargetName)
          ..add('preview', preview)
          ..add('subthreadTitle', subthreadTitle)
          ..add('threadTitle', threadTitle)
          ..add('threadId', threadId)
          ..add('oldRole', oldRole)
          ..add('newRole', newRole)
          ..add('momentTitle', momentTitle)
          ..add('totalCount', totalCount)
          ..add('likers', likers)
          ..add('grossAmount', grossAmount)
          ..add('recipientAmount', recipientAmount)
          ..add('platformAmount', platformAmount)
          ..add('previousLevel', previousLevel)
          ..add('level', level)
          ..add('experience', experience))
        .toString();
  }
}

class NotificationPayloadResponseDtoBuilder
    implements
        Builder<
          NotificationPayloadResponseDto,
          NotificationPayloadResponseDtoBuilder
        > {
  _$NotificationPayloadResponseDto? _$v;

  NotificationPayloadResponseDtoSchemaVersionEnum? _schemaVersion;
  NotificationPayloadResponseDtoSchemaVersionEnum? get schemaVersion =>
      _$this._schemaVersion;
  set schemaVersion(
    NotificationPayloadResponseDtoSchemaVersionEnum? schemaVersion,
  ) => _$this._schemaVersion = schemaVersion;

  String? _action;
  String? get action => _$this._action;
  set action(String? action) => _$this._action = action;

  String? _actorId;
  String? get actorId => _$this._actorId;
  set actorId(String? actorId) => _$this._actorId = actorId;

  String? _actorName;
  String? get actorName => _$this._actorName;
  set actorName(String? actorName) => _$this._actorName = actorName;

  String? _replyTargetUserId;
  String? get replyTargetUserId => _$this._replyTargetUserId;
  set replyTargetUserId(String? replyTargetUserId) =>
      _$this._replyTargetUserId = replyTargetUserId;

  String? _replyTargetName;
  String? get replyTargetName => _$this._replyTargetName;
  set replyTargetName(String? replyTargetName) =>
      _$this._replyTargetName = replyTargetName;

  String? _preview;
  String? get preview => _$this._preview;
  set preview(String? preview) => _$this._preview = preview;

  String? _subthreadTitle;
  String? get subthreadTitle => _$this._subthreadTitle;
  set subthreadTitle(String? subthreadTitle) =>
      _$this._subthreadTitle = subthreadTitle;

  String? _threadTitle;
  String? get threadTitle => _$this._threadTitle;
  set threadTitle(String? threadTitle) => _$this._threadTitle = threadTitle;

  String? _threadId;
  String? get threadId => _$this._threadId;
  set threadId(String? threadId) => _$this._threadId = threadId;

  NotificationPayloadResponseDtoOldRoleEnum? _oldRole;
  NotificationPayloadResponseDtoOldRoleEnum? get oldRole => _$this._oldRole;
  set oldRole(NotificationPayloadResponseDtoOldRoleEnum? oldRole) =>
      _$this._oldRole = oldRole;

  NotificationPayloadResponseDtoNewRoleEnum? _newRole;
  NotificationPayloadResponseDtoNewRoleEnum? get newRole => _$this._newRole;
  set newRole(NotificationPayloadResponseDtoNewRoleEnum? newRole) =>
      _$this._newRole = newRole;

  String? _momentTitle;
  String? get momentTitle => _$this._momentTitle;
  set momentTitle(String? momentTitle) => _$this._momentTitle = momentTitle;

  num? _totalCount;
  num? get totalCount => _$this._totalCount;
  set totalCount(num? totalCount) => _$this._totalCount = totalCount;

  ListBuilder<NotificationLikerResponseDto>? _likers;
  ListBuilder<NotificationLikerResponseDto> get likers =>
      _$this._likers ??= ListBuilder<NotificationLikerResponseDto>();
  set likers(ListBuilder<NotificationLikerResponseDto>? likers) =>
      _$this._likers = likers;

  String? _grossAmount;
  String? get grossAmount => _$this._grossAmount;
  set grossAmount(String? grossAmount) => _$this._grossAmount = grossAmount;

  String? _recipientAmount;
  String? get recipientAmount => _$this._recipientAmount;
  set recipientAmount(String? recipientAmount) =>
      _$this._recipientAmount = recipientAmount;

  String? _platformAmount;
  String? get platformAmount => _$this._platformAmount;
  set platformAmount(String? platformAmount) =>
      _$this._platformAmount = platformAmount;

  num? _previousLevel;
  num? get previousLevel => _$this._previousLevel;
  set previousLevel(num? previousLevel) =>
      _$this._previousLevel = previousLevel;

  num? _level;
  num? get level => _$this._level;
  set level(num? level) => _$this._level = level;

  num? _experience;
  num? get experience => _$this._experience;
  set experience(num? experience) => _$this._experience = experience;

  NotificationPayloadResponseDtoBuilder() {
    NotificationPayloadResponseDto._defaults(this);
  }

  NotificationPayloadResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _schemaVersion = $v.schemaVersion;
      _action = $v.action;
      _actorId = $v.actorId;
      _actorName = $v.actorName;
      _replyTargetUserId = $v.replyTargetUserId;
      _replyTargetName = $v.replyTargetName;
      _preview = $v.preview;
      _subthreadTitle = $v.subthreadTitle;
      _threadTitle = $v.threadTitle;
      _threadId = $v.threadId;
      _oldRole = $v.oldRole;
      _newRole = $v.newRole;
      _momentTitle = $v.momentTitle;
      _totalCount = $v.totalCount;
      _likers = $v.likers?.toBuilder();
      _grossAmount = $v.grossAmount;
      _recipientAmount = $v.recipientAmount;
      _platformAmount = $v.platformAmount;
      _previousLevel = $v.previousLevel;
      _level = $v.level;
      _experience = $v.experience;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotificationPayloadResponseDto other) {
    _$v = other as _$NotificationPayloadResponseDto;
  }

  @override
  void update(void Function(NotificationPayloadResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationPayloadResponseDto build() => _build();

  _$NotificationPayloadResponseDto _build() {
    _$NotificationPayloadResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$NotificationPayloadResponseDto._(
            schemaVersion: BuiltValueNullFieldError.checkNotNull(
              schemaVersion,
              r'NotificationPayloadResponseDto',
              'schemaVersion',
            ),
            action: action,
            actorId: actorId,
            actorName: actorName,
            replyTargetUserId: replyTargetUserId,
            replyTargetName: replyTargetName,
            preview: preview,
            subthreadTitle: subthreadTitle,
            threadTitle: threadTitle,
            threadId: threadId,
            oldRole: oldRole,
            newRole: newRole,
            momentTitle: momentTitle,
            totalCount: totalCount,
            likers: _likers?.build(),
            grossAmount: grossAmount,
            recipientAmount: recipientAmount,
            platformAmount: platformAmount,
            previousLevel: previousLevel,
            level: level,
            experience: experience,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'likers';
        _likers?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'NotificationPayloadResponseDto',
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
