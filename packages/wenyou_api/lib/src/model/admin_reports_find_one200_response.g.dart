// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_reports_find_one200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminReportsFindOne200ResponseCodeEnum
_$adminReportsFindOne200ResponseCodeEnum_number0 =
    const AdminReportsFindOne200ResponseCodeEnum._('number0');
const AdminReportsFindOne200ResponseCodeEnum
_$adminReportsFindOne200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminReportsFindOne200ResponseCodeEnum._('unknownDefaultOpenApi');

AdminReportsFindOne200ResponseCodeEnum
_$adminReportsFindOne200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminReportsFindOne200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminReportsFindOne200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminReportsFindOne200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminReportsFindOne200ResponseCodeEnum>
_$adminReportsFindOne200ResponseCodeEnumValues =
    BuiltSet<AdminReportsFindOne200ResponseCodeEnum>(
      const <AdminReportsFindOne200ResponseCodeEnum>[
        _$adminReportsFindOne200ResponseCodeEnum_number0,
        _$adminReportsFindOne200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminReportsFindOne200ResponseCodeEnum>
_$adminReportsFindOne200ResponseCodeEnumSerializer =
    _$AdminReportsFindOne200ResponseCodeEnumSerializer();

class _$AdminReportsFindOne200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminReportsFindOne200ResponseCodeEnum> {
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
    AdminReportsFindOne200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminReportsFindOne200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminReportsFindOne200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminReportsFindOne200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminReportsFindOne200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminReportsFindOne200Response extends AdminReportsFindOne200Response {
  @override
  final AdminReportResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminReportsFindOne200Response([
    void Function(AdminReportsFindOne200ResponseBuilder)? updates,
  ]) => (AdminReportsFindOne200ResponseBuilder()..update(updates))._build();

  _$AdminReportsFindOne200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminReportsFindOne200Response rebuild(
    void Function(AdminReportsFindOne200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminReportsFindOne200ResponseBuilder toBuilder() =>
      AdminReportsFindOne200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminReportsFindOne200Response &&
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
    return (newBuiltValueToStringHelper(r'AdminReportsFindOne200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminReportsFindOne200ResponseBuilder
    implements
        Builder<
          AdminReportsFindOne200Response,
          AdminReportsFindOne200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminReportsFindOne200Response? _$v;

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

  AdminReportsFindOne200ResponseBuilder() {
    AdminReportsFindOne200Response._defaults(this);
  }

  AdminReportsFindOne200ResponseBuilder get _$this {
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
  void replace(covariant AdminReportsFindOne200Response other) {
    _$v = other as _$AdminReportsFindOne200Response;
  }

  @override
  void update(void Function(AdminReportsFindOne200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminReportsFindOne200Response build() => _build();

  _$AdminReportsFindOne200Response _build() {
    _$AdminReportsFindOne200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminReportsFindOne200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminReportsFindOne200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminReportsFindOne200Response',
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
          r'AdminReportsFindOne200Response',
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
