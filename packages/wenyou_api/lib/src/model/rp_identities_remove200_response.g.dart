// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rp_identities_remove200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RpIdentitiesRemove200ResponseCodeEnum
_$rpIdentitiesRemove200ResponseCodeEnum_number0 =
    const RpIdentitiesRemove200ResponseCodeEnum._('number0');
const RpIdentitiesRemove200ResponseCodeEnum
_$rpIdentitiesRemove200ResponseCodeEnum_unknownDefaultOpenApi =
    const RpIdentitiesRemove200ResponseCodeEnum._('unknownDefaultOpenApi');

RpIdentitiesRemove200ResponseCodeEnum
_$rpIdentitiesRemove200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$rpIdentitiesRemove200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$rpIdentitiesRemove200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$rpIdentitiesRemove200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<RpIdentitiesRemove200ResponseCodeEnum>
_$rpIdentitiesRemove200ResponseCodeEnumValues =
    BuiltSet<RpIdentitiesRemove200ResponseCodeEnum>(
      const <RpIdentitiesRemove200ResponseCodeEnum>[
        _$rpIdentitiesRemove200ResponseCodeEnum_number0,
        _$rpIdentitiesRemove200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<RpIdentitiesRemove200ResponseCodeEnum>
_$rpIdentitiesRemove200ResponseCodeEnumSerializer =
    _$RpIdentitiesRemove200ResponseCodeEnumSerializer();

class _$RpIdentitiesRemove200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<RpIdentitiesRemove200ResponseCodeEnum> {
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
    RpIdentitiesRemove200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'RpIdentitiesRemove200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    RpIdentitiesRemove200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  RpIdentitiesRemove200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => RpIdentitiesRemove200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$RpIdentitiesRemove200Response extends RpIdentitiesRemove200Response {
  @override
  final RpIdentityStateDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$RpIdentitiesRemove200Response([
    void Function(RpIdentitiesRemove200ResponseBuilder)? updates,
  ]) => (RpIdentitiesRemove200ResponseBuilder()..update(updates))._build();

  _$RpIdentitiesRemove200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  RpIdentitiesRemove200Response rebuild(
    void Function(RpIdentitiesRemove200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  RpIdentitiesRemove200ResponseBuilder toBuilder() =>
      RpIdentitiesRemove200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RpIdentitiesRemove200Response &&
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
    return (newBuiltValueToStringHelper(r'RpIdentitiesRemove200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class RpIdentitiesRemove200ResponseBuilder
    implements
        Builder<
          RpIdentitiesRemove200Response,
          RpIdentitiesRemove200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$RpIdentitiesRemove200Response? _$v;

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

  RpIdentitiesRemove200ResponseBuilder() {
    RpIdentitiesRemove200Response._defaults(this);
  }

  RpIdentitiesRemove200ResponseBuilder get _$this {
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
  void replace(covariant RpIdentitiesRemove200Response other) {
    _$v = other as _$RpIdentitiesRemove200Response;
  }

  @override
  void update(void Function(RpIdentitiesRemove200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RpIdentitiesRemove200Response build() => _build();

  _$RpIdentitiesRemove200Response _build() {
    _$RpIdentitiesRemove200Response _$result;
    try {
      _$result =
          _$v ??
          _$RpIdentitiesRemove200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'RpIdentitiesRemove200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'RpIdentitiesRemove200Response',
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
          r'RpIdentitiesRemove200Response',
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
