// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmarks_move200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BookmarksMove200ResponseCodeEnum
_$bookmarksMove200ResponseCodeEnum_number0 =
    const BookmarksMove200ResponseCodeEnum._('number0');
const BookmarksMove200ResponseCodeEnum
_$bookmarksMove200ResponseCodeEnum_unknownDefaultOpenApi =
    const BookmarksMove200ResponseCodeEnum._('unknownDefaultOpenApi');

BookmarksMove200ResponseCodeEnum _$bookmarksMove200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$bookmarksMove200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$bookmarksMove200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$bookmarksMove200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<BookmarksMove200ResponseCodeEnum>
_$bookmarksMove200ResponseCodeEnumValues =
    BuiltSet<BookmarksMove200ResponseCodeEnum>(
      const <BookmarksMove200ResponseCodeEnum>[
        _$bookmarksMove200ResponseCodeEnum_number0,
        _$bookmarksMove200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<BookmarksMove200ResponseCodeEnum>
_$bookmarksMove200ResponseCodeEnumSerializer =
    _$BookmarksMove200ResponseCodeEnumSerializer();

class _$BookmarksMove200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<BookmarksMove200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[BookmarksMove200ResponseCodeEnum];
  @override
  final String wireName = 'BookmarksMove200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    BookmarksMove200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  BookmarksMove200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => BookmarksMove200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$BookmarksMove200Response extends BookmarksMove200Response {
  @override
  final BookmarkResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$BookmarksMove200Response([
    void Function(BookmarksMove200ResponseBuilder)? updates,
  ]) => (BookmarksMove200ResponseBuilder()..update(updates))._build();

  _$BookmarksMove200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  BookmarksMove200Response rebuild(
    void Function(BookmarksMove200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  BookmarksMove200ResponseBuilder toBuilder() =>
      BookmarksMove200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BookmarksMove200Response &&
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
    return (newBuiltValueToStringHelper(r'BookmarksMove200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class BookmarksMove200ResponseBuilder
    implements
        Builder<BookmarksMove200Response, BookmarksMove200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$BookmarksMove200Response? _$v;

  BookmarkResponseDtoBuilder? _data;
  BookmarkResponseDtoBuilder get data =>
      _$this._data ??= BookmarkResponseDtoBuilder();
  set data(covariant BookmarkResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  BookmarksMove200ResponseBuilder() {
    BookmarksMove200Response._defaults(this);
  }

  BookmarksMove200ResponseBuilder get _$this {
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
  void replace(covariant BookmarksMove200Response other) {
    _$v = other as _$BookmarksMove200Response;
  }

  @override
  void update(void Function(BookmarksMove200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BookmarksMove200Response build() => _build();

  _$BookmarksMove200Response _build() {
    _$BookmarksMove200Response _$result;
    try {
      _$result =
          _$v ??
          _$BookmarksMove200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'BookmarksMove200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'BookmarksMove200Response',
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
          r'BookmarksMove200Response',
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
