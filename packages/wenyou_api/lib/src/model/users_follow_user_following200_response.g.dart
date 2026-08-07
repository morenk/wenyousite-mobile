// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_follow_user_following200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UsersFollowUserFollowing200ResponseCodeEnum
_$usersFollowUserFollowing200ResponseCodeEnum_number0 =
    const UsersFollowUserFollowing200ResponseCodeEnum._('number0');
const UsersFollowUserFollowing200ResponseCodeEnum
_$usersFollowUserFollowing200ResponseCodeEnum_unknownDefaultOpenApi =
    const UsersFollowUserFollowing200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

UsersFollowUserFollowing200ResponseCodeEnum
_$usersFollowUserFollowing200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$usersFollowUserFollowing200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$usersFollowUserFollowing200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$usersFollowUserFollowing200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UsersFollowUserFollowing200ResponseCodeEnum>
_$usersFollowUserFollowing200ResponseCodeEnumValues =
    BuiltSet<UsersFollowUserFollowing200ResponseCodeEnum>(
      const <UsersFollowUserFollowing200ResponseCodeEnum>[
        _$usersFollowUserFollowing200ResponseCodeEnum_number0,
        _$usersFollowUserFollowing200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<UsersFollowUserFollowing200ResponseCodeEnum>
_$usersFollowUserFollowing200ResponseCodeEnumSerializer =
    _$UsersFollowUserFollowing200ResponseCodeEnumSerializer();

class _$UsersFollowUserFollowing200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<UsersFollowUserFollowing200ResponseCodeEnum> {
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
    UsersFollowUserFollowing200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'UsersFollowUserFollowing200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    UsersFollowUserFollowing200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UsersFollowUserFollowing200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UsersFollowUserFollowing200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UsersFollowUserFollowing200Response
    extends UsersFollowUserFollowing200Response {
  @override
  final BuiltList<UserFollowRecordResponseDto> data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$UsersFollowUserFollowing200Response([
    void Function(UsersFollowUserFollowing200ResponseBuilder)? updates,
  ]) =>
      (UsersFollowUserFollowing200ResponseBuilder()..update(updates))._build();

  _$UsersFollowUserFollowing200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  UsersFollowUserFollowing200Response rebuild(
    void Function(UsersFollowUserFollowing200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UsersFollowUserFollowing200ResponseBuilder toBuilder() =>
      UsersFollowUserFollowing200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UsersFollowUserFollowing200Response &&
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
    return (newBuiltValueToStringHelper(r'UsersFollowUserFollowing200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class UsersFollowUserFollowing200ResponseBuilder
    implements
        Builder<
          UsersFollowUserFollowing200Response,
          UsersFollowUserFollowing200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$UsersFollowUserFollowing200Response? _$v;

  ListBuilder<UserFollowRecordResponseDto>? _data;
  ListBuilder<UserFollowRecordResponseDto> get data =>
      _$this._data ??= ListBuilder<UserFollowRecordResponseDto>();
  set data(covariant ListBuilder<UserFollowRecordResponseDto>? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  UsersFollowUserFollowing200ResponseBuilder() {
    UsersFollowUserFollowing200Response._defaults(this);
  }

  UsersFollowUserFollowing200ResponseBuilder get _$this {
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
  void replace(covariant UsersFollowUserFollowing200Response other) {
    _$v = other as _$UsersFollowUserFollowing200Response;
  }

  @override
  void update(
    void Function(UsersFollowUserFollowing200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  UsersFollowUserFollowing200Response build() => _build();

  _$UsersFollowUserFollowing200Response _build() {
    _$UsersFollowUserFollowing200Response _$result;
    try {
      _$result =
          _$v ??
          _$UsersFollowUserFollowing200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'UsersFollowUserFollowing200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'UsersFollowUserFollowing200Response',
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
          r'UsersFollowUserFollowing200Response',
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
