// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_fonts_v2_get_catalog200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TextFontsV2GetCatalog200ResponseCodeEnum
_$textFontsV2GetCatalog200ResponseCodeEnum_number0 =
    const TextFontsV2GetCatalog200ResponseCodeEnum._('number0');
const TextFontsV2GetCatalog200ResponseCodeEnum
_$textFontsV2GetCatalog200ResponseCodeEnum_unknownDefaultOpenApi =
    const TextFontsV2GetCatalog200ResponseCodeEnum._('unknownDefaultOpenApi');

TextFontsV2GetCatalog200ResponseCodeEnum
_$textFontsV2GetCatalog200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$textFontsV2GetCatalog200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$textFontsV2GetCatalog200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$textFontsV2GetCatalog200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<TextFontsV2GetCatalog200ResponseCodeEnum>
_$textFontsV2GetCatalog200ResponseCodeEnumValues =
    BuiltSet<TextFontsV2GetCatalog200ResponseCodeEnum>(
      const <TextFontsV2GetCatalog200ResponseCodeEnum>[
        _$textFontsV2GetCatalog200ResponseCodeEnum_number0,
        _$textFontsV2GetCatalog200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<TextFontsV2GetCatalog200ResponseCodeEnum>
_$textFontsV2GetCatalog200ResponseCodeEnumSerializer =
    _$TextFontsV2GetCatalog200ResponseCodeEnumSerializer();

class _$TextFontsV2GetCatalog200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<TextFontsV2GetCatalog200ResponseCodeEnum> {
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
    TextFontsV2GetCatalog200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'TextFontsV2GetCatalog200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    TextFontsV2GetCatalog200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  TextFontsV2GetCatalog200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => TextFontsV2GetCatalog200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$TextFontsV2GetCatalog200Response
    extends TextFontsV2GetCatalog200Response {
  @override
  final FontCatalogPageDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$TextFontsV2GetCatalog200Response([
    void Function(TextFontsV2GetCatalog200ResponseBuilder)? updates,
  ]) => (TextFontsV2GetCatalog200ResponseBuilder()..update(updates))._build();

  _$TextFontsV2GetCatalog200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  TextFontsV2GetCatalog200Response rebuild(
    void Function(TextFontsV2GetCatalog200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  TextFontsV2GetCatalog200ResponseBuilder toBuilder() =>
      TextFontsV2GetCatalog200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TextFontsV2GetCatalog200Response &&
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
    return (newBuiltValueToStringHelper(r'TextFontsV2GetCatalog200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class TextFontsV2GetCatalog200ResponseBuilder
    implements
        Builder<
          TextFontsV2GetCatalog200Response,
          TextFontsV2GetCatalog200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$TextFontsV2GetCatalog200Response? _$v;

  FontCatalogPageDtoBuilder? _data;
  FontCatalogPageDtoBuilder get data =>
      _$this._data ??= FontCatalogPageDtoBuilder();
  set data(covariant FontCatalogPageDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  TextFontsV2GetCatalog200ResponseBuilder() {
    TextFontsV2GetCatalog200Response._defaults(this);
  }

  TextFontsV2GetCatalog200ResponseBuilder get _$this {
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
  void replace(covariant TextFontsV2GetCatalog200Response other) {
    _$v = other as _$TextFontsV2GetCatalog200Response;
  }

  @override
  void update(void Function(TextFontsV2GetCatalog200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TextFontsV2GetCatalog200Response build() => _build();

  _$TextFontsV2GetCatalog200Response _build() {
    _$TextFontsV2GetCatalog200Response _$result;
    try {
      _$result =
          _$v ??
          _$TextFontsV2GetCatalog200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'TextFontsV2GetCatalog200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'TextFontsV2GetCatalog200Response',
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
          r'TextFontsV2GetCatalog200Response',
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
