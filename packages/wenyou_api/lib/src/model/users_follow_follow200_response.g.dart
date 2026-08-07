// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_follow_follow200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UsersFollowFollow200ResponseCodeEnum
_$usersFollowFollow200ResponseCodeEnum_number0 =
    const UsersFollowFollow200ResponseCodeEnum._('number0');
const UsersFollowFollow200ResponseCodeEnum
_$usersFollowFollow200ResponseCodeEnum_unknownDefaultOpenApi =
    const UsersFollowFollow200ResponseCodeEnum._('unknownDefaultOpenApi');

UsersFollowFollow200ResponseCodeEnum
_$usersFollowFollow200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$usersFollowFollow200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$usersFollowFollow200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$usersFollowFollow200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UsersFollowFollow200ResponseCodeEnum>
_$usersFollowFollow200ResponseCodeEnumValues =
    BuiltSet<UsersFollowFollow200ResponseCodeEnum>(
      const <UsersFollowFollow200ResponseCodeEnum>[
        _$usersFollowFollow200ResponseCodeEnum_number0,
        _$usersFollowFollow200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<UsersFollowFollow200ResponseCodeEnum>
_$usersFollowFollow200ResponseCodeEnumSerializer =
    _$UsersFollowFollow200ResponseCodeEnumSerializer();

class _$UsersFollowFollow200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<UsersFollowFollow200ResponseCodeEnum> {
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
    UsersFollowFollow200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'UsersFollowFollow200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    UsersFollowFollow200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UsersFollowFollow200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UsersFollowFollow200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UsersFollowFollow200Response extends UsersFollowFollow200Response {
  @override
  final MessageResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$UsersFollowFollow200Response([
    void Function(UsersFollowFollow200ResponseBuilder)? updates,
  ]) => (UsersFollowFollow200ResponseBuilder()..update(updates))._build();

  _$UsersFollowFollow200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  UsersFollowFollow200Response rebuild(
    void Function(UsersFollowFollow200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UsersFollowFollow200ResponseBuilder toBuilder() =>
      UsersFollowFollow200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UsersFollowFollow200Response &&
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
    return (newBuiltValueToStringHelper(r'UsersFollowFollow200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class UsersFollowFollow200ResponseBuilder
    implements
        Builder<
          UsersFollowFollow200Response,
          UsersFollowFollow200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$UsersFollowFollow200Response? _$v;

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

  UsersFollowFollow200ResponseBuilder() {
    UsersFollowFollow200Response._defaults(this);
  }

  UsersFollowFollow200ResponseBuilder get _$this {
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
  void replace(covariant UsersFollowFollow200Response other) {
    _$v = other as _$UsersFollowFollow200Response;
  }

  @override
  void update(void Function(UsersFollowFollow200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UsersFollowFollow200Response build() => _build();

  _$UsersFollowFollow200Response _build() {
    _$UsersFollowFollow200Response _$result;
    try {
      _$result =
          _$v ??
          _$UsersFollowFollow200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'UsersFollowFollow200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'UsersFollowFollow200Response',
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
          r'UsersFollowFollow200Response',
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
