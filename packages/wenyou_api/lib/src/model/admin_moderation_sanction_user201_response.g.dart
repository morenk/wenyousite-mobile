// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_moderation_sanction_user201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminModerationSanctionUser201ResponseCodeEnum
_$adminModerationSanctionUser201ResponseCodeEnum_number0 =
    const AdminModerationSanctionUser201ResponseCodeEnum._('number0');
const AdminModerationSanctionUser201ResponseCodeEnum
_$adminModerationSanctionUser201ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminModerationSanctionUser201ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

AdminModerationSanctionUser201ResponseCodeEnum
_$adminModerationSanctionUser201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminModerationSanctionUser201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminModerationSanctionUser201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminModerationSanctionUser201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminModerationSanctionUser201ResponseCodeEnum>
_$adminModerationSanctionUser201ResponseCodeEnumValues =
    BuiltSet<AdminModerationSanctionUser201ResponseCodeEnum>(
      const <AdminModerationSanctionUser201ResponseCodeEnum>[
        _$adminModerationSanctionUser201ResponseCodeEnum_number0,
        _$adminModerationSanctionUser201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminModerationSanctionUser201ResponseCodeEnum>
_$adminModerationSanctionUser201ResponseCodeEnumSerializer =
    _$AdminModerationSanctionUser201ResponseCodeEnumSerializer();

class _$AdminModerationSanctionUser201ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<AdminModerationSanctionUser201ResponseCodeEnum> {
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
    AdminModerationSanctionUser201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminModerationSanctionUser201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminModerationSanctionUser201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminModerationSanctionUser201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminModerationSanctionUser201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminModerationSanctionUser201Response
    extends AdminModerationSanctionUser201Response {
  @override
  final AdminUserSanctionResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminModerationSanctionUser201Response([
    void Function(AdminModerationSanctionUser201ResponseBuilder)? updates,
  ]) => (AdminModerationSanctionUser201ResponseBuilder()..update(updates))
      ._build();

  _$AdminModerationSanctionUser201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminModerationSanctionUser201Response rebuild(
    void Function(AdminModerationSanctionUser201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminModerationSanctionUser201ResponseBuilder toBuilder() =>
      AdminModerationSanctionUser201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminModerationSanctionUser201Response &&
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
            r'AdminModerationSanctionUser201Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminModerationSanctionUser201ResponseBuilder
    implements
        Builder<
          AdminModerationSanctionUser201Response,
          AdminModerationSanctionUser201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminModerationSanctionUser201Response? _$v;

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

  AdminModerationSanctionUser201ResponseBuilder() {
    AdminModerationSanctionUser201Response._defaults(this);
  }

  AdminModerationSanctionUser201ResponseBuilder get _$this {
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
  void replace(covariant AdminModerationSanctionUser201Response other) {
    _$v = other as _$AdminModerationSanctionUser201Response;
  }

  @override
  void update(
    void Function(AdminModerationSanctionUser201ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminModerationSanctionUser201Response build() => _build();

  _$AdminModerationSanctionUser201Response _build() {
    _$AdminModerationSanctionUser201Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminModerationSanctionUser201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminModerationSanctionUser201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminModerationSanctionUser201Response',
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
          r'AdminModerationSanctionUser201Response',
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
