// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_moderation_revoke_sanction200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminModerationRevokeSanction200ResponseCodeEnum
_$adminModerationRevokeSanction200ResponseCodeEnum_number0 =
    const AdminModerationRevokeSanction200ResponseCodeEnum._('number0');
const AdminModerationRevokeSanction200ResponseCodeEnum
_$adminModerationRevokeSanction200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminModerationRevokeSanction200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

AdminModerationRevokeSanction200ResponseCodeEnum
_$adminModerationRevokeSanction200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminModerationRevokeSanction200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminModerationRevokeSanction200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminModerationRevokeSanction200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminModerationRevokeSanction200ResponseCodeEnum>
_$adminModerationRevokeSanction200ResponseCodeEnumValues =
    BuiltSet<AdminModerationRevokeSanction200ResponseCodeEnum>(const <
      AdminModerationRevokeSanction200ResponseCodeEnum
    >[
      _$adminModerationRevokeSanction200ResponseCodeEnum_number0,
      _$adminModerationRevokeSanction200ResponseCodeEnum_unknownDefaultOpenApi,
    ]);

Serializer<AdminModerationRevokeSanction200ResponseCodeEnum>
_$adminModerationRevokeSanction200ResponseCodeEnumSerializer =
    _$AdminModerationRevokeSanction200ResponseCodeEnumSerializer();

class _$AdminModerationRevokeSanction200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<AdminModerationRevokeSanction200ResponseCodeEnum> {
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
    AdminModerationRevokeSanction200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminModerationRevokeSanction200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminModerationRevokeSanction200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminModerationRevokeSanction200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminModerationRevokeSanction200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminModerationRevokeSanction200Response
    extends AdminModerationRevokeSanction200Response {
  @override
  final AdminUserSanctionResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminModerationRevokeSanction200Response([
    void Function(AdminModerationRevokeSanction200ResponseBuilder)? updates,
  ]) => (AdminModerationRevokeSanction200ResponseBuilder()..update(updates))
      ._build();

  _$AdminModerationRevokeSanction200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminModerationRevokeSanction200Response rebuild(
    void Function(AdminModerationRevokeSanction200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminModerationRevokeSanction200ResponseBuilder toBuilder() =>
      AdminModerationRevokeSanction200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminModerationRevokeSanction200Response &&
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
            r'AdminModerationRevokeSanction200Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminModerationRevokeSanction200ResponseBuilder
    implements
        Builder<
          AdminModerationRevokeSanction200Response,
          AdminModerationRevokeSanction200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminModerationRevokeSanction200Response? _$v;

  AdminUserSanctionResponseDtoBuilder? _data;
  AdminUserSanctionResponseDtoBuilder get data =>
      _$this._data ??= AdminUserSanctionResponseDtoBuilder();
  set data(covariant AdminUserSanctionResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminModerationRevokeSanction200ResponseBuilder() {
    AdminModerationRevokeSanction200Response._defaults(this);
  }

  AdminModerationRevokeSanction200ResponseBuilder get _$this {
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
  void replace(covariant AdminModerationRevokeSanction200Response other) {
    _$v = other as _$AdminModerationRevokeSanction200Response;
  }

  @override
  void update(
    void Function(AdminModerationRevokeSanction200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminModerationRevokeSanction200Response build() => _build();

  _$AdminModerationRevokeSanction200Response _build() {
    _$AdminModerationRevokeSanction200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminModerationRevokeSanction200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminModerationRevokeSanction200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminModerationRevokeSanction200Response',
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
          r'AdminModerationRevokeSanction200Response',
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
