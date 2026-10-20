// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_font_family_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TextFontFamilyDtoAvailabilityEnum
_$textFontFamilyDtoAvailabilityEnum_ready =
    const TextFontFamilyDtoAvailabilityEnum._('ready');
const TextFontFamilyDtoAvailabilityEnum
_$textFontFamilyDtoAvailabilityEnum_pendingSource =
    const TextFontFamilyDtoAvailabilityEnum._('pendingSource');
const TextFontFamilyDtoAvailabilityEnum
_$textFontFamilyDtoAvailabilityEnum_pendingLicense =
    const TextFontFamilyDtoAvailabilityEnum._('pendingLicense');
const TextFontFamilyDtoAvailabilityEnum
_$textFontFamilyDtoAvailabilityEnum_unknownDefaultOpenApi =
    const TextFontFamilyDtoAvailabilityEnum._('unknownDefaultOpenApi');

TextFontFamilyDtoAvailabilityEnum _$textFontFamilyDtoAvailabilityEnumValueOf(
  String name,
) {
  switch (name) {
    case 'ready':
      return _$textFontFamilyDtoAvailabilityEnum_ready;
    case 'pendingSource':
      return _$textFontFamilyDtoAvailabilityEnum_pendingSource;
    case 'pendingLicense':
      return _$textFontFamilyDtoAvailabilityEnum_pendingLicense;
    case 'unknownDefaultOpenApi':
      return _$textFontFamilyDtoAvailabilityEnum_unknownDefaultOpenApi;
    default:
      return _$textFontFamilyDtoAvailabilityEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<TextFontFamilyDtoAvailabilityEnum>
_$textFontFamilyDtoAvailabilityEnumValues =
    BuiltSet<TextFontFamilyDtoAvailabilityEnum>(
      const <TextFontFamilyDtoAvailabilityEnum>[
        _$textFontFamilyDtoAvailabilityEnum_ready,
        _$textFontFamilyDtoAvailabilityEnum_pendingSource,
        _$textFontFamilyDtoAvailabilityEnum_pendingLicense,
        _$textFontFamilyDtoAvailabilityEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<TextFontFamilyDtoAvailabilityEnum>
_$textFontFamilyDtoAvailabilityEnumSerializer =
    _$TextFontFamilyDtoAvailabilityEnumSerializer();

class _$TextFontFamilyDtoAvailabilityEnumSerializer
    implements PrimitiveSerializer<TextFontFamilyDtoAvailabilityEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ready': 'ready',
    'pendingSource': 'pendingSource',
    'pendingLicense': 'pendingLicense',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ready': 'ready',
    'pendingSource': 'pendingSource',
    'pendingLicense': 'pendingLicense',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[TextFontFamilyDtoAvailabilityEnum];
  @override
  final String wireName = 'TextFontFamilyDtoAvailabilityEnum';

  @override
  Object serialize(
    Serializers serializers,
    TextFontFamilyDtoAvailabilityEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  TextFontFamilyDtoAvailabilityEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => TextFontFamilyDtoAvailabilityEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$TextFontFamilyDto extends TextFontFamilyDto {
  @override
  final String id;
  @override
  final String name;
  @override
  final TextFontFamilyDtoAvailabilityEnum availability;

  factory _$TextFontFamilyDto([
    void Function(TextFontFamilyDtoBuilder)? updates,
  ]) => (TextFontFamilyDtoBuilder()..update(updates))._build();

  _$TextFontFamilyDto._({
    required this.id,
    required this.name,
    required this.availability,
  }) : super._();
  @override
  TextFontFamilyDto rebuild(void Function(TextFontFamilyDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TextFontFamilyDtoBuilder toBuilder() =>
      TextFontFamilyDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TextFontFamilyDto &&
        id == other.id &&
        name == other.name &&
        availability == other.availability;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, availability.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TextFontFamilyDto')
          ..add('id', id)
          ..add('name', name)
          ..add('availability', availability))
        .toString();
  }
}

class TextFontFamilyDtoBuilder
    implements Builder<TextFontFamilyDto, TextFontFamilyDtoBuilder> {
  _$TextFontFamilyDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  TextFontFamilyDtoAvailabilityEnum? _availability;
  TextFontFamilyDtoAvailabilityEnum? get availability => _$this._availability;
  set availability(TextFontFamilyDtoAvailabilityEnum? availability) =>
      _$this._availability = availability;

  TextFontFamilyDtoBuilder() {
    TextFontFamilyDto._defaults(this);
  }

  TextFontFamilyDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _availability = $v.availability;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TextFontFamilyDto other) {
    _$v = other as _$TextFontFamilyDto;
  }

  @override
  void update(void Function(TextFontFamilyDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TextFontFamilyDto build() => _build();

  _$TextFontFamilyDto _build() {
    final _$result =
        _$v ??
        _$TextFontFamilyDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'TextFontFamilyDto',
            'id',
          ),
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'TextFontFamilyDto',
            'name',
          ),
          availability: BuiltValueNullFieldError.checkNotNull(
            availability,
            r'TextFontFamilyDto',
            'availability',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
