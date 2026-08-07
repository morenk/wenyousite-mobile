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

Serializer<NotificationPayloadResponseDtoSchemaVersionEnum>
_$notificationPayloadResponseDtoSchemaVersionEnumSerializer =
    _$NotificationPayloadResponseDtoSchemaVersionEnumSerializer();

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
  final String? preview;
  @override
  final String? subthreadTitle;
  @override
  final String? threadTitle;
  @override
  final num? totalCount;
  @override
  final BuiltList<NotificationLikerResponseDto>? likers;

  factory _$NotificationPayloadResponseDto([
    void Function(NotificationPayloadResponseDtoBuilder)? updates,
  ]) => (NotificationPayloadResponseDtoBuilder()..update(updates))._build();

  _$NotificationPayloadResponseDto._({
    required this.schemaVersion,
    this.action,
    this.actorId,
    this.actorName,
    this.preview,
    this.subthreadTitle,
    this.threadTitle,
    this.totalCount,
    this.likers,
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
        preview == other.preview &&
        subthreadTitle == other.subthreadTitle &&
        threadTitle == other.threadTitle &&
        totalCount == other.totalCount &&
        likers == other.likers;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, schemaVersion.hashCode);
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, actorId.hashCode);
    _$hash = $jc(_$hash, actorName.hashCode);
    _$hash = $jc(_$hash, preview.hashCode);
    _$hash = $jc(_$hash, subthreadTitle.hashCode);
    _$hash = $jc(_$hash, threadTitle.hashCode);
    _$hash = $jc(_$hash, totalCount.hashCode);
    _$hash = $jc(_$hash, likers.hashCode);
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
          ..add('preview', preview)
          ..add('subthreadTitle', subthreadTitle)
          ..add('threadTitle', threadTitle)
          ..add('totalCount', totalCount)
          ..add('likers', likers))
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

  num? _totalCount;
  num? get totalCount => _$this._totalCount;
  set totalCount(num? totalCount) => _$this._totalCount = totalCount;

  ListBuilder<NotificationLikerResponseDto>? _likers;
  ListBuilder<NotificationLikerResponseDto> get likers =>
      _$this._likers ??= ListBuilder<NotificationLikerResponseDto>();
  set likers(ListBuilder<NotificationLikerResponseDto>? likers) =>
      _$this._likers = likers;

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
      _preview = $v.preview;
      _subthreadTitle = $v.subthreadTitle;
      _threadTitle = $v.threadTitle;
      _totalCount = $v.totalCount;
      _likers = $v.likers?.toBuilder();
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
            preview: preview,
            subthreadTitle: subthreadTitle,
            threadTitle: threadTitle,
            totalCount: totalCount,
            likers: _likers?.build(),
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
