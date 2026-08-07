// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_get_user200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UsersGetUser200ResponseCodeEnum
_$usersGetUser200ResponseCodeEnum_number0 =
    const UsersGetUser200ResponseCodeEnum._('number0');
const UsersGetUser200ResponseCodeEnum
_$usersGetUser200ResponseCodeEnum_unknownDefaultOpenApi =
    const UsersGetUser200ResponseCodeEnum._('unknownDefaultOpenApi');

UsersGetUser200ResponseCodeEnum _$usersGetUser200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$usersGetUser200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$usersGetUser200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$usersGetUser200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UsersGetUser200ResponseCodeEnum>
_$usersGetUser200ResponseCodeEnumValues =
    BuiltSet<UsersGetUser200ResponseCodeEnum>(
      const <UsersGetUser200ResponseCodeEnum>[
        _$usersGetUser200ResponseCodeEnum_number0,
        _$usersGetUser200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<UsersGetUser200ResponseCodeEnum>
_$usersGetUser200ResponseCodeEnumSerializer =
    _$UsersGetUser200ResponseCodeEnumSerializer();

class _$UsersGetUser200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<UsersGetUser200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[UsersGetUser200ResponseCodeEnum];
  @override
  final String wireName = 'UsersGetUser200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    UsersGetUser200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UsersGetUser200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UsersGetUser200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UsersGetUser200Response extends UsersGetUser200Response {
  @override
  final PublicUserResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$UsersGetUser200Response([
    void Function(UsersGetUser200ResponseBuilder)? updates,
  ]) => (UsersGetUser200ResponseBuilder()..update(updates))._build();

  _$UsersGetUser200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  UsersGetUser200Response rebuild(
    void Function(UsersGetUser200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UsersGetUser200ResponseBuilder toBuilder() =>
      UsersGetUser200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UsersGetUser200Response &&
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
    return (newBuiltValueToStringHelper(r'UsersGetUser200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class UsersGetUser200ResponseBuilder
    implements
        Builder<UsersGetUser200Response, UsersGetUser200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$UsersGetUser200Response? _$v;

  PublicUserResponseDtoBuilder? _data;
  PublicUserResponseDtoBuilder get data =>
      _$this._data ??= PublicUserResponseDtoBuilder();
  set data(covariant PublicUserResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  UsersGetUser200ResponseBuilder() {
    UsersGetUser200Response._defaults(this);
  }

  UsersGetUser200ResponseBuilder get _$this {
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
  void replace(covariant UsersGetUser200Response other) {
    _$v = other as _$UsersGetUser200Response;
  }

  @override
  void update(void Function(UsersGetUser200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UsersGetUser200Response build() => _build();

  _$UsersGetUser200Response _build() {
    _$UsersGetUser200Response _$result;
    try {
      _$result =
          _$v ??
          _$UsersGetUser200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'UsersGetUser200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'UsersGetUser200Response',
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
          r'UsersGetUser200Response',
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
