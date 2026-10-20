// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rp_identities_update200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RpIdentitiesUpdate200ResponseCodeEnum
_$rpIdentitiesUpdate200ResponseCodeEnum_number0 =
    const RpIdentitiesUpdate200ResponseCodeEnum._('number0');
const RpIdentitiesUpdate200ResponseCodeEnum
_$rpIdentitiesUpdate200ResponseCodeEnum_unknownDefaultOpenApi =
    const RpIdentitiesUpdate200ResponseCodeEnum._('unknownDefaultOpenApi');

RpIdentitiesUpdate200ResponseCodeEnum
_$rpIdentitiesUpdate200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$rpIdentitiesUpdate200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$rpIdentitiesUpdate200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$rpIdentitiesUpdate200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<RpIdentitiesUpdate200ResponseCodeEnum>
_$rpIdentitiesUpdate200ResponseCodeEnumValues =
    BuiltSet<RpIdentitiesUpdate200ResponseCodeEnum>(
      const <RpIdentitiesUpdate200ResponseCodeEnum>[
        _$rpIdentitiesUpdate200ResponseCodeEnum_number0,
        _$rpIdentitiesUpdate200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<RpIdentitiesUpdate200ResponseCodeEnum>
_$rpIdentitiesUpdate200ResponseCodeEnumSerializer =
    _$RpIdentitiesUpdate200ResponseCodeEnumSerializer();

class _$RpIdentitiesUpdate200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<RpIdentitiesUpdate200ResponseCodeEnum> {
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
    RpIdentitiesUpdate200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'RpIdentitiesUpdate200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    RpIdentitiesUpdate200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  RpIdentitiesUpdate200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => RpIdentitiesUpdate200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$RpIdentitiesUpdate200Response extends RpIdentitiesUpdate200Response {
  @override
  final RpIdentityStateDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$RpIdentitiesUpdate200Response([
    void Function(RpIdentitiesUpdate200ResponseBuilder)? updates,
  ]) => (RpIdentitiesUpdate200ResponseBuilder()..update(updates))._build();

  _$RpIdentitiesUpdate200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  RpIdentitiesUpdate200Response rebuild(
    void Function(RpIdentitiesUpdate200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  RpIdentitiesUpdate200ResponseBuilder toBuilder() =>
      RpIdentitiesUpdate200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RpIdentitiesUpdate200Response &&
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
    return (newBuiltValueToStringHelper(r'RpIdentitiesUpdate200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class RpIdentitiesUpdate200ResponseBuilder
    implements
        Builder<
          RpIdentitiesUpdate200Response,
          RpIdentitiesUpdate200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$RpIdentitiesUpdate200Response? _$v;

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

  RpIdentitiesUpdate200ResponseBuilder() {
    RpIdentitiesUpdate200Response._defaults(this);
  }

  RpIdentitiesUpdate200ResponseBuilder get _$this {
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
  void replace(covariant RpIdentitiesUpdate200Response other) {
    _$v = other as _$RpIdentitiesUpdate200Response;
  }

  @override
  void update(void Function(RpIdentitiesUpdate200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RpIdentitiesUpdate200Response build() => _build();

  _$RpIdentitiesUpdate200Response _build() {
    _$RpIdentitiesUpdate200Response _$result;
    try {
      _$result =
          _$v ??
          _$RpIdentitiesUpdate200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'RpIdentitiesUpdate200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'RpIdentitiesUpdate200Response',
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
          r'RpIdentitiesUpdate200Response',
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
