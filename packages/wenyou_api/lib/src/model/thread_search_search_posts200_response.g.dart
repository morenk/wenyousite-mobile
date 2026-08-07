// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_search_search_posts200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ThreadSearchSearchPosts200ResponseCodeEnum
_$threadSearchSearchPosts200ResponseCodeEnum_number0 =
    const ThreadSearchSearchPosts200ResponseCodeEnum._('number0');
const ThreadSearchSearchPosts200ResponseCodeEnum
_$threadSearchSearchPosts200ResponseCodeEnum_unknownDefaultOpenApi =
    const ThreadSearchSearchPosts200ResponseCodeEnum._('unknownDefaultOpenApi');

ThreadSearchSearchPosts200ResponseCodeEnum
_$threadSearchSearchPosts200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$threadSearchSearchPosts200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$threadSearchSearchPosts200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$threadSearchSearchPosts200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadSearchSearchPosts200ResponseCodeEnum>
_$threadSearchSearchPosts200ResponseCodeEnumValues =
    BuiltSet<ThreadSearchSearchPosts200ResponseCodeEnum>(
      const <ThreadSearchSearchPosts200ResponseCodeEnum>[
        _$threadSearchSearchPosts200ResponseCodeEnum_number0,
        _$threadSearchSearchPosts200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ThreadSearchSearchPosts200ResponseCodeEnum>
_$threadSearchSearchPosts200ResponseCodeEnumSerializer =
    _$ThreadSearchSearchPosts200ResponseCodeEnumSerializer();

class _$ThreadSearchSearchPosts200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<ThreadSearchSearchPosts200ResponseCodeEnum> {
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
    ThreadSearchSearchPosts200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'ThreadSearchSearchPosts200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadSearchSearchPosts200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadSearchSearchPosts200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadSearchSearchPosts200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadSearchSearchPosts200Response
    extends ThreadSearchSearchPosts200Response {
  @override
  final BuiltList<SearchPostResponseDto> data;
  @override
  final ApiPaginationMeta meta;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$ThreadSearchSearchPosts200Response([
    void Function(ThreadSearchSearchPosts200ResponseBuilder)? updates,
  ]) => (ThreadSearchSearchPosts200ResponseBuilder()..update(updates))._build();

  _$ThreadSearchSearchPosts200Response._({
    required this.data,
    required this.meta,
    required this.code,
    required this.message,
  }) : super._();
  @override
  ThreadSearchSearchPosts200Response rebuild(
    void Function(ThreadSearchSearchPosts200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadSearchSearchPosts200ResponseBuilder toBuilder() =>
      ThreadSearchSearchPosts200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadSearchSearchPosts200Response &&
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
    return (newBuiltValueToStringHelper(r'ThreadSearchSearchPosts200Response')
          ..add('data', data)
          ..add('meta', meta)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ThreadSearchSearchPosts200ResponseBuilder
    implements
        Builder<
          ThreadSearchSearchPosts200Response,
          ThreadSearchSearchPosts200ResponseBuilder
        >,
        ApiPaginatedSuccessEnvelopeBuilder {
  _$ThreadSearchSearchPosts200Response? _$v;

  ListBuilder<SearchPostResponseDto>? _data;
  ListBuilder<SearchPostResponseDto> get data =>
      _$this._data ??= ListBuilder<SearchPostResponseDto>();
  set data(covariant ListBuilder<SearchPostResponseDto>? data) =>
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

  ThreadSearchSearchPosts200ResponseBuilder() {
    ThreadSearchSearchPosts200Response._defaults(this);
  }

  ThreadSearchSearchPosts200ResponseBuilder get _$this {
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
  void replace(covariant ThreadSearchSearchPosts200Response other) {
    _$v = other as _$ThreadSearchSearchPosts200Response;
  }

  @override
  void update(
    void Function(ThreadSearchSearchPosts200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  ThreadSearchSearchPosts200Response build() => _build();

  _$ThreadSearchSearchPosts200Response _build() {
    _$ThreadSearchSearchPosts200Response _$result;
    try {
      _$result =
          _$v ??
          _$ThreadSearchSearchPosts200Response._(
            data: data.build(),
            meta: meta.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'ThreadSearchSearchPosts200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'ThreadSearchSearchPosts200Response',
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
          r'ThreadSearchSearchPosts200Response',
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
