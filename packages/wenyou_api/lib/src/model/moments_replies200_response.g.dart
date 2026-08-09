// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moments_replies200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MomentsReplies200ResponseCodeEnum
_$momentsReplies200ResponseCodeEnum_number0 =
    const MomentsReplies200ResponseCodeEnum._('number0');
const MomentsReplies200ResponseCodeEnum
_$momentsReplies200ResponseCodeEnum_unknownDefaultOpenApi =
    const MomentsReplies200ResponseCodeEnum._('unknownDefaultOpenApi');

MomentsReplies200ResponseCodeEnum _$momentsReplies200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$momentsReplies200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$momentsReplies200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$momentsReplies200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MomentsReplies200ResponseCodeEnum>
_$momentsReplies200ResponseCodeEnumValues =
    BuiltSet<MomentsReplies200ResponseCodeEnum>(
      const <MomentsReplies200ResponseCodeEnum>[
        _$momentsReplies200ResponseCodeEnum_number0,
        _$momentsReplies200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<MomentsReplies200ResponseCodeEnum>
_$momentsReplies200ResponseCodeEnumSerializer =
    _$MomentsReplies200ResponseCodeEnumSerializer();

class _$MomentsReplies200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<MomentsReplies200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[MomentsReplies200ResponseCodeEnum];
  @override
  final String wireName = 'MomentsReplies200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MomentsReplies200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MomentsReplies200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MomentsReplies200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MomentsReplies200Response extends MomentsReplies200Response {
  @override
  final BuiltList<MomentCommentResponseDto> data;
  @override
  final ApiPaginationMeta meta;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$MomentsReplies200Response([
    void Function(MomentsReplies200ResponseBuilder)? updates,
  ]) => (MomentsReplies200ResponseBuilder()..update(updates))._build();

  _$MomentsReplies200Response._({
    required this.data,
    required this.meta,
    required this.code,
    required this.message,
  }) : super._();
  @override
  MomentsReplies200Response rebuild(
    void Function(MomentsReplies200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MomentsReplies200ResponseBuilder toBuilder() =>
      MomentsReplies200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentsReplies200Response &&
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
    return (newBuiltValueToStringHelper(r'MomentsReplies200Response')
          ..add('data', data)
          ..add('meta', meta)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class MomentsReplies200ResponseBuilder
    implements
        Builder<MomentsReplies200Response, MomentsReplies200ResponseBuilder>,
        ApiPaginatedSuccessEnvelopeBuilder {
  _$MomentsReplies200Response? _$v;

  ListBuilder<MomentCommentResponseDto>? _data;
  ListBuilder<MomentCommentResponseDto> get data =>
      _$this._data ??= ListBuilder<MomentCommentResponseDto>();
  set data(covariant ListBuilder<MomentCommentResponseDto>? data) =>
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

  MomentsReplies200ResponseBuilder() {
    MomentsReplies200Response._defaults(this);
  }

  MomentsReplies200ResponseBuilder get _$this {
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
  void replace(covariant MomentsReplies200Response other) {
    _$v = other as _$MomentsReplies200Response;
  }

  @override
  void update(void Function(MomentsReplies200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MomentsReplies200Response build() => _build();

  _$MomentsReplies200Response _build() {
    _$MomentsReplies200Response _$result;
    try {
      _$result =
          _$v ??
          _$MomentsReplies200Response._(
            data: data.build(),
            meta: meta.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'MomentsReplies200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'MomentsReplies200Response',
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
          r'MomentsReplies200Response',
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
