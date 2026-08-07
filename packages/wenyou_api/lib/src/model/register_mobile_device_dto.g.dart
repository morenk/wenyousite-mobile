// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_mobile_device_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RegisterMobileDeviceDtoPlatformEnum
_$registerMobileDeviceDtoPlatformEnum_android =
    const RegisterMobileDeviceDtoPlatformEnum._('android');
const RegisterMobileDeviceDtoPlatformEnum
_$registerMobileDeviceDtoPlatformEnum_ios =
    const RegisterMobileDeviceDtoPlatformEnum._('ios');
const RegisterMobileDeviceDtoPlatformEnum
_$registerMobileDeviceDtoPlatformEnum_unknownDefaultOpenApi =
    const RegisterMobileDeviceDtoPlatformEnum._('unknownDefaultOpenApi');

RegisterMobileDeviceDtoPlatformEnum
_$registerMobileDeviceDtoPlatformEnumValueOf(String name) {
  switch (name) {
    case 'android':
      return _$registerMobileDeviceDtoPlatformEnum_android;
    case 'ios':
      return _$registerMobileDeviceDtoPlatformEnum_ios;
    case 'unknownDefaultOpenApi':
      return _$registerMobileDeviceDtoPlatformEnum_unknownDefaultOpenApi;
    default:
      return _$registerMobileDeviceDtoPlatformEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<RegisterMobileDeviceDtoPlatformEnum>
_$registerMobileDeviceDtoPlatformEnumValues =
    BuiltSet<RegisterMobileDeviceDtoPlatformEnum>(
      const <RegisterMobileDeviceDtoPlatformEnum>[
        _$registerMobileDeviceDtoPlatformEnum_android,
        _$registerMobileDeviceDtoPlatformEnum_ios,
        _$registerMobileDeviceDtoPlatformEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<RegisterMobileDeviceDtoPlatformEnum>
_$registerMobileDeviceDtoPlatformEnumSerializer =
    _$RegisterMobileDeviceDtoPlatformEnumSerializer();

class _$RegisterMobileDeviceDtoPlatformEnumSerializer
    implements PrimitiveSerializer<RegisterMobileDeviceDtoPlatformEnum> {
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
    RegisterMobileDeviceDtoPlatformEnum,
  ];
  @override
  final String wireName = 'RegisterMobileDeviceDtoPlatformEnum';

  @override
  Object serialize(
    Serializers serializers,
    RegisterMobileDeviceDtoPlatformEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  RegisterMobileDeviceDtoPlatformEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => RegisterMobileDeviceDtoPlatformEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$RegisterMobileDeviceDto extends RegisterMobileDeviceDto {
  @override
  final String pushToken;
  @override
  final RegisterMobileDeviceDtoPlatformEnum platform;
  @override
  final String? appVersion;
  @override
  final String? locale;

  factory _$RegisterMobileDeviceDto([
    void Function(RegisterMobileDeviceDtoBuilder)? updates,
  ]) => (RegisterMobileDeviceDtoBuilder()..update(updates))._build();

  _$RegisterMobileDeviceDto._({
    required this.pushToken,
    required this.platform,
    this.appVersion,
    this.locale,
  }) : super._();
  @override
  RegisterMobileDeviceDto rebuild(
    void Function(RegisterMobileDeviceDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  RegisterMobileDeviceDtoBuilder toBuilder() =>
      RegisterMobileDeviceDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RegisterMobileDeviceDto &&
        pushToken == other.pushToken &&
        platform == other.platform &&
        appVersion == other.appVersion &&
        locale == other.locale;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, pushToken.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, appVersion.hashCode);
    _$hash = $jc(_$hash, locale.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RegisterMobileDeviceDto')
          ..add('pushToken', pushToken)
          ..add('platform', platform)
          ..add('appVersion', appVersion)
          ..add('locale', locale))
        .toString();
  }
}

class RegisterMobileDeviceDtoBuilder
    implements
        Builder<RegisterMobileDeviceDto, RegisterMobileDeviceDtoBuilder> {
  _$RegisterMobileDeviceDto? _$v;

  String? _pushToken;
  String? get pushToken => _$this._pushToken;
  set pushToken(String? pushToken) => _$this._pushToken = pushToken;

  RegisterMobileDeviceDtoPlatformEnum? _platform;
  RegisterMobileDeviceDtoPlatformEnum? get platform => _$this._platform;
  set platform(RegisterMobileDeviceDtoPlatformEnum? platform) =>
      _$this._platform = platform;

  String? _appVersion;
  String? get appVersion => _$this._appVersion;
  set appVersion(String? appVersion) => _$this._appVersion = appVersion;

  String? _locale;
  String? get locale => _$this._locale;
  set locale(String? locale) => _$this._locale = locale;

  RegisterMobileDeviceDtoBuilder() {
    RegisterMobileDeviceDto._defaults(this);
  }

  RegisterMobileDeviceDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _pushToken = $v.pushToken;
      _platform = $v.platform;
      _appVersion = $v.appVersion;
      _locale = $v.locale;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RegisterMobileDeviceDto other) {
    _$v = other as _$RegisterMobileDeviceDto;
  }

  @override
  void update(void Function(RegisterMobileDeviceDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RegisterMobileDeviceDto build() => _build();

  _$RegisterMobileDeviceDto _build() {
    final _$result =
        _$v ??
        _$RegisterMobileDeviceDto._(
          pushToken: BuiltValueNullFieldError.checkNotNull(
            pushToken,
            r'RegisterMobileDeviceDto',
            'pushToken',
          ),
          platform: BuiltValueNullFieldError.checkNotNull(
            platform,
            r'RegisterMobileDeviceDto',
            'platform',
          ),
          appVersion: appVersion,
          locale: locale,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
