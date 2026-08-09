// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moments_list200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MomentsList200ResponseCodeEnum _$momentsList200ResponseCodeEnum_number0 =
    const MomentsList200ResponseCodeEnum._('number0');
const MomentsList200ResponseCodeEnum
_$momentsList200ResponseCodeEnum_unknownDefaultOpenApi =
    const MomentsList200ResponseCodeEnum._('unknownDefaultOpenApi');

MomentsList200ResponseCodeEnum _$momentsList200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$momentsList200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$momentsList200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$momentsList200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MomentsList200ResponseCodeEnum>
_$momentsList200ResponseCodeEnumValues =
    BuiltSet<MomentsList200ResponseCodeEnum>(
      const <MomentsList200ResponseCodeEnum>[
        _$momentsList200ResponseCodeEnum_number0,
        _$momentsList200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<MomentsList200ResponseCodeEnum>
_$momentsList200ResponseCodeEnumSerializer =
    _$MomentsList200ResponseCodeEnumSerializer();

class _$MomentsList200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<MomentsList200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[MomentsList200ResponseCodeEnum];
  @override
  final String wireName = 'MomentsList200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MomentsList200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MomentsList200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MomentsList200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MomentsList200Response extends MomentsList200Response {
  @override
  final BuiltList<MomentCardResponseDto> data;
  @override
  final ApiPaginationMeta meta;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$MomentsList200Response([
    void Function(MomentsList200ResponseBuilder)? updates,
  ]) => (MomentsList200ResponseBuilder()..update(updates))._build();

  _$MomentsList200Response._({
    required this.data,
    required this.meta,
    required this.code,
    required this.message,
  }) : super._();
  @override
  MomentsList200Response rebuild(
    void Function(MomentsList200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MomentsList200ResponseBuilder toBuilder() =>
      MomentsList200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentsList200Response &&
        data == other.data &&
        meta == other.meta &&
        code == other.code &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, meta.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MomentsList200Response')
          ..add('data', data)
          ..add('meta', meta)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class MomentsList200ResponseBuilder
    implements
        Builder<MomentsList200Response, MomentsList200ResponseBuilder>,
        ApiPaginatedSuccessEnvelopeBuilder {
  _$MomentsList200Response? _$v;

  ListBuilder<MomentCardResponseDto>? _data;
  ListBuilder<MomentCardResponseDto> get data =>
      _$this._data ??= ListBuilder<MomentCardResponseDto>();
  set data(covariant ListBuilder<MomentCardResponseDto>? data) =>
      _$this._data = data;

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

  MomentsList200ResponseBuilder() {
    MomentsList200Response._defaults(this);
  }

  MomentsList200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _meta = $v.meta.toBuilder();
      _code = $v.code;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant MomentsList200Response other) {
    _$v = other as _$MomentsList200Response;
  }

  @override
  void update(void Function(MomentsList200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MomentsList200Response build() => _build();

  _$MomentsList200Response _build() {
    _$MomentsList200Response _$result;
    try {
      _$result =
          _$v ??
          _$MomentsList200Response._(
            data: data.build(),
            meta: meta.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'MomentsList200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'MomentsList200Response',
              'message',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
        _$failedField = 'meta';
        meta.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'MomentsList200Response',
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
