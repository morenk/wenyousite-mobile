// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_follow_following200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UsersFollowFollowing200ResponseCodeEnum
_$usersFollowFollowing200ResponseCodeEnum_number0 =
    const UsersFollowFollowing200ResponseCodeEnum._('number0');
const UsersFollowFollowing200ResponseCodeEnum
_$usersFollowFollowing200ResponseCodeEnum_unknownDefaultOpenApi =
    const UsersFollowFollowing200ResponseCodeEnum._('unknownDefaultOpenApi');

UsersFollowFollowing200ResponseCodeEnum
_$usersFollowFollowing200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$usersFollowFollowing200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$usersFollowFollowing200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$usersFollowFollowing200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UsersFollowFollowing200ResponseCodeEnum>
_$usersFollowFollowing200ResponseCodeEnumValues =
    BuiltSet<UsersFollowFollowing200ResponseCodeEnum>(
      const <UsersFollowFollowing200ResponseCodeEnum>[
        _$usersFollowFollowing200ResponseCodeEnum_number0,
        _$usersFollowFollowing200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<UsersFollowFollowing200ResponseCodeEnum>
_$usersFollowFollowing200ResponseCodeEnumSerializer =
    _$UsersFollowFollowing200ResponseCodeEnumSerializer();

class _$UsersFollowFollowing200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<UsersFollowFollowing200ResponseCodeEnum> {
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
    UsersFollowFollowing200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'UsersFollowFollowing200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    UsersFollowFollowing200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UsersFollowFollowing200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UsersFollowFollowing200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UsersFollowFollowing200Response
    extends UsersFollowFollowing200Response {
  @override
  final BuiltList<UserFollowRecordResponseDto> data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$UsersFollowFollowing200Response([
    void Function(UsersFollowFollowing200ResponseBuilder)? updates,
  ]) => (UsersFollowFollowing200ResponseBuilder()..update(updates))._build();

  _$UsersFollowFollowing200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  UsersFollowFollowing200Response rebuild(
    void Function(UsersFollowFollowing200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UsersFollowFollowing200ResponseBuilder toBuilder() =>
      UsersFollowFollowing200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UsersFollowFollowing200Response &&
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
    return (newBuiltValueToStringHelper(r'UsersFollowFollowing200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class UsersFollowFollowing200ResponseBuilder
    implements
        Builder<
          UsersFollowFollowing200Response,
          UsersFollowFollowing200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$UsersFollowFollowing200Response? _$v;

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

  UsersFollowFollowing200ResponseBuilder() {
    UsersFollowFollowing200Response._defaults(this);
  }

  UsersFollowFollowing200ResponseBuilder get _$this {
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
  void replace(covariant UsersFollowFollowing200Response other) {
    _$v = other as _$UsersFollowFollowing200Response;
  }

  @override
  void update(void Function(UsersFollowFollowing200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UsersFollowFollowing200Response build() => _build();

  _$UsersFollowFollowing200Response _build() {
    _$UsersFollowFollowing200Response _$result;
    try {
      _$result =
          _$v ??
          _$UsersFollowFollowing200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'UsersFollowFollowing200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'UsersFollowFollowing200Response',
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
          r'UsersFollowFollowing200Response',
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
