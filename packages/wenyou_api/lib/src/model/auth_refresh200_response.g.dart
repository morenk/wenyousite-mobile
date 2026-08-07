// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_refresh200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AuthRefresh200ResponseCodeEnum _$authRefresh200ResponseCodeEnum_number0 =
    const AuthRefresh200ResponseCodeEnum._('number0');
const AuthRefresh200ResponseCodeEnum
_$authRefresh200ResponseCodeEnum_unknownDefaultOpenApi =
    const AuthRefresh200ResponseCodeEnum._('unknownDefaultOpenApi');

AuthRefresh200ResponseCodeEnum _$authRefresh200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$authRefresh200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$authRefresh200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$authRefresh200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AuthRefresh200ResponseCodeEnum>
_$authRefresh200ResponseCodeEnumValues =
    BuiltSet<AuthRefresh200ResponseCodeEnum>(
      const <AuthRefresh200ResponseCodeEnum>[
        _$authRefresh200ResponseCodeEnum_number0,
        _$authRefresh200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AuthRefresh200ResponseCodeEnum>
_$authRefresh200ResponseCodeEnumSerializer =
    _$AuthRefresh200ResponseCodeEnumSerializer();

class _$AuthRefresh200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AuthRefresh200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[AuthRefresh200ResponseCodeEnum];
  @override
  final String wireName = 'AuthRefresh200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AuthRefresh200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AuthRefresh200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AuthRefresh200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AuthRefresh200Response extends AuthRefresh200Response {
  @override
  final AuthResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AuthRefresh200Response([
    void Function(AuthRefresh200ResponseBuilder)? updates,
  ]) => (AuthRefresh200ResponseBuilder()..update(updates))._build();

  _$AuthRefresh200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AuthRefresh200Response rebuild(
    void Function(AuthRefresh200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AuthRefresh200ResponseBuilder toBuilder() =>
      AuthRefresh200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthRefresh200Response &&
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
    return (newBuiltValueToStringHelper(r'AuthRefresh200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AuthRefresh200ResponseBuilder
    implements
        Builder<AuthRefresh200Response, AuthRefresh200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$AuthRefresh200Response? _$v;

  AuthResponseDtoBuilder? _data;
  AuthResponseDtoBuilder get data => _$this._data ??= AuthResponseDtoBuilder();
  set data(covariant AuthResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AuthRefresh200ResponseBuilder() {
    AuthRefresh200Response._defaults(this);
  }

  AuthRefresh200ResponseBuilder get _$this {
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
  void replace(covariant AuthRefresh200Response other) {
    _$v = other as _$AuthRefresh200Response;
  }

  @override
  void update(void Function(AuthRefresh200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthRefresh200Response build() => _build();

  _$AuthRefresh200Response _build() {
    _$AuthRefresh200Response _$result;
    try {
      _$result =
          _$v ??
          _$AuthRefresh200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AuthRefresh200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AuthRefresh200Response',
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
          r'AuthRefresh200Response',
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
