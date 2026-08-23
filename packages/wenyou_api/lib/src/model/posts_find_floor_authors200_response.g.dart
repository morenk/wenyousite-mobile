// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'posts_find_floor_authors200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostsFindFloorAuthors200ResponseCodeEnum
_$postsFindFloorAuthors200ResponseCodeEnum_number0 =
    const PostsFindFloorAuthors200ResponseCodeEnum._('number0');
const PostsFindFloorAuthors200ResponseCodeEnum
_$postsFindFloorAuthors200ResponseCodeEnum_unknownDefaultOpenApi =
    const PostsFindFloorAuthors200ResponseCodeEnum._('unknownDefaultOpenApi');

PostsFindFloorAuthors200ResponseCodeEnum
_$postsFindFloorAuthors200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$postsFindFloorAuthors200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$postsFindFloorAuthors200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$postsFindFloorAuthors200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<PostsFindFloorAuthors200ResponseCodeEnum>
_$postsFindFloorAuthors200ResponseCodeEnumValues =
    BuiltSet<PostsFindFloorAuthors200ResponseCodeEnum>(
      const <PostsFindFloorAuthors200ResponseCodeEnum>[
        _$postsFindFloorAuthors200ResponseCodeEnum_number0,
        _$postsFindFloorAuthors200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<PostsFindFloorAuthors200ResponseCodeEnum>
_$postsFindFloorAuthors200ResponseCodeEnumSerializer =
    _$PostsFindFloorAuthors200ResponseCodeEnumSerializer();

class _$PostsFindFloorAuthors200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<PostsFindFloorAuthors200ResponseCodeEnum> {
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
    PostsFindFloorAuthors200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'PostsFindFloorAuthors200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    PostsFindFloorAuthors200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  PostsFindFloorAuthors200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => PostsFindFloorAuthors200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$PostsFindFloorAuthors200Response
    extends PostsFindFloorAuthors200Response {
  @override
  final BuiltList<DiscussionAuthorResponseDto> data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$PostsFindFloorAuthors200Response([
    void Function(PostsFindFloorAuthors200ResponseBuilder)? updates,
  ]) => (PostsFindFloorAuthors200ResponseBuilder()..update(updates))._build();

  _$PostsFindFloorAuthors200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  PostsFindFloorAuthors200Response rebuild(
    void Function(PostsFindFloorAuthors200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  PostsFindFloorAuthors200ResponseBuilder toBuilder() =>
      PostsFindFloorAuthors200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostsFindFloorAuthors200Response &&
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
    return (newBuiltValueToStringHelper(r'PostsFindFloorAuthors200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class PostsFindFloorAuthors200ResponseBuilder
    implements
        Builder<
          PostsFindFloorAuthors200Response,
          PostsFindFloorAuthors200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$PostsFindFloorAuthors200Response? _$v;

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

  PostsFindFloorAuthors200ResponseBuilder() {
    PostsFindFloorAuthors200Response._defaults(this);
  }

  PostsFindFloorAuthors200ResponseBuilder get _$this {
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
  void replace(covariant PostsFindFloorAuthors200Response other) {
    _$v = other as _$PostsFindFloorAuthors200Response;
  }

  @override
  void update(void Function(PostsFindFloorAuthors200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostsFindFloorAuthors200Response build() => _build();

  _$PostsFindFloorAuthors200Response _build() {
    _$PostsFindFloorAuthors200Response _$result;
    try {
      _$result =
          _$v ??
          _$PostsFindFloorAuthors200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'PostsFindFloorAuthors200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'PostsFindFloorAuthors200Response',
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
          r'PostsFindFloorAuthors200Response',
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
