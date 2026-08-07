// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_paginated_success_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ApiPaginatedSuccessEnvelopeCodeEnum
_$apiPaginatedSuccessEnvelopeCodeEnum_number0 =
    const ApiPaginatedSuccessEnvelopeCodeEnum._('number0');
const ApiPaginatedSuccessEnvelopeCodeEnum
_$apiPaginatedSuccessEnvelopeCodeEnum_unknownDefaultOpenApi =
    const ApiPaginatedSuccessEnvelopeCodeEnum._('unknownDefaultOpenApi');

ApiPaginatedSuccessEnvelopeCodeEnum
_$apiPaginatedSuccessEnvelopeCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$apiPaginatedSuccessEnvelopeCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$apiPaginatedSuccessEnvelopeCodeEnum_unknownDefaultOpenApi;
    default:
      return _$apiPaginatedSuccessEnvelopeCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ApiPaginatedSuccessEnvelopeCodeEnum>
_$apiPaginatedSuccessEnvelopeCodeEnumValues =
    BuiltSet<ApiPaginatedSuccessEnvelopeCodeEnum>(
      const <ApiPaginatedSuccessEnvelopeCodeEnum>[
        _$apiPaginatedSuccessEnvelopeCodeEnum_number0,
        _$apiPaginatedSuccessEnvelopeCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ApiPaginatedSuccessEnvelopeCodeEnum>
_$apiPaginatedSuccessEnvelopeCodeEnumSerializer =
    _$ApiPaginatedSuccessEnvelopeCodeEnumSerializer();

class _$ApiPaginatedSuccessEnvelopeCodeEnumSerializer
    implements PrimitiveSerializer<ApiPaginatedSuccessEnvelopeCodeEnum> {
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
    ApiPaginatedSuccessEnvelopeCodeEnum,
  ];
  @override
  final String wireName = 'ApiPaginatedSuccessEnvelopeCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ApiPaginatedSuccessEnvelopeCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ApiPaginatedSuccessEnvelopeCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ApiPaginatedSuccessEnvelopeCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

abstract mixin class ApiPaginatedSuccessEnvelopeBuilder
    implements ApiSuccessEnvelopeBuilder {
  void replace(covariant ApiPaginatedSuccessEnvelope other);
  void update(void Function(ApiPaginatedSuccessEnvelopeBuilder) updates);
  ApiPaginationMetaBuilder get meta;
  set meta(covariant ApiPaginationMetaBuilder? meta);

  ApiSuccessEnvelopeCodeEnum? get code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code);

  String? get message;
  set message(covariant String? message);
}

class _$$ApiPaginatedSuccessEnvelope extends $ApiPaginatedSuccessEnvelope {
  @override
  final ApiPaginationMeta meta;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$$ApiPaginatedSuccessEnvelope([
    void Function($ApiPaginatedSuccessEnvelopeBuilder)? updates,
  ]) => ($ApiPaginatedSuccessEnvelopeBuilder()..update(updates))._build();

  _$$ApiPaginatedSuccessEnvelope._({
    required this.meta,
    required this.code,
    required this.message,
  }) : super._();
  @override
  $ApiPaginatedSuccessEnvelope rebuild(
    void Function($ApiPaginatedSuccessEnvelopeBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  $ApiPaginatedSuccessEnvelopeBuilder toBuilder() =>
      $ApiPaginatedSuccessEnvelopeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is $ApiPaginatedSuccessEnvelope &&
        meta == other.meta &&
        code == other.code &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, meta.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'$ApiPaginatedSuccessEnvelope')
          ..add('meta', meta)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class $ApiPaginatedSuccessEnvelopeBuilder
    implements
        Builder<
          $ApiPaginatedSuccessEnvelope,
          $ApiPaginatedSuccessEnvelopeBuilder
        >,
        ApiPaginatedSuccessEnvelopeBuilder {
  _$$ApiPaginatedSuccessEnvelope? _$v;

  ApiPaginationMetaBuilder? _meta;
  ApiPaginationMetaBuilder get meta =>
      _$this._meta ??= ApiPaginationMetaBuilder();
  set meta(covariant ApiPaginationMetaBuilder? meta) => _$this._meta = meta;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  $ApiPaginatedSuccessEnvelopeBuilder() {
    $ApiPaginatedSuccessEnvelope._defaults(this);
  }

  $ApiPaginatedSuccessEnvelopeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _meta = $v.meta.toBuilder();
      _code = $v.code;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant $ApiPaginatedSuccessEnvelope other) {
    _$v = other as _$$ApiPaginatedSuccessEnvelope;
  }

  @override
  void update(void Function($ApiPaginatedSuccessEnvelopeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  $ApiPaginatedSuccessEnvelope build() => _build();

  _$$ApiPaginatedSuccessEnvelope _build() {
    _$$ApiPaginatedSuccessEnvelope _$result;
    try {
      _$result =
          _$v ??
          _$$ApiPaginatedSuccessEnvelope._(
            meta: meta.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'$ApiPaginatedSuccessEnvelope',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'$ApiPaginatedSuccessEnvelope',
              'message',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'meta';
        meta.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'$ApiPaginatedSuccessEnvelope',
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
