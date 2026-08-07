// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_search200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SearchSearch200ResponseCodeEnum
_$searchSearch200ResponseCodeEnum_number0 =
    const SearchSearch200ResponseCodeEnum._('number0');
const SearchSearch200ResponseCodeEnum
_$searchSearch200ResponseCodeEnum_unknownDefaultOpenApi =
    const SearchSearch200ResponseCodeEnum._('unknownDefaultOpenApi');

SearchSearch200ResponseCodeEnum _$searchSearch200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$searchSearch200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$searchSearch200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$searchSearch200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<SearchSearch200ResponseCodeEnum>
_$searchSearch200ResponseCodeEnumValues =
    BuiltSet<SearchSearch200ResponseCodeEnum>(
      const <SearchSearch200ResponseCodeEnum>[
        _$searchSearch200ResponseCodeEnum_number0,
        _$searchSearch200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<SearchSearch200ResponseCodeEnum>
_$searchSearch200ResponseCodeEnumSerializer =
    _$SearchSearch200ResponseCodeEnumSerializer();

class _$SearchSearch200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<SearchSearch200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[SearchSearch200ResponseCodeEnum];
  @override
  final String wireName = 'SearchSearch200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    SearchSearch200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SearchSearch200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SearchSearch200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$SearchSearch200Response extends SearchSearch200Response {
  @override
  final SearchResultResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$SearchSearch200Response([
    void Function(SearchSearch200ResponseBuilder)? updates,
  ]) => (SearchSearch200ResponseBuilder()..update(updates))._build();

  _$SearchSearch200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  SearchSearch200Response rebuild(
    void Function(SearchSearch200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SearchSearch200ResponseBuilder toBuilder() =>
      SearchSearch200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SearchSearch200Response &&
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
    return (newBuiltValueToStringHelper(r'SearchSearch200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class SearchSearch200ResponseBuilder
    implements
        Builder<SearchSearch200Response, SearchSearch200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$SearchSearch200Response? _$v;

  SearchResultResponseDtoBuilder? _data;
  SearchResultResponseDtoBuilder get data =>
      _$this._data ??= SearchResultResponseDtoBuilder();
  set data(covariant SearchResultResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  SearchSearch200ResponseBuilder() {
    SearchSearch200Response._defaults(this);
  }

  SearchSearch200ResponseBuilder get _$this {
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
  void replace(covariant SearchSearch200Response other) {
    _$v = other as _$SearchSearch200Response;
  }

  @override
  void update(void Function(SearchSearch200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SearchSearch200Response build() => _build();

  _$SearchSearch200Response _build() {
    _$SearchSearch200Response _$result;
    try {
      _$result =
          _$v ??
          _$SearchSearch200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'SearchSearch200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'SearchSearch200Response',
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
          r'SearchSearch200Response',
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
