// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_moderation_appeals_appeal201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UserModerationAppealsAppeal201ResponseCodeEnum
_$userModerationAppealsAppeal201ResponseCodeEnum_number0 =
    const UserModerationAppealsAppeal201ResponseCodeEnum._('number0');
const UserModerationAppealsAppeal201ResponseCodeEnum
_$userModerationAppealsAppeal201ResponseCodeEnum_unknownDefaultOpenApi =
    const UserModerationAppealsAppeal201ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

UserModerationAppealsAppeal201ResponseCodeEnum
_$userModerationAppealsAppeal201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$userModerationAppealsAppeal201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$userModerationAppealsAppeal201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$userModerationAppealsAppeal201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UserModerationAppealsAppeal201ResponseCodeEnum>
_$userModerationAppealsAppeal201ResponseCodeEnumValues =
    BuiltSet<UserModerationAppealsAppeal201ResponseCodeEnum>(
      const <UserModerationAppealsAppeal201ResponseCodeEnum>[
        _$userModerationAppealsAppeal201ResponseCodeEnum_number0,
        _$userModerationAppealsAppeal201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<UserModerationAppealsAppeal201ResponseCodeEnum>
_$userModerationAppealsAppeal201ResponseCodeEnumSerializer =
    _$UserModerationAppealsAppeal201ResponseCodeEnumSerializer();

class _$UserModerationAppealsAppeal201ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<UserModerationAppealsAppeal201ResponseCodeEnum> {
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
    UserModerationAppealsAppeal201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'UserModerationAppealsAppeal201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    UserModerationAppealsAppeal201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UserModerationAppealsAppeal201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UserModerationAppealsAppeal201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UserModerationAppealsAppeal201Response
    extends UserModerationAppealsAppeal201Response {
  @override
  final ModerationAppealResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$UserModerationAppealsAppeal201Response([
    void Function(UserModerationAppealsAppeal201ResponseBuilder)? updates,
  ]) => (UserModerationAppealsAppeal201ResponseBuilder()..update(updates))
      ._build();

  _$UserModerationAppealsAppeal201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  UserModerationAppealsAppeal201Response rebuild(
    void Function(UserModerationAppealsAppeal201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UserModerationAppealsAppeal201ResponseBuilder toBuilder() =>
      UserModerationAppealsAppeal201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserModerationAppealsAppeal201Response &&
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
    return (newBuiltValueToStringHelper(
            r'UserModerationAppealsAppeal201Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class UserModerationAppealsAppeal201ResponseBuilder
    implements
        Builder<
          UserModerationAppealsAppeal201Response,
          UserModerationAppealsAppeal201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$UserModerationAppealsAppeal201Response? _$v;

  ModerationAppealResponseDtoBuilder? _data;
  ModerationAppealResponseDtoBuilder get data =>
      _$this._data ??= ModerationAppealResponseDtoBuilder();
  set data(covariant ModerationAppealResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  UserModerationAppealsAppeal201ResponseBuilder() {
    UserModerationAppealsAppeal201Response._defaults(this);
  }

  UserModerationAppealsAppeal201ResponseBuilder get _$this {
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
  void replace(covariant UserModerationAppealsAppeal201Response other) {
    _$v = other as _$UserModerationAppealsAppeal201Response;
  }

  @override
  void update(
    void Function(UserModerationAppealsAppeal201ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  UserModerationAppealsAppeal201Response build() => _build();

  _$UserModerationAppealsAppeal201Response _build() {
    _$UserModerationAppealsAppeal201Response _$result;
    try {
      _$result =
          _$v ??
          _$UserModerationAppealsAppeal201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'UserModerationAppealsAppeal201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'UserModerationAppealsAppeal201Response',
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
          r'UserModerationAppealsAppeal201Response',
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
