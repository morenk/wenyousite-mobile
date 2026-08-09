// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_index200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminIndex200ResponseCodeEnum _$adminIndex200ResponseCodeEnum_number0 =
    const AdminIndex200ResponseCodeEnum._('number0');
const AdminIndex200ResponseCodeEnum
_$adminIndex200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminIndex200ResponseCodeEnum._('unknownDefaultOpenApi');

AdminIndex200ResponseCodeEnum _$adminIndex200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$adminIndex200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminIndex200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminIndex200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminIndex200ResponseCodeEnum>
_$adminIndex200ResponseCodeEnumValues = BuiltSet<AdminIndex200ResponseCodeEnum>(
  const <AdminIndex200ResponseCodeEnum>[
    _$adminIndex200ResponseCodeEnum_number0,
    _$adminIndex200ResponseCodeEnum_unknownDefaultOpenApi,
  ],
);

Serializer<AdminIndex200ResponseCodeEnum>
_$adminIndex200ResponseCodeEnumSerializer =
    _$AdminIndex200ResponseCodeEnumSerializer();

class _$AdminIndex200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminIndex200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[AdminIndex200ResponseCodeEnum];
  @override
  final String wireName = 'AdminIndex200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminIndex200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminIndex200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminIndex200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminIndex200Response extends AdminIndex200Response {
  @override
  final AdminCapabilityResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminIndex200Response([
    void Function(AdminIndex200ResponseBuilder)? updates,
  ]) => (AdminIndex200ResponseBuilder()..update(updates))._build();

  _$AdminIndex200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminIndex200Response rebuild(
    void Function(AdminIndex200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminIndex200ResponseBuilder toBuilder() =>
      AdminIndex200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminIndex200Response &&
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
    return (newBuiltValueToStringHelper(r'AdminIndex200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminIndex200ResponseBuilder
    implements
        Builder<AdminIndex200Response, AdminIndex200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$AdminIndex200Response? _$v;

  AdminCapabilityResponseDtoBuilder? _data;
  AdminCapabilityResponseDtoBuilder get data =>
      _$this._data ??= AdminCapabilityResponseDtoBuilder();
  set data(covariant AdminCapabilityResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminIndex200ResponseBuilder() {
    AdminIndex200Response._defaults(this);
  }

  AdminIndex200ResponseBuilder get _$this {
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
  void replace(covariant AdminIndex200Response other) {
    _$v = other as _$AdminIndex200Response;
  }

  @override
  void update(void Function(AdminIndex200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminIndex200Response build() => _build();

  _$AdminIndex200Response _build() {
    _$AdminIndex200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminIndex200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminIndex200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminIndex200Response',
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
          r'AdminIndex200Response',
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
