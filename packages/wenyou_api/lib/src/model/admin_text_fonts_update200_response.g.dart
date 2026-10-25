// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_text_fonts_update200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminTextFontsUpdate200ResponseCodeEnum
_$adminTextFontsUpdate200ResponseCodeEnum_number0 =
    const AdminTextFontsUpdate200ResponseCodeEnum._('number0');
const AdminTextFontsUpdate200ResponseCodeEnum
_$adminTextFontsUpdate200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminTextFontsUpdate200ResponseCodeEnum._('unknownDefaultOpenApi');

AdminTextFontsUpdate200ResponseCodeEnum
_$adminTextFontsUpdate200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminTextFontsUpdate200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminTextFontsUpdate200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminTextFontsUpdate200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminTextFontsUpdate200ResponseCodeEnum>
_$adminTextFontsUpdate200ResponseCodeEnumValues =
    BuiltSet<AdminTextFontsUpdate200ResponseCodeEnum>(
      const <AdminTextFontsUpdate200ResponseCodeEnum>[
        _$adminTextFontsUpdate200ResponseCodeEnum_number0,
        _$adminTextFontsUpdate200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminTextFontsUpdate200ResponseCodeEnum>
_$adminTextFontsUpdate200ResponseCodeEnumSerializer =
    _$AdminTextFontsUpdate200ResponseCodeEnumSerializer();

class _$AdminTextFontsUpdate200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminTextFontsUpdate200ResponseCodeEnum> {
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
    AdminTextFontsUpdate200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminTextFontsUpdate200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminTextFontsUpdate200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminTextFontsUpdate200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminTextFontsUpdate200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminTextFontsUpdate200Response
    extends AdminTextFontsUpdate200Response {
  @override
  final FontFamilyDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminTextFontsUpdate200Response([
    void Function(AdminTextFontsUpdate200ResponseBuilder)? updates,
  ]) => (AdminTextFontsUpdate200ResponseBuilder()..update(updates))._build();

  _$AdminTextFontsUpdate200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminTextFontsUpdate200Response rebuild(
    void Function(AdminTextFontsUpdate200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminTextFontsUpdate200ResponseBuilder toBuilder() =>
      AdminTextFontsUpdate200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminTextFontsUpdate200Response &&
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
    return (newBuiltValueToStringHelper(r'AdminTextFontsUpdate200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminTextFontsUpdate200ResponseBuilder
    implements
        Builder<
          AdminTextFontsUpdate200Response,
          AdminTextFontsUpdate200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminTextFontsUpdate200Response? _$v;

  FontFamilyDtoBuilder? _data;
  FontFamilyDtoBuilder get data => _$this._data ??= FontFamilyDtoBuilder();
  set data(covariant FontFamilyDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminTextFontsUpdate200ResponseBuilder() {
    AdminTextFontsUpdate200Response._defaults(this);
  }

  AdminTextFontsUpdate200ResponseBuilder get _$this {
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
  void replace(covariant AdminTextFontsUpdate200Response other) {
    _$v = other as _$AdminTextFontsUpdate200Response;
  }

  @override
  void update(void Function(AdminTextFontsUpdate200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminTextFontsUpdate200Response build() => _build();

  _$AdminTextFontsUpdate200Response _build() {
    _$AdminTextFontsUpdate200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminTextFontsUpdate200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminTextFontsUpdate200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminTextFontsUpdate200Response',
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
          r'AdminTextFontsUpdate200Response',
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
