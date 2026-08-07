// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_follow_user_followers200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UsersFollowUserFollowers200ResponseCodeEnum
_$usersFollowUserFollowers200ResponseCodeEnum_number0 =
    const UsersFollowUserFollowers200ResponseCodeEnum._('number0');
const UsersFollowUserFollowers200ResponseCodeEnum
_$usersFollowUserFollowers200ResponseCodeEnum_unknownDefaultOpenApi =
    const UsersFollowUserFollowers200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

UsersFollowUserFollowers200ResponseCodeEnum
_$usersFollowUserFollowers200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$usersFollowUserFollowers200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$usersFollowUserFollowers200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$usersFollowUserFollowers200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UsersFollowUserFollowers200ResponseCodeEnum>
_$usersFollowUserFollowers200ResponseCodeEnumValues =
    BuiltSet<UsersFollowUserFollowers200ResponseCodeEnum>(
      const <UsersFollowUserFollowers200ResponseCodeEnum>[
        _$usersFollowUserFollowers200ResponseCodeEnum_number0,
        _$usersFollowUserFollowers200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<UsersFollowUserFollowers200ResponseCodeEnum>
_$usersFollowUserFollowers200ResponseCodeEnumSerializer =
    _$UsersFollowUserFollowers200ResponseCodeEnumSerializer();

class _$UsersFollowUserFollowers200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<UsersFollowUserFollowers200ResponseCodeEnum> {
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
    UsersFollowUserFollowers200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'UsersFollowUserFollowers200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    UsersFollowUserFollowers200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UsersFollowUserFollowers200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UsersFollowUserFollowers200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UsersFollowUserFollowers200Response
    extends UsersFollowUserFollowers200Response {
  @override
  final BuiltList<UserFollowRecordResponseDto> data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$UsersFollowUserFollowers200Response([
    void Function(UsersFollowUserFollowers200ResponseBuilder)? updates,
  ]) =>
      (UsersFollowUserFollowers200ResponseBuilder()..update(updates))._build();

  _$UsersFollowUserFollowers200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  UsersFollowUserFollowers200Response rebuild(
    void Function(UsersFollowUserFollowers200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UsersFollowUserFollowers200ResponseBuilder toBuilder() =>
      UsersFollowUserFollowers200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UsersFollowUserFollowers200Response &&
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
    return (newBuiltValueToStringHelper(r'UsersFollowUserFollowers200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class UsersFollowUserFollowers200ResponseBuilder
    implements
        Builder<
          UsersFollowUserFollowers200Response,
          UsersFollowUserFollowers200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$UsersFollowUserFollowers200Response? _$v;

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

  UsersFollowUserFollowers200ResponseBuilder() {
    UsersFollowUserFollowers200Response._defaults(this);
  }

  UsersFollowUserFollowers200ResponseBuilder get _$this {
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
  void replace(covariant UsersFollowUserFollowers200Response other) {
    _$v = other as _$UsersFollowUserFollowers200Response;
  }

  @override
  void update(
    void Function(UsersFollowUserFollowers200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  UsersFollowUserFollowers200Response build() => _build();

  _$UsersFollowUserFollowers200Response _build() {
    _$UsersFollowUserFollowers200Response _$result;
    try {
      _$result =
          _$v ??
          _$UsersFollowUserFollowers200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'UsersFollowUserFollowers200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'UsersFollowUserFollowers200Response',
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
          r'UsersFollowUserFollowers200Response',
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
