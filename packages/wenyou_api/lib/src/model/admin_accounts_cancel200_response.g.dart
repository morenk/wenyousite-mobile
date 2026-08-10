// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_accounts_cancel200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminAccountsCancel200ResponseCodeEnum
_$adminAccountsCancel200ResponseCodeEnum_number0 =
    const AdminAccountsCancel200ResponseCodeEnum._('number0');
const AdminAccountsCancel200ResponseCodeEnum
_$adminAccountsCancel200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminAccountsCancel200ResponseCodeEnum._('unknownDefaultOpenApi');

AdminAccountsCancel200ResponseCodeEnum
_$adminAccountsCancel200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminAccountsCancel200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminAccountsCancel200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminAccountsCancel200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminAccountsCancel200ResponseCodeEnum>
_$adminAccountsCancel200ResponseCodeEnumValues =
    BuiltSet<AdminAccountsCancel200ResponseCodeEnum>(
      const <AdminAccountsCancel200ResponseCodeEnum>[
        _$adminAccountsCancel200ResponseCodeEnum_number0,
        _$adminAccountsCancel200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminAccountsCancel200ResponseCodeEnum>
_$adminAccountsCancel200ResponseCodeEnumSerializer =
    _$AdminAccountsCancel200ResponseCodeEnumSerializer();

class _$AdminAccountsCancel200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminAccountsCancel200ResponseCodeEnum> {
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
    AdminAccountsCancel200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminAccountsCancel200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminAccountsCancel200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminAccountsCancel200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminAccountsCancel200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminAccountsCancel200Response extends AdminAccountsCancel200Response {
  @override
  final MessageResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminAccountsCancel200Response([
    void Function(AdminAccountsCancel200ResponseBuilder)? updates,
  ]) => (AdminAccountsCancel200ResponseBuilder()..update(updates))._build();

  _$AdminAccountsCancel200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminAccountsCancel200Response rebuild(
    void Function(AdminAccountsCancel200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminAccountsCancel200ResponseBuilder toBuilder() =>
      AdminAccountsCancel200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminAccountsCancel200Response &&
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
    return (newBuiltValueToStringHelper(r'AdminAccountsCancel200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminAccountsCancel200ResponseBuilder
    implements
        Builder<
          AdminAccountsCancel200Response,
          AdminAccountsCancel200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminAccountsCancel200Response? _$v;

  MessageResponseDtoBuilder? _data;
  MessageResponseDtoBuilder get data =>
      _$this._data ??= MessageResponseDtoBuilder();
  set data(covariant MessageResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminAccountsCancel200ResponseBuilder() {
    AdminAccountsCancel200Response._defaults(this);
  }

  AdminAccountsCancel200ResponseBuilder get _$this {
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
  void replace(covariant AdminAccountsCancel200Response other) {
    _$v = other as _$AdminAccountsCancel200Response;
  }

  @override
  void update(void Function(AdminAccountsCancel200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminAccountsCancel200Response build() => _build();

  _$AdminAccountsCancel200Response _build() {
    _$AdminAccountsCancel200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminAccountsCancel200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminAccountsCancel200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminAccountsCancel200Response',
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
          r'AdminAccountsCancel200Response',
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
