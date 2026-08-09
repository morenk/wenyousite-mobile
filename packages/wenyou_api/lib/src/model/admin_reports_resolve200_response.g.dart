// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_reports_resolve200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminReportsResolve200ResponseCodeEnum
_$adminReportsResolve200ResponseCodeEnum_number0 =
    const AdminReportsResolve200ResponseCodeEnum._('number0');
const AdminReportsResolve200ResponseCodeEnum
_$adminReportsResolve200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminReportsResolve200ResponseCodeEnum._('unknownDefaultOpenApi');

AdminReportsResolve200ResponseCodeEnum
_$adminReportsResolve200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminReportsResolve200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminReportsResolve200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminReportsResolve200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminReportsResolve200ResponseCodeEnum>
_$adminReportsResolve200ResponseCodeEnumValues =
    BuiltSet<AdminReportsResolve200ResponseCodeEnum>(
      const <AdminReportsResolve200ResponseCodeEnum>[
        _$adminReportsResolve200ResponseCodeEnum_number0,
        _$adminReportsResolve200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminReportsResolve200ResponseCodeEnum>
_$adminReportsResolve200ResponseCodeEnumSerializer =
    _$AdminReportsResolve200ResponseCodeEnumSerializer();

class _$AdminReportsResolve200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminReportsResolve200ResponseCodeEnum> {
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
    AdminReportsResolve200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminReportsResolve200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminReportsResolve200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminReportsResolve200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminReportsResolve200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminReportsResolve200Response extends AdminReportsResolve200Response {
  @override
  final AdminReportResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminReportsResolve200Response([
    void Function(AdminReportsResolve200ResponseBuilder)? updates,
  ]) => (AdminReportsResolve200ResponseBuilder()..update(updates))._build();

  _$AdminReportsResolve200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminReportsResolve200Response rebuild(
    void Function(AdminReportsResolve200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminReportsResolve200ResponseBuilder toBuilder() =>
      AdminReportsResolve200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminReportsResolve200Response &&
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
    return (newBuiltValueToStringHelper(r'AdminReportsResolve200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminReportsResolve200ResponseBuilder
    implements
        Builder<
          AdminReportsResolve200Response,
          AdminReportsResolve200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminReportsResolve200Response? _$v;

  AdminReportResponseDtoBuilder? _data;
  AdminReportResponseDtoBuilder get data =>
      _$this._data ??= AdminReportResponseDtoBuilder();
  set data(covariant AdminReportResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminReportsResolve200ResponseBuilder() {
    AdminReportsResolve200Response._defaults(this);
  }

  AdminReportsResolve200ResponseBuilder get _$this {
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
  void replace(covariant AdminReportsResolve200Response other) {
    _$v = other as _$AdminReportsResolve200Response;
  }

  @override
  void update(void Function(AdminReportsResolve200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminReportsResolve200Response build() => _build();

  _$AdminReportsResolve200Response _build() {
    _$AdminReportsResolve200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminReportsResolve200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminReportsResolve200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminReportsResolve200Response',
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
          r'AdminReportsResolve200Response',
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
