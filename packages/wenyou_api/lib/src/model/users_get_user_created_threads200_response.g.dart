// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_get_user_created_threads200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UsersGetUserCreatedThreads200ResponseCodeEnum
_$usersGetUserCreatedThreads200ResponseCodeEnum_number0 =
    const UsersGetUserCreatedThreads200ResponseCodeEnum._('number0');
const UsersGetUserCreatedThreads200ResponseCodeEnum
_$usersGetUserCreatedThreads200ResponseCodeEnum_unknownDefaultOpenApi =
    const UsersGetUserCreatedThreads200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

UsersGetUserCreatedThreads200ResponseCodeEnum
_$usersGetUserCreatedThreads200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$usersGetUserCreatedThreads200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$usersGetUserCreatedThreads200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$usersGetUserCreatedThreads200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UsersGetUserCreatedThreads200ResponseCodeEnum>
_$usersGetUserCreatedThreads200ResponseCodeEnumValues =
    BuiltSet<UsersGetUserCreatedThreads200ResponseCodeEnum>(
      const <UsersGetUserCreatedThreads200ResponseCodeEnum>[
        _$usersGetUserCreatedThreads200ResponseCodeEnum_number0,
        _$usersGetUserCreatedThreads200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<UsersGetUserCreatedThreads200ResponseCodeEnum>
_$usersGetUserCreatedThreads200ResponseCodeEnumSerializer =
    _$UsersGetUserCreatedThreads200ResponseCodeEnumSerializer();

class _$UsersGetUserCreatedThreads200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<UsersGetUserCreatedThreads200ResponseCodeEnum> {
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
    UsersGetUserCreatedThreads200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'UsersGetUserCreatedThreads200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    UsersGetUserCreatedThreads200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UsersGetUserCreatedThreads200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UsersGetUserCreatedThreads200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UsersGetUserCreatedThreads200Response
    extends UsersGetUserCreatedThreads200Response {
  @override
  final BuiltList<ThreadListItemResponseDto> data;
  @override
  final ApiPaginationMeta meta;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$UsersGetUserCreatedThreads200Response([
    void Function(UsersGetUserCreatedThreads200ResponseBuilder)? updates,
  ]) => (UsersGetUserCreatedThreads200ResponseBuilder()..update(updates))
      ._build();

  _$UsersGetUserCreatedThreads200Response._({
    required this.data,
    required this.meta,
    required this.code,
    required this.message,
  }) : super._();
  @override
  UsersGetUserCreatedThreads200Response rebuild(
    void Function(UsersGetUserCreatedThreads200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UsersGetUserCreatedThreads200ResponseBuilder toBuilder() =>
      UsersGetUserCreatedThreads200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UsersGetUserCreatedThreads200Response &&
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
            r'UsersGetUserCreatedThreads200Response',
          )
          ..add('data', data)
          ..add('meta', meta)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class UsersGetUserCreatedThreads200ResponseBuilder
    implements
        Builder<
          UsersGetUserCreatedThreads200Response,
          UsersGetUserCreatedThreads200ResponseBuilder
        >,
        ApiPaginatedSuccessEnvelopeBuilder {
  _$UsersGetUserCreatedThreads200Response? _$v;

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

  UsersGetUserCreatedThreads200ResponseBuilder() {
    UsersGetUserCreatedThreads200Response._defaults(this);
  }

  UsersGetUserCreatedThreads200ResponseBuilder get _$this {
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
  void replace(covariant UsersGetUserCreatedThreads200Response other) {
    _$v = other as _$UsersGetUserCreatedThreads200Response;
  }

  @override
  void update(
    void Function(UsersGetUserCreatedThreads200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  UsersGetUserCreatedThreads200Response build() => _build();

  _$UsersGetUserCreatedThreads200Response _build() {
    _$UsersGetUserCreatedThreads200Response _$result;
    try {
      _$result =
          _$v ??
          _$UsersGetUserCreatedThreads200Response._(
            data: data.build(),
            meta: meta.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'UsersGetUserCreatedThreads200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'UsersGetUserCreatedThreads200Response',
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
          r'UsersGetUserCreatedThreads200Response',
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
