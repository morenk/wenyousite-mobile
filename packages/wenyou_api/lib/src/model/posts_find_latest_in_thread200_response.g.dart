// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'posts_find_latest_in_thread200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostsFindLatestInThread200ResponseCodeEnum
_$postsFindLatestInThread200ResponseCodeEnum_number0 =
    const PostsFindLatestInThread200ResponseCodeEnum._('number0');
const PostsFindLatestInThread200ResponseCodeEnum
_$postsFindLatestInThread200ResponseCodeEnum_unknownDefaultOpenApi =
    const PostsFindLatestInThread200ResponseCodeEnum._('unknownDefaultOpenApi');

PostsFindLatestInThread200ResponseCodeEnum
_$postsFindLatestInThread200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$postsFindLatestInThread200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$postsFindLatestInThread200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$postsFindLatestInThread200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<PostsFindLatestInThread200ResponseCodeEnum>
_$postsFindLatestInThread200ResponseCodeEnumValues =
    BuiltSet<PostsFindLatestInThread200ResponseCodeEnum>(
      const <PostsFindLatestInThread200ResponseCodeEnum>[
        _$postsFindLatestInThread200ResponseCodeEnum_number0,
        _$postsFindLatestInThread200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<PostsFindLatestInThread200ResponseCodeEnum>
_$postsFindLatestInThread200ResponseCodeEnumSerializer =
    _$PostsFindLatestInThread200ResponseCodeEnumSerializer();

class _$PostsFindLatestInThread200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<PostsFindLatestInThread200ResponseCodeEnum> {
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
    PostsFindLatestInThread200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'PostsFindLatestInThread200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    PostsFindLatestInThread200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  PostsFindLatestInThread200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => PostsFindLatestInThread200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$PostsFindLatestInThread200Response
    extends PostsFindLatestInThread200Response {
  @override
  final LatestThreadPostResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$PostsFindLatestInThread200Response([
    void Function(PostsFindLatestInThread200ResponseBuilder)? updates,
  ]) => (PostsFindLatestInThread200ResponseBuilder()..update(updates))._build();

  _$PostsFindLatestInThread200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  PostsFindLatestInThread200Response rebuild(
    void Function(PostsFindLatestInThread200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  PostsFindLatestInThread200ResponseBuilder toBuilder() =>
      PostsFindLatestInThread200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostsFindLatestInThread200Response &&
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
    return (newBuiltValueToStringHelper(r'PostsFindLatestInThread200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class PostsFindLatestInThread200ResponseBuilder
    implements
        Builder<
          PostsFindLatestInThread200Response,
          PostsFindLatestInThread200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$PostsFindLatestInThread200Response? _$v;

  LatestThreadPostResponseDtoBuilder? _data;
  LatestThreadPostResponseDtoBuilder get data =>
      _$this._data ??= LatestThreadPostResponseDtoBuilder();
  set data(covariant LatestThreadPostResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  PostsFindLatestInThread200ResponseBuilder() {
    PostsFindLatestInThread200Response._defaults(this);
  }

  PostsFindLatestInThread200ResponseBuilder get _$this {
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
  void replace(covariant PostsFindLatestInThread200Response other) {
    _$v = other as _$PostsFindLatestInThread200Response;
  }

  @override
  void update(
    void Function(PostsFindLatestInThread200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  PostsFindLatestInThread200Response build() => _build();

  _$PostsFindLatestInThread200Response _build() {
    _$PostsFindLatestInThread200Response _$result;
    try {
      _$result =
          _$v ??
          _$PostsFindLatestInThread200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'PostsFindLatestInThread200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'PostsFindLatestInThread200Response',
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
          r'PostsFindLatestInThread200Response',
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
