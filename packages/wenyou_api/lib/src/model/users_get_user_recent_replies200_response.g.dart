// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_get_user_recent_replies200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UsersGetUserRecentReplies200ResponseCodeEnum
_$usersGetUserRecentReplies200ResponseCodeEnum_number0 =
    const UsersGetUserRecentReplies200ResponseCodeEnum._('number0');
const UsersGetUserRecentReplies200ResponseCodeEnum
_$usersGetUserRecentReplies200ResponseCodeEnum_unknownDefaultOpenApi =
    const UsersGetUserRecentReplies200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

UsersGetUserRecentReplies200ResponseCodeEnum
_$usersGetUserRecentReplies200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$usersGetUserRecentReplies200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$usersGetUserRecentReplies200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$usersGetUserRecentReplies200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UsersGetUserRecentReplies200ResponseCodeEnum>
_$usersGetUserRecentReplies200ResponseCodeEnumValues =
    BuiltSet<UsersGetUserRecentReplies200ResponseCodeEnum>(
      const <UsersGetUserRecentReplies200ResponseCodeEnum>[
        _$usersGetUserRecentReplies200ResponseCodeEnum_number0,
        _$usersGetUserRecentReplies200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<UsersGetUserRecentReplies200ResponseCodeEnum>
_$usersGetUserRecentReplies200ResponseCodeEnumSerializer =
    _$UsersGetUserRecentReplies200ResponseCodeEnumSerializer();

class _$UsersGetUserRecentReplies200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<UsersGetUserRecentReplies200ResponseCodeEnum> {
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
    UsersGetUserRecentReplies200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'UsersGetUserRecentReplies200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    UsersGetUserRecentReplies200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UsersGetUserRecentReplies200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UsersGetUserRecentReplies200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UsersGetUserRecentReplies200Response
    extends UsersGetUserRecentReplies200Response {
  @override
  final BuiltList<RecentReplyResponseDto> data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$UsersGetUserRecentReplies200Response([
    void Function(UsersGetUserRecentReplies200ResponseBuilder)? updates,
  ]) =>
      (UsersGetUserRecentReplies200ResponseBuilder()..update(updates))._build();

  _$UsersGetUserRecentReplies200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  UsersGetUserRecentReplies200Response rebuild(
    void Function(UsersGetUserRecentReplies200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UsersGetUserRecentReplies200ResponseBuilder toBuilder() =>
      UsersGetUserRecentReplies200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UsersGetUserRecentReplies200Response &&
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
    return (newBuiltValueToStringHelper(r'UsersGetUserRecentReplies200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class UsersGetUserRecentReplies200ResponseBuilder
    implements
        Builder<
          UsersGetUserRecentReplies200Response,
          UsersGetUserRecentReplies200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$UsersGetUserRecentReplies200Response? _$v;

  ListBuilder<RecentReplyResponseDto>? _data;
  ListBuilder<RecentReplyResponseDto> get data =>
      _$this._data ??= ListBuilder<RecentReplyResponseDto>();
  set data(covariant ListBuilder<RecentReplyResponseDto>? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  UsersGetUserRecentReplies200ResponseBuilder() {
    UsersGetUserRecentReplies200Response._defaults(this);
  }

  UsersGetUserRecentReplies200ResponseBuilder get _$this {
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
  void replace(covariant UsersGetUserRecentReplies200Response other) {
    _$v = other as _$UsersGetUserRecentReplies200Response;
  }

  @override
  void update(
    void Function(UsersGetUserRecentReplies200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  UsersGetUserRecentReplies200Response build() => _build();

  _$UsersGetUserRecentReplies200Response _build() {
    _$UsersGetUserRecentReplies200Response _$result;
    try {
      _$result =
          _$v ??
          _$UsersGetUserRecentReplies200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'UsersGetUserRecentReplies200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'UsersGetUserRecentReplies200Response',
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
          r'UsersGetUserRecentReplies200Response',
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
