// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tags_search200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TagsSearch200ResponseCodeEnum _$tagsSearch200ResponseCodeEnum_number0 =
    const TagsSearch200ResponseCodeEnum._('number0');
const TagsSearch200ResponseCodeEnum
_$tagsSearch200ResponseCodeEnum_unknownDefaultOpenApi =
    const TagsSearch200ResponseCodeEnum._('unknownDefaultOpenApi');

TagsSearch200ResponseCodeEnum _$tagsSearch200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$tagsSearch200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$tagsSearch200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$tagsSearch200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<TagsSearch200ResponseCodeEnum>
_$tagsSearch200ResponseCodeEnumValues = BuiltSet<TagsSearch200ResponseCodeEnum>(
  const <TagsSearch200ResponseCodeEnum>[
    _$tagsSearch200ResponseCodeEnum_number0,
    _$tagsSearch200ResponseCodeEnum_unknownDefaultOpenApi,
  ],
);

Serializer<TagsSearch200ResponseCodeEnum>
_$tagsSearch200ResponseCodeEnumSerializer =
    _$TagsSearch200ResponseCodeEnumSerializer();

class _$TagsSearch200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<TagsSearch200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[TagsSearch200ResponseCodeEnum];
  @override
  final String wireName = 'TagsSearch200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    TagsSearch200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  TagsSearch200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => TagsSearch200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$TagsSearch200Response extends TagsSearch200Response {
  @override
  final BuiltList<TagResponseDto> data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$TagsSearch200Response([
    void Function(TagsSearch200ResponseBuilder)? updates,
  ]) => (TagsSearch200ResponseBuilder()..update(updates))._build();

  _$TagsSearch200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  TagsSearch200Response rebuild(
    void Function(TagsSearch200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  TagsSearch200ResponseBuilder toBuilder() =>
      TagsSearch200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TagsSearch200Response &&
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
    return (newBuiltValueToStringHelper(r'TagsSearch200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class TagsSearch200ResponseBuilder
    implements
        Builder<TagsSearch200Response, TagsSearch200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$TagsSearch200Response? _$v;

  ListBuilder<TagResponseDto>? _data;
  ListBuilder<TagResponseDto> get data =>
      _$this._data ??= ListBuilder<TagResponseDto>();
  set data(covariant ListBuilder<TagResponseDto>? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  TagsSearch200ResponseBuilder() {
    TagsSearch200Response._defaults(this);
  }

  TagsSearch200ResponseBuilder get _$this {
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
  void replace(covariant TagsSearch200Response other) {
    _$v = other as _$TagsSearch200Response;
  }

  @override
  void update(void Function(TagsSearch200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TagsSearch200Response build() => _build();

  _$TagsSearch200Response _build() {
    _$TagsSearch200Response _$result;
    try {
      _$result =
          _$v ??
          _$TagsSearch200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'TagsSearch200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'TagsSearch200Response',
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
          r'TagsSearch200Response',
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
