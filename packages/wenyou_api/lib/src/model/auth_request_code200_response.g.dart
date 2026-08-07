// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_request_code200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AuthRequestCode200ResponseCodeEnum
_$authRequestCode200ResponseCodeEnum_number0 =
    const AuthRequestCode200ResponseCodeEnum._('number0');
const AuthRequestCode200ResponseCodeEnum
_$authRequestCode200ResponseCodeEnum_unknownDefaultOpenApi =
    const AuthRequestCode200ResponseCodeEnum._('unknownDefaultOpenApi');

AuthRequestCode200ResponseCodeEnum _$authRequestCode200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$authRequestCode200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$authRequestCode200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$authRequestCode200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AuthRequestCode200ResponseCodeEnum>
_$authRequestCode200ResponseCodeEnumValues =
    BuiltSet<AuthRequestCode200ResponseCodeEnum>(
      const <AuthRequestCode200ResponseCodeEnum>[
        _$authRequestCode200ResponseCodeEnum_number0,
        _$authRequestCode200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AuthRequestCode200ResponseCodeEnum>
_$authRequestCode200ResponseCodeEnumSerializer =
    _$AuthRequestCode200ResponseCodeEnumSerializer();

class _$AuthRequestCode200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AuthRequestCode200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[AuthRequestCode200ResponseCodeEnum];
  @override
  final String wireName = 'AuthRequestCode200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AuthRequestCode200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AuthRequestCode200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AuthRequestCode200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AuthRequestCode200Response extends AuthRequestCode200Response {
  @override
  final RegisterCodeResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AuthRequestCode200Response([
    void Function(AuthRequestCode200ResponseBuilder)? updates,
  ]) => (AuthRequestCode200ResponseBuilder()..update(updates))._build();

  _$AuthRequestCode200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AuthRequestCode200Response rebuild(
    void Function(AuthRequestCode200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AuthRequestCode200ResponseBuilder toBuilder() =>
      AuthRequestCode200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthRequestCode200Response &&
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
    return (newBuiltValueToStringHelper(r'AuthRequestCode200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AuthRequestCode200ResponseBuilder
    implements
        Builder<AuthRequestCode200Response, AuthRequestCode200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$AuthRequestCode200Response? _$v;

  RegisterCodeResponseDtoBuilder? _data;
  RegisterCodeResponseDtoBuilder get data =>
      _$this._data ??= RegisterCodeResponseDtoBuilder();
  set data(covariant RegisterCodeResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AuthRequestCode200ResponseBuilder() {
    AuthRequestCode200Response._defaults(this);
  }

  AuthRequestCode200ResponseBuilder get _$this {
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
  void replace(covariant AuthRequestCode200Response other) {
    _$v = other as _$AuthRequestCode200Response;
  }

  @override
  void update(void Function(AuthRequestCode200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthRequestCode200Response build() => _build();

  _$AuthRequestCode200Response _build() {
    _$AuthRequestCode200Response _$result;
    try {
      _$result =
          _$v ??
          _$AuthRequestCode200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AuthRequestCode200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AuthRequestCode200Response',
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
          r'AuthRequestCode200Response',
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
