// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_dashboard_timeseries200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminDashboardTimeseries200ResponseCodeEnum
_$adminDashboardTimeseries200ResponseCodeEnum_number0 =
    const AdminDashboardTimeseries200ResponseCodeEnum._('number0');
const AdminDashboardTimeseries200ResponseCodeEnum
_$adminDashboardTimeseries200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminDashboardTimeseries200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

AdminDashboardTimeseries200ResponseCodeEnum
_$adminDashboardTimeseries200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminDashboardTimeseries200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminDashboardTimeseries200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminDashboardTimeseries200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminDashboardTimeseries200ResponseCodeEnum>
_$adminDashboardTimeseries200ResponseCodeEnumValues =
    BuiltSet<AdminDashboardTimeseries200ResponseCodeEnum>(
      const <AdminDashboardTimeseries200ResponseCodeEnum>[
        _$adminDashboardTimeseries200ResponseCodeEnum_number0,
        _$adminDashboardTimeseries200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminDashboardTimeseries200ResponseCodeEnum>
_$adminDashboardTimeseries200ResponseCodeEnumSerializer =
    _$AdminDashboardTimeseries200ResponseCodeEnumSerializer();

class _$AdminDashboardTimeseries200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<AdminDashboardTimeseries200ResponseCodeEnum> {
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
    AdminDashboardTimeseries200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminDashboardTimeseries200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminDashboardTimeseries200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminDashboardTimeseries200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminDashboardTimeseries200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminDashboardTimeseries200Response
    extends AdminDashboardTimeseries200Response {
  @override
  final AdminDashboardTimeseriesResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminDashboardTimeseries200Response([
    void Function(AdminDashboardTimeseries200ResponseBuilder)? updates,
  ]) =>
      (AdminDashboardTimeseries200ResponseBuilder()..update(updates))._build();

  _$AdminDashboardTimeseries200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminDashboardTimeseries200Response rebuild(
    void Function(AdminDashboardTimeseries200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminDashboardTimeseries200ResponseBuilder toBuilder() =>
      AdminDashboardTimeseries200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminDashboardTimeseries200Response &&
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
    return (newBuiltValueToStringHelper(r'AdminDashboardTimeseries200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminDashboardTimeseries200ResponseBuilder
    implements
        Builder<
          AdminDashboardTimeseries200Response,
          AdminDashboardTimeseries200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminDashboardTimeseries200Response? _$v;

  AdminDashboardTimeseriesResponseDtoBuilder? _data;
  AdminDashboardTimeseriesResponseDtoBuilder get data =>
      _$this._data ??= AdminDashboardTimeseriesResponseDtoBuilder();
  set data(covariant AdminDashboardTimeseriesResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminDashboardTimeseries200ResponseBuilder() {
    AdminDashboardTimeseries200Response._defaults(this);
  }

  AdminDashboardTimeseries200ResponseBuilder get _$this {
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
  void replace(covariant AdminDashboardTimeseries200Response other) {
    _$v = other as _$AdminDashboardTimeseries200Response;
  }

  @override
  void update(
    void Function(AdminDashboardTimeseries200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminDashboardTimeseries200Response build() => _build();

  _$AdminDashboardTimeseries200Response _build() {
    _$AdminDashboardTimeseries200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminDashboardTimeseries200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminDashboardTimeseries200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminDashboardTimeseries200Response',
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
          r'AdminDashboardTimeseries200Response',
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
