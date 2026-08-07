// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_get_user_bookmarks200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UsersGetUserBookmarks200ResponseCodeEnum
_$usersGetUserBookmarks200ResponseCodeEnum_number0 =
    const UsersGetUserBookmarks200ResponseCodeEnum._('number0');
const UsersGetUserBookmarks200ResponseCodeEnum
_$usersGetUserBookmarks200ResponseCodeEnum_unknownDefaultOpenApi =
    const UsersGetUserBookmarks200ResponseCodeEnum._('unknownDefaultOpenApi');

UsersGetUserBookmarks200ResponseCodeEnum
_$usersGetUserBookmarks200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$usersGetUserBookmarks200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$usersGetUserBookmarks200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$usersGetUserBookmarks200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UsersGetUserBookmarks200ResponseCodeEnum>
_$usersGetUserBookmarks200ResponseCodeEnumValues =
    BuiltSet<UsersGetUserBookmarks200ResponseCodeEnum>(
      const <UsersGetUserBookmarks200ResponseCodeEnum>[
        _$usersGetUserBookmarks200ResponseCodeEnum_number0,
        _$usersGetUserBookmarks200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<UsersGetUserBookmarks200ResponseCodeEnum>
_$usersGetUserBookmarks200ResponseCodeEnumSerializer =
    _$UsersGetUserBookmarks200ResponseCodeEnumSerializer();

class _$UsersGetUserBookmarks200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<UsersGetUserBookmarks200ResponseCodeEnum> {
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
    UsersGetUserBookmarks200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'UsersGetUserBookmarks200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    UsersGetUserBookmarks200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UsersGetUserBookmarks200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UsersGetUserBookmarks200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UsersGetUserBookmarks200Response
    extends UsersGetUserBookmarks200Response {
  @override
  final BuiltList<BookmarkThreadResponseDto> data;
  @override
  final ApiPaginationMeta meta;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$UsersGetUserBookmarks200Response([
    void Function(UsersGetUserBookmarks200ResponseBuilder)? updates,
  ]) => (UsersGetUserBookmarks200ResponseBuilder()..update(updates))._build();

  _$UsersGetUserBookmarks200Response._({
    required this.data,
    required this.meta,
    required this.code,
    required this.message,
  }) : super._();
  @override
  UsersGetUserBookmarks200Response rebuild(
    void Function(UsersGetUserBookmarks200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UsersGetUserBookmarks200ResponseBuilder toBuilder() =>
      UsersGetUserBookmarks200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UsersGetUserBookmarks200Response &&
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
    return (newBuiltValueToStringHelper(r'UsersGetUserBookmarks200Response')
          ..add('data', data)
          ..add('meta', meta)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class UsersGetUserBookmarks200ResponseBuilder
    implements
        Builder<
          UsersGetUserBookmarks200Response,
          UsersGetUserBookmarks200ResponseBuilder
        >,
        ApiPaginatedSuccessEnvelopeBuilder {
  _$UsersGetUserBookmarks200Response? _$v;

  ListBuilder<BookmarkThreadResponseDto>? _data;
  ListBuilder<BookmarkThreadResponseDto> get data =>
      _$this._data ??= ListBuilder<BookmarkThreadResponseDto>();
  set data(covariant ListBuilder<BookmarkThreadResponseDto>? data) =>
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

  UsersGetUserBookmarks200ResponseBuilder() {
    UsersGetUserBookmarks200Response._defaults(this);
  }

  UsersGetUserBookmarks200ResponseBuilder get _$this {
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
  void replace(covariant UsersGetUserBookmarks200Response other) {
    _$v = other as _$UsersGetUserBookmarks200Response;
  }

  @override
  void update(void Function(UsersGetUserBookmarks200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UsersGetUserBookmarks200Response build() => _build();

  _$UsersGetUserBookmarks200Response _build() {
    _$UsersGetUserBookmarks200Response _$result;
    try {
      _$result =
          _$v ??
          _$UsersGetUserBookmarks200Response._(
            data: data.build(),
            meta: meta.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'UsersGetUserBookmarks200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'UsersGetUserBookmarks200Response',
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
          r'UsersGetUserBookmarks200Response',
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
