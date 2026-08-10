// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moderation_cases_list200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ModerationCasesList200ResponseCodeEnum
_$moderationCasesList200ResponseCodeEnum_number0 =
    const ModerationCasesList200ResponseCodeEnum._('number0');
const ModerationCasesList200ResponseCodeEnum
_$moderationCasesList200ResponseCodeEnum_unknownDefaultOpenApi =
    const ModerationCasesList200ResponseCodeEnum._('unknownDefaultOpenApi');

ModerationCasesList200ResponseCodeEnum
_$moderationCasesList200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$moderationCasesList200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$moderationCasesList200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$moderationCasesList200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ModerationCasesList200ResponseCodeEnum>
_$moderationCasesList200ResponseCodeEnumValues =
    BuiltSet<ModerationCasesList200ResponseCodeEnum>(
      const <ModerationCasesList200ResponseCodeEnum>[
        _$moderationCasesList200ResponseCodeEnum_number0,
        _$moderationCasesList200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ModerationCasesList200ResponseCodeEnum>
_$moderationCasesList200ResponseCodeEnumSerializer =
    _$ModerationCasesList200ResponseCodeEnumSerializer();

class _$ModerationCasesList200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<ModerationCasesList200ResponseCodeEnum> {
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
    ModerationCasesList200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'ModerationCasesList200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ModerationCasesList200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ModerationCasesList200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ModerationCasesList200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ModerationCasesList200Response extends ModerationCasesList200Response {
  @override
  final BuiltList<ModerationCaseResponseDto> data;
  @override
  final ApiPaginationMeta meta;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$ModerationCasesList200Response([
    void Function(ModerationCasesList200ResponseBuilder)? updates,
  ]) => (ModerationCasesList200ResponseBuilder()..update(updates))._build();

  _$ModerationCasesList200Response._({
    required this.data,
    required this.meta,
    required this.code,
    required this.message,
  }) : super._();
  @override
  ModerationCasesList200Response rebuild(
    void Function(ModerationCasesList200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ModerationCasesList200ResponseBuilder toBuilder() =>
      ModerationCasesList200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ModerationCasesList200Response &&
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
    return (newBuiltValueToStringHelper(r'ModerationCasesList200Response')
          ..add('data', data)
          ..add('meta', meta)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ModerationCasesList200ResponseBuilder
    implements
        Builder<
          ModerationCasesList200Response,
          ModerationCasesList200ResponseBuilder
        >,
        ApiPaginatedSuccessEnvelopeBuilder {
  _$ModerationCasesList200Response? _$v;

  ListBuilder<ModerationCaseResponseDto>? _data;
  ListBuilder<ModerationCaseResponseDto> get data =>
      _$this._data ??= ListBuilder<ModerationCaseResponseDto>();
  set data(covariant ListBuilder<ModerationCaseResponseDto>? data) =>
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

  ModerationCasesList200ResponseBuilder() {
    ModerationCasesList200Response._defaults(this);
  }

  ModerationCasesList200ResponseBuilder get _$this {
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
  void replace(covariant ModerationCasesList200Response other) {
    _$v = other as _$ModerationCasesList200Response;
  }

  @override
  void update(void Function(ModerationCasesList200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ModerationCasesList200Response build() => _build();

  _$ModerationCasesList200Response _build() {
    _$ModerationCasesList200Response _$result;
    try {
      _$result =
          _$v ??
          _$ModerationCasesList200Response._(
            data: data.build(),
            meta: meta.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'ModerationCasesList200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'ModerationCasesList200Response',
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
          r'ModerationCasesList200Response',
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
