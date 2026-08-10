// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_accounts_revoke200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminAccountsRevoke200ResponseCodeEnum
_$adminAccountsRevoke200ResponseCodeEnum_number0 =
    const AdminAccountsRevoke200ResponseCodeEnum._('number0');
const AdminAccountsRevoke200ResponseCodeEnum
_$adminAccountsRevoke200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminAccountsRevoke200ResponseCodeEnum._('unknownDefaultOpenApi');

AdminAccountsRevoke200ResponseCodeEnum
_$adminAccountsRevoke200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminAccountsRevoke200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminAccountsRevoke200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminAccountsRevoke200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminAccountsRevoke200ResponseCodeEnum>
_$adminAccountsRevoke200ResponseCodeEnumValues =
    BuiltSet<AdminAccountsRevoke200ResponseCodeEnum>(
      const <AdminAccountsRevoke200ResponseCodeEnum>[
        _$adminAccountsRevoke200ResponseCodeEnum_number0,
        _$adminAccountsRevoke200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminAccountsRevoke200ResponseCodeEnum>
_$adminAccountsRevoke200ResponseCodeEnumSerializer =
    _$AdminAccountsRevoke200ResponseCodeEnumSerializer();

class _$AdminAccountsRevoke200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminAccountsRevoke200ResponseCodeEnum> {
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
    AdminAccountsRevoke200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminAccountsRevoke200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminAccountsRevoke200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminAccountsRevoke200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminAccountsRevoke200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminAccountsRevoke200Response extends AdminAccountsRevoke200Response {
  @override
  final MessageResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminAccountsRevoke200Response([
    void Function(AdminAccountsRevoke200ResponseBuilder)? updates,
  ]) => (AdminAccountsRevoke200ResponseBuilder()..update(updates))._build();

  _$AdminAccountsRevoke200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminAccountsRevoke200Response rebuild(
    void Function(AdminAccountsRevoke200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminAccountsRevoke200ResponseBuilder toBuilder() =>
      AdminAccountsRevoke200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminAccountsRevoke200Response &&
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
    return (newBuiltValueToStringHelper(r'AdminAccountsRevoke200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminAccountsRevoke200ResponseBuilder
    implements
        Builder<
          AdminAccountsRevoke200Response,
          AdminAccountsRevoke200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminAccountsRevoke200Response? _$v;

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

  AdminAccountsRevoke200ResponseBuilder() {
    AdminAccountsRevoke200Response._defaults(this);
  }

  AdminAccountsRevoke200ResponseBuilder get _$this {
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
  void replace(covariant AdminAccountsRevoke200Response other) {
    _$v = other as _$AdminAccountsRevoke200Response;
  }

  @override
  void update(void Function(AdminAccountsRevoke200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminAccountsRevoke200Response build() => _build();

  _$AdminAccountsRevoke200Response _build() {
    _$AdminAccountsRevoke200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminAccountsRevoke200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminAccountsRevoke200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminAccountsRevoke200Response',
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
          r'AdminAccountsRevoke200Response',
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
