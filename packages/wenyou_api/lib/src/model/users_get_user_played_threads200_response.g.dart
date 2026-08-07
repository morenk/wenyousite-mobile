// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_get_user_played_threads200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UsersGetUserPlayedThreads200ResponseCodeEnum
_$usersGetUserPlayedThreads200ResponseCodeEnum_number0 =
    const UsersGetUserPlayedThreads200ResponseCodeEnum._('number0');
const UsersGetUserPlayedThreads200ResponseCodeEnum
_$usersGetUserPlayedThreads200ResponseCodeEnum_unknownDefaultOpenApi =
    const UsersGetUserPlayedThreads200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

UsersGetUserPlayedThreads200ResponseCodeEnum
_$usersGetUserPlayedThreads200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$usersGetUserPlayedThreads200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$usersGetUserPlayedThreads200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$usersGetUserPlayedThreads200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UsersGetUserPlayedThreads200ResponseCodeEnum>
_$usersGetUserPlayedThreads200ResponseCodeEnumValues =
    BuiltSet<UsersGetUserPlayedThreads200ResponseCodeEnum>(
      const <UsersGetUserPlayedThreads200ResponseCodeEnum>[
        _$usersGetUserPlayedThreads200ResponseCodeEnum_number0,
        _$usersGetUserPlayedThreads200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<UsersGetUserPlayedThreads200ResponseCodeEnum>
_$usersGetUserPlayedThreads200ResponseCodeEnumSerializer =
    _$UsersGetUserPlayedThreads200ResponseCodeEnumSerializer();

class _$UsersGetUserPlayedThreads200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<UsersGetUserPlayedThreads200ResponseCodeEnum> {
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
    UsersGetUserPlayedThreads200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'UsersGetUserPlayedThreads200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    UsersGetUserPlayedThreads200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UsersGetUserPlayedThreads200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UsersGetUserPlayedThreads200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UsersGetUserPlayedThreads200Response
    extends UsersGetUserPlayedThreads200Response {
  @override
  final BuiltList<ThreadListItemResponseDto> data;
  @override
  final ApiPaginationMeta meta;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$UsersGetUserPlayedThreads200Response([
    void Function(UsersGetUserPlayedThreads200ResponseBuilder)? updates,
  ]) =>
      (UsersGetUserPlayedThreads200ResponseBuilder()..update(updates))._build();

  _$UsersGetUserPlayedThreads200Response._({
    required this.data,
    required this.meta,
    required this.code,
    required this.message,
  }) : super._();
  @override
  UsersGetUserPlayedThreads200Response rebuild(
    void Function(UsersGetUserPlayedThreads200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UsersGetUserPlayedThreads200ResponseBuilder toBuilder() =>
      UsersGetUserPlayedThreads200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UsersGetUserPlayedThreads200Response &&
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
    return (newBuiltValueToStringHelper(r'UsersGetUserPlayedThreads200Response')
          ..add('data', data)
          ..add('meta', meta)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class UsersGetUserPlayedThreads200ResponseBuilder
    implements
        Builder<
          UsersGetUserPlayedThreads200Response,
          UsersGetUserPlayedThreads200ResponseBuilder
        >,
        ApiPaginatedSuccessEnvelopeBuilder {
  _$UsersGetUserPlayedThreads200Response? _$v;

  ListBuilder<ThreadListItemResponseDto>? _data;
  ListBuilder<ThreadListItemResponseDto> get data =>
      _$this._data ??= ListBuilder<ThreadListItemResponseDto>();
  set data(covariant ListBuilder<ThreadListItemResponseDto>? data) =>
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

  UsersGetUserPlayedThreads200ResponseBuilder() {
    UsersGetUserPlayedThreads200Response._defaults(this);
  }

  UsersGetUserPlayedThreads200ResponseBuilder get _$this {
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
  void replace(covariant UsersGetUserPlayedThreads200Response other) {
    _$v = other as _$UsersGetUserPlayedThreads200Response;
  }

  @override
  void update(
    void Function(UsersGetUserPlayedThreads200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  UsersGetUserPlayedThreads200Response build() => _build();

  _$UsersGetUserPlayedThreads200Response _build() {
    _$UsersGetUserPlayedThreads200Response _$result;
    try {
      _$result =
          _$v ??
          _$UsersGetUserPlayedThreads200Response._(
            data: data.build(),
            meta: meta.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'UsersGetUserPlayedThreads200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'UsersGetUserPlayedThreads200Response',
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
          r'UsersGetUserPlayedThreads200Response',
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
