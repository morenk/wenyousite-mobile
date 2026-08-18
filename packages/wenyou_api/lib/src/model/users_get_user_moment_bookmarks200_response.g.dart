// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_get_user_moment_bookmarks200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UsersGetUserMomentBookmarks200ResponseCodeEnum
_$usersGetUserMomentBookmarks200ResponseCodeEnum_number0 =
    const UsersGetUserMomentBookmarks200ResponseCodeEnum._('number0');
const UsersGetUserMomentBookmarks200ResponseCodeEnum
_$usersGetUserMomentBookmarks200ResponseCodeEnum_unknownDefaultOpenApi =
    const UsersGetUserMomentBookmarks200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

UsersGetUserMomentBookmarks200ResponseCodeEnum
_$usersGetUserMomentBookmarks200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$usersGetUserMomentBookmarks200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$usersGetUserMomentBookmarks200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$usersGetUserMomentBookmarks200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UsersGetUserMomentBookmarks200ResponseCodeEnum>
_$usersGetUserMomentBookmarks200ResponseCodeEnumValues =
    BuiltSet<UsersGetUserMomentBookmarks200ResponseCodeEnum>(
      const <UsersGetUserMomentBookmarks200ResponseCodeEnum>[
        _$usersGetUserMomentBookmarks200ResponseCodeEnum_number0,
        _$usersGetUserMomentBookmarks200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<UsersGetUserMomentBookmarks200ResponseCodeEnum>
_$usersGetUserMomentBookmarks200ResponseCodeEnumSerializer =
    _$UsersGetUserMomentBookmarks200ResponseCodeEnumSerializer();

class _$UsersGetUserMomentBookmarks200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<UsersGetUserMomentBookmarks200ResponseCodeEnum> {
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
    UsersGetUserMomentBookmarks200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'UsersGetUserMomentBookmarks200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    UsersGetUserMomentBookmarks200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UsersGetUserMomentBookmarks200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UsersGetUserMomentBookmarks200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UsersGetUserMomentBookmarks200Response
    extends UsersGetUserMomentBookmarks200Response {
  @override
  final BuiltList<MomentCardResponseDto> data;
  @override
  final ApiPaginationMeta meta;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$UsersGetUserMomentBookmarks200Response([
    void Function(UsersGetUserMomentBookmarks200ResponseBuilder)? updates,
  ]) => (UsersGetUserMomentBookmarks200ResponseBuilder()..update(updates))
      ._build();

  _$UsersGetUserMomentBookmarks200Response._({
    required this.data,
    required this.meta,
    required this.code,
    required this.message,
  }) : super._();
  @override
  UsersGetUserMomentBookmarks200Response rebuild(
    void Function(UsersGetUserMomentBookmarks200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UsersGetUserMomentBookmarks200ResponseBuilder toBuilder() =>
      UsersGetUserMomentBookmarks200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UsersGetUserMomentBookmarks200Response &&
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
    return (newBuiltValueToStringHelper(
            r'UsersGetUserMomentBookmarks200Response',
          )
          ..add('data', data)
          ..add('meta', meta)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class UsersGetUserMomentBookmarks200ResponseBuilder
    implements
        Builder<
          UsersGetUserMomentBookmarks200Response,
          UsersGetUserMomentBookmarks200ResponseBuilder
        >,
        ApiPaginatedSuccessEnvelopeBuilder {
  _$UsersGetUserMomentBookmarks200Response? _$v;

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

  UsersGetUserMomentBookmarks200ResponseBuilder() {
    UsersGetUserMomentBookmarks200Response._defaults(this);
  }

  UsersGetUserMomentBookmarks200ResponseBuilder get _$this {
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
  void replace(covariant UsersGetUserMomentBookmarks200Response other) {
    _$v = other as _$UsersGetUserMomentBookmarks200Response;
  }

  @override
  void update(
    void Function(UsersGetUserMomentBookmarks200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  UsersGetUserMomentBookmarks200Response build() => _build();

  _$UsersGetUserMomentBookmarks200Response _build() {
    _$UsersGetUserMomentBookmarks200Response _$result;
    try {
      _$result =
          _$v ??
          _$UsersGetUserMomentBookmarks200Response._(
            data: data.build(),
            meta: meta.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'UsersGetUserMomentBookmarks200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'UsersGetUserMomentBookmarks200Response',
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
          r'UsersGetUserMomentBookmarks200Response',
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
