// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_asset_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const FontAssetDtoFormatEnum _$fontAssetDtoFormatEnum_woff2 =
    const FontAssetDtoFormatEnum._('woff2');
const FontAssetDtoFormatEnum _$fontAssetDtoFormatEnum_ttf =
    const FontAssetDtoFormatEnum._('ttf');
const FontAssetDtoFormatEnum _$fontAssetDtoFormatEnum_otf =
    const FontAssetDtoFormatEnum._('otf');
const FontAssetDtoFormatEnum _$fontAssetDtoFormatEnum_json =
    const FontAssetDtoFormatEnum._('json');
const FontAssetDtoFormatEnum _$fontAssetDtoFormatEnum_png =
    const FontAssetDtoFormatEnum._('png');
const FontAssetDtoFormatEnum _$fontAssetDtoFormatEnum_unknownDefaultOpenApi =
    const FontAssetDtoFormatEnum._('unknownDefaultOpenApi');

FontAssetDtoFormatEnum _$fontAssetDtoFormatEnumValueOf(String name) {
  switch (name) {
    case 'woff2':
      return _$fontAssetDtoFormatEnum_woff2;
    case 'ttf':
      return _$fontAssetDtoFormatEnum_ttf;
    case 'otf':
      return _$fontAssetDtoFormatEnum_otf;
    case 'json':
      return _$fontAssetDtoFormatEnum_json;
    case 'png':
      return _$fontAssetDtoFormatEnum_png;
    case 'unknownDefaultOpenApi':
      return _$fontAssetDtoFormatEnum_unknownDefaultOpenApi;
    default:
      return _$fontAssetDtoFormatEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<FontAssetDtoFormatEnum> _$fontAssetDtoFormatEnumValues =
    BuiltSet<FontAssetDtoFormatEnum>(const <FontAssetDtoFormatEnum>[
      _$fontAssetDtoFormatEnum_woff2,
      _$fontAssetDtoFormatEnum_ttf,
      _$fontAssetDtoFormatEnum_otf,
      _$fontAssetDtoFormatEnum_json,
      _$fontAssetDtoFormatEnum_png,
      _$fontAssetDtoFormatEnum_unknownDefaultOpenApi,
    ]);

Serializer<FontAssetDtoFormatEnum> _$fontAssetDtoFormatEnumSerializer =
    _$FontAssetDtoFormatEnumSerializer();

class _$FontAssetDtoFormatEnumSerializer
    implements PrimitiveSerializer<FontAssetDtoFormatEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'woff2': 'woff2',
    'ttf': 'ttf',
    'otf': 'otf',
    'json': 'json',
    'png': 'png',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'woff2': 'woff2',
    'ttf': 'ttf',
    'otf': 'otf',
    'json': 'json',
    'png': 'png',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[FontAssetDtoFormatEnum];
  @override
  final String wireName = 'FontAssetDtoFormatEnum';

  @override
  Object serialize(
    Serializers serializers,
    FontAssetDtoFormatEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  FontAssetDtoFormatEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => FontAssetDtoFormatEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$FontAssetDto extends FontAssetDto {
  @override
  final String sha256;
  @override
  final int bytes;
  @override
  final FontAssetDtoFormatEnum format;

  factory _$FontAssetDto([void Function(FontAssetDtoBuilder)? updates]) =>
      (FontAssetDtoBuilder()..update(updates))._build();

  _$FontAssetDto._({
    required this.sha256,
    required this.bytes,
    required this.format,
  }) : super._();
  @override
  FontAssetDto rebuild(void Function(FontAssetDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FontAssetDtoBuilder toBuilder() => FontAssetDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FontAssetDto &&
        sha256 == other.sha256 &&
        bytes == other.bytes &&
        format == other.format;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, sha256.hashCode);
    _$hash = $jc(_$hash, bytes.hashCode);
    _$hash = $jc(_$hash, format.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FontAssetDto')
          ..add('sha256', sha256)
          ..add('bytes', bytes)
          ..add('format', format))
        .toString();
  }
}

class FontAssetDtoBuilder
    implements Builder<FontAssetDto, FontAssetDtoBuilder> {
  _$FontAssetDto? _$v;

  String? _sha256;
  String? get sha256 => _$this._sha256;
  set sha256(String? sha256) => _$this._sha256 = sha256;

  int? _bytes;
  int? get bytes => _$this._bytes;
  set bytes(int? bytes) => _$this._bytes = bytes;

  FontAssetDtoFormatEnum? _format;
  FontAssetDtoFormatEnum? get format => _$this._format;
  set format(FontAssetDtoFormatEnum? format) => _$this._format = format;

  FontAssetDtoBuilder() {
    FontAssetDto._defaults(this);
  }

  FontAssetDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _sha256 = $v.sha256;
      _bytes = $v.bytes;
      _format = $v.format;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FontAssetDto other) {
    _$v = other as _$FontAssetDto;
  }

  @override
  void update(void Function(FontAssetDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FontAssetDto build() => _build();

  _$FontAssetDto _build() {
    final _$result =
        _$v ??
        _$FontAssetDto._(
          sha256: BuiltValueNullFieldError.checkNotNull(
            sha256,
            r'FontAssetDto',
            'sha256',
          ),
          bytes: BuiltValueNullFieldError.checkNotNull(
            bytes,
            r'FontAssetDto',
            'bytes',
          ),
          format: BuiltValueNullFieldError.checkNotNull(
            format,
            r'FontAssetDto',
            'format',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
