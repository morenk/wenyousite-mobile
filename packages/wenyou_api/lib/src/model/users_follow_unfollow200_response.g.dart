// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_follow_unfollow200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UsersFollowUnfollow200ResponseCodeEnum
_$usersFollowUnfollow200ResponseCodeEnum_number0 =
    const UsersFollowUnfollow200ResponseCodeEnum._('number0');
const UsersFollowUnfollow200ResponseCodeEnum
_$usersFollowUnfollow200ResponseCodeEnum_unknownDefaultOpenApi =
    const UsersFollowUnfollow200ResponseCodeEnum._('unknownDefaultOpenApi');

UsersFollowUnfollow200ResponseCodeEnum
_$usersFollowUnfollow200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$usersFollowUnfollow200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$usersFollowUnfollow200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$usersFollowUnfollow200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UsersFollowUnfollow200ResponseCodeEnum>
_$usersFollowUnfollow200ResponseCodeEnumValues =
    BuiltSet<UsersFollowUnfollow200ResponseCodeEnum>(
      const <UsersFollowUnfollow200ResponseCodeEnum>[
        _$usersFollowUnfollow200ResponseCodeEnum_number0,
        _$usersFollowUnfollow200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<UsersFollowUnfollow200ResponseCodeEnum>
_$usersFollowUnfollow200ResponseCodeEnumSerializer =
    _$UsersFollowUnfollow200ResponseCodeEnumSerializer();

class _$UsersFollowUnfollow200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<UsersFollowUnfollow200ResponseCodeEnum> {
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
    UsersFollowUnfollow200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'UsersFollowUnfollow200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    UsersFollowUnfollow200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UsersFollowUnfollow200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UsersFollowUnfollow200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UsersFollowUnfollow200Response extends UsersFollowUnfollow200Response {
  @override
  final MessageResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$UsersFollowUnfollow200Response([
    void Function(UsersFollowUnfollow200ResponseBuilder)? updates,
  ]) => (UsersFollowUnfollow200ResponseBuilder()..update(updates))._build();

  _$UsersFollowUnfollow200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  UsersFollowUnfollow200Response rebuild(
    void Function(UsersFollowUnfollow200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UsersFollowUnfollow200ResponseBuilder toBuilder() =>
      UsersFollowUnfollow200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UsersFollowUnfollow200Response &&
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
    return (newBuiltValueToStringHelper(r'UsersFollowUnfollow200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class UsersFollowUnfollow200ResponseBuilder
    implements
        Builder<
          UsersFollowUnfollow200Response,
          UsersFollowUnfollow200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$UsersFollowUnfollow200Response? _$v;

  MessageResponseDtoBuilder? _data;
  MessageResponseDtoBuilder get data =>
      _$this._data ??= MessageResponseDtoBuilder();
  set data(covariant MessageResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  UsersFollowUnfollow200ResponseBuilder() {
    UsersFollowUnfollow200Response._defaults(this);
  }

  UsersFollowUnfollow200ResponseBuilder get _$this {
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
  void replace(covariant UsersFollowUnfollow200Response other) {
    _$v = other as _$UsersFollowUnfollow200Response;
  }

  @override
  void update(void Function(UsersFollowUnfollow200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UsersFollowUnfollow200Response build() => _build();

  _$UsersFollowUnfollow200Response _build() {
    _$UsersFollowUnfollow200Response _$result;
    try {
      _$result =
          _$v ??
          _$UsersFollowUnfollow200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'UsersFollowUnfollow200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'UsersFollowUnfollow200Response',
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
          r'UsersFollowUnfollow200Response',
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
