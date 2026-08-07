// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_follow_block200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UsersFollowBlock200ResponseCodeEnum
_$usersFollowBlock200ResponseCodeEnum_number0 =
    const UsersFollowBlock200ResponseCodeEnum._('number0');
const UsersFollowBlock200ResponseCodeEnum
_$usersFollowBlock200ResponseCodeEnum_unknownDefaultOpenApi =
    const UsersFollowBlock200ResponseCodeEnum._('unknownDefaultOpenApi');

UsersFollowBlock200ResponseCodeEnum
_$usersFollowBlock200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$usersFollowBlock200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$usersFollowBlock200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$usersFollowBlock200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UsersFollowBlock200ResponseCodeEnum>
_$usersFollowBlock200ResponseCodeEnumValues =
    BuiltSet<UsersFollowBlock200ResponseCodeEnum>(
      const <UsersFollowBlock200ResponseCodeEnum>[
        _$usersFollowBlock200ResponseCodeEnum_number0,
        _$usersFollowBlock200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<UsersFollowBlock200ResponseCodeEnum>
_$usersFollowBlock200ResponseCodeEnumSerializer =
    _$UsersFollowBlock200ResponseCodeEnumSerializer();

class _$UsersFollowBlock200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<UsersFollowBlock200ResponseCodeEnum> {
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
    UsersFollowBlock200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'UsersFollowBlock200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    UsersFollowBlock200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UsersFollowBlock200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UsersFollowBlock200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UsersFollowBlock200Response extends UsersFollowBlock200Response {
  @override
  final MessageResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$UsersFollowBlock200Response([
    void Function(UsersFollowBlock200ResponseBuilder)? updates,
  ]) => (UsersFollowBlock200ResponseBuilder()..update(updates))._build();

  _$UsersFollowBlock200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  UsersFollowBlock200Response rebuild(
    void Function(UsersFollowBlock200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UsersFollowBlock200ResponseBuilder toBuilder() =>
      UsersFollowBlock200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UsersFollowBlock200Response &&
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
    return (newBuiltValueToStringHelper(r'UsersFollowBlock200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class UsersFollowBlock200ResponseBuilder
    implements
        Builder<
          UsersFollowBlock200Response,
          UsersFollowBlock200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$UsersFollowBlock200Response? _$v;

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

  UsersFollowBlock200ResponseBuilder() {
    UsersFollowBlock200Response._defaults(this);
  }

  UsersFollowBlock200ResponseBuilder get _$this {
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
  void replace(covariant UsersFollowBlock200Response other) {
    _$v = other as _$UsersFollowBlock200Response;
  }

  @override
  void update(void Function(UsersFollowBlock200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UsersFollowBlock200Response build() => _build();

  _$UsersFollowBlock200Response _build() {
    _$UsersFollowBlock200Response _$result;
    try {
      _$result =
          _$v ??
          _$UsersFollowBlock200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'UsersFollowBlock200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'UsersFollowBlock200Response',
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
          r'UsersFollowBlock200Response',
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
