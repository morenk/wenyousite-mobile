// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_moderation_list_audit_logs200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminModerationListAuditLogs200ResponseCodeEnum
_$adminModerationListAuditLogs200ResponseCodeEnum_number0 =
    const AdminModerationListAuditLogs200ResponseCodeEnum._('number0');
const AdminModerationListAuditLogs200ResponseCodeEnum
_$adminModerationListAuditLogs200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminModerationListAuditLogs200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

AdminModerationListAuditLogs200ResponseCodeEnum
_$adminModerationListAuditLogs200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminModerationListAuditLogs200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminModerationListAuditLogs200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminModerationListAuditLogs200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminModerationListAuditLogs200ResponseCodeEnum>
_$adminModerationListAuditLogs200ResponseCodeEnumValues =
    BuiltSet<AdminModerationListAuditLogs200ResponseCodeEnum>(
      const <AdminModerationListAuditLogs200ResponseCodeEnum>[
        _$adminModerationListAuditLogs200ResponseCodeEnum_number0,
        _$adminModerationListAuditLogs200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminModerationListAuditLogs200ResponseCodeEnum>
_$adminModerationListAuditLogs200ResponseCodeEnumSerializer =
    _$AdminModerationListAuditLogs200ResponseCodeEnumSerializer();

class _$AdminModerationListAuditLogs200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<AdminModerationListAuditLogs200ResponseCodeEnum> {
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
    AdminModerationListAuditLogs200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminModerationListAuditLogs200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminModerationListAuditLogs200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminModerationListAuditLogs200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminModerationListAuditLogs200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminModerationListAuditLogs200Response
    extends AdminModerationListAuditLogs200Response {
  @override
  final BuiltList<AdminAuditLogResponseDto> data;
  @override
  final ApiPaginationMeta meta;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminModerationListAuditLogs200Response([
    void Function(AdminModerationListAuditLogs200ResponseBuilder)? updates,
  ]) => (AdminModerationListAuditLogs200ResponseBuilder()..update(updates))
      ._build();

  _$AdminModerationListAuditLogs200Response._({
    required this.data,
    required this.meta,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminModerationListAuditLogs200Response rebuild(
    void Function(AdminModerationListAuditLogs200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminModerationListAuditLogs200ResponseBuilder toBuilder() =>
      AdminModerationListAuditLogs200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminModerationListAuditLogs200Response &&
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
            r'AdminModerationListAuditLogs200Response',
          )
          ..add('data', data)
          ..add('meta', meta)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminModerationListAuditLogs200ResponseBuilder
    implements
        Builder<
          AdminModerationListAuditLogs200Response,
          AdminModerationListAuditLogs200ResponseBuilder
        >,
        ApiPaginatedSuccessEnvelopeBuilder {
  _$AdminModerationListAuditLogs200Response? _$v;

  ListBuilder<AdminAuditLogResponseDto>? _data;
  ListBuilder<AdminAuditLogResponseDto> get data =>
      _$this._data ??= ListBuilder<AdminAuditLogResponseDto>();
  set data(covariant ListBuilder<AdminAuditLogResponseDto>? data) =>
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

  AdminModerationListAuditLogs200ResponseBuilder() {
    AdminModerationListAuditLogs200Response._defaults(this);
  }

  AdminModerationListAuditLogs200ResponseBuilder get _$this {
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
  void replace(covariant AdminModerationListAuditLogs200Response other) {
    _$v = other as _$AdminModerationListAuditLogs200Response;
  }

  @override
  void update(
    void Function(AdminModerationListAuditLogs200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminModerationListAuditLogs200Response build() => _build();

  _$AdminModerationListAuditLogs200Response _build() {
    _$AdminModerationListAuditLogs200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminModerationListAuditLogs200Response._(
            data: data.build(),
            meta: meta.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminModerationListAuditLogs200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminModerationListAuditLogs200Response',
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
          r'AdminModerationListAuditLogs200Response',
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
