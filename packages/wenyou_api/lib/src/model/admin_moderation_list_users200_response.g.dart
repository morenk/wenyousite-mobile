// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_moderation_list_users200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminModerationListUsers200ResponseCodeEnum
_$adminModerationListUsers200ResponseCodeEnum_number0 =
    const AdminModerationListUsers200ResponseCodeEnum._('number0');
const AdminModerationListUsers200ResponseCodeEnum
_$adminModerationListUsers200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminModerationListUsers200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

AdminModerationListUsers200ResponseCodeEnum
_$adminModerationListUsers200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminModerationListUsers200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminModerationListUsers200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminModerationListUsers200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminModerationListUsers200ResponseCodeEnum>
_$adminModerationListUsers200ResponseCodeEnumValues =
    BuiltSet<AdminModerationListUsers200ResponseCodeEnum>(
      const <AdminModerationListUsers200ResponseCodeEnum>[
        _$adminModerationListUsers200ResponseCodeEnum_number0,
        _$adminModerationListUsers200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminModerationListUsers200ResponseCodeEnum>
_$adminModerationListUsers200ResponseCodeEnumSerializer =
    _$AdminModerationListUsers200ResponseCodeEnumSerializer();

class _$AdminModerationListUsers200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<AdminModerationListUsers200ResponseCodeEnum> {
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
    AdminModerationListUsers200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminModerationListUsers200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminModerationListUsers200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminModerationListUsers200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminModerationListUsers200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminModerationListUsers200Response
    extends AdminModerationListUsers200Response {
  @override
  final BuiltList<AdminUserModerationResponseDto> data;
  @override
  final ApiPaginationMeta meta;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminModerationListUsers200Response([
    void Function(AdminModerationListUsers200ResponseBuilder)? updates,
  ]) =>
      (AdminModerationListUsers200ResponseBuilder()..update(updates))._build();

  _$AdminModerationListUsers200Response._({
    required this.data,
    required this.meta,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminModerationListUsers200Response rebuild(
    void Function(AdminModerationListUsers200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminModerationListUsers200ResponseBuilder toBuilder() =>
      AdminModerationListUsers200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminModerationListUsers200Response &&
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
    return (newBuiltValueToStringHelper(r'AdminModerationListUsers200Response')
          ..add('data', data)
          ..add('meta', meta)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminModerationListUsers200ResponseBuilder
    implements
        Builder<
          AdminModerationListUsers200Response,
          AdminModerationListUsers200ResponseBuilder
        >,
        ApiPaginatedSuccessEnvelopeBuilder {
  _$AdminModerationListUsers200Response? _$v;

  ListBuilder<AdminUserModerationResponseDto>? _data;
  ListBuilder<AdminUserModerationResponseDto> get data =>
      _$this._data ??= ListBuilder<AdminUserModerationResponseDto>();
  set data(covariant ListBuilder<AdminUserModerationResponseDto>? data) =>
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

  AdminModerationListUsers200ResponseBuilder() {
    AdminModerationListUsers200Response._defaults(this);
  }

  AdminModerationListUsers200ResponseBuilder get _$this {
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
  void replace(covariant AdminModerationListUsers200Response other) {
    _$v = other as _$AdminModerationListUsers200Response;
  }

  @override
  void update(
    void Function(AdminModerationListUsers200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminModerationListUsers200Response build() => _build();

  _$AdminModerationListUsers200Response _build() {
    _$AdminModerationListUsers200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminModerationListUsers200Response._(
            data: data.build(),
            meta: meta.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminModerationListUsers200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminModerationListUsers200Response',
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
          r'AdminModerationListUsers200Response',
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
