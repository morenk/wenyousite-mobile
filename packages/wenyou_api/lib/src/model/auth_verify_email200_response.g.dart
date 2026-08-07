// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_verify_email200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AuthVerifyEmail200ResponseCodeEnum
_$authVerifyEmail200ResponseCodeEnum_number0 =
    const AuthVerifyEmail200ResponseCodeEnum._('number0');
const AuthVerifyEmail200ResponseCodeEnum
_$authVerifyEmail200ResponseCodeEnum_unknownDefaultOpenApi =
    const AuthVerifyEmail200ResponseCodeEnum._('unknownDefaultOpenApi');

AuthVerifyEmail200ResponseCodeEnum _$authVerifyEmail200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$authVerifyEmail200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$authVerifyEmail200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$authVerifyEmail200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AuthVerifyEmail200ResponseCodeEnum>
_$authVerifyEmail200ResponseCodeEnumValues =
    BuiltSet<AuthVerifyEmail200ResponseCodeEnum>(
      const <AuthVerifyEmail200ResponseCodeEnum>[
        _$authVerifyEmail200ResponseCodeEnum_number0,
        _$authVerifyEmail200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AuthVerifyEmail200ResponseCodeEnum>
_$authVerifyEmail200ResponseCodeEnumSerializer =
    _$AuthVerifyEmail200ResponseCodeEnumSerializer();

class _$AuthVerifyEmail200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AuthVerifyEmail200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[AuthVerifyEmail200ResponseCodeEnum];
  @override
  final String wireName = 'AuthVerifyEmail200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AuthVerifyEmail200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AuthVerifyEmail200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AuthVerifyEmail200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AuthVerifyEmail200Response extends AuthVerifyEmail200Response {
  @override
  final MessageResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AuthVerifyEmail200Response([
    void Function(AuthVerifyEmail200ResponseBuilder)? updates,
  ]) => (AuthVerifyEmail200ResponseBuilder()..update(updates))._build();

  _$AuthVerifyEmail200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AuthVerifyEmail200Response rebuild(
    void Function(AuthVerifyEmail200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AuthVerifyEmail200ResponseBuilder toBuilder() =>
      AuthVerifyEmail200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthVerifyEmail200Response &&
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
    return (newBuiltValueToStringHelper(r'AuthVerifyEmail200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AuthVerifyEmail200ResponseBuilder
    implements
        Builder<AuthVerifyEmail200Response, AuthVerifyEmail200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$AuthVerifyEmail200Response? _$v;

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

  AuthVerifyEmail200ResponseBuilder() {
    AuthVerifyEmail200Response._defaults(this);
  }

  AuthVerifyEmail200ResponseBuilder get _$this {
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
  void replace(covariant AuthVerifyEmail200Response other) {
    _$v = other as _$AuthVerifyEmail200Response;
  }

  @override
  void update(void Function(AuthVerifyEmail200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthVerifyEmail200Response build() => _build();

  _$AuthVerifyEmail200Response _build() {
    _$AuthVerifyEmail200Response _$result;
    try {
      _$result =
          _$v ??
          _$AuthVerifyEmail200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AuthVerifyEmail200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AuthVerifyEmail200Response',
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
          r'AuthVerifyEmail200Response',
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
