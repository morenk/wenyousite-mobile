// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'posts_find_reply_window200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostsFindReplyWindow200ResponseCodeEnum
_$postsFindReplyWindow200ResponseCodeEnum_number0 =
    const PostsFindReplyWindow200ResponseCodeEnum._('number0');
const PostsFindReplyWindow200ResponseCodeEnum
_$postsFindReplyWindow200ResponseCodeEnum_unknownDefaultOpenApi =
    const PostsFindReplyWindow200ResponseCodeEnum._('unknownDefaultOpenApi');

PostsFindReplyWindow200ResponseCodeEnum
_$postsFindReplyWindow200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$postsFindReplyWindow200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$postsFindReplyWindow200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$postsFindReplyWindow200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<PostsFindReplyWindow200ResponseCodeEnum>
_$postsFindReplyWindow200ResponseCodeEnumValues =
    BuiltSet<PostsFindReplyWindow200ResponseCodeEnum>(
      const <PostsFindReplyWindow200ResponseCodeEnum>[
        _$postsFindReplyWindow200ResponseCodeEnum_number0,
        _$postsFindReplyWindow200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<PostsFindReplyWindow200ResponseCodeEnum>
_$postsFindReplyWindow200ResponseCodeEnumSerializer =
    _$PostsFindReplyWindow200ResponseCodeEnumSerializer();

class _$PostsFindReplyWindow200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<PostsFindReplyWindow200ResponseCodeEnum> {
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
    PostsFindReplyWindow200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'PostsFindReplyWindow200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    PostsFindReplyWindow200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  PostsFindReplyWindow200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => PostsFindReplyWindow200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$PostsFindReplyWindow200Response
    extends PostsFindReplyWindow200Response {
  @override
  final ReplyWindowResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$PostsFindReplyWindow200Response([
    void Function(PostsFindReplyWindow200ResponseBuilder)? updates,
  ]) => (PostsFindReplyWindow200ResponseBuilder()..update(updates))._build();

  _$PostsFindReplyWindow200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  PostsFindReplyWindow200Response rebuild(
    void Function(PostsFindReplyWindow200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  PostsFindReplyWindow200ResponseBuilder toBuilder() =>
      PostsFindReplyWindow200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostsFindReplyWindow200Response &&
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
    return (newBuiltValueToStringHelper(r'PostsFindReplyWindow200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class PostsFindReplyWindow200ResponseBuilder
    implements
        Builder<
          PostsFindReplyWindow200Response,
          PostsFindReplyWindow200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$PostsFindReplyWindow200Response? _$v;

  ReplyWindowResponseDtoBuilder? _data;
  ReplyWindowResponseDtoBuilder get data =>
      _$this._data ??= ReplyWindowResponseDtoBuilder();
  set data(covariant ReplyWindowResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  PostsFindReplyWindow200ResponseBuilder() {
    PostsFindReplyWindow200Response._defaults(this);
  }

  PostsFindReplyWindow200ResponseBuilder get _$this {
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
  void replace(covariant PostsFindReplyWindow200Response other) {
    _$v = other as _$PostsFindReplyWindow200Response;
  }

  @override
  void update(void Function(PostsFindReplyWindow200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostsFindReplyWindow200Response build() => _build();

  _$PostsFindReplyWindow200Response _build() {
    _$PostsFindReplyWindow200Response _$result;
    try {
      _$result =
          _$v ??
          _$PostsFindReplyWindow200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'PostsFindReplyWindow200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'PostsFindReplyWindow200Response',
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
          r'PostsFindReplyWindow200Response',
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
