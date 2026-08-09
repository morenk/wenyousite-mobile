// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_moderation_get_user200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminModerationGetUser200ResponseCodeEnum
_$adminModerationGetUser200ResponseCodeEnum_number0 =
    const AdminModerationGetUser200ResponseCodeEnum._('number0');
const AdminModerationGetUser200ResponseCodeEnum
_$adminModerationGetUser200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminModerationGetUser200ResponseCodeEnum._('unknownDefaultOpenApi');

AdminModerationGetUser200ResponseCodeEnum
_$adminModerationGetUser200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminModerationGetUser200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminModerationGetUser200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminModerationGetUser200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminModerationGetUser200ResponseCodeEnum>
_$adminModerationGetUser200ResponseCodeEnumValues =
    BuiltSet<AdminModerationGetUser200ResponseCodeEnum>(
      const <AdminModerationGetUser200ResponseCodeEnum>[
        _$adminModerationGetUser200ResponseCodeEnum_number0,
        _$adminModerationGetUser200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminModerationGetUser200ResponseCodeEnum>
_$adminModerationGetUser200ResponseCodeEnumSerializer =
    _$AdminModerationGetUser200ResponseCodeEnumSerializer();

class _$AdminModerationGetUser200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminModerationGetUser200ResponseCodeEnum> {
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
    AdminModerationGetUser200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminModerationGetUser200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminModerationGetUser200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminModerationGetUser200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminModerationGetUser200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminModerationGetUser200Response
    extends AdminModerationGetUser200Response {
  @override
  final AdminUserModerationResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminModerationGetUser200Response([
    void Function(AdminModerationGetUser200ResponseBuilder)? updates,
  ]) => (AdminModerationGetUser200ResponseBuilder()..update(updates))._build();

  _$AdminModerationGetUser200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminModerationGetUser200Response rebuild(
    void Function(AdminModerationGetUser200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminModerationGetUser200ResponseBuilder toBuilder() =>
      AdminModerationGetUser200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminModerationGetUser200Response &&
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
    return (newBuiltValueToStringHelper(r'AdminModerationGetUser200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminModerationGetUser200ResponseBuilder
    implements
        Builder<
          AdminModerationGetUser200Response,
          AdminModerationGetUser200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminModerationGetUser200Response? _$v;

  AdminUserModerationResponseDtoBuilder? _data;
  AdminUserModerationResponseDtoBuilder get data =>
      _$this._data ??= AdminUserModerationResponseDtoBuilder();
  set data(covariant AdminUserModerationResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminModerationGetUser200ResponseBuilder() {
    AdminModerationGetUser200Response._defaults(this);
  }

  AdminModerationGetUser200ResponseBuilder get _$this {
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
  void replace(covariant AdminModerationGetUser200Response other) {
    _$v = other as _$AdminModerationGetUser200Response;
  }

  @override
  void update(
    void Function(AdminModerationGetUser200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminModerationGetUser200Response build() => _build();

  _$AdminModerationGetUser200Response _build() {
    _$AdminModerationGetUser200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminModerationGetUser200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminModerationGetUser200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminModerationGetUser200Response',
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
          r'AdminModerationGetUser200Response',
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
