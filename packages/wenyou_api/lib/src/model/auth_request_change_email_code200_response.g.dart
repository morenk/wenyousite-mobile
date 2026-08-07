// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_request_change_email_code200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AuthRequestChangeEmailCode200ResponseCodeEnum
_$authRequestChangeEmailCode200ResponseCodeEnum_number0 =
    const AuthRequestChangeEmailCode200ResponseCodeEnum._('number0');
const AuthRequestChangeEmailCode200ResponseCodeEnum
_$authRequestChangeEmailCode200ResponseCodeEnum_unknownDefaultOpenApi =
    const AuthRequestChangeEmailCode200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

AuthRequestChangeEmailCode200ResponseCodeEnum
_$authRequestChangeEmailCode200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$authRequestChangeEmailCode200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$authRequestChangeEmailCode200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$authRequestChangeEmailCode200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AuthRequestChangeEmailCode200ResponseCodeEnum>
_$authRequestChangeEmailCode200ResponseCodeEnumValues =
    BuiltSet<AuthRequestChangeEmailCode200ResponseCodeEnum>(
      const <AuthRequestChangeEmailCode200ResponseCodeEnum>[
        _$authRequestChangeEmailCode200ResponseCodeEnum_number0,
        _$authRequestChangeEmailCode200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AuthRequestChangeEmailCode200ResponseCodeEnum>
_$authRequestChangeEmailCode200ResponseCodeEnumSerializer =
    _$AuthRequestChangeEmailCode200ResponseCodeEnumSerializer();

class _$AuthRequestChangeEmailCode200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<AuthRequestChangeEmailCode200ResponseCodeEnum> {
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
    AuthRequestChangeEmailCode200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AuthRequestChangeEmailCode200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AuthRequestChangeEmailCode200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AuthRequestChangeEmailCode200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AuthRequestChangeEmailCode200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AuthRequestChangeEmailCode200Response
    extends AuthRequestChangeEmailCode200Response {
  @override
  final MessageResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AuthRequestChangeEmailCode200Response([
    void Function(AuthRequestChangeEmailCode200ResponseBuilder)? updates,
  ]) => (AuthRequestChangeEmailCode200ResponseBuilder()..update(updates))
      ._build();

  _$AuthRequestChangeEmailCode200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AuthRequestChangeEmailCode200Response rebuild(
    void Function(AuthRequestChangeEmailCode200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AuthRequestChangeEmailCode200ResponseBuilder toBuilder() =>
      AuthRequestChangeEmailCode200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthRequestChangeEmailCode200Response &&
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
    return (newBuiltValueToStringHelper(
            r'AuthRequestChangeEmailCode200Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AuthRequestChangeEmailCode200ResponseBuilder
    implements
        Builder<
          AuthRequestChangeEmailCode200Response,
          AuthRequestChangeEmailCode200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AuthRequestChangeEmailCode200Response? _$v;

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

  AuthRequestChangeEmailCode200ResponseBuilder() {
    AuthRequestChangeEmailCode200Response._defaults(this);
  }

  AuthRequestChangeEmailCode200ResponseBuilder get _$this {
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
  void replace(covariant AuthRequestChangeEmailCode200Response other) {
    _$v = other as _$AuthRequestChangeEmailCode200Response;
  }

  @override
  void update(
    void Function(AuthRequestChangeEmailCode200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AuthRequestChangeEmailCode200Response build() => _build();

  _$AuthRequestChangeEmailCode200Response _build() {
    _$AuthRequestChangeEmailCode200Response _$result;
    try {
      _$result =
          _$v ??
          _$AuthRequestChangeEmailCode200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AuthRequestChangeEmailCode200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AuthRequestChangeEmailCode200Response',
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
          r'AuthRequestChangeEmailCode200Response',
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
