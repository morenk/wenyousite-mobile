// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'posts_find_reply_authors200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostsFindReplyAuthors200ResponseCodeEnum
_$postsFindReplyAuthors200ResponseCodeEnum_number0 =
    const PostsFindReplyAuthors200ResponseCodeEnum._('number0');
const PostsFindReplyAuthors200ResponseCodeEnum
_$postsFindReplyAuthors200ResponseCodeEnum_unknownDefaultOpenApi =
    const PostsFindReplyAuthors200ResponseCodeEnum._('unknownDefaultOpenApi');

PostsFindReplyAuthors200ResponseCodeEnum
_$postsFindReplyAuthors200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$postsFindReplyAuthors200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$postsFindReplyAuthors200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$postsFindReplyAuthors200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<PostsFindReplyAuthors200ResponseCodeEnum>
_$postsFindReplyAuthors200ResponseCodeEnumValues =
    BuiltSet<PostsFindReplyAuthors200ResponseCodeEnum>(
      const <PostsFindReplyAuthors200ResponseCodeEnum>[
        _$postsFindReplyAuthors200ResponseCodeEnum_number0,
        _$postsFindReplyAuthors200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<PostsFindReplyAuthors200ResponseCodeEnum>
_$postsFindReplyAuthors200ResponseCodeEnumSerializer =
    _$PostsFindReplyAuthors200ResponseCodeEnumSerializer();

class _$PostsFindReplyAuthors200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<PostsFindReplyAuthors200ResponseCodeEnum> {
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
    PostsFindReplyAuthors200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'PostsFindReplyAuthors200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    PostsFindReplyAuthors200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  PostsFindReplyAuthors200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => PostsFindReplyAuthors200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$PostsFindReplyAuthors200Response
    extends PostsFindReplyAuthors200Response {
  @override
  final BuiltList<DiscussionAuthorResponseDto> data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$PostsFindReplyAuthors200Response([
    void Function(PostsFindReplyAuthors200ResponseBuilder)? updates,
  ]) => (PostsFindReplyAuthors200ResponseBuilder()..update(updates))._build();

  _$PostsFindReplyAuthors200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  PostsFindReplyAuthors200Response rebuild(
    void Function(PostsFindReplyAuthors200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  PostsFindReplyAuthors200ResponseBuilder toBuilder() =>
      PostsFindReplyAuthors200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostsFindReplyAuthors200Response &&
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
    return (newBuiltValueToStringHelper(r'PostsFindReplyAuthors200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class PostsFindReplyAuthors200ResponseBuilder
    implements
        Builder<
          PostsFindReplyAuthors200Response,
          PostsFindReplyAuthors200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$PostsFindReplyAuthors200Response? _$v;

  ListBuilder<DiscussionAuthorResponseDto>? _data;
  ListBuilder<DiscussionAuthorResponseDto> get data =>
      _$this._data ??= ListBuilder<DiscussionAuthorResponseDto>();
  set data(covariant ListBuilder<DiscussionAuthorResponseDto>? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  PostsFindReplyAuthors200ResponseBuilder() {
    PostsFindReplyAuthors200Response._defaults(this);
  }

  PostsFindReplyAuthors200ResponseBuilder get _$this {
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
  void replace(covariant PostsFindReplyAuthors200Response other) {
    _$v = other as _$PostsFindReplyAuthors200Response;
  }

  @override
  void update(void Function(PostsFindReplyAuthors200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostsFindReplyAuthors200Response build() => _build();

  _$PostsFindReplyAuthors200Response _build() {
    _$PostsFindReplyAuthors200Response _$result;
    try {
      _$result =
          _$v ??
          _$PostsFindReplyAuthors200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'PostsFindReplyAuthors200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'PostsFindReplyAuthors200Response',
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
          r'PostsFindReplyAuthors200Response',
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
