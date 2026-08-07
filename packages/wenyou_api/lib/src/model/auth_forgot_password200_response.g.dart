// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_forgot_password200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AuthForgotPassword200ResponseCodeEnum
_$authForgotPassword200ResponseCodeEnum_number0 =
    const AuthForgotPassword200ResponseCodeEnum._('number0');
const AuthForgotPassword200ResponseCodeEnum
_$authForgotPassword200ResponseCodeEnum_unknownDefaultOpenApi =
    const AuthForgotPassword200ResponseCodeEnum._('unknownDefaultOpenApi');

AuthForgotPassword200ResponseCodeEnum
_$authForgotPassword200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$authForgotPassword200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$authForgotPassword200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$authForgotPassword200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AuthForgotPassword200ResponseCodeEnum>
_$authForgotPassword200ResponseCodeEnumValues =
    BuiltSet<AuthForgotPassword200ResponseCodeEnum>(
      const <AuthForgotPassword200ResponseCodeEnum>[
        _$authForgotPassword200ResponseCodeEnum_number0,
        _$authForgotPassword200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AuthForgotPassword200ResponseCodeEnum>
_$authForgotPassword200ResponseCodeEnumSerializer =
    _$AuthForgotPassword200ResponseCodeEnumSerializer();

class _$AuthForgotPassword200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AuthForgotPassword200ResponseCodeEnum> {
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
    AuthForgotPassword200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AuthForgotPassword200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AuthForgotPassword200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AuthForgotPassword200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AuthForgotPassword200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AuthForgotPassword200Response extends AuthForgotPassword200Response {
  @override
  final MessageResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AuthForgotPassword200Response([
    void Function(AuthForgotPassword200ResponseBuilder)? updates,
  ]) => (AuthForgotPassword200ResponseBuilder()..update(updates))._build();

  _$AuthForgotPassword200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AuthForgotPassword200Response rebuild(
    void Function(AuthForgotPassword200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AuthForgotPassword200ResponseBuilder toBuilder() =>
      AuthForgotPassword200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthForgotPassword200Response &&
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
    return (newBuiltValueToStringHelper(r'AuthForgotPassword200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AuthForgotPassword200ResponseBuilder
    implements
        Builder<
          AuthForgotPassword200Response,
          AuthForgotPassword200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AuthForgotPassword200Response? _$v;

  MessageResponseDtoBuilder? _data;
  MessageResponseDtoBuilder get data =>
      _$this._data ??= MessageResponseDtoBuilder();
  set data(covariant MessageResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AuthForgotPassword200ResponseBuilder() {
    AuthForgotPassword200Response._defaults(this);
  }

  AuthForgotPassword200ResponseBuilder get _$this {
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
  void replace(covariant AuthForgotPassword200Response other) {
    _$v = other as _$AuthForgotPassword200Response;
  }

  @override
  void update(void Function(AuthForgotPassword200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthForgotPassword200Response build() => _build();

  _$AuthForgotPassword200Response _build() {
    _$AuthForgotPassword200Response _$result;
    try {
      _$result =
          _$v ??
          _$AuthForgotPassword200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AuthForgotPassword200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AuthForgotPassword200Response',
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
          r'AuthForgotPassword200Response',
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
