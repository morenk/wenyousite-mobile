// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'posts_find_floors200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostsFindFloors200ResponseCodeEnum
_$postsFindFloors200ResponseCodeEnum_number0 =
    const PostsFindFloors200ResponseCodeEnum._('number0');
const PostsFindFloors200ResponseCodeEnum
_$postsFindFloors200ResponseCodeEnum_unknownDefaultOpenApi =
    const PostsFindFloors200ResponseCodeEnum._('unknownDefaultOpenApi');

PostsFindFloors200ResponseCodeEnum _$postsFindFloors200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$postsFindFloors200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$postsFindFloors200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$postsFindFloors200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<PostsFindFloors200ResponseCodeEnum>
_$postsFindFloors200ResponseCodeEnumValues =
    BuiltSet<PostsFindFloors200ResponseCodeEnum>(
      const <PostsFindFloors200ResponseCodeEnum>[
        _$postsFindFloors200ResponseCodeEnum_number0,
        _$postsFindFloors200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<PostsFindFloors200ResponseCodeEnum>
_$postsFindFloors200ResponseCodeEnumSerializer =
    _$PostsFindFloors200ResponseCodeEnumSerializer();

class _$PostsFindFloors200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<PostsFindFloors200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[PostsFindFloors200ResponseCodeEnum];
  @override
  final String wireName = 'PostsFindFloors200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    PostsFindFloors200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  PostsFindFloors200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => PostsFindFloors200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$PostsFindFloors200Response extends PostsFindFloors200Response {
  @override
  final BuiltList<FloorResponseDto> data;
  @override
  final ApiPaginationMeta meta;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$PostsFindFloors200Response([
    void Function(PostsFindFloors200ResponseBuilder)? updates,
  ]) => (PostsFindFloors200ResponseBuilder()..update(updates))._build();

  _$PostsFindFloors200Response._({
    required this.data,
    required this.meta,
    required this.code,
    required this.message,
  }) : super._();
  @override
  PostsFindFloors200Response rebuild(
    void Function(PostsFindFloors200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  PostsFindFloors200ResponseBuilder toBuilder() =>
      PostsFindFloors200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostsFindFloors200Response &&
        data == other.data &&
        meta == other.meta &&
        code == other.code &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, meta.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostsFindFloors200Response')
          ..add('data', data)
          ..add('meta', meta)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class PostsFindFloors200ResponseBuilder
    implements
        Builder<PostsFindFloors200Response, PostsFindFloors200ResponseBuilder>,
        ApiPaginatedSuccessEnvelopeBuilder {
  _$PostsFindFloors200Response? _$v;

  ListBuilder<FloorResponseDto>? _data;
  ListBuilder<FloorResponseDto> get data =>
      _$this._data ??= ListBuilder<FloorResponseDto>();
  set data(covariant ListBuilder<FloorResponseDto>? data) =>
      _$this._data = data;

  ApiPaginationMetaBuilder? _meta;
  ApiPaginationMetaBuilder get meta =>
      _$this._meta ??= ApiPaginationMetaBuilder();
  set meta(covariant ApiPaginationMetaBuilder? meta) => _$this._meta = meta;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  PostsFindFloors200ResponseBuilder() {
    PostsFindFloors200Response._defaults(this);
  }

  PostsFindFloors200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _meta = $v.meta.toBuilder();
      _code = $v.code;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant PostsFindFloors200Response other) {
    _$v = other as _$PostsFindFloors200Response;
  }

  @override
  void update(void Function(PostsFindFloors200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostsFindFloors200Response build() => _build();

  _$PostsFindFloors200Response _build() {
    _$PostsFindFloors200Response _$result;
    try {
      _$result =
          _$v ??
          _$PostsFindFloors200Response._(
            data: data.build(),
            meta: meta.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'PostsFindFloors200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'PostsFindFloors200Response',
              'message',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
        _$failedField = 'meta';
        meta.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'PostsFindFloors200Response',
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
