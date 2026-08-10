// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_auth_session200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminAuthSession200ResponseCodeEnum
_$adminAuthSession200ResponseCodeEnum_number0 =
    const AdminAuthSession200ResponseCodeEnum._('number0');
const AdminAuthSession200ResponseCodeEnum
_$adminAuthSession200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminAuthSession200ResponseCodeEnum._('unknownDefaultOpenApi');

AdminAuthSession200ResponseCodeEnum
_$adminAuthSession200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminAuthSession200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminAuthSession200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminAuthSession200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminAuthSession200ResponseCodeEnum>
_$adminAuthSession200ResponseCodeEnumValues =
    BuiltSet<AdminAuthSession200ResponseCodeEnum>(
      const <AdminAuthSession200ResponseCodeEnum>[
        _$adminAuthSession200ResponseCodeEnum_number0,
        _$adminAuthSession200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminAuthSession200ResponseCodeEnum>
_$adminAuthSession200ResponseCodeEnumSerializer =
    _$AdminAuthSession200ResponseCodeEnumSerializer();

class _$AdminAuthSession200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminAuthSession200ResponseCodeEnum> {
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
    AdminAuthSession200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminAuthSession200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminAuthSession200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminAuthSession200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminAuthSession200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminAuthSession200Response extends AdminAuthSession200Response {
  @override
  final AdminSessionResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminAuthSession200Response([
    void Function(AdminAuthSession200ResponseBuilder)? updates,
  ]) => (AdminAuthSession200ResponseBuilder()..update(updates))._build();

  _$AdminAuthSession200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminAuthSession200Response rebuild(
    void Function(AdminAuthSession200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminAuthSession200ResponseBuilder toBuilder() =>
      AdminAuthSession200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminAuthSession200Response &&
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
    return (newBuiltValueToStringHelper(r'AdminAuthSession200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminAuthSession200ResponseBuilder
    implements
        Builder<
          AdminAuthSession200Response,
          AdminAuthSession200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminAuthSession200Response? _$v;

  AdminSessionResponseDtoBuilder? _data;
  AdminSessionResponseDtoBuilder get data =>
      _$this._data ??= AdminSessionResponseDtoBuilder();
  set data(covariant AdminSessionResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminAuthSession200ResponseBuilder() {
    AdminAuthSession200Response._defaults(this);
  }

  AdminAuthSession200ResponseBuilder get _$this {
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
  void replace(covariant AdminAuthSession200Response other) {
    _$v = other as _$AdminAuthSession200Response;
  }

  @override
  void update(void Function(AdminAuthSession200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminAuthSession200Response build() => _build();

  _$AdminAuthSession200Response _build() {
    _$AdminAuthSession200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminAuthSession200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminAuthSession200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminAuthSession200Response',
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
          r'AdminAuthSession200Response',
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
