// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_moderation_hide_content200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminModerationHideContent200ResponseCodeEnum
_$adminModerationHideContent200ResponseCodeEnum_number0 =
    const AdminModerationHideContent200ResponseCodeEnum._('number0');
const AdminModerationHideContent200ResponseCodeEnum
_$adminModerationHideContent200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminModerationHideContent200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

AdminModerationHideContent200ResponseCodeEnum
_$adminModerationHideContent200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminModerationHideContent200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminModerationHideContent200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminModerationHideContent200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminModerationHideContent200ResponseCodeEnum>
_$adminModerationHideContent200ResponseCodeEnumValues =
    BuiltSet<AdminModerationHideContent200ResponseCodeEnum>(
      const <AdminModerationHideContent200ResponseCodeEnum>[
        _$adminModerationHideContent200ResponseCodeEnum_number0,
        _$adminModerationHideContent200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminModerationHideContent200ResponseCodeEnum>
_$adminModerationHideContent200ResponseCodeEnumSerializer =
    _$AdminModerationHideContent200ResponseCodeEnumSerializer();

class _$AdminModerationHideContent200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<AdminModerationHideContent200ResponseCodeEnum> {
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
    AdminModerationHideContent200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminModerationHideContent200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminModerationHideContent200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminModerationHideContent200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminModerationHideContent200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminModerationHideContent200Response
    extends AdminModerationHideContent200Response {
  @override
  final AdminContentModerationResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminModerationHideContent200Response([
    void Function(AdminModerationHideContent200ResponseBuilder)? updates,
  ]) => (AdminModerationHideContent200ResponseBuilder()..update(updates))
      ._build();

  _$AdminModerationHideContent200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminModerationHideContent200Response rebuild(
    void Function(AdminModerationHideContent200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminModerationHideContent200ResponseBuilder toBuilder() =>
      AdminModerationHideContent200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminModerationHideContent200Response &&
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
            r'AdminModerationHideContent200Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminModerationHideContent200ResponseBuilder
    implements
        Builder<
          AdminModerationHideContent200Response,
          AdminModerationHideContent200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminModerationHideContent200Response? _$v;

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

  AdminModerationHideContent200ResponseBuilder() {
    AdminModerationHideContent200Response._defaults(this);
  }

  AdminModerationHideContent200ResponseBuilder get _$this {
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
  void replace(covariant AdminModerationHideContent200Response other) {
    _$v = other as _$AdminModerationHideContent200Response;
  }

  @override
  void update(
    void Function(AdminModerationHideContent200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminModerationHideContent200Response build() => _build();

  _$AdminModerationHideContent200Response _build() {
    _$AdminModerationHideContent200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminModerationHideContent200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminModerationHideContent200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminModerationHideContent200Response',
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
          r'AdminModerationHideContent200Response',
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
