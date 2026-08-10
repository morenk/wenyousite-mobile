// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_campaign_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const NotificationCampaignResponseDtoStatusEnum
_$notificationCampaignResponseDtoStatusEnum_SCHEDULED =
    const NotificationCampaignResponseDtoStatusEnum._('SCHEDULED');
const NotificationCampaignResponseDtoStatusEnum
_$notificationCampaignResponseDtoStatusEnum_SENDING =
    const NotificationCampaignResponseDtoStatusEnum._('SENDING');
const NotificationCampaignResponseDtoStatusEnum
_$notificationCampaignResponseDtoStatusEnum_SENT =
    const NotificationCampaignResponseDtoStatusEnum._('SENT');
const NotificationCampaignResponseDtoStatusEnum
_$notificationCampaignResponseDtoStatusEnum_CANCELED =
    const NotificationCampaignResponseDtoStatusEnum._('CANCELED');
const NotificationCampaignResponseDtoStatusEnum
_$notificationCampaignResponseDtoStatusEnum_FAILED =
    const NotificationCampaignResponseDtoStatusEnum._('FAILED');
const NotificationCampaignResponseDtoStatusEnum
_$notificationCampaignResponseDtoStatusEnum_unknownDefaultOpenApi =
    const NotificationCampaignResponseDtoStatusEnum._('unknownDefaultOpenApi');

NotificationCampaignResponseDtoStatusEnum
_$notificationCampaignResponseDtoStatusEnumValueOf(String name) {
  switch (name) {
    case 'SCHEDULED':
      return _$notificationCampaignResponseDtoStatusEnum_SCHEDULED;
    case 'SENDING':
      return _$notificationCampaignResponseDtoStatusEnum_SENDING;
    case 'SENT':
      return _$notificationCampaignResponseDtoStatusEnum_SENT;
    case 'CANCELED':
      return _$notificationCampaignResponseDtoStatusEnum_CANCELED;
    case 'FAILED':
      return _$notificationCampaignResponseDtoStatusEnum_FAILED;
    case 'unknownDefaultOpenApi':
      return _$notificationCampaignResponseDtoStatusEnum_unknownDefaultOpenApi;
    default:
      return _$notificationCampaignResponseDtoStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<NotificationCampaignResponseDtoStatusEnum>
_$notificationCampaignResponseDtoStatusEnumValues =
    BuiltSet<NotificationCampaignResponseDtoStatusEnum>(
      const <NotificationCampaignResponseDtoStatusEnum>[
        _$notificationCampaignResponseDtoStatusEnum_SCHEDULED,
        _$notificationCampaignResponseDtoStatusEnum_SENDING,
        _$notificationCampaignResponseDtoStatusEnum_SENT,
        _$notificationCampaignResponseDtoStatusEnum_CANCELED,
        _$notificationCampaignResponseDtoStatusEnum_FAILED,
        _$notificationCampaignResponseDtoStatusEnum_unknownDefaultOpenApi,
      ],
    );

const NotificationCampaignResponseDtoAudienceRoleEnum
_$notificationCampaignResponseDtoAudienceRoleEnum_USER =
    const NotificationCampaignResponseDtoAudienceRoleEnum._('USER');
const NotificationCampaignResponseDtoAudienceRoleEnum
_$notificationCampaignResponseDtoAudienceRoleEnum_ADMIN =
    const NotificationCampaignResponseDtoAudienceRoleEnum._('ADMIN');
const NotificationCampaignResponseDtoAudienceRoleEnum
_$notificationCampaignResponseDtoAudienceRoleEnum_SUPER_ADMIN =
    const NotificationCampaignResponseDtoAudienceRoleEnum._('SUPER_ADMIN');
const NotificationCampaignResponseDtoAudienceRoleEnum
_$notificationCampaignResponseDtoAudienceRoleEnum_unknownDefaultOpenApi =
    const NotificationCampaignResponseDtoAudienceRoleEnum._(
      'unknownDefaultOpenApi',
    );

NotificationCampaignResponseDtoAudienceRoleEnum
_$notificationCampaignResponseDtoAudienceRoleEnumValueOf(String name) {
  switch (name) {
    case 'USER':
      return _$notificationCampaignResponseDtoAudienceRoleEnum_USER;
    case 'ADMIN':
      return _$notificationCampaignResponseDtoAudienceRoleEnum_ADMIN;
    case 'SUPER_ADMIN':
      return _$notificationCampaignResponseDtoAudienceRoleEnum_SUPER_ADMIN;
    case 'unknownDefaultOpenApi':
      return _$notificationCampaignResponseDtoAudienceRoleEnum_unknownDefaultOpenApi;
    default:
      return _$notificationCampaignResponseDtoAudienceRoleEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<NotificationCampaignResponseDtoAudienceRoleEnum>
_$notificationCampaignResponseDtoAudienceRoleEnumValues =
    BuiltSet<NotificationCampaignResponseDtoAudienceRoleEnum>(
      const <NotificationCampaignResponseDtoAudienceRoleEnum>[
        _$notificationCampaignResponseDtoAudienceRoleEnum_USER,
        _$notificationCampaignResponseDtoAudienceRoleEnum_ADMIN,
        _$notificationCampaignResponseDtoAudienceRoleEnum_SUPER_ADMIN,
        _$notificationCampaignResponseDtoAudienceRoleEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<NotificationCampaignResponseDtoStatusEnum>
_$notificationCampaignResponseDtoStatusEnumSerializer =
    _$NotificationCampaignResponseDtoStatusEnumSerializer();
Serializer<NotificationCampaignResponseDtoAudienceRoleEnum>
_$notificationCampaignResponseDtoAudienceRoleEnumSerializer =
    _$NotificationCampaignResponseDtoAudienceRoleEnumSerializer();

class _$NotificationCampaignResponseDtoStatusEnumSerializer
    implements PrimitiveSerializer<NotificationCampaignResponseDtoStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'SCHEDULED': 'SCHEDULED',
    'SENDING': 'SENDING',
    'SENT': 'SENT',
    'CANCELED': 'CANCELED',
    'FAILED': 'FAILED',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'SCHEDULED': 'SCHEDULED',
    'SENDING': 'SENDING',
    'SENT': 'SENT',
    'CANCELED': 'CANCELED',
    'FAILED': 'FAILED',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    NotificationCampaignResponseDtoStatusEnum,
  ];
  @override
  final String wireName = 'NotificationCampaignResponseDtoStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    NotificationCampaignResponseDtoStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  NotificationCampaignResponseDtoStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => NotificationCampaignResponseDtoStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$NotificationCampaignResponseDtoAudienceRoleEnumSerializer
    implements
        PrimitiveSerializer<NotificationCampaignResponseDtoAudienceRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'USER': 'USER',
    'ADMIN': 'ADMIN',
    'SUPER_ADMIN': 'SUPER_ADMIN',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'USER': 'USER',
    'ADMIN': 'ADMIN',
    'SUPER_ADMIN': 'SUPER_ADMIN',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    NotificationCampaignResponseDtoAudienceRoleEnum,
  ];
  @override
  final String wireName = 'NotificationCampaignResponseDtoAudienceRoleEnum';

  @override
  Object serialize(
    Serializers serializers,
    NotificationCampaignResponseDtoAudienceRoleEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  NotificationCampaignResponseDtoAudienceRoleEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => NotificationCampaignResponseDtoAudienceRoleEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$NotificationCampaignResponseDto
    extends NotificationCampaignResponseDto {
  @override
  final String id;
  @override
  final String title;
  @override
  final String content;
  @override
  final NotificationCampaignResponseDtoStatusEnum status;
  @override
  final DateTime scheduledAt;
  @override
  final num estimatedCount;
  @override
  final num recipientCount;
  @override
  final NotificationCampaignResponseDtoAudienceRoleEnum? audienceRole;
  @override
  final BuiltMap<String, JsonObject?>? createdBy;
  @override
  final DateTime createdAt;

  factory _$NotificationCampaignResponseDto([
    void Function(NotificationCampaignResponseDtoBuilder)? updates,
  ]) => (NotificationCampaignResponseDtoBuilder()..update(updates))._build();

  _$NotificationCampaignResponseDto._({
    required this.id,
    required this.title,
    required this.content,
    required this.status,
    required this.scheduledAt,
    required this.estimatedCount,
    required this.recipientCount,
    this.audienceRole,
    this.createdBy,
    required this.createdAt,
  }) : super._();
  @override
  NotificationCampaignResponseDto rebuild(
    void Function(NotificationCampaignResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  NotificationCampaignResponseDtoBuilder toBuilder() =>
      NotificationCampaignResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationCampaignResponseDto &&
        id == other.id &&
        title == other.title &&
        content == other.content &&
        status == other.status &&
        scheduledAt == other.scheduledAt &&
        estimatedCount == other.estimatedCount &&
        recipientCount == other.recipientCount &&
        audienceRole == other.audienceRole &&
        createdBy == other.createdBy &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, scheduledAt.hashCode);
    _$hash = $jc(_$hash, estimatedCount.hashCode);
    _$hash = $jc(_$hash, recipientCount.hashCode);
    _$hash = $jc(_$hash, audienceRole.hashCode);
    _$hash = $jc(_$hash, createdBy.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NotificationCampaignResponseDto')
          ..add('id', id)
          ..add('title', title)
          ..add('content', content)
          ..add('status', status)
          ..add('scheduledAt', scheduledAt)
          ..add('estimatedCount', estimatedCount)
          ..add('recipientCount', recipientCount)
          ..add('audienceRole', audienceRole)
          ..add('createdBy', createdBy)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class NotificationCampaignResponseDtoBuilder
    implements
        Builder<
          NotificationCampaignResponseDto,
          NotificationCampaignResponseDtoBuilder
        > {
  _$NotificationCampaignResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  NotificationCampaignResponseDtoStatusEnum? _status;
  NotificationCampaignResponseDtoStatusEnum? get status => _$this._status;
  set status(NotificationCampaignResponseDtoStatusEnum? status) =>
      _$this._status = status;

  DateTime? _scheduledAt;
  DateTime? get scheduledAt => _$this._scheduledAt;
  set scheduledAt(DateTime? scheduledAt) => _$this._scheduledAt = scheduledAt;

  num? _estimatedCount;
  num? get estimatedCount => _$this._estimatedCount;
  set estimatedCount(num? estimatedCount) =>
      _$this._estimatedCount = estimatedCount;

  num? _recipientCount;
  num? get recipientCount => _$this._recipientCount;
  set recipientCount(num? recipientCount) =>
      _$this._recipientCount = recipientCount;

  NotificationCampaignResponseDtoAudienceRoleEnum? _audienceRole;
  NotificationCampaignResponseDtoAudienceRoleEnum? get audienceRole =>
      _$this._audienceRole;
  set audienceRole(
    NotificationCampaignResponseDtoAudienceRoleEnum? audienceRole,
  ) => _$this._audienceRole = audienceRole;

  MapBuilder<String, JsonObject?>? _createdBy;
  MapBuilder<String, JsonObject?> get createdBy =>
      _$this._createdBy ??= MapBuilder<String, JsonObject?>();
  set createdBy(MapBuilder<String, JsonObject?>? createdBy) =>
      _$this._createdBy = createdBy;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  NotificationCampaignResponseDtoBuilder() {
    NotificationCampaignResponseDto._defaults(this);
  }

  NotificationCampaignResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _content = $v.content;
      _status = $v.status;
      _scheduledAt = $v.scheduledAt;
      _estimatedCount = $v.estimatedCount;
      _recipientCount = $v.recipientCount;
      _audienceRole = $v.audienceRole;
      _createdBy = $v.createdBy?.toBuilder();
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotificationCampaignResponseDto other) {
    _$v = other as _$NotificationCampaignResponseDto;
  }

  @override
  void update(void Function(NotificationCampaignResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationCampaignResponseDto build() => _build();

  _$NotificationCampaignResponseDto _build() {
    _$NotificationCampaignResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$NotificationCampaignResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'NotificationCampaignResponseDto',
              'id',
            ),
            title: BuiltValueNullFieldError.checkNotNull(
              title,
              r'NotificationCampaignResponseDto',
              'title',
            ),
            content: BuiltValueNullFieldError.checkNotNull(
              content,
              r'NotificationCampaignResponseDto',
              'content',
            ),
            status: BuiltValueNullFieldError.checkNotNull(
              status,
              r'NotificationCampaignResponseDto',
              'status',
            ),
            scheduledAt: BuiltValueNullFieldError.checkNotNull(
              scheduledAt,
              r'NotificationCampaignResponseDto',
              'scheduledAt',
            ),
            estimatedCount: BuiltValueNullFieldError.checkNotNull(
              estimatedCount,
              r'NotificationCampaignResponseDto',
              'estimatedCount',
            ),
            recipientCount: BuiltValueNullFieldError.checkNotNull(
              recipientCount,
              r'NotificationCampaignResponseDto',
              'recipientCount',
            ),
            audienceRole: audienceRole,
            createdBy: _createdBy?.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'NotificationCampaignResponseDto',
              'createdAt',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'createdBy';
        _createdBy?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'NotificationCampaignResponseDto',
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
