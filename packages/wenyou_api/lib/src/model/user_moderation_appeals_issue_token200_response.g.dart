// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_moderation_appeals_issue_token200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UserModerationAppealsIssueToken200ResponseCodeEnum
_$userModerationAppealsIssueToken200ResponseCodeEnum_number0 =
    const UserModerationAppealsIssueToken200ResponseCodeEnum._('number0');
const UserModerationAppealsIssueToken200ResponseCodeEnum
_$userModerationAppealsIssueToken200ResponseCodeEnum_unknownDefaultOpenApi =
    const UserModerationAppealsIssueToken200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

UserModerationAppealsIssueToken200ResponseCodeEnum
_$userModerationAppealsIssueToken200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$userModerationAppealsIssueToken200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$userModerationAppealsIssueToken200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$userModerationAppealsIssueToken200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UserModerationAppealsIssueToken200ResponseCodeEnum>
_$userModerationAppealsIssueToken200ResponseCodeEnumValues =
    BuiltSet<UserModerationAppealsIssueToken200ResponseCodeEnum>(const <
      UserModerationAppealsIssueToken200ResponseCodeEnum
    >[
      _$userModerationAppealsIssueToken200ResponseCodeEnum_number0,
      _$userModerationAppealsIssueToken200ResponseCodeEnum_unknownDefaultOpenApi,
    ]);

Serializer<UserModerationAppealsIssueToken200ResponseCodeEnum>
_$userModerationAppealsIssueToken200ResponseCodeEnumSerializer =
    _$UserModerationAppealsIssueToken200ResponseCodeEnumSerializer();

class _$UserModerationAppealsIssueToken200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<
          UserModerationAppealsIssueToken200ResponseCodeEnum
        > {
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
    UserModerationAppealsIssueToken200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'UserModerationAppealsIssueToken200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    UserModerationAppealsIssueToken200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UserModerationAppealsIssueToken200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UserModerationAppealsIssueToken200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UserModerationAppealsIssueToken200Response
    extends UserModerationAppealsIssueToken200Response {
  @override
  final AppealAccessTokenResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$UserModerationAppealsIssueToken200Response([
    void Function(UserModerationAppealsIssueToken200ResponseBuilder)? updates,
  ]) => (UserModerationAppealsIssueToken200ResponseBuilder()..update(updates))
      ._build();

  _$UserModerationAppealsIssueToken200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  UserModerationAppealsIssueToken200Response rebuild(
    void Function(UserModerationAppealsIssueToken200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UserModerationAppealsIssueToken200ResponseBuilder toBuilder() =>
      UserModerationAppealsIssueToken200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserModerationAppealsIssueToken200Response &&
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
            r'UserModerationAppealsIssueToken200Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class UserModerationAppealsIssueToken200ResponseBuilder
    implements
        Builder<
          UserModerationAppealsIssueToken200Response,
          UserModerationAppealsIssueToken200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$UserModerationAppealsIssueToken200Response? _$v;

  AppealAccessTokenResponseDtoBuilder? _data;
  AppealAccessTokenResponseDtoBuilder get data =>
      _$this._data ??= AppealAccessTokenResponseDtoBuilder();
  set data(covariant AppealAccessTokenResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  UserModerationAppealsIssueToken200ResponseBuilder() {
    UserModerationAppealsIssueToken200Response._defaults(this);
  }

  UserModerationAppealsIssueToken200ResponseBuilder get _$this {
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
  void replace(covariant UserModerationAppealsIssueToken200Response other) {
    _$v = other as _$UserModerationAppealsIssueToken200Response;
  }

  @override
  void update(
    void Function(UserModerationAppealsIssueToken200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  UserModerationAppealsIssueToken200Response build() => _build();

  _$UserModerationAppealsIssueToken200Response _build() {
    _$UserModerationAppealsIssueToken200Response _$result;
    try {
      _$result =
          _$v ??
          _$UserModerationAppealsIssueToken200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'UserModerationAppealsIssueToken200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'UserModerationAppealsIssueToken200Response',
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
          r'UserModerationAppealsIssueToken200Response',
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
