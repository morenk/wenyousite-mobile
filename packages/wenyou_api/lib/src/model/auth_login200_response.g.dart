// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_login200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AuthLogin200ResponseCodeEnum _$authLogin200ResponseCodeEnum_number0 =
    const AuthLogin200ResponseCodeEnum._('number0');
const AuthLogin200ResponseCodeEnum
_$authLogin200ResponseCodeEnum_unknownDefaultOpenApi =
    const AuthLogin200ResponseCodeEnum._('unknownDefaultOpenApi');

AuthLogin200ResponseCodeEnum _$authLogin200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$authLogin200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$authLogin200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$authLogin200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AuthLogin200ResponseCodeEnum>
_$authLogin200ResponseCodeEnumValues =
    BuiltSet<AuthLogin200ResponseCodeEnum>(const <AuthLogin200ResponseCodeEnum>[
      _$authLogin200ResponseCodeEnum_number0,
      _$authLogin200ResponseCodeEnum_unknownDefaultOpenApi,
    ]);

Serializer<AuthLogin200ResponseCodeEnum>
_$authLogin200ResponseCodeEnumSerializer =
    _$AuthLogin200ResponseCodeEnumSerializer();

class _$AuthLogin200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AuthLogin200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[AuthLogin200ResponseCodeEnum];
  @override
  final String wireName = 'AuthLogin200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AuthLogin200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AuthLogin200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AuthLogin200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AuthLogin200Response extends AuthLogin200Response {
  @override
  final AuthResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AuthLogin200Response([
    void Function(AuthLogin200ResponseBuilder)? updates,
  ]) => (AuthLogin200ResponseBuilder()..update(updates))._build();

  _$AuthLogin200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AuthLogin200Response rebuild(
    void Function(AuthLogin200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AuthLogin200ResponseBuilder toBuilder() =>
      AuthLogin200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthLogin200Response &&
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
    return (newBuiltValueToStringHelper(r'AuthLogin200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AuthLogin200ResponseBuilder
    implements
        Builder<AuthLogin200Response, AuthLogin200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$AuthLogin200Response? _$v;

  AuthResponseDtoBuilder? _data;
  AuthResponseDtoBuilder get data => _$this._data ??= AuthResponseDtoBuilder();
  set data(covariant AuthResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AuthLogin200ResponseBuilder() {
    AuthLogin200Response._defaults(this);
  }

  AuthLogin200ResponseBuilder get _$this {
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
  void replace(covariant AuthLogin200Response other) {
    _$v = other as _$AuthLogin200Response;
  }

  @override
  void update(void Function(AuthLogin200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthLogin200Response build() => _build();

  _$AuthLogin200Response _build() {
    _$AuthLogin200Response _$result;
    try {
      _$result =
          _$v ??
          _$AuthLogin200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AuthLogin200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AuthLogin200Response',
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
          r'AuthLogin200Response',
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
