// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_search_users200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SearchSearchUsers200ResponseCodeEnum
_$searchSearchUsers200ResponseCodeEnum_number0 =
    const SearchSearchUsers200ResponseCodeEnum._('number0');
const SearchSearchUsers200ResponseCodeEnum
_$searchSearchUsers200ResponseCodeEnum_unknownDefaultOpenApi =
    const SearchSearchUsers200ResponseCodeEnum._('unknownDefaultOpenApi');

SearchSearchUsers200ResponseCodeEnum
_$searchSearchUsers200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$searchSearchUsers200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$searchSearchUsers200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$searchSearchUsers200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<SearchSearchUsers200ResponseCodeEnum>
_$searchSearchUsers200ResponseCodeEnumValues =
    BuiltSet<SearchSearchUsers200ResponseCodeEnum>(
      const <SearchSearchUsers200ResponseCodeEnum>[
        _$searchSearchUsers200ResponseCodeEnum_number0,
        _$searchSearchUsers200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<SearchSearchUsers200ResponseCodeEnum>
_$searchSearchUsers200ResponseCodeEnumSerializer =
    _$SearchSearchUsers200ResponseCodeEnumSerializer();

class _$SearchSearchUsers200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<SearchSearchUsers200ResponseCodeEnum> {
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
    SearchSearchUsers200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'SearchSearchUsers200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    SearchSearchUsers200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SearchSearchUsers200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SearchSearchUsers200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$SearchSearchUsers200Response extends SearchSearchUsers200Response {
  @override
  final BuiltList<SearchUserResponseDto> data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$SearchSearchUsers200Response([
    void Function(SearchSearchUsers200ResponseBuilder)? updates,
  ]) => (SearchSearchUsers200ResponseBuilder()..update(updates))._build();

  _$SearchSearchUsers200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  SearchSearchUsers200Response rebuild(
    void Function(SearchSearchUsers200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SearchSearchUsers200ResponseBuilder toBuilder() =>
      SearchSearchUsers200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SearchSearchUsers200Response &&
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
    return (newBuiltValueToStringHelper(r'SearchSearchUsers200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class SearchSearchUsers200ResponseBuilder
    implements
        Builder<
          SearchSearchUsers200Response,
          SearchSearchUsers200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$SearchSearchUsers200Response? _$v;

  ListBuilder<SearchUserResponseDto>? _data;
  ListBuilder<SearchUserResponseDto> get data =>
      _$this._data ??= ListBuilder<SearchUserResponseDto>();
  set data(covariant ListBuilder<SearchUserResponseDto>? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  SearchSearchUsers200ResponseBuilder() {
    SearchSearchUsers200Response._defaults(this);
  }

  SearchSearchUsers200ResponseBuilder get _$this {
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
  void replace(covariant SearchSearchUsers200Response other) {
    _$v = other as _$SearchSearchUsers200Response;
  }

  @override
  void update(void Function(SearchSearchUsers200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SearchSearchUsers200Response build() => _build();

  _$SearchSearchUsers200Response _build() {
    _$SearchSearchUsers200Response _$result;
    try {
      _$result =
          _$v ??
          _$SearchSearchUsers200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'SearchSearchUsers200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'SearchSearchUsers200Response',
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
          r'SearchSearchUsers200Response',
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
