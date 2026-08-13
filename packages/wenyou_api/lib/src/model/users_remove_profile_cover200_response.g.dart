// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_remove_profile_cover200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UsersRemoveProfileCover200ResponseCodeEnum
_$usersRemoveProfileCover200ResponseCodeEnum_number0 =
    const UsersRemoveProfileCover200ResponseCodeEnum._('number0');
const UsersRemoveProfileCover200ResponseCodeEnum
_$usersRemoveProfileCover200ResponseCodeEnum_unknownDefaultOpenApi =
    const UsersRemoveProfileCover200ResponseCodeEnum._('unknownDefaultOpenApi');

UsersRemoveProfileCover200ResponseCodeEnum
_$usersRemoveProfileCover200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$usersRemoveProfileCover200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$usersRemoveProfileCover200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$usersRemoveProfileCover200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UsersRemoveProfileCover200ResponseCodeEnum>
_$usersRemoveProfileCover200ResponseCodeEnumValues =
    BuiltSet<UsersRemoveProfileCover200ResponseCodeEnum>(
      const <UsersRemoveProfileCover200ResponseCodeEnum>[
        _$usersRemoveProfileCover200ResponseCodeEnum_number0,
        _$usersRemoveProfileCover200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<UsersRemoveProfileCover200ResponseCodeEnum>
_$usersRemoveProfileCover200ResponseCodeEnumSerializer =
    _$UsersRemoveProfileCover200ResponseCodeEnumSerializer();

class _$UsersRemoveProfileCover200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<UsersRemoveProfileCover200ResponseCodeEnum> {
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
    UsersRemoveProfileCover200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'UsersRemoveProfileCover200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    UsersRemoveProfileCover200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UsersRemoveProfileCover200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UsersRemoveProfileCover200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UsersRemoveProfileCover200Response
    extends UsersRemoveProfileCover200Response {
  @override
  final PrivateUserResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$UsersRemoveProfileCover200Response([
    void Function(UsersRemoveProfileCover200ResponseBuilder)? updates,
  ]) => (UsersRemoveProfileCover200ResponseBuilder()..update(updates))._build();

  _$UsersRemoveProfileCover200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  UsersRemoveProfileCover200Response rebuild(
    void Function(UsersRemoveProfileCover200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UsersRemoveProfileCover200ResponseBuilder toBuilder() =>
      UsersRemoveProfileCover200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UsersRemoveProfileCover200Response &&
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
    return (newBuiltValueToStringHelper(r'UsersRemoveProfileCover200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class UsersRemoveProfileCover200ResponseBuilder
    implements
        Builder<
          UsersRemoveProfileCover200Response,
          UsersRemoveProfileCover200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$UsersRemoveProfileCover200Response? _$v;

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

  UsersRemoveProfileCover200ResponseBuilder() {
    UsersRemoveProfileCover200Response._defaults(this);
  }

  UsersRemoveProfileCover200ResponseBuilder get _$this {
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
  void replace(covariant UsersRemoveProfileCover200Response other) {
    _$v = other as _$UsersRemoveProfileCover200Response;
  }

  @override
  void update(
    void Function(UsersRemoveProfileCover200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  UsersRemoveProfileCover200Response build() => _build();

  _$UsersRemoveProfileCover200Response _build() {
    _$UsersRemoveProfileCover200Response _$result;
    try {
      _$result =
          _$v ??
          _$UsersRemoveProfileCover200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'UsersRemoveProfileCover200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'UsersRemoveProfileCover200Response',
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
          r'UsersRemoveProfileCover200Response',
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
