// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rp_identities_find200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RpIdentitiesFind200ResponseCodeEnum
_$rpIdentitiesFind200ResponseCodeEnum_number0 =
    const RpIdentitiesFind200ResponseCodeEnum._('number0');
const RpIdentitiesFind200ResponseCodeEnum
_$rpIdentitiesFind200ResponseCodeEnum_unknownDefaultOpenApi =
    const RpIdentitiesFind200ResponseCodeEnum._('unknownDefaultOpenApi');

RpIdentitiesFind200ResponseCodeEnum
_$rpIdentitiesFind200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$rpIdentitiesFind200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$rpIdentitiesFind200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$rpIdentitiesFind200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<RpIdentitiesFind200ResponseCodeEnum>
_$rpIdentitiesFind200ResponseCodeEnumValues =
    BuiltSet<RpIdentitiesFind200ResponseCodeEnum>(
      const <RpIdentitiesFind200ResponseCodeEnum>[
        _$rpIdentitiesFind200ResponseCodeEnum_number0,
        _$rpIdentitiesFind200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<RpIdentitiesFind200ResponseCodeEnum>
_$rpIdentitiesFind200ResponseCodeEnumSerializer =
    _$RpIdentitiesFind200ResponseCodeEnumSerializer();

class _$RpIdentitiesFind200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<RpIdentitiesFind200ResponseCodeEnum> {
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
    RpIdentitiesFind200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'RpIdentitiesFind200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    RpIdentitiesFind200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  RpIdentitiesFind200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => RpIdentitiesFind200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$RpIdentitiesFind200Response extends RpIdentitiesFind200Response {
  @override
  final RpIdentityStateDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$RpIdentitiesFind200Response([
    void Function(RpIdentitiesFind200ResponseBuilder)? updates,
  ]) => (RpIdentitiesFind200ResponseBuilder()..update(updates))._build();

  _$RpIdentitiesFind200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  RpIdentitiesFind200Response rebuild(
    void Function(RpIdentitiesFind200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  RpIdentitiesFind200ResponseBuilder toBuilder() =>
      RpIdentitiesFind200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RpIdentitiesFind200Response &&
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
    return (newBuiltValueToStringHelper(r'RpIdentitiesFind200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class RpIdentitiesFind200ResponseBuilder
    implements
        Builder<
          RpIdentitiesFind200Response,
          RpIdentitiesFind200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$RpIdentitiesFind200Response? _$v;

  RpIdentityStateDtoBuilder? _data;
  RpIdentityStateDtoBuilder get data =>
      _$this._data ??= RpIdentityStateDtoBuilder();
  set data(covariant RpIdentityStateDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  RpIdentitiesFind200ResponseBuilder() {
    RpIdentitiesFind200Response._defaults(this);
  }

  RpIdentitiesFind200ResponseBuilder get _$this {
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
  void replace(covariant RpIdentitiesFind200Response other) {
    _$v = other as _$RpIdentitiesFind200Response;
  }

  @override
  void update(void Function(RpIdentitiesFind200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RpIdentitiesFind200Response build() => _build();

  _$RpIdentitiesFind200Response _build() {
    _$RpIdentitiesFind200Response _$result;
    try {
      _$result =
          _$v ??
          _$RpIdentitiesFind200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'RpIdentitiesFind200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'RpIdentitiesFind200Response',
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
          r'RpIdentitiesFind200Response',
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
