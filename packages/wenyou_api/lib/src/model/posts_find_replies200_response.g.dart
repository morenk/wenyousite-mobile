// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'posts_find_replies200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostsFindReplies200ResponseCodeEnum
_$postsFindReplies200ResponseCodeEnum_number0 =
    const PostsFindReplies200ResponseCodeEnum._('number0');
const PostsFindReplies200ResponseCodeEnum
_$postsFindReplies200ResponseCodeEnum_unknownDefaultOpenApi =
    const PostsFindReplies200ResponseCodeEnum._('unknownDefaultOpenApi');

PostsFindReplies200ResponseCodeEnum
_$postsFindReplies200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$postsFindReplies200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$postsFindReplies200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$postsFindReplies200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<PostsFindReplies200ResponseCodeEnum>
_$postsFindReplies200ResponseCodeEnumValues =
    BuiltSet<PostsFindReplies200ResponseCodeEnum>(
      const <PostsFindReplies200ResponseCodeEnum>[
        _$postsFindReplies200ResponseCodeEnum_number0,
        _$postsFindReplies200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<PostsFindReplies200ResponseCodeEnum>
_$postsFindReplies200ResponseCodeEnumSerializer =
    _$PostsFindReplies200ResponseCodeEnumSerializer();

class _$PostsFindReplies200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<PostsFindReplies200ResponseCodeEnum> {
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
    PostsFindReplies200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'PostsFindReplies200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    PostsFindReplies200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  PostsFindReplies200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => PostsFindReplies200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$PostsFindReplies200Response extends PostsFindReplies200Response {
  @override
  final BuiltList<ReplyResponseDto> data;
  @override
  final ApiPaginationMeta meta;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$PostsFindReplies200Response([
    void Function(PostsFindReplies200ResponseBuilder)? updates,
  ]) => (PostsFindReplies200ResponseBuilder()..update(updates))._build();

  _$PostsFindReplies200Response._({
    required this.data,
    required this.meta,
    required this.code,
    required this.message,
  }) : super._();
  @override
  PostsFindReplies200Response rebuild(
    void Function(PostsFindReplies200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  PostsFindReplies200ResponseBuilder toBuilder() =>
      PostsFindReplies200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostsFindReplies200Response &&
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
    return (newBuiltValueToStringHelper(r'PostsFindReplies200Response')
          ..add('data', data)
          ..add('meta', meta)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class PostsFindReplies200ResponseBuilder
    implements
        Builder<
          PostsFindReplies200Response,
          PostsFindReplies200ResponseBuilder
        >,
        ApiPaginatedSuccessEnvelopeBuilder {
  _$PostsFindReplies200Response? _$v;

  ListBuilder<ReplyResponseDto>? _data;
  ListBuilder<ReplyResponseDto> get data =>
      _$this._data ??= ListBuilder<ReplyResponseDto>();
  set data(covariant ListBuilder<ReplyResponseDto>? data) =>
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

  PostsFindReplies200ResponseBuilder() {
    PostsFindReplies200Response._defaults(this);
  }

  PostsFindReplies200ResponseBuilder get _$this {
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
  void replace(covariant PostsFindReplies200Response other) {
    _$v = other as _$PostsFindReplies200Response;
  }

  @override
  void update(void Function(PostsFindReplies200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostsFindReplies200Response build() => _build();

  _$PostsFindReplies200Response _build() {
    _$PostsFindReplies200Response _$result;
    try {
      _$result =
          _$v ??
          _$PostsFindReplies200Response._(
            data: data.build(),
            meta: meta.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'PostsFindReplies200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'PostsFindReplies200Response',
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
          r'PostsFindReplies200Response',
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
