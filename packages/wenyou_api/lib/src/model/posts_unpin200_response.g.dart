// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'posts_unpin200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostsUnpin200ResponseCodeEnum _$postsUnpin200ResponseCodeEnum_number0 =
    const PostsUnpin200ResponseCodeEnum._('number0');
const PostsUnpin200ResponseCodeEnum
_$postsUnpin200ResponseCodeEnum_unknownDefaultOpenApi =
    const PostsUnpin200ResponseCodeEnum._('unknownDefaultOpenApi');

PostsUnpin200ResponseCodeEnum _$postsUnpin200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$postsUnpin200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$postsUnpin200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$postsUnpin200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<PostsUnpin200ResponseCodeEnum>
_$postsUnpin200ResponseCodeEnumValues = BuiltSet<PostsUnpin200ResponseCodeEnum>(
  const <PostsUnpin200ResponseCodeEnum>[
    _$postsUnpin200ResponseCodeEnum_number0,
    _$postsUnpin200ResponseCodeEnum_unknownDefaultOpenApi,
  ],
);

Serializer<PostsUnpin200ResponseCodeEnum>
_$postsUnpin200ResponseCodeEnumSerializer =
    _$PostsUnpin200ResponseCodeEnumSerializer();

class _$PostsUnpin200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<PostsUnpin200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[PostsUnpin200ResponseCodeEnum];
  @override
  final String wireName = 'PostsUnpin200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    PostsUnpin200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  PostsUnpin200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => PostsUnpin200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$PostsUnpin200Response extends PostsUnpin200Response {
  @override
  final MessageResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$PostsUnpin200Response([
    void Function(PostsUnpin200ResponseBuilder)? updates,
  ]) => (PostsUnpin200ResponseBuilder()..update(updates))._build();

  _$PostsUnpin200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  PostsUnpin200Response rebuild(
    void Function(PostsUnpin200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  PostsUnpin200ResponseBuilder toBuilder() =>
      PostsUnpin200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostsUnpin200Response &&
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
    return (newBuiltValueToStringHelper(r'PostsUnpin200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class PostsUnpin200ResponseBuilder
    implements
        Builder<PostsUnpin200Response, PostsUnpin200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$PostsUnpin200Response? _$v;

  MessageResponseDtoBuilder? _data;
  MessageResponseDtoBuilder get data =>
      _$this._data ??= MessageResponseDtoBuilder();
  set data(covariant MessageResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  PostsUnpin200ResponseBuilder() {
    PostsUnpin200Response._defaults(this);
  }

  PostsUnpin200ResponseBuilder get _$this {
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
  void replace(covariant PostsUnpin200Response other) {
    _$v = other as _$PostsUnpin200Response;
  }

  @override
  void update(void Function(PostsUnpin200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostsUnpin200Response build() => _build();

  _$PostsUnpin200Response _build() {
    _$PostsUnpin200Response _$result;
    try {
      _$result =
          _$v ??
          _$PostsUnpin200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'PostsUnpin200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'PostsUnpin200Response',
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
          r'PostsUnpin200Response',
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
