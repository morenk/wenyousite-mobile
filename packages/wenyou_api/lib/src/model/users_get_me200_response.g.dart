// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_get_me200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UsersGetMe200ResponseCodeEnum _$usersGetMe200ResponseCodeEnum_number0 =
    const UsersGetMe200ResponseCodeEnum._('number0');
const UsersGetMe200ResponseCodeEnum
_$usersGetMe200ResponseCodeEnum_unknownDefaultOpenApi =
    const UsersGetMe200ResponseCodeEnum._('unknownDefaultOpenApi');

UsersGetMe200ResponseCodeEnum _$usersGetMe200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$usersGetMe200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$usersGetMe200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$usersGetMe200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UsersGetMe200ResponseCodeEnum>
_$usersGetMe200ResponseCodeEnumValues = BuiltSet<UsersGetMe200ResponseCodeEnum>(
  const <UsersGetMe200ResponseCodeEnum>[
    _$usersGetMe200ResponseCodeEnum_number0,
    _$usersGetMe200ResponseCodeEnum_unknownDefaultOpenApi,
  ],
);

Serializer<UsersGetMe200ResponseCodeEnum>
_$usersGetMe200ResponseCodeEnumSerializer =
    _$UsersGetMe200ResponseCodeEnumSerializer();

class _$UsersGetMe200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<UsersGetMe200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[UsersGetMe200ResponseCodeEnum];
  @override
  final String wireName = 'UsersGetMe200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    UsersGetMe200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UsersGetMe200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UsersGetMe200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UsersGetMe200Response extends UsersGetMe200Response {
  @override
  final CurrentUserResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$UsersGetMe200Response([
    void Function(UsersGetMe200ResponseBuilder)? updates,
  ]) => (UsersGetMe200ResponseBuilder()..update(updates))._build();

  _$UsersGetMe200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  UsersGetMe200Response rebuild(
    void Function(UsersGetMe200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UsersGetMe200ResponseBuilder toBuilder() =>
      UsersGetMe200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UsersGetMe200Response &&
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
    return (newBuiltValueToStringHelper(r'UsersGetMe200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class UsersGetMe200ResponseBuilder
    implements
        Builder<UsersGetMe200Response, UsersGetMe200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$UsersGetMe200Response? _$v;

  CurrentUserResponseDtoBuilder? _data;
  CurrentUserResponseDtoBuilder get data =>
      _$this._data ??= CurrentUserResponseDtoBuilder();
  set data(covariant CurrentUserResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  UsersGetMe200ResponseBuilder() {
    UsersGetMe200Response._defaults(this);
  }

  UsersGetMe200ResponseBuilder get _$this {
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
  void replace(covariant UsersGetMe200Response other) {
    _$v = other as _$UsersGetMe200Response;
  }

  @override
  void update(void Function(UsersGetMe200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UsersGetMe200Response build() => _build();

  _$UsersGetMe200Response _build() {
    _$UsersGetMe200Response _$result;
    try {
      _$result =
          _$v ??
          _$UsersGetMe200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'UsersGetMe200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'UsersGetMe200Response',
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
          r'UsersGetMe200Response',
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
