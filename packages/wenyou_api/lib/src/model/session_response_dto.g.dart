// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SessionResponseDtoPlatformEnum _$sessionResponseDtoPlatformEnum_web =
    const SessionResponseDtoPlatformEnum._('web');
const SessionResponseDtoPlatformEnum _$sessionResponseDtoPlatformEnum_mobile =
    const SessionResponseDtoPlatformEnum._('mobile');
const SessionResponseDtoPlatformEnum
_$sessionResponseDtoPlatformEnum_unknownDefaultOpenApi =
    const SessionResponseDtoPlatformEnum._('unknownDefaultOpenApi');

SessionResponseDtoPlatformEnum _$sessionResponseDtoPlatformEnumValueOf(
  String name,
) {
  switch (name) {
    case 'web':
      return _$sessionResponseDtoPlatformEnum_web;
    case 'mobile':
      return _$sessionResponseDtoPlatformEnum_mobile;
    case 'unknownDefaultOpenApi':
      return _$sessionResponseDtoPlatformEnum_unknownDefaultOpenApi;
    default:
      return _$sessionResponseDtoPlatformEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<SessionResponseDtoPlatformEnum>
_$sessionResponseDtoPlatformEnumValues =
    BuiltSet<SessionResponseDtoPlatformEnum>(
      const <SessionResponseDtoPlatformEnum>[
        _$sessionResponseDtoPlatformEnum_web,
        _$sessionResponseDtoPlatformEnum_mobile,
        _$sessionResponseDtoPlatformEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<SessionResponseDtoPlatformEnum>
_$sessionResponseDtoPlatformEnumSerializer =
    _$SessionResponseDtoPlatformEnumSerializer();

class _$SessionResponseDtoPlatformEnumSerializer
    implements PrimitiveSerializer<SessionResponseDtoPlatformEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'web': 'web',
    'mobile': 'mobile',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'web': 'web',
    'mobile': 'mobile',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[SessionResponseDtoPlatformEnum];
  @override
  final String wireName = 'SessionResponseDtoPlatformEnum';

  @override
  Object serialize(
    Serializers serializers,
    SessionResponseDtoPlatformEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SessionResponseDtoPlatformEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SessionResponseDtoPlatformEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$SessionResponseDto extends SessionResponseDto {
  @override
  final String id;
  @override
  final SessionResponseDtoPlatformEnum platform;
  @override
  final String? deviceInfo;
  @override
  final bool isCurrent;
  @override
  final DateTime signedInAt;
  @override
  final DateTime lastActiveAt;
  @override
  final DateTime expiresAt;
  @override
  final DateTime createdAt;

  factory _$SessionResponseDto([
    void Function(SessionResponseDtoBuilder)? updates,
  ]) => (SessionResponseDtoBuilder()..update(updates))._build();

  _$SessionResponseDto._({
    required this.id,
    required this.platform,
    this.deviceInfo,
    required this.isCurrent,
    required this.signedInAt,
    required this.lastActiveAt,
    required this.expiresAt,
    required this.createdAt,
  }) : super._();
  @override
  SessionResponseDto rebuild(
    void Function(SessionResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SessionResponseDtoBuilder toBuilder() =>
      SessionResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SessionResponseDto &&
        id == other.id &&
        platform == other.platform &&
        deviceInfo == other.deviceInfo &&
        isCurrent == other.isCurrent &&
        signedInAt == other.signedInAt &&
        lastActiveAt == other.lastActiveAt &&
        expiresAt == other.expiresAt &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, deviceInfo.hashCode);
    _$hash = $jc(_$hash, isCurrent.hashCode);
    _$hash = $jc(_$hash, signedInAt.hashCode);
    _$hash = $jc(_$hash, lastActiveAt.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SessionResponseDto')
          ..add('id', id)
          ..add('platform', platform)
          ..add('deviceInfo', deviceInfo)
          ..add('isCurrent', isCurrent)
          ..add('signedInAt', signedInAt)
          ..add('lastActiveAt', lastActiveAt)
          ..add('expiresAt', expiresAt)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class SessionResponseDtoBuilder
    implements Builder<SessionResponseDto, SessionResponseDtoBuilder> {
  _$SessionResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  SessionResponseDtoPlatformEnum? _platform;
  SessionResponseDtoPlatformEnum? get platform => _$this._platform;
  set platform(SessionResponseDtoPlatformEnum? platform) =>
      _$this._platform = platform;

  String? _deviceInfo;
  String? get deviceInfo => _$this._deviceInfo;
  set deviceInfo(String? deviceInfo) => _$this._deviceInfo = deviceInfo;

  bool? _isCurrent;
  bool? get isCurrent => _$this._isCurrent;
  set isCurrent(bool? isCurrent) => _$this._isCurrent = isCurrent;

  DateTime? _signedInAt;
  DateTime? get signedInAt => _$this._signedInAt;
  set signedInAt(DateTime? signedInAt) => _$this._signedInAt = signedInAt;

  DateTime? _lastActiveAt;
  DateTime? get lastActiveAt => _$this._lastActiveAt;
  set lastActiveAt(DateTime? lastActiveAt) =>
      _$this._lastActiveAt = lastActiveAt;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  SessionResponseDtoBuilder() {
    SessionResponseDto._defaults(this);
  }

  SessionResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _platform = $v.platform;
      _deviceInfo = $v.deviceInfo;
      _isCurrent = $v.isCurrent;
      _signedInAt = $v.signedInAt;
      _lastActiveAt = $v.lastActiveAt;
      _expiresAt = $v.expiresAt;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SessionResponseDto other) {
    _$v = other as _$SessionResponseDto;
  }

  @override
  void update(void Function(SessionResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SessionResponseDto build() => _build();

  _$SessionResponseDto _build() {
    final _$result =
        _$v ??
        _$SessionResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'SessionResponseDto',
            'id',
          ),
          platform: BuiltValueNullFieldError.checkNotNull(
            platform,
            r'SessionResponseDto',
            'platform',
          ),
          deviceInfo: deviceInfo,
          isCurrent: BuiltValueNullFieldError.checkNotNull(
            isCurrent,
            r'SessionResponseDto',
            'isCurrent',
          ),
          signedInAt: BuiltValueNullFieldError.checkNotNull(
            signedInAt,
            r'SessionResponseDto',
            'signedInAt',
          ),
          lastActiveAt: BuiltValueNullFieldError.checkNotNull(
            lastActiveAt,
            r'SessionResponseDto',
            'lastActiveAt',
          ),
          expiresAt: BuiltValueNullFieldError.checkNotNull(
            expiresAt,
            r'SessionResponseDto',
            'expiresAt',
          ),
          createdAt: BuiltValueNullFieldError.checkNotNull(
            createdAt,
            r'SessionResponseDto',
            'createdAt',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
