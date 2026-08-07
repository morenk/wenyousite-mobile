// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_change_password200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AuthChangePassword200ResponseCodeEnum
_$authChangePassword200ResponseCodeEnum_number0 =
    const AuthChangePassword200ResponseCodeEnum._('number0');
const AuthChangePassword200ResponseCodeEnum
_$authChangePassword200ResponseCodeEnum_unknownDefaultOpenApi =
    const AuthChangePassword200ResponseCodeEnum._('unknownDefaultOpenApi');

AuthChangePassword200ResponseCodeEnum
_$authChangePassword200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$authChangePassword200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$authChangePassword200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$authChangePassword200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AuthChangePassword200ResponseCodeEnum>
_$authChangePassword200ResponseCodeEnumValues =
    BuiltSet<AuthChangePassword200ResponseCodeEnum>(
      const <AuthChangePassword200ResponseCodeEnum>[
        _$authChangePassword200ResponseCodeEnum_number0,
        _$authChangePassword200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AuthChangePassword200ResponseCodeEnum>
_$authChangePassword200ResponseCodeEnumSerializer =
    _$AuthChangePassword200ResponseCodeEnumSerializer();

class _$AuthChangePassword200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AuthChangePassword200ResponseCodeEnum> {
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
    AuthChangePassword200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AuthChangePassword200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AuthChangePassword200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AuthChangePassword200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AuthChangePassword200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AuthChangePassword200Response extends AuthChangePassword200Response {
  @override
  final MessageResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AuthChangePassword200Response([
    void Function(AuthChangePassword200ResponseBuilder)? updates,
  ]) => (AuthChangePassword200ResponseBuilder()..update(updates))._build();

  _$AuthChangePassword200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AuthChangePassword200Response rebuild(
    void Function(AuthChangePassword200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AuthChangePassword200ResponseBuilder toBuilder() =>
      AuthChangePassword200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthChangePassword200Response &&
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
    return (newBuiltValueToStringHelper(r'AuthChangePassword200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AuthChangePassword200ResponseBuilder
    implements
        Builder<
          AuthChangePassword200Response,
          AuthChangePassword200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AuthChangePassword200Response? _$v;

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

  AuthChangePassword200ResponseBuilder() {
    AuthChangePassword200Response._defaults(this);
  }

  AuthChangePassword200ResponseBuilder get _$this {
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
  void replace(covariant AuthChangePassword200Response other) {
    _$v = other as _$AuthChangePassword200Response;
  }

  @override
  void update(void Function(AuthChangePassword200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthChangePassword200Response build() => _build();

  _$AuthChangePassword200Response _build() {
    _$AuthChangePassword200Response _$result;
    try {
      _$result =
          _$v ??
          _$AuthChangePassword200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AuthChangePassword200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AuthChangePassword200Response',
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
          r'AuthChangePassword200Response',
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
