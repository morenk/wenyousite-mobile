// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'posts_create201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostsCreate201ResponseCodeEnum _$postsCreate201ResponseCodeEnum_number0 =
    const PostsCreate201ResponseCodeEnum._('number0');
const PostsCreate201ResponseCodeEnum
_$postsCreate201ResponseCodeEnum_unknownDefaultOpenApi =
    const PostsCreate201ResponseCodeEnum._('unknownDefaultOpenApi');

PostsCreate201ResponseCodeEnum _$postsCreate201ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$postsCreate201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$postsCreate201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$postsCreate201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<PostsCreate201ResponseCodeEnum>
_$postsCreate201ResponseCodeEnumValues =
    BuiltSet<PostsCreate201ResponseCodeEnum>(
      const <PostsCreate201ResponseCodeEnum>[
        _$postsCreate201ResponseCodeEnum_number0,
        _$postsCreate201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<PostsCreate201ResponseCodeEnum>
_$postsCreate201ResponseCodeEnumSerializer =
    _$PostsCreate201ResponseCodeEnumSerializer();

class _$PostsCreate201ResponseCodeEnumSerializer
    implements PrimitiveSerializer<PostsCreate201ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[PostsCreate201ResponseCodeEnum];
  @override
  final String wireName = 'PostsCreate201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    PostsCreate201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  PostsCreate201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => PostsCreate201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$PostsCreate201Response extends PostsCreate201Response {
  @override
  final PostResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$PostsCreate201Response([
    void Function(PostsCreate201ResponseBuilder)? updates,
  ]) => (PostsCreate201ResponseBuilder()..update(updates))._build();

  _$PostsCreate201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  PostsCreate201Response rebuild(
    void Function(PostsCreate201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  PostsCreate201ResponseBuilder toBuilder() =>
      PostsCreate201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostsCreate201Response &&
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
    return (newBuiltValueToStringHelper(r'PostsCreate201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class PostsCreate201ResponseBuilder
    implements
        Builder<PostsCreate201Response, PostsCreate201ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$PostsCreate201Response? _$v;

  PostResponseDtoBuilder? _data;
  PostResponseDtoBuilder get data => _$this._data ??= PostResponseDtoBuilder();
  set data(covariant PostResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  PostsCreate201ResponseBuilder() {
    PostsCreate201Response._defaults(this);
  }

  PostsCreate201ResponseBuilder get _$this {
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
  void replace(covariant PostsCreate201Response other) {
    _$v = other as _$PostsCreate201Response;
  }

  @override
  void update(void Function(PostsCreate201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostsCreate201Response build() => _build();

  _$PostsCreate201Response _build() {
    _$PostsCreate201Response _$result;
    try {
      _$result =
          _$v ??
          _$PostsCreate201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'PostsCreate201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'PostsCreate201Response',
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
          r'PostsCreate201Response',
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
