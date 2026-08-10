// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_moderation_appeals_mine200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UserModerationAppealsMine200ResponseCodeEnum
_$userModerationAppealsMine200ResponseCodeEnum_number0 =
    const UserModerationAppealsMine200ResponseCodeEnum._('number0');
const UserModerationAppealsMine200ResponseCodeEnum
_$userModerationAppealsMine200ResponseCodeEnum_unknownDefaultOpenApi =
    const UserModerationAppealsMine200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

UserModerationAppealsMine200ResponseCodeEnum
_$userModerationAppealsMine200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$userModerationAppealsMine200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$userModerationAppealsMine200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$userModerationAppealsMine200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UserModerationAppealsMine200ResponseCodeEnum>
_$userModerationAppealsMine200ResponseCodeEnumValues =
    BuiltSet<UserModerationAppealsMine200ResponseCodeEnum>(
      const <UserModerationAppealsMine200ResponseCodeEnum>[
        _$userModerationAppealsMine200ResponseCodeEnum_number0,
        _$userModerationAppealsMine200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<UserModerationAppealsMine200ResponseCodeEnum>
_$userModerationAppealsMine200ResponseCodeEnumSerializer =
    _$UserModerationAppealsMine200ResponseCodeEnumSerializer();

class _$UserModerationAppealsMine200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<UserModerationAppealsMine200ResponseCodeEnum> {
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
    UserModerationAppealsMine200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'UserModerationAppealsMine200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    UserModerationAppealsMine200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UserModerationAppealsMine200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UserModerationAppealsMine200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UserModerationAppealsMine200Response
    extends UserModerationAppealsMine200Response {
  @override
  final BuiltList<ModerationDecisionPublicResponseDto> data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$UserModerationAppealsMine200Response([
    void Function(UserModerationAppealsMine200ResponseBuilder)? updates,
  ]) =>
      (UserModerationAppealsMine200ResponseBuilder()..update(updates))._build();

  _$UserModerationAppealsMine200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  UserModerationAppealsMine200Response rebuild(
    void Function(UserModerationAppealsMine200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UserModerationAppealsMine200ResponseBuilder toBuilder() =>
      UserModerationAppealsMine200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserModerationAppealsMine200Response &&
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
    return (newBuiltValueToStringHelper(r'UserModerationAppealsMine200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class UserModerationAppealsMine200ResponseBuilder
    implements
        Builder<
          UserModerationAppealsMine200Response,
          UserModerationAppealsMine200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$UserModerationAppealsMine200Response? _$v;

  ListBuilder<ModerationDecisionPublicResponseDto>? _data;
  ListBuilder<ModerationDecisionPublicResponseDto> get data =>
      _$this._data ??= ListBuilder<ModerationDecisionPublicResponseDto>();
  set data(covariant ListBuilder<ModerationDecisionPublicResponseDto>? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  UserModerationAppealsMine200ResponseBuilder() {
    UserModerationAppealsMine200Response._defaults(this);
  }

  UserModerationAppealsMine200ResponseBuilder get _$this {
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
  void replace(covariant UserModerationAppealsMine200Response other) {
    _$v = other as _$UserModerationAppealsMine200Response;
  }

  @override
  void update(
    void Function(UserModerationAppealsMine200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  UserModerationAppealsMine200Response build() => _build();

  _$UserModerationAppealsMine200Response _build() {
    _$UserModerationAppealsMine200Response _$result;
    try {
      _$result =
          _$v ??
          _$UserModerationAppealsMine200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'UserModerationAppealsMine200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'UserModerationAppealsMine200Response',
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
          r'UserModerationAppealsMine200Response',
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
