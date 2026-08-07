// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tags_create200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TagsCreate200ResponseCodeEnum _$tagsCreate200ResponseCodeEnum_number0 =
    const TagsCreate200ResponseCodeEnum._('number0');
const TagsCreate200ResponseCodeEnum
_$tagsCreate200ResponseCodeEnum_unknownDefaultOpenApi =
    const TagsCreate200ResponseCodeEnum._('unknownDefaultOpenApi');

TagsCreate200ResponseCodeEnum _$tagsCreate200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$tagsCreate200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$tagsCreate200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$tagsCreate200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<TagsCreate200ResponseCodeEnum>
_$tagsCreate200ResponseCodeEnumValues = BuiltSet<TagsCreate200ResponseCodeEnum>(
  const <TagsCreate200ResponseCodeEnum>[
    _$tagsCreate200ResponseCodeEnum_number0,
    _$tagsCreate200ResponseCodeEnum_unknownDefaultOpenApi,
  ],
);

Serializer<TagsCreate200ResponseCodeEnum>
_$tagsCreate200ResponseCodeEnumSerializer =
    _$TagsCreate200ResponseCodeEnumSerializer();

class _$TagsCreate200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<TagsCreate200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[TagsCreate200ResponseCodeEnum];
  @override
  final String wireName = 'TagsCreate200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    TagsCreate200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  TagsCreate200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => TagsCreate200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$TagsCreate200Response extends TagsCreate200Response {
  @override
  final TagResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$TagsCreate200Response([
    void Function(TagsCreate200ResponseBuilder)? updates,
  ]) => (TagsCreate200ResponseBuilder()..update(updates))._build();

  _$TagsCreate200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  TagsCreate200Response rebuild(
    void Function(TagsCreate200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  TagsCreate200ResponseBuilder toBuilder() =>
      TagsCreate200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TagsCreate200Response &&
        data == other.data &&
        code == other.code &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TagsCreate200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class TagsCreate200ResponseBuilder
    implements
        Builder<TagsCreate200Response, TagsCreate200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$TagsCreate200Response? _$v;

  TagResponseDtoBuilder? _data;
  TagResponseDtoBuilder get data => _$this._data ??= TagResponseDtoBuilder();
  set data(covariant TagResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  TagsCreate200ResponseBuilder() {
    TagsCreate200Response._defaults(this);
  }

  TagsCreate200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _code = $v.code;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant TagsCreate200Response other) {
    _$v = other as _$TagsCreate200Response;
  }

  @override
  void update(void Function(TagsCreate200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TagsCreate200Response build() => _build();

  _$TagsCreate200Response _build() {
    _$TagsCreate200Response _$result;
    try {
      _$result =
          _$v ??
          _$TagsCreate200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'TagsCreate200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'TagsCreate200Response',
              'message',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'TagsCreate200Response',
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
