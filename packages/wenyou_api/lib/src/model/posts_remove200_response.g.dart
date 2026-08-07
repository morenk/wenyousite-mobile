// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'posts_remove200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostsRemove200ResponseCodeEnum _$postsRemove200ResponseCodeEnum_number0 =
    const PostsRemove200ResponseCodeEnum._('number0');
const PostsRemove200ResponseCodeEnum
_$postsRemove200ResponseCodeEnum_unknownDefaultOpenApi =
    const PostsRemove200ResponseCodeEnum._('unknownDefaultOpenApi');

PostsRemove200ResponseCodeEnum _$postsRemove200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$postsRemove200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$postsRemove200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$postsRemove200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<PostsRemove200ResponseCodeEnum>
_$postsRemove200ResponseCodeEnumValues =
    BuiltSet<PostsRemove200ResponseCodeEnum>(
      const <PostsRemove200ResponseCodeEnum>[
        _$postsRemove200ResponseCodeEnum_number0,
        _$postsRemove200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<PostsRemove200ResponseCodeEnum>
_$postsRemove200ResponseCodeEnumSerializer =
    _$PostsRemove200ResponseCodeEnumSerializer();

class _$PostsRemove200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<PostsRemove200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[PostsRemove200ResponseCodeEnum];
  @override
  final String wireName = 'PostsRemove200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    PostsRemove200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  PostsRemove200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => PostsRemove200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$PostsRemove200Response extends PostsRemove200Response {
  @override
  final MessageResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$PostsRemove200Response([
    void Function(PostsRemove200ResponseBuilder)? updates,
  ]) => (PostsRemove200ResponseBuilder()..update(updates))._build();

  _$PostsRemove200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  PostsRemove200Response rebuild(
    void Function(PostsRemove200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  PostsRemove200ResponseBuilder toBuilder() =>
      PostsRemove200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostsRemove200Response &&
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
    return (newBuiltValueToStringHelper(r'PostsRemove200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class PostsRemove200ResponseBuilder
    implements
        Builder<PostsRemove200Response, PostsRemove200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$PostsRemove200Response? _$v;

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

  PostsRemove200ResponseBuilder() {
    PostsRemove200Response._defaults(this);
  }

  PostsRemove200ResponseBuilder get _$this {
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
  void replace(covariant PostsRemove200Response other) {
    _$v = other as _$PostsRemove200Response;
  }

  @override
  void update(void Function(PostsRemove200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostsRemove200Response build() => _build();

  _$PostsRemove200Response _build() {
    _$PostsRemove200Response _$result;
    try {
      _$result =
          _$v ??
          _$PostsRemove200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'PostsRemove200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'PostsRemove200Response',
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
          r'PostsRemove200Response',
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
