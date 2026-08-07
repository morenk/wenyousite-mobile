// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_delete_me200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UsersDeleteMe200ResponseCodeEnum
_$usersDeleteMe200ResponseCodeEnum_number0 =
    const UsersDeleteMe200ResponseCodeEnum._('number0');
const UsersDeleteMe200ResponseCodeEnum
_$usersDeleteMe200ResponseCodeEnum_unknownDefaultOpenApi =
    const UsersDeleteMe200ResponseCodeEnum._('unknownDefaultOpenApi');

UsersDeleteMe200ResponseCodeEnum _$usersDeleteMe200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$usersDeleteMe200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$usersDeleteMe200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$usersDeleteMe200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UsersDeleteMe200ResponseCodeEnum>
_$usersDeleteMe200ResponseCodeEnumValues =
    BuiltSet<UsersDeleteMe200ResponseCodeEnum>(
      const <UsersDeleteMe200ResponseCodeEnum>[
        _$usersDeleteMe200ResponseCodeEnum_number0,
        _$usersDeleteMe200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<UsersDeleteMe200ResponseCodeEnum>
_$usersDeleteMe200ResponseCodeEnumSerializer =
    _$UsersDeleteMe200ResponseCodeEnumSerializer();

class _$UsersDeleteMe200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<UsersDeleteMe200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[UsersDeleteMe200ResponseCodeEnum];
  @override
  final String wireName = 'UsersDeleteMe200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    UsersDeleteMe200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UsersDeleteMe200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UsersDeleteMe200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UsersDeleteMe200Response extends UsersDeleteMe200Response {
  @override
  final MessageResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$UsersDeleteMe200Response([
    void Function(UsersDeleteMe200ResponseBuilder)? updates,
  ]) => (UsersDeleteMe200ResponseBuilder()..update(updates))._build();

  _$UsersDeleteMe200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  UsersDeleteMe200Response rebuild(
    void Function(UsersDeleteMe200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UsersDeleteMe200ResponseBuilder toBuilder() =>
      UsersDeleteMe200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UsersDeleteMe200Response &&
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
    return (newBuiltValueToStringHelper(r'UsersDeleteMe200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class UsersDeleteMe200ResponseBuilder
    implements
        Builder<UsersDeleteMe200Response, UsersDeleteMe200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$UsersDeleteMe200Response? _$v;

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

  UsersDeleteMe200ResponseBuilder() {
    UsersDeleteMe200Response._defaults(this);
  }

  UsersDeleteMe200ResponseBuilder get _$this {
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
  void replace(covariant UsersDeleteMe200Response other) {
    _$v = other as _$UsersDeleteMe200Response;
  }

  @override
  void update(void Function(UsersDeleteMe200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UsersDeleteMe200Response build() => _build();

  _$UsersDeleteMe200Response _build() {
    _$UsersDeleteMe200Response _$result;
    try {
      _$result =
          _$v ??
          _$UsersDeleteMe200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'UsersDeleteMe200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'UsersDeleteMe200Response',
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
          r'UsersDeleteMe200Response',
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
