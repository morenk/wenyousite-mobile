// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_set_avatar200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UsersSetAvatar200ResponseCodeEnum
_$usersSetAvatar200ResponseCodeEnum_number0 =
    const UsersSetAvatar200ResponseCodeEnum._('number0');
const UsersSetAvatar200ResponseCodeEnum
_$usersSetAvatar200ResponseCodeEnum_unknownDefaultOpenApi =
    const UsersSetAvatar200ResponseCodeEnum._('unknownDefaultOpenApi');

UsersSetAvatar200ResponseCodeEnum _$usersSetAvatar200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$usersSetAvatar200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$usersSetAvatar200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$usersSetAvatar200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UsersSetAvatar200ResponseCodeEnum>
_$usersSetAvatar200ResponseCodeEnumValues =
    BuiltSet<UsersSetAvatar200ResponseCodeEnum>(
      const <UsersSetAvatar200ResponseCodeEnum>[
        _$usersSetAvatar200ResponseCodeEnum_number0,
        _$usersSetAvatar200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<UsersSetAvatar200ResponseCodeEnum>
_$usersSetAvatar200ResponseCodeEnumSerializer =
    _$UsersSetAvatar200ResponseCodeEnumSerializer();

class _$UsersSetAvatar200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<UsersSetAvatar200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[UsersSetAvatar200ResponseCodeEnum];
  @override
  final String wireName = 'UsersSetAvatar200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    UsersSetAvatar200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UsersSetAvatar200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UsersSetAvatar200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UsersSetAvatar200Response extends UsersSetAvatar200Response {
  @override
  final PrivateUserResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$UsersSetAvatar200Response([
    void Function(UsersSetAvatar200ResponseBuilder)? updates,
  ]) => (UsersSetAvatar200ResponseBuilder()..update(updates))._build();

  _$UsersSetAvatar200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  UsersSetAvatar200Response rebuild(
    void Function(UsersSetAvatar200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UsersSetAvatar200ResponseBuilder toBuilder() =>
      UsersSetAvatar200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UsersSetAvatar200Response &&
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
    return (newBuiltValueToStringHelper(r'UsersSetAvatar200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class UsersSetAvatar200ResponseBuilder
    implements
        Builder<UsersSetAvatar200Response, UsersSetAvatar200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$UsersSetAvatar200Response? _$v;

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

  UsersSetAvatar200ResponseBuilder() {
    UsersSetAvatar200Response._defaults(this);
  }

  UsersSetAvatar200ResponseBuilder get _$this {
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
  void replace(covariant UsersSetAvatar200Response other) {
    _$v = other as _$UsersSetAvatar200Response;
  }

  @override
  void update(void Function(UsersSetAvatar200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UsersSetAvatar200Response build() => _build();

  _$UsersSetAvatar200Response _build() {
    _$UsersSetAvatar200Response _$result;
    try {
      _$result =
          _$v ??
          _$UsersSetAvatar200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'UsersSetAvatar200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'UsersSetAvatar200Response',
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
          r'UsersSetAvatar200Response',
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
