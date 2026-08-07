// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_search_posts200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SearchSearchPosts200ResponseCodeEnum
_$searchSearchPosts200ResponseCodeEnum_number0 =
    const SearchSearchPosts200ResponseCodeEnum._('number0');
const SearchSearchPosts200ResponseCodeEnum
_$searchSearchPosts200ResponseCodeEnum_unknownDefaultOpenApi =
    const SearchSearchPosts200ResponseCodeEnum._('unknownDefaultOpenApi');

SearchSearchPosts200ResponseCodeEnum
_$searchSearchPosts200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$searchSearchPosts200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$searchSearchPosts200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$searchSearchPosts200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<SearchSearchPosts200ResponseCodeEnum>
_$searchSearchPosts200ResponseCodeEnumValues =
    BuiltSet<SearchSearchPosts200ResponseCodeEnum>(
      const <SearchSearchPosts200ResponseCodeEnum>[
        _$searchSearchPosts200ResponseCodeEnum_number0,
        _$searchSearchPosts200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<SearchSearchPosts200ResponseCodeEnum>
_$searchSearchPosts200ResponseCodeEnumSerializer =
    _$SearchSearchPosts200ResponseCodeEnumSerializer();

class _$SearchSearchPosts200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<SearchSearchPosts200ResponseCodeEnum> {
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
    SearchSearchPosts200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'SearchSearchPosts200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    SearchSearchPosts200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SearchSearchPosts200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SearchSearchPosts200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$SearchSearchPosts200Response extends SearchSearchPosts200Response {
  @override
  final BuiltList<SearchPostResponseDto> data;
  @override
  final ApiPaginationMeta meta;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$SearchSearchPosts200Response([
    void Function(SearchSearchPosts200ResponseBuilder)? updates,
  ]) => (SearchSearchPosts200ResponseBuilder()..update(updates))._build();

  _$SearchSearchPosts200Response._({
    required this.data,
    required this.meta,
    required this.code,
    required this.message,
  }) : super._();
  @override
  SearchSearchPosts200Response rebuild(
    void Function(SearchSearchPosts200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SearchSearchPosts200ResponseBuilder toBuilder() =>
      SearchSearchPosts200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SearchSearchPosts200Response &&
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
    return (newBuiltValueToStringHelper(r'SearchSearchPosts200Response')
          ..add('data', data)
          ..add('meta', meta)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class SearchSearchPosts200ResponseBuilder
    implements
        Builder<
          SearchSearchPosts200Response,
          SearchSearchPosts200ResponseBuilder
        >,
        ApiPaginatedSuccessEnvelopeBuilder {
  _$SearchSearchPosts200Response? _$v;

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

  SearchSearchPosts200ResponseBuilder() {
    SearchSearchPosts200Response._defaults(this);
  }

  SearchSearchPosts200ResponseBuilder get _$this {
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
  void replace(covariant SearchSearchPosts200Response other) {
    _$v = other as _$SearchSearchPosts200Response;
  }

  @override
  void update(void Function(SearchSearchPosts200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SearchSearchPosts200Response build() => _build();

  _$SearchSearchPosts200Response _build() {
    _$SearchSearchPosts200Response _$result;
    try {
      _$result =
          _$v ??
          _$SearchSearchPosts200Response._(
            data: data.build(),
            meta: meta.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'SearchSearchPosts200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'SearchSearchPosts200Response',
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
          r'SearchSearchPosts200Response',
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
