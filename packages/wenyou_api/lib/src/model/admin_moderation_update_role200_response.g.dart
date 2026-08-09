// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_moderation_update_role200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminModerationUpdateRole200ResponseCodeEnum
_$adminModerationUpdateRole200ResponseCodeEnum_number0 =
    const AdminModerationUpdateRole200ResponseCodeEnum._('number0');
const AdminModerationUpdateRole200ResponseCodeEnum
_$adminModerationUpdateRole200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminModerationUpdateRole200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

AdminModerationUpdateRole200ResponseCodeEnum
_$adminModerationUpdateRole200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminModerationUpdateRole200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminModerationUpdateRole200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminModerationUpdateRole200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminModerationUpdateRole200ResponseCodeEnum>
_$adminModerationUpdateRole200ResponseCodeEnumValues =
    BuiltSet<AdminModerationUpdateRole200ResponseCodeEnum>(
      const <AdminModerationUpdateRole200ResponseCodeEnum>[
        _$adminModerationUpdateRole200ResponseCodeEnum_number0,
        _$adminModerationUpdateRole200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminModerationUpdateRole200ResponseCodeEnum>
_$adminModerationUpdateRole200ResponseCodeEnumSerializer =
    _$AdminModerationUpdateRole200ResponseCodeEnumSerializer();

class _$AdminModerationUpdateRole200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<AdminModerationUpdateRole200ResponseCodeEnum> {
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
    AdminModerationUpdateRole200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminModerationUpdateRole200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminModerationUpdateRole200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminModerationUpdateRole200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminModerationUpdateRole200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminModerationUpdateRole200Response
    extends AdminModerationUpdateRole200Response {
  @override
  final AdminUserModerationResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminModerationUpdateRole200Response([
    void Function(AdminModerationUpdateRole200ResponseBuilder)? updates,
  ]) =>
      (AdminModerationUpdateRole200ResponseBuilder()..update(updates))._build();

  _$AdminModerationUpdateRole200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminModerationUpdateRole200Response rebuild(
    void Function(AdminModerationUpdateRole200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminModerationUpdateRole200ResponseBuilder toBuilder() =>
      AdminModerationUpdateRole200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminModerationUpdateRole200Response &&
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
    return (newBuiltValueToStringHelper(r'AdminModerationUpdateRole200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminModerationUpdateRole200ResponseBuilder
    implements
        Builder<
          AdminModerationUpdateRole200Response,
          AdminModerationUpdateRole200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminModerationUpdateRole200Response? _$v;

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

  AdminModerationUpdateRole200ResponseBuilder() {
    AdminModerationUpdateRole200Response._defaults(this);
  }

  AdminModerationUpdateRole200ResponseBuilder get _$this {
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
  void replace(covariant AdminModerationUpdateRole200Response other) {
    _$v = other as _$AdminModerationUpdateRole200Response;
  }

  @override
  void update(
    void Function(AdminModerationUpdateRole200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminModerationUpdateRole200Response build() => _build();

  _$AdminModerationUpdateRole200Response _build() {
    _$AdminModerationUpdateRole200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminModerationUpdateRole200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminModerationUpdateRole200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminModerationUpdateRole200Response',
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
          r'AdminModerationUpdateRole200Response',
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
