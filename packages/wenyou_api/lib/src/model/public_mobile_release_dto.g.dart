// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_mobile_release_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PublicMobileReleaseDtoPlatformEnum
_$publicMobileReleaseDtoPlatformEnum_android =
    const PublicMobileReleaseDtoPlatformEnum._('android');
const PublicMobileReleaseDtoPlatformEnum
_$publicMobileReleaseDtoPlatformEnum_unknownDefaultOpenApi =
    const PublicMobileReleaseDtoPlatformEnum._('unknownDefaultOpenApi');

PublicMobileReleaseDtoPlatformEnum _$publicMobileReleaseDtoPlatformEnumValueOf(
  String name,
) {
  switch (name) {
    case 'android':
      return _$publicMobileReleaseDtoPlatformEnum_android;
    case 'unknownDefaultOpenApi':
      return _$publicMobileReleaseDtoPlatformEnum_unknownDefaultOpenApi;
    default:
      return _$publicMobileReleaseDtoPlatformEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<PublicMobileReleaseDtoPlatformEnum>
_$publicMobileReleaseDtoPlatformEnumValues =
    BuiltSet<PublicMobileReleaseDtoPlatformEnum>(
      const <PublicMobileReleaseDtoPlatformEnum>[
        _$publicMobileReleaseDtoPlatformEnum_android,
        _$publicMobileReleaseDtoPlatformEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<PublicMobileReleaseDtoPlatformEnum>
_$publicMobileReleaseDtoPlatformEnumSerializer =
    _$PublicMobileReleaseDtoPlatformEnumSerializer();

class _$PublicMobileReleaseDtoPlatformEnumSerializer
    implements PrimitiveSerializer<PublicMobileReleaseDtoPlatformEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'android': 'android',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'android': 'android',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[PublicMobileReleaseDtoPlatformEnum];
  @override
  final String wireName = 'PublicMobileReleaseDtoPlatformEnum';

  @override
  Object serialize(
    Serializers serializers,
    PublicMobileReleaseDtoPlatformEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  PublicMobileReleaseDtoPlatformEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => PublicMobileReleaseDtoPlatformEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$PublicMobileReleaseDto extends PublicMobileReleaseDto {
  @override
  final PublicMobileReleaseDtoPlatformEnum platform;
  @override
  final String versionName;
  @override
  final num buildNumber;
  @override
  final String summary;
  @override
  final BuiltList<String> items;
  @override
  final num revision;
  @override
  final DateTime publishedAt;

  factory _$PublicMobileReleaseDto([
    void Function(PublicMobileReleaseDtoBuilder)? updates,
  ]) => (PublicMobileReleaseDtoBuilder()..update(updates))._build();

  _$PublicMobileReleaseDto._({
    required this.platform,
    required this.versionName,
    required this.buildNumber,
    required this.summary,
    required this.items,
    required this.revision,
    required this.publishedAt,
  }) : super._();
  @override
  PublicMobileReleaseDto rebuild(
    void Function(PublicMobileReleaseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  PublicMobileReleaseDtoBuilder toBuilder() =>
      PublicMobileReleaseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PublicMobileReleaseDto &&
        platform == other.platform &&
        versionName == other.versionName &&
        buildNumber == other.buildNumber &&
        summary == other.summary &&
        items == other.items &&
        revision == other.revision &&
        publishedAt == other.publishedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, versionName.hashCode);
    _$hash = $jc(_$hash, buildNumber.hashCode);
    _$hash = $jc(_$hash, summary.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, publishedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PublicMobileReleaseDto')
          ..add('platform', platform)
          ..add('versionName', versionName)
          ..add('buildNumber', buildNumber)
          ..add('summary', summary)
          ..add('items', items)
          ..add('revision', revision)
          ..add('publishedAt', publishedAt))
        .toString();
  }
}

class PublicMobileReleaseDtoBuilder
    implements Builder<PublicMobileReleaseDto, PublicMobileReleaseDtoBuilder> {
  _$PublicMobileReleaseDto? _$v;

  PublicMobileReleaseDtoPlatformEnum? _platform;
  PublicMobileReleaseDtoPlatformEnum? get platform => _$this._platform;
  set platform(PublicMobileReleaseDtoPlatformEnum? platform) =>
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

  num? _revision;
  num? get revision => _$this._revision;
  set revision(num? revision) => _$this._revision = revision;

  DateTime? _publishedAt;
  DateTime? get publishedAt => _$this._publishedAt;
  set publishedAt(DateTime? publishedAt) => _$this._publishedAt = publishedAt;

  PublicMobileReleaseDtoBuilder() {
    PublicMobileReleaseDto._defaults(this);
  }

  PublicMobileReleaseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _platform = $v.platform;
      _versionName = $v.versionName;
      _buildNumber = $v.buildNumber;
      _summary = $v.summary;
      _items = $v.items.toBuilder();
      _revision = $v.revision;
      _publishedAt = $v.publishedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PublicMobileReleaseDto other) {
    _$v = other as _$PublicMobileReleaseDto;
  }

  @override
  void update(void Function(PublicMobileReleaseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PublicMobileReleaseDto build() => _build();

  _$PublicMobileReleaseDto _build() {
    _$PublicMobileReleaseDto _$result;
    try {
      _$result =
          _$v ??
          _$PublicMobileReleaseDto._(
            platform: BuiltValueNullFieldError.checkNotNull(
              platform,
              r'PublicMobileReleaseDto',
              'platform',
            ),
            versionName: BuiltValueNullFieldError.checkNotNull(
              versionName,
              r'PublicMobileReleaseDto',
              'versionName',
            ),
            buildNumber: BuiltValueNullFieldError.checkNotNull(
              buildNumber,
              r'PublicMobileReleaseDto',
              'buildNumber',
            ),
            summary: BuiltValueNullFieldError.checkNotNull(
              summary,
              r'PublicMobileReleaseDto',
              'summary',
            ),
            items: items.build(),
            revision: BuiltValueNullFieldError.checkNotNull(
              revision,
              r'PublicMobileReleaseDto',
              'revision',
            ),
            publishedAt: BuiltValueNullFieldError.checkNotNull(
              publishedAt,
              r'PublicMobileReleaseDto',
              'publishedAt',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'PublicMobileReleaseDto',
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
