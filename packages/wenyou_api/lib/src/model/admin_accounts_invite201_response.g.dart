// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_accounts_invite201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminAccountsInvite201ResponseCodeEnum
_$adminAccountsInvite201ResponseCodeEnum_number0 =
    const AdminAccountsInvite201ResponseCodeEnum._('number0');
const AdminAccountsInvite201ResponseCodeEnum
_$adminAccountsInvite201ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminAccountsInvite201ResponseCodeEnum._('unknownDefaultOpenApi');

AdminAccountsInvite201ResponseCodeEnum
_$adminAccountsInvite201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminAccountsInvite201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminAccountsInvite201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminAccountsInvite201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminAccountsInvite201ResponseCodeEnum>
_$adminAccountsInvite201ResponseCodeEnumValues =
    BuiltSet<AdminAccountsInvite201ResponseCodeEnum>(
      const <AdminAccountsInvite201ResponseCodeEnum>[
        _$adminAccountsInvite201ResponseCodeEnum_number0,
        _$adminAccountsInvite201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminAccountsInvite201ResponseCodeEnum>
_$adminAccountsInvite201ResponseCodeEnumSerializer =
    _$AdminAccountsInvite201ResponseCodeEnumSerializer();

class _$AdminAccountsInvite201ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminAccountsInvite201ResponseCodeEnum> {
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
    AdminAccountsInvite201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminAccountsInvite201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminAccountsInvite201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminAccountsInvite201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminAccountsInvite201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminAccountsInvite201Response extends AdminAccountsInvite201Response {
  @override
  final AdminInviteCreatedResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminAccountsInvite201Response([
    void Function(AdminAccountsInvite201ResponseBuilder)? updates,
  ]) => (AdminAccountsInvite201ResponseBuilder()..update(updates))._build();

  _$AdminAccountsInvite201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminAccountsInvite201Response rebuild(
    void Function(AdminAccountsInvite201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminAccountsInvite201ResponseBuilder toBuilder() =>
      AdminAccountsInvite201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminAccountsInvite201Response &&
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
    return (newBuiltValueToStringHelper(r'AdminAccountsInvite201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminAccountsInvite201ResponseBuilder
    implements
        Builder<
          AdminAccountsInvite201Response,
          AdminAccountsInvite201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminAccountsInvite201Response? _$v;

  AdminInviteCreatedResponseDtoBuilder? _data;
  AdminInviteCreatedResponseDtoBuilder get data =>
      _$this._data ??= AdminInviteCreatedResponseDtoBuilder();
  set data(covariant AdminInviteCreatedResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminAccountsInvite201ResponseBuilder() {
    AdminAccountsInvite201Response._defaults(this);
  }

  AdminAccountsInvite201ResponseBuilder get _$this {
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
  void replace(covariant AdminAccountsInvite201Response other) {
    _$v = other as _$AdminAccountsInvite201Response;
  }

  @override
  void update(void Function(AdminAccountsInvite201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminAccountsInvite201Response build() => _build();

  _$AdminAccountsInvite201Response _build() {
    _$AdminAccountsInvite201Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminAccountsInvite201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminAccountsInvite201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminAccountsInvite201Response',
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
          r'AdminAccountsInvite201Response',
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
