// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_accounts_transfer201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminAccountsTransfer201ResponseCodeEnum
_$adminAccountsTransfer201ResponseCodeEnum_number0 =
    const AdminAccountsTransfer201ResponseCodeEnum._('number0');
const AdminAccountsTransfer201ResponseCodeEnum
_$adminAccountsTransfer201ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminAccountsTransfer201ResponseCodeEnum._('unknownDefaultOpenApi');

AdminAccountsTransfer201ResponseCodeEnum
_$adminAccountsTransfer201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminAccountsTransfer201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminAccountsTransfer201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminAccountsTransfer201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminAccountsTransfer201ResponseCodeEnum>
_$adminAccountsTransfer201ResponseCodeEnumValues =
    BuiltSet<AdminAccountsTransfer201ResponseCodeEnum>(
      const <AdminAccountsTransfer201ResponseCodeEnum>[
        _$adminAccountsTransfer201ResponseCodeEnum_number0,
        _$adminAccountsTransfer201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminAccountsTransfer201ResponseCodeEnum>
_$adminAccountsTransfer201ResponseCodeEnumSerializer =
    _$AdminAccountsTransfer201ResponseCodeEnumSerializer();

class _$AdminAccountsTransfer201ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminAccountsTransfer201ResponseCodeEnum> {
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
    AdminAccountsTransfer201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminAccountsTransfer201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminAccountsTransfer201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminAccountsTransfer201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminAccountsTransfer201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminAccountsTransfer201Response
    extends AdminAccountsTransfer201Response {
  @override
  final MessageResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminAccountsTransfer201Response([
    void Function(AdminAccountsTransfer201ResponseBuilder)? updates,
  ]) => (AdminAccountsTransfer201ResponseBuilder()..update(updates))._build();

  _$AdminAccountsTransfer201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminAccountsTransfer201Response rebuild(
    void Function(AdminAccountsTransfer201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminAccountsTransfer201ResponseBuilder toBuilder() =>
      AdminAccountsTransfer201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminAccountsTransfer201Response &&
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
    return (newBuiltValueToStringHelper(r'AdminAccountsTransfer201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminAccountsTransfer201ResponseBuilder
    implements
        Builder<
          AdminAccountsTransfer201Response,
          AdminAccountsTransfer201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminAccountsTransfer201Response? _$v;

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

  AdminAccountsTransfer201ResponseBuilder() {
    AdminAccountsTransfer201Response._defaults(this);
  }

  AdminAccountsTransfer201ResponseBuilder get _$this {
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
  void replace(covariant AdminAccountsTransfer201Response other) {
    _$v = other as _$AdminAccountsTransfer201Response;
  }

  @override
  void update(void Function(AdminAccountsTransfer201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminAccountsTransfer201Response build() => _build();

  _$AdminAccountsTransfer201Response _build() {
    _$AdminAccountsTransfer201Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminAccountsTransfer201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminAccountsTransfer201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminAccountsTransfer201Response',
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
          r'AdminAccountsTransfer201Response',
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
