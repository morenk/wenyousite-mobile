// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_search_threads200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SearchSearchThreads200ResponseCodeEnum
_$searchSearchThreads200ResponseCodeEnum_number0 =
    const SearchSearchThreads200ResponseCodeEnum._('number0');
const SearchSearchThreads200ResponseCodeEnum
_$searchSearchThreads200ResponseCodeEnum_unknownDefaultOpenApi =
    const SearchSearchThreads200ResponseCodeEnum._('unknownDefaultOpenApi');

SearchSearchThreads200ResponseCodeEnum
_$searchSearchThreads200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$searchSearchThreads200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$searchSearchThreads200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$searchSearchThreads200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<SearchSearchThreads200ResponseCodeEnum>
_$searchSearchThreads200ResponseCodeEnumValues =
    BuiltSet<SearchSearchThreads200ResponseCodeEnum>(
      const <SearchSearchThreads200ResponseCodeEnum>[
        _$searchSearchThreads200ResponseCodeEnum_number0,
        _$searchSearchThreads200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<SearchSearchThreads200ResponseCodeEnum>
_$searchSearchThreads200ResponseCodeEnumSerializer =
    _$SearchSearchThreads200ResponseCodeEnumSerializer();

class _$SearchSearchThreads200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<SearchSearchThreads200ResponseCodeEnum> {
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
    SearchSearchThreads200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'SearchSearchThreads200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    SearchSearchThreads200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SearchSearchThreads200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SearchSearchThreads200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$SearchSearchThreads200Response extends SearchSearchThreads200Response {
  @override
  final BuiltList<SearchThreadResponseDto> data;
  @override
  final ApiPaginationMeta meta;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$SearchSearchThreads200Response([
    void Function(SearchSearchThreads200ResponseBuilder)? updates,
  ]) => (SearchSearchThreads200ResponseBuilder()..update(updates))._build();

  _$SearchSearchThreads200Response._({
    required this.data,
    required this.meta,
    required this.code,
    required this.message,
  }) : super._();
  @override
  SearchSearchThreads200Response rebuild(
    void Function(SearchSearchThreads200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SearchSearchThreads200ResponseBuilder toBuilder() =>
      SearchSearchThreads200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SearchSearchThreads200Response &&
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
    return (newBuiltValueToStringHelper(r'SearchSearchThreads200Response')
          ..add('data', data)
          ..add('meta', meta)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class SearchSearchThreads200ResponseBuilder
    implements
        Builder<
          SearchSearchThreads200Response,
          SearchSearchThreads200ResponseBuilder
        >,
        ApiPaginatedSuccessEnvelopeBuilder {
  _$SearchSearchThreads200Response? _$v;

  ListBuilder<SearchThreadResponseDto>? _data;
  ListBuilder<SearchThreadResponseDto> get data =>
      _$this._data ??= ListBuilder<SearchThreadResponseDto>();
  set data(covariant ListBuilder<SearchThreadResponseDto>? data) =>
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

  SearchSearchThreads200ResponseBuilder() {
    SearchSearchThreads200Response._defaults(this);
  }

  SearchSearchThreads200ResponseBuilder get _$this {
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
  void replace(covariant SearchSearchThreads200Response other) {
    _$v = other as _$SearchSearchThreads200Response;
  }

  @override
  void update(void Function(SearchSearchThreads200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SearchSearchThreads200Response build() => _build();

  _$SearchSearchThreads200Response _build() {
    _$SearchSearchThreads200Response _$result;
    try {
      _$result =
          _$v ??
          _$SearchSearchThreads200Response._(
            data: data.build(),
            meta: meta.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'SearchSearchThreads200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'SearchSearchThreads200Response',
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
          r'SearchSearchThreads200Response',
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
