// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_moderation_restore_content200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminModerationRestoreContent200ResponseCodeEnum
_$adminModerationRestoreContent200ResponseCodeEnum_number0 =
    const AdminModerationRestoreContent200ResponseCodeEnum._('number0');
const AdminModerationRestoreContent200ResponseCodeEnum
_$adminModerationRestoreContent200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminModerationRestoreContent200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

AdminModerationRestoreContent200ResponseCodeEnum
_$adminModerationRestoreContent200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminModerationRestoreContent200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminModerationRestoreContent200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminModerationRestoreContent200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminModerationRestoreContent200ResponseCodeEnum>
_$adminModerationRestoreContent200ResponseCodeEnumValues =
    BuiltSet<AdminModerationRestoreContent200ResponseCodeEnum>(const <
      AdminModerationRestoreContent200ResponseCodeEnum
    >[
      _$adminModerationRestoreContent200ResponseCodeEnum_number0,
      _$adminModerationRestoreContent200ResponseCodeEnum_unknownDefaultOpenApi,
    ]);

Serializer<AdminModerationRestoreContent200ResponseCodeEnum>
_$adminModerationRestoreContent200ResponseCodeEnumSerializer =
    _$AdminModerationRestoreContent200ResponseCodeEnumSerializer();

class _$AdminModerationRestoreContent200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<AdminModerationRestoreContent200ResponseCodeEnum> {
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
    AdminModerationRestoreContent200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminModerationRestoreContent200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminModerationRestoreContent200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminModerationRestoreContent200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminModerationRestoreContent200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminModerationRestoreContent200Response
    extends AdminModerationRestoreContent200Response {
  @override
  final AdminContentModerationResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminModerationRestoreContent200Response([
    void Function(AdminModerationRestoreContent200ResponseBuilder)? updates,
  ]) => (AdminModerationRestoreContent200ResponseBuilder()..update(updates))
      ._build();

  _$AdminModerationRestoreContent200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminModerationRestoreContent200Response rebuild(
    void Function(AdminModerationRestoreContent200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminModerationRestoreContent200ResponseBuilder toBuilder() =>
      AdminModerationRestoreContent200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminModerationRestoreContent200Response &&
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
            r'AdminModerationRestoreContent200Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminModerationRestoreContent200ResponseBuilder
    implements
        Builder<
          AdminModerationRestoreContent200Response,
          AdminModerationRestoreContent200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminModerationRestoreContent200Response? _$v;

  AdminContentModerationResponseDtoBuilder? _data;
  AdminContentModerationResponseDtoBuilder get data =>
      _$this._data ??= AdminContentModerationResponseDtoBuilder();
  set data(covariant AdminContentModerationResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminModerationRestoreContent200ResponseBuilder() {
    AdminModerationRestoreContent200Response._defaults(this);
  }

  AdminModerationRestoreContent200ResponseBuilder get _$this {
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
  void replace(covariant AdminModerationRestoreContent200Response other) {
    _$v = other as _$AdminModerationRestoreContent200Response;
  }

  @override
  void update(
    void Function(AdminModerationRestoreContent200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminModerationRestoreContent200Response build() => _build();

  _$AdminModerationRestoreContent200Response _build() {
    _$AdminModerationRestoreContent200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminModerationRestoreContent200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminModerationRestoreContent200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminModerationRestoreContent200Response',
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
          r'AdminModerationRestoreContent200Response',
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
