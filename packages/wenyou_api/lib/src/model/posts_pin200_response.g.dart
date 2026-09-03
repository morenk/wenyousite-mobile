// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'posts_pin200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostsPin200ResponseCodeEnum _$postsPin200ResponseCodeEnum_number0 =
    const PostsPin200ResponseCodeEnum._('number0');
const PostsPin200ResponseCodeEnum
_$postsPin200ResponseCodeEnum_unknownDefaultOpenApi =
    const PostsPin200ResponseCodeEnum._('unknownDefaultOpenApi');

PostsPin200ResponseCodeEnum _$postsPin200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$postsPin200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$postsPin200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$postsPin200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<PostsPin200ResponseCodeEnum>
_$postsPin200ResponseCodeEnumValues =
    BuiltSet<PostsPin200ResponseCodeEnum>(const <PostsPin200ResponseCodeEnum>[
      _$postsPin200ResponseCodeEnum_number0,
      _$postsPin200ResponseCodeEnum_unknownDefaultOpenApi,
    ]);

Serializer<PostsPin200ResponseCodeEnum>
_$postsPin200ResponseCodeEnumSerializer =
    _$PostsPin200ResponseCodeEnumSerializer();

class _$PostsPin200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<PostsPin200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[PostsPin200ResponseCodeEnum];
  @override
  final String wireName = 'PostsPin200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    PostsPin200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  PostsPin200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => PostsPin200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$PostsPin200Response extends PostsPin200Response {
  @override
  final MessageResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$PostsPin200Response([
    void Function(PostsPin200ResponseBuilder)? updates,
  ]) => (PostsPin200ResponseBuilder()..update(updates))._build();

  _$PostsPin200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  PostsPin200Response rebuild(
    void Function(PostsPin200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  PostsPin200ResponseBuilder toBuilder() =>
      PostsPin200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostsPin200Response &&
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
    return (newBuiltValueToStringHelper(r'PostsPin200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class PostsPin200ResponseBuilder
    implements
        Builder<PostsPin200Response, PostsPin200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$PostsPin200Response? _$v;

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

  PostsPin200ResponseBuilder() {
    PostsPin200Response._defaults(this);
  }

  PostsPin200ResponseBuilder get _$this {
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
  void replace(covariant PostsPin200Response other) {
    _$v = other as _$PostsPin200Response;
  }

  @override
  void update(void Function(PostsPin200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostsPin200Response build() => _build();

  _$PostsPin200Response _build() {
    _$PostsPin200Response _$result;
    try {
      _$result =
          _$v ??
          _$PostsPin200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'PostsPin200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'PostsPin200Response',
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
          r'PostsPin200Response',
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
