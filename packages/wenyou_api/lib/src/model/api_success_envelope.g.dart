// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_success_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ApiSuccessEnvelopeCodeEnum _$apiSuccessEnvelopeCodeEnum_number0 =
    const ApiSuccessEnvelopeCodeEnum._('number0');
const ApiSuccessEnvelopeCodeEnum
_$apiSuccessEnvelopeCodeEnum_unknownDefaultOpenApi =
    const ApiSuccessEnvelopeCodeEnum._('unknownDefaultOpenApi');

ApiSuccessEnvelopeCodeEnum _$apiSuccessEnvelopeCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$apiSuccessEnvelopeCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$apiSuccessEnvelopeCodeEnum_unknownDefaultOpenApi;
    default:
      return _$apiSuccessEnvelopeCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ApiSuccessEnvelopeCodeEnum> _$apiSuccessEnvelopeCodeEnumValues =
    BuiltSet<ApiSuccessEnvelopeCodeEnum>(const <ApiSuccessEnvelopeCodeEnum>[
      _$apiSuccessEnvelopeCodeEnum_number0,
      _$apiSuccessEnvelopeCodeEnum_unknownDefaultOpenApi,
    ]);

Serializer<ApiSuccessEnvelopeCodeEnum> _$apiSuccessEnvelopeCodeEnumSerializer =
    _$ApiSuccessEnvelopeCodeEnumSerializer();

class _$ApiSuccessEnvelopeCodeEnumSerializer
    implements PrimitiveSerializer<ApiSuccessEnvelopeCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[ApiSuccessEnvelopeCodeEnum];
  @override
  final String wireName = 'ApiSuccessEnvelopeCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ApiSuccessEnvelopeCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ApiSuccessEnvelopeCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ApiSuccessEnvelopeCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

abstract mixin class ApiSuccessEnvelopeBuilder {
  void replace(ApiSuccessEnvelope other);
  void update(void Function(ApiSuccessEnvelopeBuilder) updates);
  ApiSuccessEnvelopeCodeEnum? get code;
  set code(ApiSuccessEnvelopeCodeEnum? code);

  String? get message;
  set message(String? message);
}

class _$$ApiSuccessEnvelope extends $ApiSuccessEnvelope {
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$$ApiSuccessEnvelope([
    void Function($ApiSuccessEnvelopeBuilder)? updates,
  ]) => ($ApiSuccessEnvelopeBuilder()..update(updates))._build();

  _$$ApiSuccessEnvelope._({required this.code, required this.message})
    : super._();
  @override
  $ApiSuccessEnvelope rebuild(
    void Function($ApiSuccessEnvelopeBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  $ApiSuccessEnvelopeBuilder toBuilder() =>
      $ApiSuccessEnvelopeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is $ApiSuccessEnvelope &&
        code == other.code &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'$ApiSuccessEnvelope')
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class $ApiSuccessEnvelopeBuilder
    implements
        Builder<$ApiSuccessEnvelope, $ApiSuccessEnvelopeBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$$ApiSuccessEnvelope? _$v;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  $ApiSuccessEnvelopeBuilder() {
    $ApiSuccessEnvelope._defaults(this);
  }

  $ApiSuccessEnvelopeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant $ApiSuccessEnvelope other) {
    _$v = other as _$$ApiSuccessEnvelope;
  }

  @override
  void update(void Function($ApiSuccessEnvelopeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  $ApiSuccessEnvelope build() => _build();

  _$$ApiSuccessEnvelope _build() {
    final _$result =
        _$v ??
        _$$ApiSuccessEnvelope._(
          code: BuiltValueNullFieldError.checkNotNull(
            code,
            r'$ApiSuccessEnvelope',
            'code',
          ),
          message: BuiltValueNullFieldError.checkNotNull(
            message,
            r'$ApiSuccessEnvelope',
            'message',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
