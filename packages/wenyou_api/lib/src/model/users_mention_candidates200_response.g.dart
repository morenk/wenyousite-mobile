// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_mention_candidates200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UsersMentionCandidates200ResponseCodeEnum
_$usersMentionCandidates200ResponseCodeEnum_number0 =
    const UsersMentionCandidates200ResponseCodeEnum._('number0');
const UsersMentionCandidates200ResponseCodeEnum
_$usersMentionCandidates200ResponseCodeEnum_unknownDefaultOpenApi =
    const UsersMentionCandidates200ResponseCodeEnum._('unknownDefaultOpenApi');

UsersMentionCandidates200ResponseCodeEnum
_$usersMentionCandidates200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$usersMentionCandidates200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$usersMentionCandidates200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$usersMentionCandidates200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UsersMentionCandidates200ResponseCodeEnum>
_$usersMentionCandidates200ResponseCodeEnumValues =
    BuiltSet<UsersMentionCandidates200ResponseCodeEnum>(
      const <UsersMentionCandidates200ResponseCodeEnum>[
        _$usersMentionCandidates200ResponseCodeEnum_number0,
        _$usersMentionCandidates200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<UsersMentionCandidates200ResponseCodeEnum>
_$usersMentionCandidates200ResponseCodeEnumSerializer =
    _$UsersMentionCandidates200ResponseCodeEnumSerializer();

class _$UsersMentionCandidates200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<UsersMentionCandidates200ResponseCodeEnum> {
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
    UsersMentionCandidates200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'UsersMentionCandidates200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    UsersMentionCandidates200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UsersMentionCandidates200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UsersMentionCandidates200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UsersMentionCandidates200Response
    extends UsersMentionCandidates200Response {
  @override
  final MentionCandidatesResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$UsersMentionCandidates200Response([
    void Function(UsersMentionCandidates200ResponseBuilder)? updates,
  ]) => (UsersMentionCandidates200ResponseBuilder()..update(updates))._build();

  _$UsersMentionCandidates200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  UsersMentionCandidates200Response rebuild(
    void Function(UsersMentionCandidates200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UsersMentionCandidates200ResponseBuilder toBuilder() =>
      UsersMentionCandidates200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UsersMentionCandidates200Response &&
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
    return (newBuiltValueToStringHelper(r'UsersMentionCandidates200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class UsersMentionCandidates200ResponseBuilder
    implements
        Builder<
          UsersMentionCandidates200Response,
          UsersMentionCandidates200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$UsersMentionCandidates200Response? _$v;

  MentionCandidatesResponseDtoBuilder? _data;
  MentionCandidatesResponseDtoBuilder get data =>
      _$this._data ??= MentionCandidatesResponseDtoBuilder();
  set data(covariant MentionCandidatesResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  UsersMentionCandidates200ResponseBuilder() {
    UsersMentionCandidates200Response._defaults(this);
  }

  UsersMentionCandidates200ResponseBuilder get _$this {
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
  void replace(covariant UsersMentionCandidates200Response other) {
    _$v = other as _$UsersMentionCandidates200Response;
  }

  @override
  void update(
    void Function(UsersMentionCandidates200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  UsersMentionCandidates200Response build() => _build();

  _$UsersMentionCandidates200Response _build() {
    _$UsersMentionCandidates200Response _$result;
    try {
      _$result =
          _$v ??
          _$UsersMentionCandidates200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'UsersMentionCandidates200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'UsersMentionCandidates200Response',
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
          r'UsersMentionCandidates200Response',
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
