// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_font_catalog_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TextFontCatalogDtoFontVersionEnum _$textFontCatalogDtoFontVersionEnum_n1 =
    const TextFontCatalogDtoFontVersionEnum._('n1');
const TextFontCatalogDtoFontVersionEnum
_$textFontCatalogDtoFontVersionEnum_unknownDefaultOpenApi =
    const TextFontCatalogDtoFontVersionEnum._('unknownDefaultOpenApi');

TextFontCatalogDtoFontVersionEnum _$textFontCatalogDtoFontVersionEnumValueOf(
  String name,
) {
  switch (name) {
    case 'n1':
      return _$textFontCatalogDtoFontVersionEnum_n1;
    case 'unknownDefaultOpenApi':
      return _$textFontCatalogDtoFontVersionEnum_unknownDefaultOpenApi;
    default:
      return _$textFontCatalogDtoFontVersionEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<TextFontCatalogDtoFontVersionEnum>
_$textFontCatalogDtoFontVersionEnumValues =
    BuiltSet<TextFontCatalogDtoFontVersionEnum>(
      const <TextFontCatalogDtoFontVersionEnum>[
        _$textFontCatalogDtoFontVersionEnum_n1,
        _$textFontCatalogDtoFontVersionEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<TextFontCatalogDtoFontVersionEnum>
_$textFontCatalogDtoFontVersionEnumSerializer =
    _$TextFontCatalogDtoFontVersionEnumSerializer();

class _$TextFontCatalogDtoFontVersionEnumSerializer
    implements PrimitiveSerializer<TextFontCatalogDtoFontVersionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'n1': '1',
    'unknownDefaultOpenApi': '11184809',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    '1': 'n1',
    '11184809': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[TextFontCatalogDtoFontVersionEnum];
  @override
  final String wireName = 'TextFontCatalogDtoFontVersionEnum';

  @override
  Object serialize(
    Serializers serializers,
    TextFontCatalogDtoFontVersionEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  TextFontCatalogDtoFontVersionEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => TextFontCatalogDtoFontVersionEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$TextFontCatalogDto extends TextFontCatalogDto {
  @override
  final TextFontCatalogDtoFontVersionEnum fontVersion;
  @override
  final String catalogVersion;
  @override
  final String? assetBaseUrl;
  @override
  final TextFontManifestDto? manifest;
  @override
  final BuiltList<TextFontFamilyDto> fonts;

  factory _$TextFontCatalogDto([
    void Function(TextFontCatalogDtoBuilder)? updates,
  ]) => (TextFontCatalogDtoBuilder()..update(updates))._build();

  _$TextFontCatalogDto._({
    required this.fontVersion,
    required this.catalogVersion,
    this.assetBaseUrl,
    this.manifest,
    required this.fonts,
  }) : super._();
  @override
  TextFontCatalogDto rebuild(
    void Function(TextFontCatalogDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  TextFontCatalogDtoBuilder toBuilder() =>
      TextFontCatalogDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TextFontCatalogDto &&
        fontVersion == other.fontVersion &&
        catalogVersion == other.catalogVersion &&
        assetBaseUrl == other.assetBaseUrl &&
        manifest == other.manifest &&
        fonts == other.fonts;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, fontVersion.hashCode);
    _$hash = $jc(_$hash, catalogVersion.hashCode);
    _$hash = $jc(_$hash, assetBaseUrl.hashCode);
    _$hash = $jc(_$hash, manifest.hashCode);
    _$hash = $jc(_$hash, fonts.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TextFontCatalogDto')
          ..add('fontVersion', fontVersion)
          ..add('catalogVersion', catalogVersion)
          ..add('assetBaseUrl', assetBaseUrl)
          ..add('manifest', manifest)
          ..add('fonts', fonts))
        .toString();
  }
}

class TextFontCatalogDtoBuilder
    implements Builder<TextFontCatalogDto, TextFontCatalogDtoBuilder> {
  _$TextFontCatalogDto? _$v;

  TextFontCatalogDtoFontVersionEnum? _fontVersion;
  TextFontCatalogDtoFontVersionEnum? get fontVersion => _$this._fontVersion;
  set fontVersion(TextFontCatalogDtoFontVersionEnum? fontVersion) =>
      _$this._fontVersion = fontVersion;

  String? _catalogVersion;
  String? get catalogVersion => _$this._catalogVersion;
  set catalogVersion(String? catalogVersion) =>
      _$this._catalogVersion = catalogVersion;

  String? _assetBaseUrl;
  String? get assetBaseUrl => _$this._assetBaseUrl;
  set assetBaseUrl(String? assetBaseUrl) => _$this._assetBaseUrl = assetBaseUrl;

  TextFontManifestDtoBuilder? _manifest;
  TextFontManifestDtoBuilder get manifest =>
      _$this._manifest ??= TextFontManifestDtoBuilder();
  set manifest(TextFontManifestDtoBuilder? manifest) =>
      _$this._manifest = manifest;

  ListBuilder<TextFontFamilyDto>? _fonts;
  ListBuilder<TextFontFamilyDto> get fonts =>
      _$this._fonts ??= ListBuilder<TextFontFamilyDto>();
  set fonts(ListBuilder<TextFontFamilyDto>? fonts) => _$this._fonts = fonts;

  TextFontCatalogDtoBuilder() {
    TextFontCatalogDto._defaults(this);
  }

  TextFontCatalogDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _fontVersion = $v.fontVersion;
      _catalogVersion = $v.catalogVersion;
      _assetBaseUrl = $v.assetBaseUrl;
      _manifest = $v.manifest?.toBuilder();
      _fonts = $v.fonts.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TextFontCatalogDto other) {
    _$v = other as _$TextFontCatalogDto;
  }

  @override
  void update(void Function(TextFontCatalogDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TextFontCatalogDto build() => _build();

  _$TextFontCatalogDto _build() {
    _$TextFontCatalogDto _$result;
    try {
      _$result =
          _$v ??
          _$TextFontCatalogDto._(
            fontVersion: BuiltValueNullFieldError.checkNotNull(
              fontVersion,
              r'TextFontCatalogDto',
              'fontVersion',
            ),
            catalogVersion: BuiltValueNullFieldError.checkNotNull(
              catalogVersion,
              r'TextFontCatalogDto',
              'catalogVersion',
            ),
            assetBaseUrl: assetBaseUrl,
            manifest: _manifest?.build(),
            fonts: fonts.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'manifest';
        _manifest?.build();
        _$failedField = 'fonts';
        fonts.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'TextFontCatalogDto',
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
