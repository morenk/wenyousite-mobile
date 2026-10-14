// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rp_identities_list200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RpIdentitiesList200ResponseCodeEnum
_$rpIdentitiesList200ResponseCodeEnum_number0 =
    const RpIdentitiesList200ResponseCodeEnum._('number0');
const RpIdentitiesList200ResponseCodeEnum
_$rpIdentitiesList200ResponseCodeEnum_unknownDefaultOpenApi =
    const RpIdentitiesList200ResponseCodeEnum._('unknownDefaultOpenApi');

RpIdentitiesList200ResponseCodeEnum
_$rpIdentitiesList200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$rpIdentitiesList200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$rpIdentitiesList200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$rpIdentitiesList200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<RpIdentitiesList200ResponseCodeEnum>
_$rpIdentitiesList200ResponseCodeEnumValues =
    BuiltSet<RpIdentitiesList200ResponseCodeEnum>(
      const <RpIdentitiesList200ResponseCodeEnum>[
        _$rpIdentitiesList200ResponseCodeEnum_number0,
        _$rpIdentitiesList200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<RpIdentitiesList200ResponseCodeEnum>
_$rpIdentitiesList200ResponseCodeEnumSerializer =
    _$RpIdentitiesList200ResponseCodeEnumSerializer();

class _$RpIdentitiesList200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<RpIdentitiesList200ResponseCodeEnum> {
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
    RpIdentitiesList200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'RpIdentitiesList200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    RpIdentitiesList200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  RpIdentitiesList200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => RpIdentitiesList200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$RpIdentitiesList200Response extends RpIdentitiesList200Response {
  @override
  final RpIdentityCollectionDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$RpIdentitiesList200Response([
    void Function(RpIdentitiesList200ResponseBuilder)? updates,
  ]) => (RpIdentitiesList200ResponseBuilder()..update(updates))._build();

  _$RpIdentitiesList200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  RpIdentitiesList200Response rebuild(
    void Function(RpIdentitiesList200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  RpIdentitiesList200ResponseBuilder toBuilder() =>
      RpIdentitiesList200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RpIdentitiesList200Response &&
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
    return (newBuiltValueToStringHelper(r'RpIdentitiesList200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class RpIdentitiesList200ResponseBuilder
    implements
        Builder<
          RpIdentitiesList200Response,
          RpIdentitiesList200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$RpIdentitiesList200Response? _$v;

  RpIdentityCollectionDtoBuilder? _data;
  RpIdentityCollectionDtoBuilder get data =>
      _$this._data ??= RpIdentityCollectionDtoBuilder();
  set data(covariant RpIdentityCollectionDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  RpIdentitiesList200ResponseBuilder() {
    RpIdentitiesList200Response._defaults(this);
  }

  RpIdentitiesList200ResponseBuilder get _$this {
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
  void replace(covariant RpIdentitiesList200Response other) {
    _$v = other as _$RpIdentitiesList200Response;
  }

  @override
  void update(void Function(RpIdentitiesList200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RpIdentitiesList200Response build() => _build();

  _$RpIdentitiesList200Response _build() {
    _$RpIdentitiesList200Response _$result;
    try {
      _$result =
          _$v ??
          _$RpIdentitiesList200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'RpIdentitiesList200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'RpIdentitiesList200Response',
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
          r'RpIdentitiesList200Response',
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
