// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mobile_device_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MobileDeviceResponseDtoPlatformEnum
_$mobileDeviceResponseDtoPlatformEnum_android =
    const MobileDeviceResponseDtoPlatformEnum._('android');
const MobileDeviceResponseDtoPlatformEnum
_$mobileDeviceResponseDtoPlatformEnum_ios =
    const MobileDeviceResponseDtoPlatformEnum._('ios');
const MobileDeviceResponseDtoPlatformEnum
_$mobileDeviceResponseDtoPlatformEnum_unknownDefaultOpenApi =
    const MobileDeviceResponseDtoPlatformEnum._('unknownDefaultOpenApi');

MobileDeviceResponseDtoPlatformEnum
_$mobileDeviceResponseDtoPlatformEnumValueOf(String name) {
  switch (name) {
    case 'android':
      return _$mobileDeviceResponseDtoPlatformEnum_android;
    case 'ios':
      return _$mobileDeviceResponseDtoPlatformEnum_ios;
    case 'unknownDefaultOpenApi':
      return _$mobileDeviceResponseDtoPlatformEnum_unknownDefaultOpenApi;
    default:
      return _$mobileDeviceResponseDtoPlatformEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MobileDeviceResponseDtoPlatformEnum>
_$mobileDeviceResponseDtoPlatformEnumValues =
    BuiltSet<MobileDeviceResponseDtoPlatformEnum>(
      const <MobileDeviceResponseDtoPlatformEnum>[
        _$mobileDeviceResponseDtoPlatformEnum_android,
        _$mobileDeviceResponseDtoPlatformEnum_ios,
        _$mobileDeviceResponseDtoPlatformEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<MobileDeviceResponseDtoPlatformEnum>
_$mobileDeviceResponseDtoPlatformEnumSerializer =
    _$MobileDeviceResponseDtoPlatformEnumSerializer();

class _$MobileDeviceResponseDtoPlatformEnumSerializer
    implements PrimitiveSerializer<MobileDeviceResponseDtoPlatformEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'android': 'android',
    'ios': 'ios',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'android': 'android',
    'ios': 'ios',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    MobileDeviceResponseDtoPlatformEnum,
  ];
  @override
  final String wireName = 'MobileDeviceResponseDtoPlatformEnum';

  @override
  Object serialize(
    Serializers serializers,
    MobileDeviceResponseDtoPlatformEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MobileDeviceResponseDtoPlatformEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MobileDeviceResponseDtoPlatformEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MobileDeviceResponseDto extends MobileDeviceResponseDto {
  @override
  final String id;
  @override
  final MobileDeviceResponseDtoPlatformEnum platform;
  @override
  final String? appVersion;
  @override
  final String? locale;
  @override
  final bool enabled;
  @override
  final DateTime lastSeenAt;

  factory _$MobileDeviceResponseDto([
    void Function(MobileDeviceResponseDtoBuilder)? updates,
  ]) => (MobileDeviceResponseDtoBuilder()..update(updates))._build();

  _$MobileDeviceResponseDto._({
    required this.id,
    required this.platform,
    this.appVersion,
    this.locale,
    required this.enabled,
    required this.lastSeenAt,
  }) : super._();
  @override
  MobileDeviceResponseDto rebuild(
    void Function(MobileDeviceResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MobileDeviceResponseDtoBuilder toBuilder() =>
      MobileDeviceResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MobileDeviceResponseDto &&
        id == other.id &&
        platform == other.platform &&
        appVersion == other.appVersion &&
        locale == other.locale &&
        enabled == other.enabled &&
        lastSeenAt == other.lastSeenAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, appVersion.hashCode);
    _$hash = $jc(_$hash, locale.hashCode);
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, lastSeenAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MobileDeviceResponseDto')
          ..add('id', id)
          ..add('platform', platform)
          ..add('appVersion', appVersion)
          ..add('locale', locale)
          ..add('enabled', enabled)
          ..add('lastSeenAt', lastSeenAt))
        .toString();
  }
}

class MobileDeviceResponseDtoBuilder
    implements
        Builder<MobileDeviceResponseDto, MobileDeviceResponseDtoBuilder> {
  _$MobileDeviceResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  MobileDeviceResponseDtoPlatformEnum? _platform;
  MobileDeviceResponseDtoPlatformEnum? get platform => _$this._platform;
  set platform(MobileDeviceResponseDtoPlatformEnum? platform) =>
      _$this._platform = platform;

  String? _appVersion;
  String? get appVersion => _$this._appVersion;
  set appVersion(String? appVersion) => _$this._appVersion = appVersion;

  String? _locale;
  String? get locale => _$this._locale;
  set locale(String? locale) => _$this._locale = locale;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  DateTime? _lastSeenAt;
  DateTime? get lastSeenAt => _$this._lastSeenAt;
  set lastSeenAt(DateTime? lastSeenAt) => _$this._lastSeenAt = lastSeenAt;

  MobileDeviceResponseDtoBuilder() {
    MobileDeviceResponseDto._defaults(this);
  }

  MobileDeviceResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _platform = $v.platform;
      _appVersion = $v.appVersion;
      _locale = $v.locale;
      _enabled = $v.enabled;
      _lastSeenAt = $v.lastSeenAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MobileDeviceResponseDto other) {
    _$v = other as _$MobileDeviceResponseDto;
  }

  @override
  void update(void Function(MobileDeviceResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MobileDeviceResponseDto build() => _build();

  _$MobileDeviceResponseDto _build() {
    final _$result =
        _$v ??
        _$MobileDeviceResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'MobileDeviceResponseDto',
            'id',
          ),
          platform: BuiltValueNullFieldError.checkNotNull(
            platform,
            r'MobileDeviceResponseDto',
            'platform',
          ),
          appVersion: appVersion,
          locale: locale,
          enabled: BuiltValueNullFieldError.checkNotNull(
            enabled,
            r'MobileDeviceResponseDto',
            'enabled',
          ),
          lastSeenAt: BuiltValueNullFieldError.checkNotNull(
            lastSeenAt,
            r'MobileDeviceResponseDto',
            'lastSeenAt',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
