// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_accounts_list200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminAccountsList200ResponseCodeEnum
_$adminAccountsList200ResponseCodeEnum_number0 =
    const AdminAccountsList200ResponseCodeEnum._('number0');
const AdminAccountsList200ResponseCodeEnum
_$adminAccountsList200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminAccountsList200ResponseCodeEnum._('unknownDefaultOpenApi');

AdminAccountsList200ResponseCodeEnum
_$adminAccountsList200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminAccountsList200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminAccountsList200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminAccountsList200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminAccountsList200ResponseCodeEnum>
_$adminAccountsList200ResponseCodeEnumValues =
    BuiltSet<AdminAccountsList200ResponseCodeEnum>(
      const <AdminAccountsList200ResponseCodeEnum>[
        _$adminAccountsList200ResponseCodeEnum_number0,
        _$adminAccountsList200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminAccountsList200ResponseCodeEnum>
_$adminAccountsList200ResponseCodeEnumSerializer =
    _$AdminAccountsList200ResponseCodeEnumSerializer();

class _$AdminAccountsList200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminAccountsList200ResponseCodeEnum> {
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
    AdminAccountsList200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminAccountsList200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminAccountsList200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminAccountsList200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminAccountsList200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminAccountsList200Response extends AdminAccountsList200Response {
  @override
  final AdminAccountsResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminAccountsList200Response([
    void Function(AdminAccountsList200ResponseBuilder)? updates,
  ]) => (AdminAccountsList200ResponseBuilder()..update(updates))._build();

  _$AdminAccountsList200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminAccountsList200Response rebuild(
    void Function(AdminAccountsList200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminAccountsList200ResponseBuilder toBuilder() =>
      AdminAccountsList200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminAccountsList200Response &&
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
    return (newBuiltValueToStringHelper(r'AdminAccountsList200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminAccountsList200ResponseBuilder
    implements
        Builder<
          AdminAccountsList200Response,
          AdminAccountsList200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminAccountsList200Response? _$v;

  AdminAccountsResponseDtoBuilder? _data;
  AdminAccountsResponseDtoBuilder get data =>
      _$this._data ??= AdminAccountsResponseDtoBuilder();
  set data(covariant AdminAccountsResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminAccountsList200ResponseBuilder() {
    AdminAccountsList200Response._defaults(this);
  }

  AdminAccountsList200ResponseBuilder get _$this {
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
  void replace(covariant AdminAccountsList200Response other) {
    _$v = other as _$AdminAccountsList200Response;
  }

  @override
  void update(void Function(AdminAccountsList200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminAccountsList200Response build() => _build();

  _$AdminAccountsList200Response _build() {
    _$AdminAccountsList200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminAccountsList200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminAccountsList200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminAccountsList200Response',
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
          r'AdminAccountsList200Response',
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
