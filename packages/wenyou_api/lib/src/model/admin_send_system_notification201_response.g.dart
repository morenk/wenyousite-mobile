// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_send_system_notification201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminSendSystemNotification201ResponseCodeEnum
_$adminSendSystemNotification201ResponseCodeEnum_number0 =
    const AdminSendSystemNotification201ResponseCodeEnum._('number0');
const AdminSendSystemNotification201ResponseCodeEnum
_$adminSendSystemNotification201ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminSendSystemNotification201ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

AdminSendSystemNotification201ResponseCodeEnum
_$adminSendSystemNotification201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminSendSystemNotification201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminSendSystemNotification201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminSendSystemNotification201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminSendSystemNotification201ResponseCodeEnum>
_$adminSendSystemNotification201ResponseCodeEnumValues =
    BuiltSet<AdminSendSystemNotification201ResponseCodeEnum>(
      const <AdminSendSystemNotification201ResponseCodeEnum>[
        _$adminSendSystemNotification201ResponseCodeEnum_number0,
        _$adminSendSystemNotification201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminSendSystemNotification201ResponseCodeEnum>
_$adminSendSystemNotification201ResponseCodeEnumSerializer =
    _$AdminSendSystemNotification201ResponseCodeEnumSerializer();

class _$AdminSendSystemNotification201ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<AdminSendSystemNotification201ResponseCodeEnum> {
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
    AdminSendSystemNotification201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminSendSystemNotification201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminSendSystemNotification201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminSendSystemNotification201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminSendSystemNotification201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminSendSystemNotification201Response
    extends AdminSendSystemNotification201Response {
  @override
  final AdminRecipientCountResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminSendSystemNotification201Response([
    void Function(AdminSendSystemNotification201ResponseBuilder)? updates,
  ]) => (AdminSendSystemNotification201ResponseBuilder()..update(updates))
      ._build();

  _$AdminSendSystemNotification201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminSendSystemNotification201Response rebuild(
    void Function(AdminSendSystemNotification201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminSendSystemNotification201ResponseBuilder toBuilder() =>
      AdminSendSystemNotification201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminSendSystemNotification201Response &&
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
            r'AdminSendSystemNotification201Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminSendSystemNotification201ResponseBuilder
    implements
        Builder<
          AdminSendSystemNotification201Response,
          AdminSendSystemNotification201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminSendSystemNotification201Response? _$v;

  AdminRecipientCountResponseDtoBuilder? _data;
  AdminRecipientCountResponseDtoBuilder get data =>
      _$this._data ??= AdminRecipientCountResponseDtoBuilder();
  set data(covariant AdminRecipientCountResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminSendSystemNotification201ResponseBuilder() {
    AdminSendSystemNotification201Response._defaults(this);
  }

  AdminSendSystemNotification201ResponseBuilder get _$this {
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
  void replace(covariant AdminSendSystemNotification201Response other) {
    _$v = other as _$AdminSendSystemNotification201Response;
  }

  @override
  void update(
    void Function(AdminSendSystemNotification201ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminSendSystemNotification201Response build() => _build();

  _$AdminSendSystemNotification201Response _build() {
    _$AdminSendSystemNotification201Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminSendSystemNotification201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminSendSystemNotification201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminSendSystemNotification201Response',
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
          r'AdminSendSystemNotification201Response',
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
