// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_auth_verify200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminAuthVerify200ResponseCodeEnum
_$adminAuthVerify200ResponseCodeEnum_number0 =
    const AdminAuthVerify200ResponseCodeEnum._('number0');
const AdminAuthVerify200ResponseCodeEnum
_$adminAuthVerify200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminAuthVerify200ResponseCodeEnum._('unknownDefaultOpenApi');

AdminAuthVerify200ResponseCodeEnum _$adminAuthVerify200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$adminAuthVerify200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminAuthVerify200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminAuthVerify200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminAuthVerify200ResponseCodeEnum>
_$adminAuthVerify200ResponseCodeEnumValues =
    BuiltSet<AdminAuthVerify200ResponseCodeEnum>(
      const <AdminAuthVerify200ResponseCodeEnum>[
        _$adminAuthVerify200ResponseCodeEnum_number0,
        _$adminAuthVerify200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminAuthVerify200ResponseCodeEnum>
_$adminAuthVerify200ResponseCodeEnumSerializer =
    _$AdminAuthVerify200ResponseCodeEnumSerializer();

class _$AdminAuthVerify200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminAuthVerify200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[AdminAuthVerify200ResponseCodeEnum];
  @override
  final String wireName = 'AdminAuthVerify200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminAuthVerify200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminAuthVerify200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminAuthVerify200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminAuthVerify200Response extends AdminAuthVerify200Response {
  @override
  final AdminSessionResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminAuthVerify200Response([
    void Function(AdminAuthVerify200ResponseBuilder)? updates,
  ]) => (AdminAuthVerify200ResponseBuilder()..update(updates))._build();

  _$AdminAuthVerify200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminAuthVerify200Response rebuild(
    void Function(AdminAuthVerify200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminAuthVerify200ResponseBuilder toBuilder() =>
      AdminAuthVerify200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminAuthVerify200Response &&
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
    return (newBuiltValueToStringHelper(r'AdminAuthVerify200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminAuthVerify200ResponseBuilder
    implements
        Builder<AdminAuthVerify200Response, AdminAuthVerify200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$AdminAuthVerify200Response? _$v;

  AdminSessionResponseDtoBuilder? _data;
  AdminSessionResponseDtoBuilder get data =>
      _$this._data ??= AdminSessionResponseDtoBuilder();
  set data(covariant AdminSessionResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminAuthVerify200ResponseBuilder() {
    AdminAuthVerify200Response._defaults(this);
  }

  AdminAuthVerify200ResponseBuilder get _$this {
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
  void replace(covariant AdminAuthVerify200Response other) {
    _$v = other as _$AdminAuthVerify200Response;
  }

  @override
  void update(void Function(AdminAuthVerify200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminAuthVerify200Response build() => _build();

  _$AdminAuthVerify200Response _build() {
    _$AdminAuthVerify200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminAuthVerify200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminAuthVerify200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminAuthVerify200Response',
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
          r'AdminAuthVerify200Response',
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
