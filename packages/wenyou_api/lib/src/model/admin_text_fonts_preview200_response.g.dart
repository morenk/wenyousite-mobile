// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_text_fonts_preview200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminTextFontsPreview200ResponseCodeEnum
_$adminTextFontsPreview200ResponseCodeEnum_number0 =
    const AdminTextFontsPreview200ResponseCodeEnum._('number0');
const AdminTextFontsPreview200ResponseCodeEnum
_$adminTextFontsPreview200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminTextFontsPreview200ResponseCodeEnum._('unknownDefaultOpenApi');

AdminTextFontsPreview200ResponseCodeEnum
_$adminTextFontsPreview200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminTextFontsPreview200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminTextFontsPreview200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminTextFontsPreview200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminTextFontsPreview200ResponseCodeEnum>
_$adminTextFontsPreview200ResponseCodeEnumValues =
    BuiltSet<AdminTextFontsPreview200ResponseCodeEnum>(
      const <AdminTextFontsPreview200ResponseCodeEnum>[
        _$adminTextFontsPreview200ResponseCodeEnum_number0,
        _$adminTextFontsPreview200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminTextFontsPreview200ResponseCodeEnum>
_$adminTextFontsPreview200ResponseCodeEnumSerializer =
    _$AdminTextFontsPreview200ResponseCodeEnumSerializer();

class _$AdminTextFontsPreview200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminTextFontsPreview200ResponseCodeEnum> {
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
    AdminTextFontsPreview200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminTextFontsPreview200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminTextFontsPreview200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminTextFontsPreview200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminTextFontsPreview200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminTextFontsPreview200Response
    extends AdminTextFontsPreview200Response {
  @override
  final FontVersionDescriptorDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminTextFontsPreview200Response([
    void Function(AdminTextFontsPreview200ResponseBuilder)? updates,
  ]) => (AdminTextFontsPreview200ResponseBuilder()..update(updates))._build();

  _$AdminTextFontsPreview200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminTextFontsPreview200Response rebuild(
    void Function(AdminTextFontsPreview200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminTextFontsPreview200ResponseBuilder toBuilder() =>
      AdminTextFontsPreview200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminTextFontsPreview200Response &&
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
    return (newBuiltValueToStringHelper(r'AdminTextFontsPreview200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminTextFontsPreview200ResponseBuilder
    implements
        Builder<
          AdminTextFontsPreview200Response,
          AdminTextFontsPreview200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminTextFontsPreview200Response? _$v;

  FontVersionDescriptorDtoBuilder? _data;
  FontVersionDescriptorDtoBuilder get data =>
      _$this._data ??= FontVersionDescriptorDtoBuilder();
  set data(covariant FontVersionDescriptorDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminTextFontsPreview200ResponseBuilder() {
    AdminTextFontsPreview200Response._defaults(this);
  }

  AdminTextFontsPreview200ResponseBuilder get _$this {
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
  void replace(covariant AdminTextFontsPreview200Response other) {
    _$v = other as _$AdminTextFontsPreview200Response;
  }

  @override
  void update(void Function(AdminTextFontsPreview200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminTextFontsPreview200Response build() => _build();

  _$AdminTextFontsPreview200Response _build() {
    _$AdminTextFontsPreview200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminTextFontsPreview200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminTextFontsPreview200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminTextFontsPreview200Response',
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
          r'AdminTextFontsPreview200Response',
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
