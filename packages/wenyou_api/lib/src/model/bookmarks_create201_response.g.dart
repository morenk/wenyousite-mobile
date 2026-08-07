// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmarks_create201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BookmarksCreate201ResponseCodeEnum
_$bookmarksCreate201ResponseCodeEnum_number0 =
    const BookmarksCreate201ResponseCodeEnum._('number0');
const BookmarksCreate201ResponseCodeEnum
_$bookmarksCreate201ResponseCodeEnum_unknownDefaultOpenApi =
    const BookmarksCreate201ResponseCodeEnum._('unknownDefaultOpenApi');

BookmarksCreate201ResponseCodeEnum _$bookmarksCreate201ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$bookmarksCreate201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$bookmarksCreate201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$bookmarksCreate201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<BookmarksCreate201ResponseCodeEnum>
_$bookmarksCreate201ResponseCodeEnumValues =
    BuiltSet<BookmarksCreate201ResponseCodeEnum>(
      const <BookmarksCreate201ResponseCodeEnum>[
        _$bookmarksCreate201ResponseCodeEnum_number0,
        _$bookmarksCreate201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<BookmarksCreate201ResponseCodeEnum>
_$bookmarksCreate201ResponseCodeEnumSerializer =
    _$BookmarksCreate201ResponseCodeEnumSerializer();

class _$BookmarksCreate201ResponseCodeEnumSerializer
    implements PrimitiveSerializer<BookmarksCreate201ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[BookmarksCreate201ResponseCodeEnum];
  @override
  final String wireName = 'BookmarksCreate201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    BookmarksCreate201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  BookmarksCreate201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => BookmarksCreate201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$BookmarksCreate201Response extends BookmarksCreate201Response {
  @override
  final BookmarkResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$BookmarksCreate201Response([
    void Function(BookmarksCreate201ResponseBuilder)? updates,
  ]) => (BookmarksCreate201ResponseBuilder()..update(updates))._build();

  _$BookmarksCreate201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  BookmarksCreate201Response rebuild(
    void Function(BookmarksCreate201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  BookmarksCreate201ResponseBuilder toBuilder() =>
      BookmarksCreate201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BookmarksCreate201Response &&
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
    return (newBuiltValueToStringHelper(r'BookmarksCreate201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class BookmarksCreate201ResponseBuilder
    implements
        Builder<BookmarksCreate201Response, BookmarksCreate201ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$BookmarksCreate201Response? _$v;

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

  BookmarksCreate201ResponseBuilder() {
    BookmarksCreate201Response._defaults(this);
  }

  BookmarksCreate201ResponseBuilder get _$this {
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
  void replace(covariant BookmarksCreate201Response other) {
    _$v = other as _$BookmarksCreate201Response;
  }

  @override
  void update(void Function(BookmarksCreate201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BookmarksCreate201Response build() => _build();

  _$BookmarksCreate201Response _build() {
    _$BookmarksCreate201Response _$result;
    try {
      _$result =
          _$v ??
          _$BookmarksCreate201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'BookmarksCreate201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'BookmarksCreate201Response',
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
          r'BookmarksCreate201Response',
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
