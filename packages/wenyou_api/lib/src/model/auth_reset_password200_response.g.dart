// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_reset_password200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AuthResetPassword200ResponseCodeEnum
_$authResetPassword200ResponseCodeEnum_number0 =
    const AuthResetPassword200ResponseCodeEnum._('number0');
const AuthResetPassword200ResponseCodeEnum
_$authResetPassword200ResponseCodeEnum_unknownDefaultOpenApi =
    const AuthResetPassword200ResponseCodeEnum._('unknownDefaultOpenApi');

AuthResetPassword200ResponseCodeEnum
_$authResetPassword200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$authResetPassword200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$authResetPassword200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$authResetPassword200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AuthResetPassword200ResponseCodeEnum>
_$authResetPassword200ResponseCodeEnumValues =
    BuiltSet<AuthResetPassword200ResponseCodeEnum>(
      const <AuthResetPassword200ResponseCodeEnum>[
        _$authResetPassword200ResponseCodeEnum_number0,
        _$authResetPassword200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AuthResetPassword200ResponseCodeEnum>
_$authResetPassword200ResponseCodeEnumSerializer =
    _$AuthResetPassword200ResponseCodeEnumSerializer();

class _$AuthResetPassword200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AuthResetPassword200ResponseCodeEnum> {
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
    AuthResetPassword200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AuthResetPassword200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AuthResetPassword200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AuthResetPassword200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AuthResetPassword200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AuthResetPassword200Response extends AuthResetPassword200Response {
  @override
  final MessageResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AuthResetPassword200Response([
    void Function(AuthResetPassword200ResponseBuilder)? updates,
  ]) => (AuthResetPassword200ResponseBuilder()..update(updates))._build();

  _$AuthResetPassword200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AuthResetPassword200Response rebuild(
    void Function(AuthResetPassword200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AuthResetPassword200ResponseBuilder toBuilder() =>
      AuthResetPassword200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthResetPassword200Response &&
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
    return (newBuiltValueToStringHelper(r'AuthResetPassword200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AuthResetPassword200ResponseBuilder
    implements
        Builder<
          AuthResetPassword200Response,
          AuthResetPassword200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AuthResetPassword200Response? _$v;

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

  AuthResetPassword200ResponseBuilder() {
    AuthResetPassword200Response._defaults(this);
  }

  AuthResetPassword200ResponseBuilder get _$this {
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
  void replace(covariant AuthResetPassword200Response other) {
    _$v = other as _$AuthResetPassword200Response;
  }

  @override
  void update(void Function(AuthResetPassword200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthResetPassword200Response build() => _build();

  _$AuthResetPassword200Response _build() {
    _$AuthResetPassword200Response _$result;
    try {
      _$result =
          _$v ??
          _$AuthResetPassword200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AuthResetPassword200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AuthResetPassword200Response',
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
          r'AuthResetPassword200Response',
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
