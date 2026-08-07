// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_resend_verification200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AuthResendVerification200ResponseCodeEnum
_$authResendVerification200ResponseCodeEnum_number0 =
    const AuthResendVerification200ResponseCodeEnum._('number0');
const AuthResendVerification200ResponseCodeEnum
_$authResendVerification200ResponseCodeEnum_unknownDefaultOpenApi =
    const AuthResendVerification200ResponseCodeEnum._('unknownDefaultOpenApi');

AuthResendVerification200ResponseCodeEnum
_$authResendVerification200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$authResendVerification200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$authResendVerification200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$authResendVerification200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AuthResendVerification200ResponseCodeEnum>
_$authResendVerification200ResponseCodeEnumValues =
    BuiltSet<AuthResendVerification200ResponseCodeEnum>(
      const <AuthResendVerification200ResponseCodeEnum>[
        _$authResendVerification200ResponseCodeEnum_number0,
        _$authResendVerification200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AuthResendVerification200ResponseCodeEnum>
_$authResendVerification200ResponseCodeEnumSerializer =
    _$AuthResendVerification200ResponseCodeEnumSerializer();

class _$AuthResendVerification200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AuthResendVerification200ResponseCodeEnum> {
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
    AuthResendVerification200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AuthResendVerification200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AuthResendVerification200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AuthResendVerification200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AuthResendVerification200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AuthResendVerification200Response
    extends AuthResendVerification200Response {
  @override
  final MessageResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AuthResendVerification200Response([
    void Function(AuthResendVerification200ResponseBuilder)? updates,
  ]) => (AuthResendVerification200ResponseBuilder()..update(updates))._build();

  _$AuthResendVerification200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AuthResendVerification200Response rebuild(
    void Function(AuthResendVerification200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AuthResendVerification200ResponseBuilder toBuilder() =>
      AuthResendVerification200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthResendVerification200Response &&
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
    return (newBuiltValueToStringHelper(r'AuthResendVerification200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AuthResendVerification200ResponseBuilder
    implements
        Builder<
          AuthResendVerification200Response,
          AuthResendVerification200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AuthResendVerification200Response? _$v;

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

  AuthResendVerification200ResponseBuilder() {
    AuthResendVerification200Response._defaults(this);
  }

  AuthResendVerification200ResponseBuilder get _$this {
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
  void replace(covariant AuthResendVerification200Response other) {
    _$v = other as _$AuthResendVerification200Response;
  }

  @override
  void update(
    void Function(AuthResendVerification200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AuthResendVerification200Response build() => _build();

  _$AuthResendVerification200Response _build() {
    _$AuthResendVerification200Response _$result;
    try {
      _$result =
          _$v ??
          _$AuthResendVerification200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AuthResendVerification200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AuthResendVerification200Response',
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
          r'AuthResendVerification200Response',
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
