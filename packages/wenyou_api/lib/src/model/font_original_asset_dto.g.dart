// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_original_asset_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const FontOriginalAssetDtoFontIdEnum
_$fontOriginalAssetDtoFontIdEnum_xiaochengLafeng =
    const FontOriginalAssetDtoFontIdEnum._('xiaochengLafeng');
const FontOriginalAssetDtoFontIdEnum
_$fontOriginalAssetDtoFontIdEnum_unknownDefaultOpenApi =
    const FontOriginalAssetDtoFontIdEnum._('unknownDefaultOpenApi');

FontOriginalAssetDtoFontIdEnum _$fontOriginalAssetDtoFontIdEnumValueOf(
  String name,
) {
  switch (name) {
    case 'xiaochengLafeng':
      return _$fontOriginalAssetDtoFontIdEnum_xiaochengLafeng;
    case 'unknownDefaultOpenApi':
      return _$fontOriginalAssetDtoFontIdEnum_unknownDefaultOpenApi;
    default:
      return _$fontOriginalAssetDtoFontIdEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<FontOriginalAssetDtoFontIdEnum>
_$fontOriginalAssetDtoFontIdEnumValues =
    BuiltSet<FontOriginalAssetDtoFontIdEnum>(
      const <FontOriginalAssetDtoFontIdEnum>[
        _$fontOriginalAssetDtoFontIdEnum_xiaochengLafeng,
        _$fontOriginalAssetDtoFontIdEnum_unknownDefaultOpenApi,
      ],
    );

const FontOriginalAssetDtoBytesEnum _$fontOriginalAssetDtoBytesEnum_n18410600 =
    const FontOriginalAssetDtoBytesEnum._('n18410600');
const FontOriginalAssetDtoBytesEnum
_$fontOriginalAssetDtoBytesEnum_unknownDefaultOpenApi =
    const FontOriginalAssetDtoBytesEnum._('unknownDefaultOpenApi');

FontOriginalAssetDtoBytesEnum _$fontOriginalAssetDtoBytesEnumValueOf(
  String name,
) {
  switch (name) {
    case 'n18410600':
      return _$fontOriginalAssetDtoBytesEnum_n18410600;
    case 'unknownDefaultOpenApi':
      return _$fontOriginalAssetDtoBytesEnum_unknownDefaultOpenApi;
    default:
      return _$fontOriginalAssetDtoBytesEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<FontOriginalAssetDtoBytesEnum>
_$fontOriginalAssetDtoBytesEnumValues = BuiltSet<FontOriginalAssetDtoBytesEnum>(
  const <FontOriginalAssetDtoBytesEnum>[
    _$fontOriginalAssetDtoBytesEnum_n18410600,
    _$fontOriginalAssetDtoBytesEnum_unknownDefaultOpenApi,
  ],
);

const FontOriginalAssetDtoMaxResidentCopiesEnum
_$fontOriginalAssetDtoMaxResidentCopiesEnum_n1 =
    const FontOriginalAssetDtoMaxResidentCopiesEnum._('n1');
const FontOriginalAssetDtoMaxResidentCopiesEnum
_$fontOriginalAssetDtoMaxResidentCopiesEnum_unknownDefaultOpenApi =
    const FontOriginalAssetDtoMaxResidentCopiesEnum._('unknownDefaultOpenApi');

FontOriginalAssetDtoMaxResidentCopiesEnum
_$fontOriginalAssetDtoMaxResidentCopiesEnumValueOf(String name) {
  switch (name) {
    case 'n1':
      return _$fontOriginalAssetDtoMaxResidentCopiesEnum_n1;
    case 'unknownDefaultOpenApi':
      return _$fontOriginalAssetDtoMaxResidentCopiesEnum_unknownDefaultOpenApi;
    default:
      return _$fontOriginalAssetDtoMaxResidentCopiesEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<FontOriginalAssetDtoMaxResidentCopiesEnum>
_$fontOriginalAssetDtoMaxResidentCopiesEnumValues =
    BuiltSet<FontOriginalAssetDtoMaxResidentCopiesEnum>(
      const <FontOriginalAssetDtoMaxResidentCopiesEnum>[
        _$fontOriginalAssetDtoMaxResidentCopiesEnum_n1,
        _$fontOriginalAssetDtoMaxResidentCopiesEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<FontOriginalAssetDtoFontIdEnum>
_$fontOriginalAssetDtoFontIdEnumSerializer =
    _$FontOriginalAssetDtoFontIdEnumSerializer();
Serializer<FontOriginalAssetDtoBytesEnum>
_$fontOriginalAssetDtoBytesEnumSerializer =
    _$FontOriginalAssetDtoBytesEnumSerializer();
Serializer<FontOriginalAssetDtoMaxResidentCopiesEnum>
_$fontOriginalAssetDtoMaxResidentCopiesEnumSerializer =
    _$FontOriginalAssetDtoMaxResidentCopiesEnumSerializer();

class _$FontOriginalAssetDtoFontIdEnumSerializer
    implements PrimitiveSerializer<FontOriginalAssetDtoFontIdEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'xiaochengLafeng': 'xiaocheng-lafeng',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'xiaocheng-lafeng': 'xiaochengLafeng',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[FontOriginalAssetDtoFontIdEnum];
  @override
  final String wireName = 'FontOriginalAssetDtoFontIdEnum';

  @override
  Object serialize(
    Serializers serializers,
    FontOriginalAssetDtoFontIdEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  FontOriginalAssetDtoFontIdEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => FontOriginalAssetDtoFontIdEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$FontOriginalAssetDtoBytesEnumSerializer
    implements PrimitiveSerializer<FontOriginalAssetDtoBytesEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'n18410600': '18410600',
    'unknownDefaultOpenApi': '11184809',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    '18410600': 'n18410600',
    '11184809': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[FontOriginalAssetDtoBytesEnum];
  @override
  final String wireName = 'FontOriginalAssetDtoBytesEnum';

  @override
  Object serialize(
    Serializers serializers,
    FontOriginalAssetDtoBytesEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  FontOriginalAssetDtoBytesEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => FontOriginalAssetDtoBytesEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$FontOriginalAssetDtoMaxResidentCopiesEnumSerializer
    implements PrimitiveSerializer<FontOriginalAssetDtoMaxResidentCopiesEnum> {
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
    FontOriginalAssetDtoMaxResidentCopiesEnum,
  ];
  @override
  final String wireName = 'FontOriginalAssetDtoMaxResidentCopiesEnum';

  @override
  Object serialize(
    Serializers serializers,
    FontOriginalAssetDtoMaxResidentCopiesEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  FontOriginalAssetDtoMaxResidentCopiesEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => FontOriginalAssetDtoMaxResidentCopiesEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$FontOriginalAssetDto extends FontOriginalAssetDto {
  @override
  final FontOriginalAssetDtoFontIdEnum fontId;
  @override
  final String sha256;
  @override
  final FontOriginalAssetDtoBytesEnum bytes;
  @override
  final FontOriginalAssetDtoMaxResidentCopiesEnum maxResidentCopies;

  factory _$FontOriginalAssetDto([
    void Function(FontOriginalAssetDtoBuilder)? updates,
  ]) => (FontOriginalAssetDtoBuilder()..update(updates))._build();

  _$FontOriginalAssetDto._({
    required this.fontId,
    required this.sha256,
    required this.bytes,
    required this.maxResidentCopies,
  }) : super._();
  @override
  FontOriginalAssetDto rebuild(
    void Function(FontOriginalAssetDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  FontOriginalAssetDtoBuilder toBuilder() =>
      FontOriginalAssetDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FontOriginalAssetDto &&
        fontId == other.fontId &&
        sha256 == other.sha256 &&
        bytes == other.bytes &&
        maxResidentCopies == other.maxResidentCopies;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, fontId.hashCode);
    _$hash = $jc(_$hash, sha256.hashCode);
    _$hash = $jc(_$hash, bytes.hashCode);
    _$hash = $jc(_$hash, maxResidentCopies.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FontOriginalAssetDto')
          ..add('fontId', fontId)
          ..add('sha256', sha256)
          ..add('bytes', bytes)
          ..add('maxResidentCopies', maxResidentCopies))
        .toString();
  }
}

class FontOriginalAssetDtoBuilder
    implements Builder<FontOriginalAssetDto, FontOriginalAssetDtoBuilder> {
  _$FontOriginalAssetDto? _$v;

  FontOriginalAssetDtoFontIdEnum? _fontId;
  FontOriginalAssetDtoFontIdEnum? get fontId => _$this._fontId;
  set fontId(FontOriginalAssetDtoFontIdEnum? fontId) => _$this._fontId = fontId;

  String? _sha256;
  String? get sha256 => _$this._sha256;
  set sha256(String? sha256) => _$this._sha256 = sha256;

  FontOriginalAssetDtoBytesEnum? _bytes;
  FontOriginalAssetDtoBytesEnum? get bytes => _$this._bytes;
  set bytes(FontOriginalAssetDtoBytesEnum? bytes) => _$this._bytes = bytes;

  FontOriginalAssetDtoMaxResidentCopiesEnum? _maxResidentCopies;
  FontOriginalAssetDtoMaxResidentCopiesEnum? get maxResidentCopies =>
      _$this._maxResidentCopies;
  set maxResidentCopies(
    FontOriginalAssetDtoMaxResidentCopiesEnum? maxResidentCopies,
  ) => _$this._maxResidentCopies = maxResidentCopies;

  FontOriginalAssetDtoBuilder() {
    FontOriginalAssetDto._defaults(this);
  }

  FontOriginalAssetDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _fontId = $v.fontId;
      _sha256 = $v.sha256;
      _bytes = $v.bytes;
      _maxResidentCopies = $v.maxResidentCopies;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FontOriginalAssetDto other) {
    _$v = other as _$FontOriginalAssetDto;
  }

  @override
  void update(void Function(FontOriginalAssetDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FontOriginalAssetDto build() => _build();

  _$FontOriginalAssetDto _build() {
    final _$result =
        _$v ??
        _$FontOriginalAssetDto._(
          fontId: BuiltValueNullFieldError.checkNotNull(
            fontId,
            r'FontOriginalAssetDto',
            'fontId',
          ),
          sha256: BuiltValueNullFieldError.checkNotNull(
            sha256,
            r'FontOriginalAssetDto',
            'sha256',
          ),
          bytes: BuiltValueNullFieldError.checkNotNull(
            bytes,
            r'FontOriginalAssetDto',
            'bytes',
          ),
          maxResidentCopies: BuiltValueNullFieldError.checkNotNull(
            maxResidentCopies,
            r'FontOriginalAssetDto',
            'maxResidentCopies',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
