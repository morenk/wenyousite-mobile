// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_dashboard_overview200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminDashboardOverview200ResponseCodeEnum
_$adminDashboardOverview200ResponseCodeEnum_number0 =
    const AdminDashboardOverview200ResponseCodeEnum._('number0');
const AdminDashboardOverview200ResponseCodeEnum
_$adminDashboardOverview200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminDashboardOverview200ResponseCodeEnum._('unknownDefaultOpenApi');

AdminDashboardOverview200ResponseCodeEnum
_$adminDashboardOverview200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminDashboardOverview200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminDashboardOverview200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminDashboardOverview200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminDashboardOverview200ResponseCodeEnum>
_$adminDashboardOverview200ResponseCodeEnumValues =
    BuiltSet<AdminDashboardOverview200ResponseCodeEnum>(
      const <AdminDashboardOverview200ResponseCodeEnum>[
        _$adminDashboardOverview200ResponseCodeEnum_number0,
        _$adminDashboardOverview200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminDashboardOverview200ResponseCodeEnum>
_$adminDashboardOverview200ResponseCodeEnumSerializer =
    _$AdminDashboardOverview200ResponseCodeEnumSerializer();

class _$AdminDashboardOverview200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminDashboardOverview200ResponseCodeEnum> {
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
    AdminDashboardOverview200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminDashboardOverview200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminDashboardOverview200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminDashboardOverview200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminDashboardOverview200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminDashboardOverview200Response
    extends AdminDashboardOverview200Response {
  @override
  final AdminDashboardOverviewResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminDashboardOverview200Response([
    void Function(AdminDashboardOverview200ResponseBuilder)? updates,
  ]) => (AdminDashboardOverview200ResponseBuilder()..update(updates))._build();

  _$AdminDashboardOverview200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminDashboardOverview200Response rebuild(
    void Function(AdminDashboardOverview200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminDashboardOverview200ResponseBuilder toBuilder() =>
      AdminDashboardOverview200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminDashboardOverview200Response &&
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
    return (newBuiltValueToStringHelper(r'AdminDashboardOverview200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminDashboardOverview200ResponseBuilder
    implements
        Builder<
          AdminDashboardOverview200Response,
          AdminDashboardOverview200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminDashboardOverview200Response? _$v;

  AdminDashboardOverviewResponseDtoBuilder? _data;
  AdminDashboardOverviewResponseDtoBuilder get data =>
      _$this._data ??= AdminDashboardOverviewResponseDtoBuilder();
  set data(covariant AdminDashboardOverviewResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminDashboardOverview200ResponseBuilder() {
    AdminDashboardOverview200Response._defaults(this);
  }

  AdminDashboardOverview200ResponseBuilder get _$this {
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
  void replace(covariant AdminDashboardOverview200Response other) {
    _$v = other as _$AdminDashboardOverview200Response;
  }

  @override
  void update(
    void Function(AdminDashboardOverview200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminDashboardOverview200Response build() => _build();

  _$AdminDashboardOverview200Response _build() {
    _$AdminDashboardOverview200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminDashboardOverview200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminDashboardOverview200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminDashboardOverview200Response',
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
          r'AdminDashboardOverview200Response',
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
