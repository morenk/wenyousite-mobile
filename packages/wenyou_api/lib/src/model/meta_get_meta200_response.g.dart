// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meta_get_meta200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MetaGetMeta200ResponseCodeEnum _$metaGetMeta200ResponseCodeEnum_number0 =
    const MetaGetMeta200ResponseCodeEnum._('number0');
const MetaGetMeta200ResponseCodeEnum
_$metaGetMeta200ResponseCodeEnum_unknownDefaultOpenApi =
    const MetaGetMeta200ResponseCodeEnum._('unknownDefaultOpenApi');

MetaGetMeta200ResponseCodeEnum _$metaGetMeta200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$metaGetMeta200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$metaGetMeta200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$metaGetMeta200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MetaGetMeta200ResponseCodeEnum>
_$metaGetMeta200ResponseCodeEnumValues =
    BuiltSet<MetaGetMeta200ResponseCodeEnum>(
      const <MetaGetMeta200ResponseCodeEnum>[
        _$metaGetMeta200ResponseCodeEnum_number0,
        _$metaGetMeta200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<MetaGetMeta200ResponseCodeEnum>
_$metaGetMeta200ResponseCodeEnumSerializer =
    _$MetaGetMeta200ResponseCodeEnumSerializer();

class _$MetaGetMeta200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<MetaGetMeta200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[MetaGetMeta200ResponseCodeEnum];
  @override
  final String wireName = 'MetaGetMeta200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MetaGetMeta200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MetaGetMeta200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MetaGetMeta200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MetaGetMeta200Response extends MetaGetMeta200Response {
  @override
  final ApiMetaResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$MetaGetMeta200Response([
    void Function(MetaGetMeta200ResponseBuilder)? updates,
  ]) => (MetaGetMeta200ResponseBuilder()..update(updates))._build();

  _$MetaGetMeta200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  MetaGetMeta200Response rebuild(
    void Function(MetaGetMeta200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MetaGetMeta200ResponseBuilder toBuilder() =>
      MetaGetMeta200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MetaGetMeta200Response &&
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
    return (newBuiltValueToStringHelper(r'MetaGetMeta200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class MetaGetMeta200ResponseBuilder
    implements
        Builder<MetaGetMeta200Response, MetaGetMeta200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$MetaGetMeta200Response? _$v;

  ApiMetaResponseDtoBuilder? _data;
  ApiMetaResponseDtoBuilder get data =>
      _$this._data ??= ApiMetaResponseDtoBuilder();
  set data(covariant ApiMetaResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  MetaGetMeta200ResponseBuilder() {
    MetaGetMeta200Response._defaults(this);
  }

  MetaGetMeta200ResponseBuilder get _$this {
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
  void replace(covariant MetaGetMeta200Response other) {
    _$v = other as _$MetaGetMeta200Response;
  }

  @override
  void update(void Function(MetaGetMeta200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MetaGetMeta200Response build() => _build();

  _$MetaGetMeta200Response _build() {
    _$MetaGetMeta200Response _$result;
    try {
      _$result =
          _$v ??
          _$MetaGetMeta200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'MetaGetMeta200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'MetaGetMeta200Response',
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
          r'MetaGetMeta200Response',
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
