// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_mobile_release_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CreateMobileReleaseDtoPlatformEnum
_$createMobileReleaseDtoPlatformEnum_android =
    const CreateMobileReleaseDtoPlatformEnum._('android');
const CreateMobileReleaseDtoPlatformEnum
_$createMobileReleaseDtoPlatformEnum_unknownDefaultOpenApi =
    const CreateMobileReleaseDtoPlatformEnum._('unknownDefaultOpenApi');

CreateMobileReleaseDtoPlatformEnum _$createMobileReleaseDtoPlatformEnumValueOf(
  String name,
) {
  switch (name) {
    case 'android':
      return _$createMobileReleaseDtoPlatformEnum_android;
    case 'unknownDefaultOpenApi':
      return _$createMobileReleaseDtoPlatformEnum_unknownDefaultOpenApi;
    default:
      return _$createMobileReleaseDtoPlatformEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<CreateMobileReleaseDtoPlatformEnum>
_$createMobileReleaseDtoPlatformEnumValues =
    BuiltSet<CreateMobileReleaseDtoPlatformEnum>(
      const <CreateMobileReleaseDtoPlatformEnum>[
        _$createMobileReleaseDtoPlatformEnum_android,
        _$createMobileReleaseDtoPlatformEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<CreateMobileReleaseDtoPlatformEnum>
_$createMobileReleaseDtoPlatformEnumSerializer =
    _$CreateMobileReleaseDtoPlatformEnumSerializer();

class _$CreateMobileReleaseDtoPlatformEnumSerializer
    implements PrimitiveSerializer<CreateMobileReleaseDtoPlatformEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'android': 'android',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'android': 'android',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[CreateMobileReleaseDtoPlatformEnum];
  @override
  final String wireName = 'CreateMobileReleaseDtoPlatformEnum';

  @override
  Object serialize(
    Serializers serializers,
    CreateMobileReleaseDtoPlatformEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  CreateMobileReleaseDtoPlatformEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => CreateMobileReleaseDtoPlatformEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$CreateMobileReleaseDto extends CreateMobileReleaseDto {
  @override
  final CreateMobileReleaseDtoPlatformEnum platform;
  @override
  final String versionName;
  @override
  final num buildNumber;
  @override
  final String summary;
  @override
  final BuiltList<String> items;

  factory _$CreateMobileReleaseDto([
    void Function(CreateMobileReleaseDtoBuilder)? updates,
  ]) => (CreateMobileReleaseDtoBuilder()..update(updates))._build();

  _$CreateMobileReleaseDto._({
    required this.platform,
    required this.versionName,
    required this.buildNumber,
    required this.summary,
    required this.items,
  }) : super._();
  @override
  CreateMobileReleaseDto rebuild(
    void Function(CreateMobileReleaseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  CreateMobileReleaseDtoBuilder toBuilder() =>
      CreateMobileReleaseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateMobileReleaseDto &&
        platform == other.platform &&
        versionName == other.versionName &&
        buildNumber == other.buildNumber &&
        summary == other.summary &&
        items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, versionName.hashCode);
    _$hash = $jc(_$hash, buildNumber.hashCode);
    _$hash = $jc(_$hash, summary.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateMobileReleaseDto')
          ..add('platform', platform)
          ..add('versionName', versionName)
          ..add('buildNumber', buildNumber)
          ..add('summary', summary)
          ..add('items', items))
        .toString();
  }
}

class CreateMobileReleaseDtoBuilder
    implements Builder<CreateMobileReleaseDto, CreateMobileReleaseDtoBuilder> {
  _$CreateMobileReleaseDto? _$v;

  CreateMobileReleaseDtoPlatformEnum? _platform;
  CreateMobileReleaseDtoPlatformEnum? get platform => _$this._platform;
  set platform(CreateMobileReleaseDtoPlatformEnum? platform) =>
      _$this._platform = platform;

  String? _versionName;
  String? get versionName => _$this._versionName;
  set versionName(String? versionName) => _$this._versionName = versionName;

  num? _buildNumber;
  num? get buildNumber => _$this._buildNumber;
  set buildNumber(num? buildNumber) => _$this._buildNumber = buildNumber;

  String? _summary;
  String? get summary => _$this._summary;
  set summary(String? summary) => _$this._summary = summary;

  ListBuilder<String>? _items;
  ListBuilder<String> get items => _$this._items ??= ListBuilder<String>();
  set items(ListBuilder<String>? items) => _$this._items = items;

  CreateMobileReleaseDtoBuilder() {
    CreateMobileReleaseDto._defaults(this);
  }

  CreateMobileReleaseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _platform = $v.platform;
      _versionName = $v.versionName;
      _buildNumber = $v.buildNumber;
      _summary = $v.summary;
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateMobileReleaseDto other) {
    _$v = other as _$CreateMobileReleaseDto;
  }

  @override
  void update(void Function(CreateMobileReleaseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateMobileReleaseDto build() => _build();

  _$CreateMobileReleaseDto _build() {
    _$CreateMobileReleaseDto _$result;
    try {
      _$result =
          _$v ??
          _$CreateMobileReleaseDto._(
            platform: BuiltValueNullFieldError.checkNotNull(
              platform,
              r'CreateMobileReleaseDto',
              'platform',
            ),
            versionName: BuiltValueNullFieldError.checkNotNull(
              versionName,
              r'CreateMobileReleaseDto',
              'versionName',
            ),
            buildNumber: BuiltValueNullFieldError.checkNotNull(
              buildNumber,
              r'CreateMobileReleaseDto',
              'buildNumber',
            ),
            summary: BuiltValueNullFieldError.checkNotNull(
              summary,
              r'CreateMobileReleaseDto',
              'summary',
            ),
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'CreateMobileReleaseDto',
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
