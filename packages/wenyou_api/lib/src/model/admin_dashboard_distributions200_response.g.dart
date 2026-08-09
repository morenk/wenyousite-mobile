// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_dashboard_distributions200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminDashboardDistributions200ResponseCodeEnum
_$adminDashboardDistributions200ResponseCodeEnum_number0 =
    const AdminDashboardDistributions200ResponseCodeEnum._('number0');
const AdminDashboardDistributions200ResponseCodeEnum
_$adminDashboardDistributions200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminDashboardDistributions200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

AdminDashboardDistributions200ResponseCodeEnum
_$adminDashboardDistributions200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminDashboardDistributions200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminDashboardDistributions200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminDashboardDistributions200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminDashboardDistributions200ResponseCodeEnum>
_$adminDashboardDistributions200ResponseCodeEnumValues =
    BuiltSet<AdminDashboardDistributions200ResponseCodeEnum>(
      const <AdminDashboardDistributions200ResponseCodeEnum>[
        _$adminDashboardDistributions200ResponseCodeEnum_number0,
        _$adminDashboardDistributions200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminDashboardDistributions200ResponseCodeEnum>
_$adminDashboardDistributions200ResponseCodeEnumSerializer =
    _$AdminDashboardDistributions200ResponseCodeEnumSerializer();

class _$AdminDashboardDistributions200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<AdminDashboardDistributions200ResponseCodeEnum> {
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
    AdminDashboardDistributions200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminDashboardDistributions200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminDashboardDistributions200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminDashboardDistributions200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminDashboardDistributions200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminDashboardDistributions200Response
    extends AdminDashboardDistributions200Response {
  @override
  final AdminDashboardDistributionsResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminDashboardDistributions200Response([
    void Function(AdminDashboardDistributions200ResponseBuilder)? updates,
  ]) => (AdminDashboardDistributions200ResponseBuilder()..update(updates))
      ._build();

  _$AdminDashboardDistributions200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminDashboardDistributions200Response rebuild(
    void Function(AdminDashboardDistributions200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminDashboardDistributions200ResponseBuilder toBuilder() =>
      AdminDashboardDistributions200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminDashboardDistributions200Response &&
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
    return (newBuiltValueToStringHelper(
            r'AdminDashboardDistributions200Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminDashboardDistributions200ResponseBuilder
    implements
        Builder<
          AdminDashboardDistributions200Response,
          AdminDashboardDistributions200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminDashboardDistributions200Response? _$v;

  AdminDashboardDistributionsResponseDtoBuilder? _data;
  AdminDashboardDistributionsResponseDtoBuilder get data =>
      _$this._data ??= AdminDashboardDistributionsResponseDtoBuilder();
  set data(covariant AdminDashboardDistributionsResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminDashboardDistributions200ResponseBuilder() {
    AdminDashboardDistributions200Response._defaults(this);
  }

  AdminDashboardDistributions200ResponseBuilder get _$this {
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
  void replace(covariant AdminDashboardDistributions200Response other) {
    _$v = other as _$AdminDashboardDistributions200Response;
  }

  @override
  void update(
    void Function(AdminDashboardDistributions200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminDashboardDistributions200Response build() => _build();

  _$AdminDashboardDistributions200Response _build() {
    _$AdminDashboardDistributions200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminDashboardDistributions200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminDashboardDistributions200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminDashboardDistributions200Response',
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
          r'AdminDashboardDistributions200Response',
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
