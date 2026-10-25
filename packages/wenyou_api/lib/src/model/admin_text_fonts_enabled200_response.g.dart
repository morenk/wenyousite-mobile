// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_text_fonts_enabled200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminTextFontsEnabled200ResponseCodeEnum
_$adminTextFontsEnabled200ResponseCodeEnum_number0 =
    const AdminTextFontsEnabled200ResponseCodeEnum._('number0');
const AdminTextFontsEnabled200ResponseCodeEnum
_$adminTextFontsEnabled200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminTextFontsEnabled200ResponseCodeEnum._('unknownDefaultOpenApi');

AdminTextFontsEnabled200ResponseCodeEnum
_$adminTextFontsEnabled200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminTextFontsEnabled200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminTextFontsEnabled200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminTextFontsEnabled200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminTextFontsEnabled200ResponseCodeEnum>
_$adminTextFontsEnabled200ResponseCodeEnumValues =
    BuiltSet<AdminTextFontsEnabled200ResponseCodeEnum>(
      const <AdminTextFontsEnabled200ResponseCodeEnum>[
        _$adminTextFontsEnabled200ResponseCodeEnum_number0,
        _$adminTextFontsEnabled200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminTextFontsEnabled200ResponseCodeEnum>
_$adminTextFontsEnabled200ResponseCodeEnumSerializer =
    _$AdminTextFontsEnabled200ResponseCodeEnumSerializer();

class _$AdminTextFontsEnabled200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminTextFontsEnabled200ResponseCodeEnum> {
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
    AdminTextFontsEnabled200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminTextFontsEnabled200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminTextFontsEnabled200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminTextFontsEnabled200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminTextFontsEnabled200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminTextFontsEnabled200Response
    extends AdminTextFontsEnabled200Response {
  @override
  final FontFamilyDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminTextFontsEnabled200Response([
    void Function(AdminTextFontsEnabled200ResponseBuilder)? updates,
  ]) => (AdminTextFontsEnabled200ResponseBuilder()..update(updates))._build();

  _$AdminTextFontsEnabled200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminTextFontsEnabled200Response rebuild(
    void Function(AdminTextFontsEnabled200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminTextFontsEnabled200ResponseBuilder toBuilder() =>
      AdminTextFontsEnabled200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminTextFontsEnabled200Response &&
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
    return (newBuiltValueToStringHelper(r'AdminTextFontsEnabled200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminTextFontsEnabled200ResponseBuilder
    implements
        Builder<
          AdminTextFontsEnabled200Response,
          AdminTextFontsEnabled200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminTextFontsEnabled200Response? _$v;

  FontFamilyDtoBuilder? _data;
  FontFamilyDtoBuilder get data => _$this._data ??= FontFamilyDtoBuilder();
  set data(covariant FontFamilyDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminTextFontsEnabled200ResponseBuilder() {
    AdminTextFontsEnabled200Response._defaults(this);
  }

  AdminTextFontsEnabled200ResponseBuilder get _$this {
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
  void replace(covariant AdminTextFontsEnabled200Response other) {
    _$v = other as _$AdminTextFontsEnabled200Response;
  }

  @override
  void update(void Function(AdminTextFontsEnabled200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminTextFontsEnabled200Response build() => _build();

  _$AdminTextFontsEnabled200Response _build() {
    _$AdminTextFontsEnabled200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminTextFontsEnabled200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminTextFontsEnabled200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminTextFontsEnabled200Response',
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
          r'AdminTextFontsEnabled200Response',
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
