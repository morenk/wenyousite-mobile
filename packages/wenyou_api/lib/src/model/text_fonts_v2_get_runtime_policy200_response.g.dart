// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_fonts_v2_get_runtime_policy200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TextFontsV2GetRuntimePolicy200ResponseCodeEnum
_$textFontsV2GetRuntimePolicy200ResponseCodeEnum_number0 =
    const TextFontsV2GetRuntimePolicy200ResponseCodeEnum._('number0');
const TextFontsV2GetRuntimePolicy200ResponseCodeEnum
_$textFontsV2GetRuntimePolicy200ResponseCodeEnum_unknownDefaultOpenApi =
    const TextFontsV2GetRuntimePolicy200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

TextFontsV2GetRuntimePolicy200ResponseCodeEnum
_$textFontsV2GetRuntimePolicy200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$textFontsV2GetRuntimePolicy200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$textFontsV2GetRuntimePolicy200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$textFontsV2GetRuntimePolicy200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<TextFontsV2GetRuntimePolicy200ResponseCodeEnum>
_$textFontsV2GetRuntimePolicy200ResponseCodeEnumValues =
    BuiltSet<TextFontsV2GetRuntimePolicy200ResponseCodeEnum>(
      const <TextFontsV2GetRuntimePolicy200ResponseCodeEnum>[
        _$textFontsV2GetRuntimePolicy200ResponseCodeEnum_number0,
        _$textFontsV2GetRuntimePolicy200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<TextFontsV2GetRuntimePolicy200ResponseCodeEnum>
_$textFontsV2GetRuntimePolicy200ResponseCodeEnumSerializer =
    _$TextFontsV2GetRuntimePolicy200ResponseCodeEnumSerializer();

class _$TextFontsV2GetRuntimePolicy200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<TextFontsV2GetRuntimePolicy200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    TextFontsV2GetRuntimePolicy200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'TextFontsV2GetRuntimePolicy200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    TextFontsV2GetRuntimePolicy200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  TextFontsV2GetRuntimePolicy200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => TextFontsV2GetRuntimePolicy200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$TextFontsV2GetRuntimePolicy200Response
    extends TextFontsV2GetRuntimePolicy200Response {
  @override
  final DynamicFontRuntimePolicyDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$TextFontsV2GetRuntimePolicy200Response([
    void Function(TextFontsV2GetRuntimePolicy200ResponseBuilder)? updates,
  ]) => (TextFontsV2GetRuntimePolicy200ResponseBuilder()..update(updates))
      ._build();

  _$TextFontsV2GetRuntimePolicy200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  TextFontsV2GetRuntimePolicy200Response rebuild(
    void Function(TextFontsV2GetRuntimePolicy200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  TextFontsV2GetRuntimePolicy200ResponseBuilder toBuilder() =>
      TextFontsV2GetRuntimePolicy200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TextFontsV2GetRuntimePolicy200Response &&
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
    return (newBuiltValueToStringHelper(
            r'TextFontsV2GetRuntimePolicy200Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class TextFontsV2GetRuntimePolicy200ResponseBuilder
    implements
        Builder<
          TextFontsV2GetRuntimePolicy200Response,
          TextFontsV2GetRuntimePolicy200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$TextFontsV2GetRuntimePolicy200Response? _$v;

  DynamicFontRuntimePolicyDtoBuilder? _data;
  DynamicFontRuntimePolicyDtoBuilder get data =>
      _$this._data ??= DynamicFontRuntimePolicyDtoBuilder();
  set data(covariant DynamicFontRuntimePolicyDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  TextFontsV2GetRuntimePolicy200ResponseBuilder() {
    TextFontsV2GetRuntimePolicy200Response._defaults(this);
  }

  TextFontsV2GetRuntimePolicy200ResponseBuilder get _$this {
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
  void replace(covariant TextFontsV2GetRuntimePolicy200Response other) {
    _$v = other as _$TextFontsV2GetRuntimePolicy200Response;
  }

  @override
  void update(
    void Function(TextFontsV2GetRuntimePolicy200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  TextFontsV2GetRuntimePolicy200Response build() => _build();

  _$TextFontsV2GetRuntimePolicy200Response _build() {
    _$TextFontsV2GetRuntimePolicy200Response _$result;
    try {
      _$result =
          _$v ??
          _$TextFontsV2GetRuntimePolicy200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'TextFontsV2GetRuntimePolicy200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'TextFontsV2GetRuntimePolicy200Response',
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
          r'TextFontsV2GetRuntimePolicy200Response',
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
