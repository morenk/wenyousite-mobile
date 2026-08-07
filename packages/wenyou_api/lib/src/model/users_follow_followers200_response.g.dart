// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_follow_followers200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UsersFollowFollowers200ResponseCodeEnum
_$usersFollowFollowers200ResponseCodeEnum_number0 =
    const UsersFollowFollowers200ResponseCodeEnum._('number0');
const UsersFollowFollowers200ResponseCodeEnum
_$usersFollowFollowers200ResponseCodeEnum_unknownDefaultOpenApi =
    const UsersFollowFollowers200ResponseCodeEnum._('unknownDefaultOpenApi');

UsersFollowFollowers200ResponseCodeEnum
_$usersFollowFollowers200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$usersFollowFollowers200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$usersFollowFollowers200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$usersFollowFollowers200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UsersFollowFollowers200ResponseCodeEnum>
_$usersFollowFollowers200ResponseCodeEnumValues =
    BuiltSet<UsersFollowFollowers200ResponseCodeEnum>(
      const <UsersFollowFollowers200ResponseCodeEnum>[
        _$usersFollowFollowers200ResponseCodeEnum_number0,
        _$usersFollowFollowers200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<UsersFollowFollowers200ResponseCodeEnum>
_$usersFollowFollowers200ResponseCodeEnumSerializer =
    _$UsersFollowFollowers200ResponseCodeEnumSerializer();

class _$UsersFollowFollowers200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<UsersFollowFollowers200ResponseCodeEnum> {
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
    UsersFollowFollowers200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'UsersFollowFollowers200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    UsersFollowFollowers200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UsersFollowFollowers200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UsersFollowFollowers200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UsersFollowFollowers200Response
    extends UsersFollowFollowers200Response {
  @override
  final BuiltList<UserFollowRecordResponseDto> data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$UsersFollowFollowers200Response([
    void Function(UsersFollowFollowers200ResponseBuilder)? updates,
  ]) => (UsersFollowFollowers200ResponseBuilder()..update(updates))._build();

  _$UsersFollowFollowers200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  UsersFollowFollowers200Response rebuild(
    void Function(UsersFollowFollowers200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UsersFollowFollowers200ResponseBuilder toBuilder() =>
      UsersFollowFollowers200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UsersFollowFollowers200Response &&
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
    return (newBuiltValueToStringHelper(r'UsersFollowFollowers200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class UsersFollowFollowers200ResponseBuilder
    implements
        Builder<
          UsersFollowFollowers200Response,
          UsersFollowFollowers200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$UsersFollowFollowers200Response? _$v;

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

  UsersFollowFollowers200ResponseBuilder() {
    UsersFollowFollowers200Response._defaults(this);
  }

  UsersFollowFollowers200ResponseBuilder get _$this {
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
  void replace(covariant UsersFollowFollowers200Response other) {
    _$v = other as _$UsersFollowFollowers200Response;
  }

  @override
  void update(void Function(UsersFollowFollowers200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UsersFollowFollowers200Response build() => _build();

  _$UsersFollowFollowers200Response _build() {
    _$UsersFollowFollowers200Response _$result;
    try {
      _$result =
          _$v ??
          _$UsersFollowFollowers200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'UsersFollowFollowers200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'UsersFollowFollowers200Response',
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
          r'UsersFollowFollowers200Response',
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
