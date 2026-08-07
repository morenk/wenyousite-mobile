// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_revoke_session200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AuthRevokeSession200ResponseCodeEnum
_$authRevokeSession200ResponseCodeEnum_number0 =
    const AuthRevokeSession200ResponseCodeEnum._('number0');
const AuthRevokeSession200ResponseCodeEnum
_$authRevokeSession200ResponseCodeEnum_unknownDefaultOpenApi =
    const AuthRevokeSession200ResponseCodeEnum._('unknownDefaultOpenApi');

AuthRevokeSession200ResponseCodeEnum
_$authRevokeSession200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$authRevokeSession200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$authRevokeSession200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$authRevokeSession200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AuthRevokeSession200ResponseCodeEnum>
_$authRevokeSession200ResponseCodeEnumValues =
    BuiltSet<AuthRevokeSession200ResponseCodeEnum>(
      const <AuthRevokeSession200ResponseCodeEnum>[
        _$authRevokeSession200ResponseCodeEnum_number0,
        _$authRevokeSession200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AuthRevokeSession200ResponseCodeEnum>
_$authRevokeSession200ResponseCodeEnumSerializer =
    _$AuthRevokeSession200ResponseCodeEnumSerializer();

class _$AuthRevokeSession200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AuthRevokeSession200ResponseCodeEnum> {
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
    AuthRevokeSession200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AuthRevokeSession200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AuthRevokeSession200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AuthRevokeSession200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AuthRevokeSession200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AuthRevokeSession200Response extends AuthRevokeSession200Response {
  @override
  final RevokeSessionResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AuthRevokeSession200Response([
    void Function(AuthRevokeSession200ResponseBuilder)? updates,
  ]) => (AuthRevokeSession200ResponseBuilder()..update(updates))._build();

  _$AuthRevokeSession200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AuthRevokeSession200Response rebuild(
    void Function(AuthRevokeSession200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AuthRevokeSession200ResponseBuilder toBuilder() =>
      AuthRevokeSession200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthRevokeSession200Response &&
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
    return (newBuiltValueToStringHelper(r'AuthRevokeSession200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AuthRevokeSession200ResponseBuilder
    implements
        Builder<
          AuthRevokeSession200Response,
          AuthRevokeSession200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AuthRevokeSession200Response? _$v;

  RevokeSessionResponseDtoBuilder? _data;
  RevokeSessionResponseDtoBuilder get data =>
      _$this._data ??= RevokeSessionResponseDtoBuilder();
  set data(covariant RevokeSessionResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AuthRevokeSession200ResponseBuilder() {
    AuthRevokeSession200Response._defaults(this);
  }

  AuthRevokeSession200ResponseBuilder get _$this {
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
  void replace(covariant AuthRevokeSession200Response other) {
    _$v = other as _$AuthRevokeSession200Response;
  }

  @override
  void update(void Function(AuthRevokeSession200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthRevokeSession200Response build() => _build();

  _$AuthRevokeSession200Response _build() {
    _$AuthRevokeSession200Response _$result;
    try {
      _$result =
          _$v ??
          _$AuthRevokeSession200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AuthRevokeSession200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AuthRevokeSession200Response',
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
          r'AuthRevokeSession200Response',
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
