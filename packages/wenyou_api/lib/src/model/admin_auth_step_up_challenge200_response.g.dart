// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_auth_step_up_challenge200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminAuthStepUpChallenge200ResponseCodeEnum
_$adminAuthStepUpChallenge200ResponseCodeEnum_number0 =
    const AdminAuthStepUpChallenge200ResponseCodeEnum._('number0');
const AdminAuthStepUpChallenge200ResponseCodeEnum
_$adminAuthStepUpChallenge200ResponseCodeEnum_unknownDefaultOpenApi =
    const AdminAuthStepUpChallenge200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

AdminAuthStepUpChallenge200ResponseCodeEnum
_$adminAuthStepUpChallenge200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$adminAuthStepUpChallenge200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$adminAuthStepUpChallenge200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$adminAuthStepUpChallenge200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminAuthStepUpChallenge200ResponseCodeEnum>
_$adminAuthStepUpChallenge200ResponseCodeEnumValues =
    BuiltSet<AdminAuthStepUpChallenge200ResponseCodeEnum>(
      const <AdminAuthStepUpChallenge200ResponseCodeEnum>[
        _$adminAuthStepUpChallenge200ResponseCodeEnum_number0,
        _$adminAuthStepUpChallenge200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminAuthStepUpChallenge200ResponseCodeEnum>
_$adminAuthStepUpChallenge200ResponseCodeEnumSerializer =
    _$AdminAuthStepUpChallenge200ResponseCodeEnumSerializer();

class _$AdminAuthStepUpChallenge200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<AdminAuthStepUpChallenge200ResponseCodeEnum> {
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
    AdminAuthStepUpChallenge200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AdminAuthStepUpChallenge200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminAuthStepUpChallenge200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminAuthStepUpChallenge200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminAuthStepUpChallenge200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminAuthStepUpChallenge200Response
    extends AdminAuthStepUpChallenge200Response {
  @override
  final AdminChallengeResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AdminAuthStepUpChallenge200Response([
    void Function(AdminAuthStepUpChallenge200ResponseBuilder)? updates,
  ]) =>
      (AdminAuthStepUpChallenge200ResponseBuilder()..update(updates))._build();

  _$AdminAuthStepUpChallenge200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AdminAuthStepUpChallenge200Response rebuild(
    void Function(AdminAuthStepUpChallenge200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminAuthStepUpChallenge200ResponseBuilder toBuilder() =>
      AdminAuthStepUpChallenge200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminAuthStepUpChallenge200Response &&
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
    return (newBuiltValueToStringHelper(r'AdminAuthStepUpChallenge200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AdminAuthStepUpChallenge200ResponseBuilder
    implements
        Builder<
          AdminAuthStepUpChallenge200Response,
          AdminAuthStepUpChallenge200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AdminAuthStepUpChallenge200Response? _$v;

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

  AdminAuthStepUpChallenge200ResponseBuilder() {
    AdminAuthStepUpChallenge200Response._defaults(this);
  }

  AdminAuthStepUpChallenge200ResponseBuilder get _$this {
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
  void replace(covariant AdminAuthStepUpChallenge200Response other) {
    _$v = other as _$AdminAuthStepUpChallenge200Response;
  }

  @override
  void update(
    void Function(AdminAuthStepUpChallenge200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminAuthStepUpChallenge200Response build() => _build();

  _$AdminAuthStepUpChallenge200Response _build() {
    _$AdminAuthStepUpChallenge200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminAuthStepUpChallenge200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AdminAuthStepUpChallenge200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AdminAuthStepUpChallenge200Response',
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
          r'AdminAuthStepUpChallenge200Response',
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
