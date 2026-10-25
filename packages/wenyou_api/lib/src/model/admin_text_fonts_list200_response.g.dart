// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_text_fonts_list200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminTextFontsList200ResponseCodeEnum
_$adminTextFontsList200ResponseCodeEnum_number0 =
    const AdminTextFontsList200ResponseCodeEnum._('number0');
const AdminTextFontsList200ResponseCodeEnum
_$adminTextFontsList200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminTextFontsList200ResponseCodeEnum._('unknownDefaultOpenApi');

AdminTextFontsList200ResponseCodeEnum
_$adminTextFontsList200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminTextFontsList200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminTextFontsList200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminTextFontsList200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminTextFontsList200ResponseCodeEnum>
_$adminTextFontsList200ResponseCodeEnumValues =
    BuiltSet<AdminTextFontsList200ResponseCodeEnum>(
      const <AdminTextFontsList200ResponseCodeEnum>[
        _$adminTextFontsList200ResponseCodeEnum_number0,
        _$adminTextFontsList200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminTextFontsList200ResponseCodeEnum>
_$adminTextFontsList200ResponseCodeEnumSerializer =
    _$AdminTextFontsList200ResponseCodeEnumSerializer();

class _$AdminTextFontsList200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminTextFontsList200ResponseCodeEnum> {
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
    AdminTextFontsList200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminTextFontsList200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminTextFontsList200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminTextFontsList200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminTextFontsList200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminTextFontsList200Response extends AdminTextFontsList200Response {
  @override
  final FontAdminPageDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminTextFontsList200Response([
    void Function(AdminTextFontsList200ResponseBuilder)? updates,
  ]) => (AdminTextFontsList200ResponseBuilder()..update(updates))._build();

  _$AdminTextFontsList200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminTextFontsList200Response rebuild(
    void Function(AdminTextFontsList200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminTextFontsList200ResponseBuilder toBuilder() =>
      AdminTextFontsList200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminTextFontsList200Response &&
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
    return (newBuiltValueToStringHelper(r'AdminTextFontsList200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminTextFontsList200ResponseBuilder
    implements
        Builder<
          AdminTextFontsList200Response,
          AdminTextFontsList200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminTextFontsList200Response? _$v;

  FontAdminPageDtoBuilder? _data;
  FontAdminPageDtoBuilder get data =>
      _$this._data ??= FontAdminPageDtoBuilder();
  set data(covariant FontAdminPageDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminTextFontsList200ResponseBuilder() {
    AdminTextFontsList200Response._defaults(this);
  }

  AdminTextFontsList200ResponseBuilder get _$this {
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
  void replace(covariant AdminTextFontsList200Response other) {
    _$v = other as _$AdminTextFontsList200Response;
  }

  @override
  void update(void Function(AdminTextFontsList200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminTextFontsList200Response build() => _build();

  _$AdminTextFontsList200Response _build() {
    _$AdminTextFontsList200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminTextFontsList200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminTextFontsList200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminTextFontsList200Response',
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
          r'AdminTextFontsList200Response',
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
