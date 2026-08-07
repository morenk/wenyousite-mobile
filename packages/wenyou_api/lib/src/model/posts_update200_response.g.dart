// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'posts_update200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostsUpdate200ResponseCodeEnum _$postsUpdate200ResponseCodeEnum_number0 =
    const PostsUpdate200ResponseCodeEnum._('number0');
const PostsUpdate200ResponseCodeEnum
_$postsUpdate200ResponseCodeEnum_unknownDefaultOpenApi =
    const PostsUpdate200ResponseCodeEnum._('unknownDefaultOpenApi');

PostsUpdate200ResponseCodeEnum _$postsUpdate200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$postsUpdate200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$postsUpdate200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$postsUpdate200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<PostsUpdate200ResponseCodeEnum>
_$postsUpdate200ResponseCodeEnumValues =
    BuiltSet<PostsUpdate200ResponseCodeEnum>(
      const <PostsUpdate200ResponseCodeEnum>[
        _$postsUpdate200ResponseCodeEnum_number0,
        _$postsUpdate200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<PostsUpdate200ResponseCodeEnum>
_$postsUpdate200ResponseCodeEnumSerializer =
    _$PostsUpdate200ResponseCodeEnumSerializer();

class _$PostsUpdate200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<PostsUpdate200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[PostsUpdate200ResponseCodeEnum];
  @override
  final String wireName = 'PostsUpdate200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    PostsUpdate200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  PostsUpdate200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => PostsUpdate200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$PostsUpdate200Response extends PostsUpdate200Response {
  @override
  final PostResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$PostsUpdate200Response([
    void Function(PostsUpdate200ResponseBuilder)? updates,
  ]) => (PostsUpdate200ResponseBuilder()..update(updates))._build();

  _$PostsUpdate200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  PostsUpdate200Response rebuild(
    void Function(PostsUpdate200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  PostsUpdate200ResponseBuilder toBuilder() =>
      PostsUpdate200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostsUpdate200Response &&
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
    return (newBuiltValueToStringHelper(r'PostsUpdate200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class PostsUpdate200ResponseBuilder
    implements
        Builder<PostsUpdate200Response, PostsUpdate200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$PostsUpdate200Response? _$v;

  PostResponseDtoBuilder? _data;
  PostResponseDtoBuilder get data => _$this._data ??= PostResponseDtoBuilder();
  set data(covariant PostResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  PostsUpdate200ResponseBuilder() {
    PostsUpdate200Response._defaults(this);
  }

  PostsUpdate200ResponseBuilder get _$this {
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
  void replace(covariant PostsUpdate200Response other) {
    _$v = other as _$PostsUpdate200Response;
  }

  @override
  void update(void Function(PostsUpdate200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostsUpdate200Response build() => _build();

  _$PostsUpdate200Response _build() {
    _$PostsUpdate200Response _$result;
    try {
      _$result =
          _$v ??
          _$PostsUpdate200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'PostsUpdate200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'PostsUpdate200Response',
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
          r'PostsUpdate200Response',
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
