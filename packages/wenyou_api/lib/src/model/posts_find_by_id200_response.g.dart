// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'posts_find_by_id200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostsFindById200ResponseCodeEnum
_$postsFindById200ResponseCodeEnum_number0 =
    const PostsFindById200ResponseCodeEnum._('number0');
const PostsFindById200ResponseCodeEnum
_$postsFindById200ResponseCodeEnum_unknownDefaultOpenApi =
    const PostsFindById200ResponseCodeEnum._('unknownDefaultOpenApi');

PostsFindById200ResponseCodeEnum _$postsFindById200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$postsFindById200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$postsFindById200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$postsFindById200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<PostsFindById200ResponseCodeEnum>
_$postsFindById200ResponseCodeEnumValues =
    BuiltSet<PostsFindById200ResponseCodeEnum>(
      const <PostsFindById200ResponseCodeEnum>[
        _$postsFindById200ResponseCodeEnum_number0,
        _$postsFindById200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<PostsFindById200ResponseCodeEnum>
_$postsFindById200ResponseCodeEnumSerializer =
    _$PostsFindById200ResponseCodeEnumSerializer();

class _$PostsFindById200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<PostsFindById200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[PostsFindById200ResponseCodeEnum];
  @override
  final String wireName = 'PostsFindById200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    PostsFindById200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  PostsFindById200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => PostsFindById200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$PostsFindById200Response extends PostsFindById200Response {
  @override
  final PostDetailResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$PostsFindById200Response([
    void Function(PostsFindById200ResponseBuilder)? updates,
  ]) => (PostsFindById200ResponseBuilder()..update(updates))._build();

  _$PostsFindById200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  PostsFindById200Response rebuild(
    void Function(PostsFindById200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  PostsFindById200ResponseBuilder toBuilder() =>
      PostsFindById200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostsFindById200Response &&
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
    return (newBuiltValueToStringHelper(r'PostsFindById200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class PostsFindById200ResponseBuilder
    implements
        Builder<PostsFindById200Response, PostsFindById200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$PostsFindById200Response? _$v;

  PostDetailResponseDtoBuilder? _data;
  PostDetailResponseDtoBuilder get data =>
      _$this._data ??= PostDetailResponseDtoBuilder();
  set data(covariant PostDetailResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  PostsFindById200ResponseBuilder() {
    PostsFindById200Response._defaults(this);
  }

  PostsFindById200ResponseBuilder get _$this {
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
  void replace(covariant PostsFindById200Response other) {
    _$v = other as _$PostsFindById200Response;
  }

  @override
  void update(void Function(PostsFindById200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostsFindById200Response build() => _build();

  _$PostsFindById200Response _build() {
    _$PostsFindById200Response _$result;
    try {
      _$result =
          _$v ??
          _$PostsFindById200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'PostsFindById200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'PostsFindById200Response',
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
          r'PostsFindById200Response',
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
