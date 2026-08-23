// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_get_my_collaborated_threads200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UsersGetMyCollaboratedThreads200ResponseCodeEnum
_$usersGetMyCollaboratedThreads200ResponseCodeEnum_number0 =
    const UsersGetMyCollaboratedThreads200ResponseCodeEnum._('number0');
const UsersGetMyCollaboratedThreads200ResponseCodeEnum
_$usersGetMyCollaboratedThreads200ResponseCodeEnum_unknownDefaultOpenApi =
    const UsersGetMyCollaboratedThreads200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

UsersGetMyCollaboratedThreads200ResponseCodeEnum
_$usersGetMyCollaboratedThreads200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$usersGetMyCollaboratedThreads200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$usersGetMyCollaboratedThreads200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$usersGetMyCollaboratedThreads200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UsersGetMyCollaboratedThreads200ResponseCodeEnum>
_$usersGetMyCollaboratedThreads200ResponseCodeEnumValues =
    BuiltSet<UsersGetMyCollaboratedThreads200ResponseCodeEnum>(const <
      UsersGetMyCollaboratedThreads200ResponseCodeEnum
    >[
      _$usersGetMyCollaboratedThreads200ResponseCodeEnum_number0,
      _$usersGetMyCollaboratedThreads200ResponseCodeEnum_unknownDefaultOpenApi,
    ]);

Serializer<UsersGetMyCollaboratedThreads200ResponseCodeEnum>
_$usersGetMyCollaboratedThreads200ResponseCodeEnumSerializer =
    _$UsersGetMyCollaboratedThreads200ResponseCodeEnumSerializer();

class _$UsersGetMyCollaboratedThreads200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<UsersGetMyCollaboratedThreads200ResponseCodeEnum> {
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
    UsersGetMyCollaboratedThreads200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'UsersGetMyCollaboratedThreads200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    UsersGetMyCollaboratedThreads200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UsersGetMyCollaboratedThreads200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UsersGetMyCollaboratedThreads200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UsersGetMyCollaboratedThreads200Response
    extends UsersGetMyCollaboratedThreads200Response {
  @override
  final BuiltList<ThreadListItemResponseDto> data;
  @override
  final ApiPaginationMeta meta;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$UsersGetMyCollaboratedThreads200Response([
    void Function(UsersGetMyCollaboratedThreads200ResponseBuilder)? updates,
  ]) => (UsersGetMyCollaboratedThreads200ResponseBuilder()..update(updates))
      ._build();

  _$UsersGetMyCollaboratedThreads200Response._({
    required this.data,
    required this.meta,
    required this.code,
    required this.message,
  }) : super._();
  @override
  UsersGetMyCollaboratedThreads200Response rebuild(
    void Function(UsersGetMyCollaboratedThreads200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UsersGetMyCollaboratedThreads200ResponseBuilder toBuilder() =>
      UsersGetMyCollaboratedThreads200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UsersGetMyCollaboratedThreads200Response &&
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
            r'UsersGetMyCollaboratedThreads200Response',
          )
          ..add('data', data)
          ..add('meta', meta)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class UsersGetMyCollaboratedThreads200ResponseBuilder
    implements
        Builder<
          UsersGetMyCollaboratedThreads200Response,
          UsersGetMyCollaboratedThreads200ResponseBuilder
        >,
        ApiPaginatedSuccessEnvelopeBuilder {
  _$UsersGetMyCollaboratedThreads200Response? _$v;

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

  UsersGetMyCollaboratedThreads200ResponseBuilder() {
    UsersGetMyCollaboratedThreads200Response._defaults(this);
  }

  UsersGetMyCollaboratedThreads200ResponseBuilder get _$this {
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
  void replace(covariant UsersGetMyCollaboratedThreads200Response other) {
    _$v = other as _$UsersGetMyCollaboratedThreads200Response;
  }

  @override
  void update(
    void Function(UsersGetMyCollaboratedThreads200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  UsersGetMyCollaboratedThreads200Response build() => _build();

  _$UsersGetMyCollaboratedThreads200Response _build() {
    _$UsersGetMyCollaboratedThreads200Response _$result;
    try {
      _$result =
          _$v ??
          _$UsersGetMyCollaboratedThreads200Response._(
            data: data.build(),
            meta: meta.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'UsersGetMyCollaboratedThreads200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'UsersGetMyCollaboratedThreads200Response',
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
          r'UsersGetMyCollaboratedThreads200Response',
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
