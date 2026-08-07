// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_update_me200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UsersUpdateMe200ResponseCodeEnum
_$usersUpdateMe200ResponseCodeEnum_number0 =
    const UsersUpdateMe200ResponseCodeEnum._('number0');
const UsersUpdateMe200ResponseCodeEnum
_$usersUpdateMe200ResponseCodeEnum_unknownDefaultOpenApi =
    const UsersUpdateMe200ResponseCodeEnum._('unknownDefaultOpenApi');

UsersUpdateMe200ResponseCodeEnum _$usersUpdateMe200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$usersUpdateMe200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$usersUpdateMe200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$usersUpdateMe200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UsersUpdateMe200ResponseCodeEnum>
_$usersUpdateMe200ResponseCodeEnumValues =
    BuiltSet<UsersUpdateMe200ResponseCodeEnum>(
      const <UsersUpdateMe200ResponseCodeEnum>[
        _$usersUpdateMe200ResponseCodeEnum_number0,
        _$usersUpdateMe200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<UsersUpdateMe200ResponseCodeEnum>
_$usersUpdateMe200ResponseCodeEnumSerializer =
    _$UsersUpdateMe200ResponseCodeEnumSerializer();

class _$UsersUpdateMe200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<UsersUpdateMe200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[UsersUpdateMe200ResponseCodeEnum];
  @override
  final String wireName = 'UsersUpdateMe200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    UsersUpdateMe200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UsersUpdateMe200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UsersUpdateMe200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UsersUpdateMe200Response extends UsersUpdateMe200Response {
  @override
  final PrivateUserResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$UsersUpdateMe200Response([
    void Function(UsersUpdateMe200ResponseBuilder)? updates,
  ]) => (UsersUpdateMe200ResponseBuilder()..update(updates))._build();

  _$UsersUpdateMe200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  UsersUpdateMe200Response rebuild(
    void Function(UsersUpdateMe200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UsersUpdateMe200ResponseBuilder toBuilder() =>
      UsersUpdateMe200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UsersUpdateMe200Response &&
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
    return (newBuiltValueToStringHelper(r'UsersUpdateMe200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class UsersUpdateMe200ResponseBuilder
    implements
        Builder<UsersUpdateMe200Response, UsersUpdateMe200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$UsersUpdateMe200Response? _$v;

  PrivateUserResponseDtoBuilder? _data;
  PrivateUserResponseDtoBuilder get data =>
      _$this._data ??= PrivateUserResponseDtoBuilder();
  set data(covariant PrivateUserResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  UsersUpdateMe200ResponseBuilder() {
    UsersUpdateMe200Response._defaults(this);
  }

  UsersUpdateMe200ResponseBuilder get _$this {
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
  void replace(covariant UsersUpdateMe200Response other) {
    _$v = other as _$UsersUpdateMe200Response;
  }

  @override
  void update(void Function(UsersUpdateMe200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UsersUpdateMe200Response build() => _build();

  _$UsersUpdateMe200Response _build() {
    _$UsersUpdateMe200Response _$result;
    try {
      _$result =
          _$v ??
          _$UsersUpdateMe200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'UsersUpdateMe200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'UsersUpdateMe200Response',
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
          r'UsersUpdateMe200Response',
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
