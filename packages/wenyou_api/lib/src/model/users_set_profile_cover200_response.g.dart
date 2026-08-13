// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_set_profile_cover200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UsersSetProfileCover200ResponseCodeEnum
_$usersSetProfileCover200ResponseCodeEnum_number0 =
    const UsersSetProfileCover200ResponseCodeEnum._('number0');
const UsersSetProfileCover200ResponseCodeEnum
_$usersSetProfileCover200ResponseCodeEnum_unknownDefaultOpenApi =
    const UsersSetProfileCover200ResponseCodeEnum._('unknownDefaultOpenApi');

UsersSetProfileCover200ResponseCodeEnum
_$usersSetProfileCover200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$usersSetProfileCover200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$usersSetProfileCover200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$usersSetProfileCover200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UsersSetProfileCover200ResponseCodeEnum>
_$usersSetProfileCover200ResponseCodeEnumValues =
    BuiltSet<UsersSetProfileCover200ResponseCodeEnum>(
      const <UsersSetProfileCover200ResponseCodeEnum>[
        _$usersSetProfileCover200ResponseCodeEnum_number0,
        _$usersSetProfileCover200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<UsersSetProfileCover200ResponseCodeEnum>
_$usersSetProfileCover200ResponseCodeEnumSerializer =
    _$UsersSetProfileCover200ResponseCodeEnumSerializer();

class _$UsersSetProfileCover200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<UsersSetProfileCover200ResponseCodeEnum> {
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
    UsersSetProfileCover200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'UsersSetProfileCover200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    UsersSetProfileCover200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UsersSetProfileCover200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UsersSetProfileCover200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UsersSetProfileCover200Response
    extends UsersSetProfileCover200Response {
  @override
  final PrivateUserResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$UsersSetProfileCover200Response([
    void Function(UsersSetProfileCover200ResponseBuilder)? updates,
  ]) => (UsersSetProfileCover200ResponseBuilder()..update(updates))._build();

  _$UsersSetProfileCover200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  UsersSetProfileCover200Response rebuild(
    void Function(UsersSetProfileCover200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UsersSetProfileCover200ResponseBuilder toBuilder() =>
      UsersSetProfileCover200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UsersSetProfileCover200Response &&
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
    return (newBuiltValueToStringHelper(r'UsersSetProfileCover200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class UsersSetProfileCover200ResponseBuilder
    implements
        Builder<
          UsersSetProfileCover200Response,
          UsersSetProfileCover200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$UsersSetProfileCover200Response? _$v;

  PrivateUserResponseDtoBuilder? _data;
  PrivateUserResponseDtoBuilder get data =>
      _$this._data ??= PrivateUserResponseDtoBuilder();
  set data(covariant PrivateUserResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  UsersSetProfileCover200ResponseBuilder() {
    UsersSetProfileCover200Response._defaults(this);
  }

  UsersSetProfileCover200ResponseBuilder get _$this {
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
  void replace(covariant UsersSetProfileCover200Response other) {
    _$v = other as _$UsersSetProfileCover200Response;
  }

  @override
  void update(void Function(UsersSetProfileCover200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UsersSetProfileCover200Response build() => _build();

  _$UsersSetProfileCover200Response _build() {
    _$UsersSetProfileCover200Response _$result;
    try {
      _$result =
          _$v ??
          _$UsersSetProfileCover200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'UsersSetProfileCover200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'UsersSetProfileCover200Response',
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
          r'UsersSetProfileCover200Response',
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
