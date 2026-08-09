// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_reports_find_all200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminReportsFindAll200ResponseCodeEnum
_$adminReportsFindAll200ResponseCodeEnum_number0 =
    const AdminReportsFindAll200ResponseCodeEnum._('number0');
const AdminReportsFindAll200ResponseCodeEnum
_$adminReportsFindAll200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminReportsFindAll200ResponseCodeEnum._('unknownDefaultOpenApi');

AdminReportsFindAll200ResponseCodeEnum
_$adminReportsFindAll200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminReportsFindAll200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminReportsFindAll200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminReportsFindAll200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminReportsFindAll200ResponseCodeEnum>
_$adminReportsFindAll200ResponseCodeEnumValues =
    BuiltSet<AdminReportsFindAll200ResponseCodeEnum>(
      const <AdminReportsFindAll200ResponseCodeEnum>[
        _$adminReportsFindAll200ResponseCodeEnum_number0,
        _$adminReportsFindAll200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminReportsFindAll200ResponseCodeEnum>
_$adminReportsFindAll200ResponseCodeEnumSerializer =
    _$AdminReportsFindAll200ResponseCodeEnumSerializer();

class _$AdminReportsFindAll200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminReportsFindAll200ResponseCodeEnum> {
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
    AdminReportsFindAll200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminReportsFindAll200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminReportsFindAll200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminReportsFindAll200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminReportsFindAll200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminReportsFindAll200Response extends AdminReportsFindAll200Response {
  @override
  final BuiltList<AdminReportResponseDto> data;
  @override
  final ApiPaginationMeta meta;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminReportsFindAll200Response([
    void Function(AdminReportsFindAll200ResponseBuilder)? updates,
  ]) => (AdminReportsFindAll200ResponseBuilder()..update(updates))._build();

  _$AdminReportsFindAll200Response._({
    required this.data,
    required this.meta,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminReportsFindAll200Response rebuild(
    void Function(AdminReportsFindAll200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminReportsFindAll200ResponseBuilder toBuilder() =>
      AdminReportsFindAll200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminReportsFindAll200Response &&
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
    return (newBuiltValueToStringHelper(r'AdminReportsFindAll200Response')
          ..add('data', data)
          ..add('meta', meta)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminReportsFindAll200ResponseBuilder
    implements
        Builder<
          AdminReportsFindAll200Response,
          AdminReportsFindAll200ResponseBuilder
        >,
        ApiPaginatedSuccessEnvelopeBuilder {
  _$AdminReportsFindAll200Response? _$v;

  ListBuilder<AdminReportResponseDto>? _data;
  ListBuilder<AdminReportResponseDto> get data =>
      _$this._data ??= ListBuilder<AdminReportResponseDto>();
  set data(covariant ListBuilder<AdminReportResponseDto>? data) =>
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

  AdminReportsFindAll200ResponseBuilder() {
    AdminReportsFindAll200Response._defaults(this);
  }

  AdminReportsFindAll200ResponseBuilder get _$this {
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
  void replace(covariant AdminReportsFindAll200Response other) {
    _$v = other as _$AdminReportsFindAll200Response;
  }

  @override
  void update(void Function(AdminReportsFindAll200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminReportsFindAll200Response build() => _build();

  _$AdminReportsFindAll200Response _build() {
    _$AdminReportsFindAll200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminReportsFindAll200Response._(
            data: data.build(),
            meta: meta.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminReportsFindAll200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminReportsFindAll200Response',
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
          r'AdminReportsFindAll200Response',
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
