// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moments_comments_list200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MomentsCommentsList200ResponseCodeEnum
_$momentsCommentsList200ResponseCodeEnum_number0 =
    const MomentsCommentsList200ResponseCodeEnum._('number0');
const MomentsCommentsList200ResponseCodeEnum
_$momentsCommentsList200ResponseCodeEnum_unknownDefaultOpenApi =
    const MomentsCommentsList200ResponseCodeEnum._('unknownDefaultOpenApi');

MomentsCommentsList200ResponseCodeEnum
_$momentsCommentsList200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$momentsCommentsList200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$momentsCommentsList200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$momentsCommentsList200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MomentsCommentsList200ResponseCodeEnum>
_$momentsCommentsList200ResponseCodeEnumValues =
    BuiltSet<MomentsCommentsList200ResponseCodeEnum>(
      const <MomentsCommentsList200ResponseCodeEnum>[
        _$momentsCommentsList200ResponseCodeEnum_number0,
        _$momentsCommentsList200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<MomentsCommentsList200ResponseCodeEnum>
_$momentsCommentsList200ResponseCodeEnumSerializer =
    _$MomentsCommentsList200ResponseCodeEnumSerializer();

class _$MomentsCommentsList200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<MomentsCommentsList200ResponseCodeEnum> {
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
    MomentsCommentsList200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'MomentsCommentsList200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MomentsCommentsList200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MomentsCommentsList200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MomentsCommentsList200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MomentsCommentsList200Response extends MomentsCommentsList200Response {
  @override
  final BuiltList<MomentRootCommentResponseDto> data;
  @override
  final ApiPaginationMeta meta;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$MomentsCommentsList200Response([
    void Function(MomentsCommentsList200ResponseBuilder)? updates,
  ]) => (MomentsCommentsList200ResponseBuilder()..update(updates))._build();

  _$MomentsCommentsList200Response._({
    required this.data,
    required this.meta,
    required this.code,
    required this.message,
  }) : super._();
  @override
  MomentsCommentsList200Response rebuild(
    void Function(MomentsCommentsList200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MomentsCommentsList200ResponseBuilder toBuilder() =>
      MomentsCommentsList200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentsCommentsList200Response &&
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
    return (newBuiltValueToStringHelper(r'MomentsCommentsList200Response')
          ..add('data', data)
          ..add('meta', meta)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class MomentsCommentsList200ResponseBuilder
    implements
        Builder<
          MomentsCommentsList200Response,
          MomentsCommentsList200ResponseBuilder
        >,
        ApiPaginatedSuccessEnvelopeBuilder {
  _$MomentsCommentsList200Response? _$v;

  ListBuilder<MomentRootCommentResponseDto>? _data;
  ListBuilder<MomentRootCommentResponseDto> get data =>
      _$this._data ??= ListBuilder<MomentRootCommentResponseDto>();
  set data(covariant ListBuilder<MomentRootCommentResponseDto>? data) =>
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

  MomentsCommentsList200ResponseBuilder() {
    MomentsCommentsList200Response._defaults(this);
  }

  MomentsCommentsList200ResponseBuilder get _$this {
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
  void replace(covariant MomentsCommentsList200Response other) {
    _$v = other as _$MomentsCommentsList200Response;
  }

  @override
  void update(void Function(MomentsCommentsList200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MomentsCommentsList200Response build() => _build();

  _$MomentsCommentsList200Response _build() {
    _$MomentsCommentsList200Response _$result;
    try {
      _$result =
          _$v ??
          _$MomentsCommentsList200Response._(
            data: data.build(),
            meta: meta.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'MomentsCommentsList200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'MomentsCommentsList200Response',
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
          r'MomentsCommentsList200Response',
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
