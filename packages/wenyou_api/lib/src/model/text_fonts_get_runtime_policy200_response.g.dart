// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_fonts_get_runtime_policy200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TextFontsGetRuntimePolicy200ResponseCodeEnum
_$textFontsGetRuntimePolicy200ResponseCodeEnum_number0 =
    const TextFontsGetRuntimePolicy200ResponseCodeEnum._('number0');
const TextFontsGetRuntimePolicy200ResponseCodeEnum
_$textFontsGetRuntimePolicy200ResponseCodeEnum_unknownDefaultOpenApi =
    const TextFontsGetRuntimePolicy200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

TextFontsGetRuntimePolicy200ResponseCodeEnum
_$textFontsGetRuntimePolicy200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$textFontsGetRuntimePolicy200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$textFontsGetRuntimePolicy200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$textFontsGetRuntimePolicy200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<TextFontsGetRuntimePolicy200ResponseCodeEnum>
_$textFontsGetRuntimePolicy200ResponseCodeEnumValues =
    BuiltSet<TextFontsGetRuntimePolicy200ResponseCodeEnum>(
      const <TextFontsGetRuntimePolicy200ResponseCodeEnum>[
        _$textFontsGetRuntimePolicy200ResponseCodeEnum_number0,
        _$textFontsGetRuntimePolicy200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<TextFontsGetRuntimePolicy200ResponseCodeEnum>
_$textFontsGetRuntimePolicy200ResponseCodeEnumSerializer =
    _$TextFontsGetRuntimePolicy200ResponseCodeEnumSerializer();

class _$TextFontsGetRuntimePolicy200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<TextFontsGetRuntimePolicy200ResponseCodeEnum> {
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
    TextFontsGetRuntimePolicy200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'TextFontsGetRuntimePolicy200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    TextFontsGetRuntimePolicy200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  TextFontsGetRuntimePolicy200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => TextFontsGetRuntimePolicy200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$TextFontsGetRuntimePolicy200Response
    extends TextFontsGetRuntimePolicy200Response {
  @override
  final TextFontRuntimePolicyDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$TextFontsGetRuntimePolicy200Response([
    void Function(TextFontsGetRuntimePolicy200ResponseBuilder)? updates,
  ]) =>
      (TextFontsGetRuntimePolicy200ResponseBuilder()..update(updates))._build();

  _$TextFontsGetRuntimePolicy200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  TextFontsGetRuntimePolicy200Response rebuild(
    void Function(TextFontsGetRuntimePolicy200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  TextFontsGetRuntimePolicy200ResponseBuilder toBuilder() =>
      TextFontsGetRuntimePolicy200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TextFontsGetRuntimePolicy200Response &&
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
    return (newBuiltValueToStringHelper(r'TextFontsGetRuntimePolicy200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class TextFontsGetRuntimePolicy200ResponseBuilder
    implements
        Builder<
          TextFontsGetRuntimePolicy200Response,
          TextFontsGetRuntimePolicy200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$TextFontsGetRuntimePolicy200Response? _$v;

  TextFontRuntimePolicyDtoBuilder? _data;
  TextFontRuntimePolicyDtoBuilder get data =>
      _$this._data ??= TextFontRuntimePolicyDtoBuilder();
  set data(covariant TextFontRuntimePolicyDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  TextFontsGetRuntimePolicy200ResponseBuilder() {
    TextFontsGetRuntimePolicy200Response._defaults(this);
  }

  TextFontsGetRuntimePolicy200ResponseBuilder get _$this {
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
  void replace(covariant TextFontsGetRuntimePolicy200Response other) {
    _$v = other as _$TextFontsGetRuntimePolicy200Response;
  }

  @override
  void update(
    void Function(TextFontsGetRuntimePolicy200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  TextFontsGetRuntimePolicy200Response build() => _build();

  _$TextFontsGetRuntimePolicy200Response _build() {
    _$TextFontsGetRuntimePolicy200Response _$result;
    try {
      _$result =
          _$v ??
          _$TextFontsGetRuntimePolicy200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'TextFontsGetRuntimePolicy200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'TextFontsGetRuntimePolicy200Response',
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
          r'TextFontsGetRuntimePolicy200Response',
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
