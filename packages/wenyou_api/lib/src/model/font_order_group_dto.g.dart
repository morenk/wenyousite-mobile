// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_order_group_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const FontOrderGroupDtoLanguageEnum _$fontOrderGroupDtoLanguageEnum_zh =
    const FontOrderGroupDtoLanguageEnum._('zh');
const FontOrderGroupDtoLanguageEnum _$fontOrderGroupDtoLanguageEnum_ja =
    const FontOrderGroupDtoLanguageEnum._('ja');
const FontOrderGroupDtoLanguageEnum _$fontOrderGroupDtoLanguageEnum_en =
    const FontOrderGroupDtoLanguageEnum._('en');
const FontOrderGroupDtoLanguageEnum _$fontOrderGroupDtoLanguageEnum_other =
    const FontOrderGroupDtoLanguageEnum._('other');
const FontOrderGroupDtoLanguageEnum
_$fontOrderGroupDtoLanguageEnum_unknownDefaultOpenApi =
    const FontOrderGroupDtoLanguageEnum._('unknownDefaultOpenApi');

FontOrderGroupDtoLanguageEnum _$fontOrderGroupDtoLanguageEnumValueOf(
  String name,
) {
  switch (name) {
    case 'zh':
      return _$fontOrderGroupDtoLanguageEnum_zh;
    case 'ja':
      return _$fontOrderGroupDtoLanguageEnum_ja;
    case 'en':
      return _$fontOrderGroupDtoLanguageEnum_en;
    case 'other':
      return _$fontOrderGroupDtoLanguageEnum_other;
    case 'unknownDefaultOpenApi':
      return _$fontOrderGroupDtoLanguageEnum_unknownDefaultOpenApi;
    default:
      return _$fontOrderGroupDtoLanguageEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<FontOrderGroupDtoLanguageEnum>
_$fontOrderGroupDtoLanguageEnumValues = BuiltSet<FontOrderGroupDtoLanguageEnum>(
  const <FontOrderGroupDtoLanguageEnum>[
    _$fontOrderGroupDtoLanguageEnum_zh,
    _$fontOrderGroupDtoLanguageEnum_ja,
    _$fontOrderGroupDtoLanguageEnum_en,
    _$fontOrderGroupDtoLanguageEnum_other,
    _$fontOrderGroupDtoLanguageEnum_unknownDefaultOpenApi,
  ],
);

Serializer<FontOrderGroupDtoLanguageEnum>
_$fontOrderGroupDtoLanguageEnumSerializer =
    _$FontOrderGroupDtoLanguageEnumSerializer();

class _$FontOrderGroupDtoLanguageEnumSerializer
    implements PrimitiveSerializer<FontOrderGroupDtoLanguageEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'zh': 'zh',
    'ja': 'ja',
    'en': 'en',
    'other': 'other',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'zh': 'zh',
    'ja': 'ja',
    'en': 'en',
    'other': 'other',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[FontOrderGroupDtoLanguageEnum];
  @override
  final String wireName = 'FontOrderGroupDtoLanguageEnum';

  @override
  Object serialize(
    Serializers serializers,
    FontOrderGroupDtoLanguageEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  FontOrderGroupDtoLanguageEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => FontOrderGroupDtoLanguageEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$FontOrderGroupDto extends FontOrderGroupDto {
  @override
  final FontOrderGroupDtoLanguageEnum language;
  @override
  final BuiltList<FontOrderItemDto> items;

  factory _$FontOrderGroupDto([
    void Function(FontOrderGroupDtoBuilder)? updates,
  ]) => (FontOrderGroupDtoBuilder()..update(updates))._build();

  _$FontOrderGroupDto._({required this.language, required this.items})
    : super._();
  @override
  FontOrderGroupDto rebuild(void Function(FontOrderGroupDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FontOrderGroupDtoBuilder toBuilder() =>
      FontOrderGroupDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FontOrderGroupDto &&
        language == other.language &&
        items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, language.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FontOrderGroupDto')
          ..add('language', language)
          ..add('items', items))
        .toString();
  }
}

class FontOrderGroupDtoBuilder
    implements Builder<FontOrderGroupDto, FontOrderGroupDtoBuilder> {
  _$FontOrderGroupDto? _$v;

  FontOrderGroupDtoLanguageEnum? _language;
  FontOrderGroupDtoLanguageEnum? get language => _$this._language;
  set language(FontOrderGroupDtoLanguageEnum? language) =>
      _$this._language = language;

  ListBuilder<FontOrderItemDto>? _items;
  ListBuilder<FontOrderItemDto> get items =>
      _$this._items ??= ListBuilder<FontOrderItemDto>();
  set items(ListBuilder<FontOrderItemDto>? items) => _$this._items = items;

  FontOrderGroupDtoBuilder() {
    FontOrderGroupDto._defaults(this);
  }

  FontOrderGroupDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _language = $v.language;
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FontOrderGroupDto other) {
    _$v = other as _$FontOrderGroupDto;
  }

  @override
  void update(void Function(FontOrderGroupDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FontOrderGroupDto build() => _build();

  _$FontOrderGroupDto _build() {
    _$FontOrderGroupDto _$result;
    try {
      _$result =
          _$v ??
          _$FontOrderGroupDto._(
            language: BuiltValueNullFieldError.checkNotNull(
              language,
              r'FontOrderGroupDto',
              'language',
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
          r'FontOrderGroupDto',
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
