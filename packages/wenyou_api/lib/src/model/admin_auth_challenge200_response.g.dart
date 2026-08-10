// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_auth_challenge200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminAuthChallenge200ResponseCodeEnum
_$adminAuthChallenge200ResponseCodeEnum_number0 =
    const AdminAuthChallenge200ResponseCodeEnum._('number0');
const AdminAuthChallenge200ResponseCodeEnum
_$adminAuthChallenge200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminAuthChallenge200ResponseCodeEnum._('unknownDefaultOpenApi');

AdminAuthChallenge200ResponseCodeEnum
_$adminAuthChallenge200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminAuthChallenge200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminAuthChallenge200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminAuthChallenge200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminAuthChallenge200ResponseCodeEnum>
_$adminAuthChallenge200ResponseCodeEnumValues =
    BuiltSet<AdminAuthChallenge200ResponseCodeEnum>(
      const <AdminAuthChallenge200ResponseCodeEnum>[
        _$adminAuthChallenge200ResponseCodeEnum_number0,
        _$adminAuthChallenge200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminAuthChallenge200ResponseCodeEnum>
_$adminAuthChallenge200ResponseCodeEnumSerializer =
    _$AdminAuthChallenge200ResponseCodeEnumSerializer();

class _$AdminAuthChallenge200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AdminAuthChallenge200ResponseCodeEnum> {
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
    AdminAuthChallenge200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminAuthChallenge200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminAuthChallenge200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminAuthChallenge200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminAuthChallenge200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminAuthChallenge200Response extends AdminAuthChallenge200Response {
  @override
  final AdminChallengeResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminAuthChallenge200Response([
    void Function(AdminAuthChallenge200ResponseBuilder)? updates,
  ]) => (AdminAuthChallenge200ResponseBuilder()..update(updates))._build();

  _$AdminAuthChallenge200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminAuthChallenge200Response rebuild(
    void Function(AdminAuthChallenge200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminAuthChallenge200ResponseBuilder toBuilder() =>
      AdminAuthChallenge200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminAuthChallenge200Response &&
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
    return (newBuiltValueToStringHelper(r'AdminAuthChallenge200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminAuthChallenge200ResponseBuilder
    implements
        Builder<
          AdminAuthChallenge200Response,
          AdminAuthChallenge200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminAuthChallenge200Response? _$v;

  AdminChallengeResponseDtoBuilder? _data;
  AdminChallengeResponseDtoBuilder get data =>
      _$this._data ??= AdminChallengeResponseDtoBuilder();
  set data(covariant AdminChallengeResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  AdminAuthChallenge200ResponseBuilder() {
    AdminAuthChallenge200Response._defaults(this);
  }

  AdminAuthChallenge200ResponseBuilder get _$this {
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
  void replace(covariant AdminAuthChallenge200Response other) {
    _$v = other as _$AdminAuthChallenge200Response;
  }

  @override
  void update(void Function(AdminAuthChallenge200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminAuthChallenge200Response build() => _build();

  _$AdminAuthChallenge200Response _build() {
    _$AdminAuthChallenge200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminAuthChallenge200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminAuthChallenge200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminAuthChallenge200Response',
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
          r'AdminAuthChallenge200Response',
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
