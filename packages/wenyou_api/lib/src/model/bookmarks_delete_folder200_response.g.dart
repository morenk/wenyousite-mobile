// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmarks_delete_folder200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BookmarksDeleteFolder200ResponseCodeEnum
_$bookmarksDeleteFolder200ResponseCodeEnum_number0 =
    const BookmarksDeleteFolder200ResponseCodeEnum._('number0');
const BookmarksDeleteFolder200ResponseCodeEnum
_$bookmarksDeleteFolder200ResponseCodeEnum_unknownDefaultOpenApi =
    const BookmarksDeleteFolder200ResponseCodeEnum._('unknownDefaultOpenApi');

BookmarksDeleteFolder200ResponseCodeEnum
_$bookmarksDeleteFolder200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$bookmarksDeleteFolder200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$bookmarksDeleteFolder200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$bookmarksDeleteFolder200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<BookmarksDeleteFolder200ResponseCodeEnum>
_$bookmarksDeleteFolder200ResponseCodeEnumValues =
    BuiltSet<BookmarksDeleteFolder200ResponseCodeEnum>(
      const <BookmarksDeleteFolder200ResponseCodeEnum>[
        _$bookmarksDeleteFolder200ResponseCodeEnum_number0,
        _$bookmarksDeleteFolder200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<BookmarksDeleteFolder200ResponseCodeEnum>
_$bookmarksDeleteFolder200ResponseCodeEnumSerializer =
    _$BookmarksDeleteFolder200ResponseCodeEnumSerializer();

class _$BookmarksDeleteFolder200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<BookmarksDeleteFolder200ResponseCodeEnum> {
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
    BookmarksDeleteFolder200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'BookmarksDeleteFolder200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    BookmarksDeleteFolder200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  BookmarksDeleteFolder200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => BookmarksDeleteFolder200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$BookmarksDeleteFolder200Response
    extends BookmarksDeleteFolder200Response {
  @override
  final DeleteBookmarkFolderResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$BookmarksDeleteFolder200Response([
    void Function(BookmarksDeleteFolder200ResponseBuilder)? updates,
  ]) => (BookmarksDeleteFolder200ResponseBuilder()..update(updates))._build();

  _$BookmarksDeleteFolder200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  BookmarksDeleteFolder200Response rebuild(
    void Function(BookmarksDeleteFolder200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  BookmarksDeleteFolder200ResponseBuilder toBuilder() =>
      BookmarksDeleteFolder200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BookmarksDeleteFolder200Response &&
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
    return (newBuiltValueToStringHelper(r'BookmarksDeleteFolder200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class BookmarksDeleteFolder200ResponseBuilder
    implements
        Builder<
          BookmarksDeleteFolder200Response,
          BookmarksDeleteFolder200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$BookmarksDeleteFolder200Response? _$v;

  DeleteBookmarkFolderResponseDtoBuilder? _data;
  DeleteBookmarkFolderResponseDtoBuilder get data =>
      _$this._data ??= DeleteBookmarkFolderResponseDtoBuilder();
  set data(covariant DeleteBookmarkFolderResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  BookmarksDeleteFolder200ResponseBuilder() {
    BookmarksDeleteFolder200Response._defaults(this);
  }

  BookmarksDeleteFolder200ResponseBuilder get _$this {
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
  void replace(covariant BookmarksDeleteFolder200Response other) {
    _$v = other as _$BookmarksDeleteFolder200Response;
  }

  @override
  void update(void Function(BookmarksDeleteFolder200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BookmarksDeleteFolder200Response build() => _build();

  _$BookmarksDeleteFolder200Response _build() {
    _$BookmarksDeleteFolder200Response _$result;
    try {
      _$result =
          _$v ??
          _$BookmarksDeleteFolder200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'BookmarksDeleteFolder200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'BookmarksDeleteFolder200Response',
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
          r'BookmarksDeleteFolder200Response',
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
