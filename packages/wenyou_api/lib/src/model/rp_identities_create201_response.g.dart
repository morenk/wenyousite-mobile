// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rp_identities_create201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RpIdentitiesCreate201ResponseCodeEnum
_$rpIdentitiesCreate201ResponseCodeEnum_number0 =
    const RpIdentitiesCreate201ResponseCodeEnum._('number0');
const RpIdentitiesCreate201ResponseCodeEnum
_$rpIdentitiesCreate201ResponseCodeEnum_unknownDefaultOpenApi =
    const RpIdentitiesCreate201ResponseCodeEnum._('unknownDefaultOpenApi');

RpIdentitiesCreate201ResponseCodeEnum
_$rpIdentitiesCreate201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$rpIdentitiesCreate201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$rpIdentitiesCreate201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$rpIdentitiesCreate201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<RpIdentitiesCreate201ResponseCodeEnum>
_$rpIdentitiesCreate201ResponseCodeEnumValues =
    BuiltSet<RpIdentitiesCreate201ResponseCodeEnum>(
      const <RpIdentitiesCreate201ResponseCodeEnum>[
        _$rpIdentitiesCreate201ResponseCodeEnum_number0,
        _$rpIdentitiesCreate201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<RpIdentitiesCreate201ResponseCodeEnum>
_$rpIdentitiesCreate201ResponseCodeEnumSerializer =
    _$RpIdentitiesCreate201ResponseCodeEnumSerializer();

class _$RpIdentitiesCreate201ResponseCodeEnumSerializer
    implements PrimitiveSerializer<RpIdentitiesCreate201ResponseCodeEnum> {
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
    RpIdentitiesCreate201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'RpIdentitiesCreate201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    RpIdentitiesCreate201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  RpIdentitiesCreate201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => RpIdentitiesCreate201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$RpIdentitiesCreate201Response extends RpIdentitiesCreate201Response {
  @override
  final RpIdentityStateDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$RpIdentitiesCreate201Response([
    void Function(RpIdentitiesCreate201ResponseBuilder)? updates,
  ]) => (RpIdentitiesCreate201ResponseBuilder()..update(updates))._build();

  _$RpIdentitiesCreate201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  RpIdentitiesCreate201Response rebuild(
    void Function(RpIdentitiesCreate201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  RpIdentitiesCreate201ResponseBuilder toBuilder() =>
      RpIdentitiesCreate201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RpIdentitiesCreate201Response &&
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
    return (newBuiltValueToStringHelper(r'RpIdentitiesCreate201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class RpIdentitiesCreate201ResponseBuilder
    implements
        Builder<
          RpIdentitiesCreate201Response,
          RpIdentitiesCreate201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$RpIdentitiesCreate201Response? _$v;

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

  RpIdentitiesCreate201ResponseBuilder() {
    RpIdentitiesCreate201Response._defaults(this);
  }

  RpIdentitiesCreate201ResponseBuilder get _$this {
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
  void replace(covariant RpIdentitiesCreate201Response other) {
    _$v = other as _$RpIdentitiesCreate201Response;
  }

  @override
  void update(void Function(RpIdentitiesCreate201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RpIdentitiesCreate201Response build() => _build();

  _$RpIdentitiesCreate201Response _build() {
    _$RpIdentitiesCreate201Response _$result;
    try {
      _$result =
          _$v ??
          _$RpIdentitiesCreate201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'RpIdentitiesCreate201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'RpIdentitiesCreate201Response',
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
          r'RpIdentitiesCreate201Response',
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
