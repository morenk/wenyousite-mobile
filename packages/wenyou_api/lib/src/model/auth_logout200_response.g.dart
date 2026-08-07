// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_logout200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AuthLogout200ResponseCodeEnum _$authLogout200ResponseCodeEnum_number0 =
    const AuthLogout200ResponseCodeEnum._('number0');
const AuthLogout200ResponseCodeEnum
_$authLogout200ResponseCodeEnum_unknownDefaultOpenApi =
    const AuthLogout200ResponseCodeEnum._('unknownDefaultOpenApi');

AuthLogout200ResponseCodeEnum _$authLogout200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$authLogout200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$authLogout200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$authLogout200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AuthLogout200ResponseCodeEnum>
_$authLogout200ResponseCodeEnumValues = BuiltSet<AuthLogout200ResponseCodeEnum>(
  const <AuthLogout200ResponseCodeEnum>[
    _$authLogout200ResponseCodeEnum_number0,
    _$authLogout200ResponseCodeEnum_unknownDefaultOpenApi,
  ],
);

Serializer<AuthLogout200ResponseCodeEnum>
_$authLogout200ResponseCodeEnumSerializer =
    _$AuthLogout200ResponseCodeEnumSerializer();

class _$AuthLogout200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AuthLogout200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[AuthLogout200ResponseCodeEnum];
  @override
  final String wireName = 'AuthLogout200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AuthLogout200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AuthLogout200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AuthLogout200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AuthLogout200Response extends AuthLogout200Response {
  @override
  final MessageResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AuthLogout200Response([
    void Function(AuthLogout200ResponseBuilder)? updates,
  ]) => (AuthLogout200ResponseBuilder()..update(updates))._build();

  _$AuthLogout200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AuthLogout200Response rebuild(
    void Function(AuthLogout200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AuthLogout200ResponseBuilder toBuilder() =>
      AuthLogout200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthLogout200Response &&
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
    return (newBuiltValueToStringHelper(r'AuthLogout200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AuthLogout200ResponseBuilder
    implements
        Builder<AuthLogout200Response, AuthLogout200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$AuthLogout200Response? _$v;

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

  AuthLogout200ResponseBuilder() {
    AuthLogout200Response._defaults(this);
  }

  AuthLogout200ResponseBuilder get _$this {
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
  void replace(covariant AuthLogout200Response other) {
    _$v = other as _$AuthLogout200Response;
  }

  @override
  void update(void Function(AuthLogout200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthLogout200Response build() => _build();

  _$AuthLogout200Response _build() {
    _$AuthLogout200Response _$result;
    try {
      _$result =
          _$v ??
          _$AuthLogout200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AuthLogout200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AuthLogout200Response',
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
          r'AuthLogout200Response',
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
