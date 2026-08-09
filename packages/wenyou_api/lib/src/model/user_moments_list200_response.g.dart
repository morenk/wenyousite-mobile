// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_moments_list200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UserMomentsList200ResponseCodeEnum
_$userMomentsList200ResponseCodeEnum_number0 =
    const UserMomentsList200ResponseCodeEnum._('number0');
const UserMomentsList200ResponseCodeEnum
_$userMomentsList200ResponseCodeEnum_unknownDefaultOpenApi =
    const UserMomentsList200ResponseCodeEnum._('unknownDefaultOpenApi');

UserMomentsList200ResponseCodeEnum _$userMomentsList200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$userMomentsList200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$userMomentsList200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$userMomentsList200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UserMomentsList200ResponseCodeEnum>
_$userMomentsList200ResponseCodeEnumValues =
    BuiltSet<UserMomentsList200ResponseCodeEnum>(
      const <UserMomentsList200ResponseCodeEnum>[
        _$userMomentsList200ResponseCodeEnum_number0,
        _$userMomentsList200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<UserMomentsList200ResponseCodeEnum>
_$userMomentsList200ResponseCodeEnumSerializer =
    _$UserMomentsList200ResponseCodeEnumSerializer();

class _$UserMomentsList200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<UserMomentsList200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[UserMomentsList200ResponseCodeEnum];
  @override
  final String wireName = 'UserMomentsList200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    UserMomentsList200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UserMomentsList200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UserMomentsList200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UserMomentsList200Response extends UserMomentsList200Response {
  @override
  final BuiltList<MomentCardResponseDto> data;
  @override
  final ApiPaginationMeta meta;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$UserMomentsList200Response([
    void Function(UserMomentsList200ResponseBuilder)? updates,
  ]) => (UserMomentsList200ResponseBuilder()..update(updates))._build();

  _$UserMomentsList200Response._({
    required this.data,
    required this.meta,
    required this.code,
    required this.message,
  }) : super._();
  @override
  UserMomentsList200Response rebuild(
    void Function(UserMomentsList200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UserMomentsList200ResponseBuilder toBuilder() =>
      UserMomentsList200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserMomentsList200Response &&
        data == other.data &&
        meta == other.meta &&
        code == other.code &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, meta.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserMomentsList200Response')
          ..add('data', data)
          ..add('meta', meta)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class UserMomentsList200ResponseBuilder
    implements
        Builder<UserMomentsList200Response, UserMomentsList200ResponseBuilder>,
        ApiPaginatedSuccessEnvelopeBuilder {
  _$UserMomentsList200Response? _$v;

  ListBuilder<MomentCardResponseDto>? _data;
  ListBuilder<MomentCardResponseDto> get data =>
      _$this._data ??= ListBuilder<MomentCardResponseDto>();
  set data(covariant ListBuilder<MomentCardResponseDto>? data) =>
      _$this._data = data;

  ApiPaginationMetaBuilder? _meta;
  ApiPaginationMetaBuilder get meta =>
      _$this._meta ??= ApiPaginationMetaBuilder();
  set meta(covariant ApiPaginationMetaBuilder? meta) => _$this._meta = meta;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  UserMomentsList200ResponseBuilder() {
    UserMomentsList200Response._defaults(this);
  }

  UserMomentsList200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _meta = $v.meta.toBuilder();
      _code = $v.code;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant UserMomentsList200Response other) {
    _$v = other as _$UserMomentsList200Response;
  }

  @override
  void update(void Function(UserMomentsList200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserMomentsList200Response build() => _build();

  _$UserMomentsList200Response _build() {
    _$UserMomentsList200Response _$result;
    try {
      _$result =
          _$v ??
          _$UserMomentsList200Response._(
            data: data.build(),
            meta: meta.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'UserMomentsList200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'UserMomentsList200Response',
              'message',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
        _$failedField = 'meta';
        meta.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'UserMomentsList200Response',
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
