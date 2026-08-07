// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_remove_avatar200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UsersRemoveAvatar200ResponseCodeEnum
_$usersRemoveAvatar200ResponseCodeEnum_number0 =
    const UsersRemoveAvatar200ResponseCodeEnum._('number0');
const UsersRemoveAvatar200ResponseCodeEnum
_$usersRemoveAvatar200ResponseCodeEnum_unknownDefaultOpenApi =
    const UsersRemoveAvatar200ResponseCodeEnum._('unknownDefaultOpenApi');

UsersRemoveAvatar200ResponseCodeEnum
_$usersRemoveAvatar200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$usersRemoveAvatar200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$usersRemoveAvatar200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$usersRemoveAvatar200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UsersRemoveAvatar200ResponseCodeEnum>
_$usersRemoveAvatar200ResponseCodeEnumValues =
    BuiltSet<UsersRemoveAvatar200ResponseCodeEnum>(
      const <UsersRemoveAvatar200ResponseCodeEnum>[
        _$usersRemoveAvatar200ResponseCodeEnum_number0,
        _$usersRemoveAvatar200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<UsersRemoveAvatar200ResponseCodeEnum>
_$usersRemoveAvatar200ResponseCodeEnumSerializer =
    _$UsersRemoveAvatar200ResponseCodeEnumSerializer();

class _$UsersRemoveAvatar200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<UsersRemoveAvatar200ResponseCodeEnum> {
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
    UsersRemoveAvatar200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'UsersRemoveAvatar200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    UsersRemoveAvatar200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UsersRemoveAvatar200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UsersRemoveAvatar200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UsersRemoveAvatar200Response extends UsersRemoveAvatar200Response {
  @override
  final PrivateUserResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$UsersRemoveAvatar200Response([
    void Function(UsersRemoveAvatar200ResponseBuilder)? updates,
  ]) => (UsersRemoveAvatar200ResponseBuilder()..update(updates))._build();

  _$UsersRemoveAvatar200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  UsersRemoveAvatar200Response rebuild(
    void Function(UsersRemoveAvatar200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UsersRemoveAvatar200ResponseBuilder toBuilder() =>
      UsersRemoveAvatar200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UsersRemoveAvatar200Response &&
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
    return (newBuiltValueToStringHelper(r'UsersRemoveAvatar200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class UsersRemoveAvatar200ResponseBuilder
    implements
        Builder<
          UsersRemoveAvatar200Response,
          UsersRemoveAvatar200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$UsersRemoveAvatar200Response? _$v;

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

  UsersRemoveAvatar200ResponseBuilder() {
    UsersRemoveAvatar200Response._defaults(this);
  }

  UsersRemoveAvatar200ResponseBuilder get _$this {
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
  void replace(covariant UsersRemoveAvatar200Response other) {
    _$v = other as _$UsersRemoveAvatar200Response;
  }

  @override
  void update(void Function(UsersRemoveAvatar200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UsersRemoveAvatar200Response build() => _build();

  _$UsersRemoveAvatar200Response _build() {
    _$UsersRemoveAvatar200Response _$result;
    try {
      _$result =
          _$v ??
          _$UsersRemoveAvatar200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'UsersRemoveAvatar200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'UsersRemoveAvatar200Response',
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
          r'UsersRemoveAvatar200Response',
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
