// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_follow_blocks200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UsersFollowBlocks200ResponseCodeEnum
_$usersFollowBlocks200ResponseCodeEnum_number0 =
    const UsersFollowBlocks200ResponseCodeEnum._('number0');
const UsersFollowBlocks200ResponseCodeEnum
_$usersFollowBlocks200ResponseCodeEnum_unknownDefaultOpenApi =
    const UsersFollowBlocks200ResponseCodeEnum._('unknownDefaultOpenApi');

UsersFollowBlocks200ResponseCodeEnum
_$usersFollowBlocks200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$usersFollowBlocks200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$usersFollowBlocks200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$usersFollowBlocks200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UsersFollowBlocks200ResponseCodeEnum>
_$usersFollowBlocks200ResponseCodeEnumValues =
    BuiltSet<UsersFollowBlocks200ResponseCodeEnum>(
      const <UsersFollowBlocks200ResponseCodeEnum>[
        _$usersFollowBlocks200ResponseCodeEnum_number0,
        _$usersFollowBlocks200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<UsersFollowBlocks200ResponseCodeEnum>
_$usersFollowBlocks200ResponseCodeEnumSerializer =
    _$UsersFollowBlocks200ResponseCodeEnumSerializer();

class _$UsersFollowBlocks200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<UsersFollowBlocks200ResponseCodeEnum> {
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
    UsersFollowBlocks200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'UsersFollowBlocks200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    UsersFollowBlocks200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UsersFollowBlocks200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UsersFollowBlocks200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UsersFollowBlocks200Response extends UsersFollowBlocks200Response {
  @override
  final BuiltList<BlockedUserRecordResponseDto> data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$UsersFollowBlocks200Response([
    void Function(UsersFollowBlocks200ResponseBuilder)? updates,
  ]) => (UsersFollowBlocks200ResponseBuilder()..update(updates))._build();

  _$UsersFollowBlocks200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  UsersFollowBlocks200Response rebuild(
    void Function(UsersFollowBlocks200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UsersFollowBlocks200ResponseBuilder toBuilder() =>
      UsersFollowBlocks200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UsersFollowBlocks200Response &&
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
    return (newBuiltValueToStringHelper(r'UsersFollowBlocks200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class UsersFollowBlocks200ResponseBuilder
    implements
        Builder<
          UsersFollowBlocks200Response,
          UsersFollowBlocks200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$UsersFollowBlocks200Response? _$v;

  ListBuilder<BlockedUserRecordResponseDto>? _data;
  ListBuilder<BlockedUserRecordResponseDto> get data =>
      _$this._data ??= ListBuilder<BlockedUserRecordResponseDto>();
  set data(covariant ListBuilder<BlockedUserRecordResponseDto>? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  UsersFollowBlocks200ResponseBuilder() {
    UsersFollowBlocks200Response._defaults(this);
  }

  UsersFollowBlocks200ResponseBuilder get _$this {
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
  void replace(covariant UsersFollowBlocks200Response other) {
    _$v = other as _$UsersFollowBlocks200Response;
  }

  @override
  void update(void Function(UsersFollowBlocks200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UsersFollowBlocks200Response build() => _build();

  _$UsersFollowBlocks200Response _build() {
    _$UsersFollowBlocks200Response _$result;
    try {
      _$result =
          _$v ??
          _$UsersFollowBlocks200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'UsersFollowBlocks200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'UsersFollowBlocks200Response',
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
          r'UsersFollowBlocks200Response',
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
