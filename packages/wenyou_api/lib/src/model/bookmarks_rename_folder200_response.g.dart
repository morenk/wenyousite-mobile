// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmarks_rename_folder200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BookmarksRenameFolder200ResponseCodeEnum
_$bookmarksRenameFolder200ResponseCodeEnum_number0 =
    const BookmarksRenameFolder200ResponseCodeEnum._('number0');
const BookmarksRenameFolder200ResponseCodeEnum
_$bookmarksRenameFolder200ResponseCodeEnum_unknownDefaultOpenApi =
    const BookmarksRenameFolder200ResponseCodeEnum._('unknownDefaultOpenApi');

BookmarksRenameFolder200ResponseCodeEnum
_$bookmarksRenameFolder200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$bookmarksRenameFolder200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$bookmarksRenameFolder200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$bookmarksRenameFolder200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<BookmarksRenameFolder200ResponseCodeEnum>
_$bookmarksRenameFolder200ResponseCodeEnumValues =
    BuiltSet<BookmarksRenameFolder200ResponseCodeEnum>(
      const <BookmarksRenameFolder200ResponseCodeEnum>[
        _$bookmarksRenameFolder200ResponseCodeEnum_number0,
        _$bookmarksRenameFolder200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<BookmarksRenameFolder200ResponseCodeEnum>
_$bookmarksRenameFolder200ResponseCodeEnumSerializer =
    _$BookmarksRenameFolder200ResponseCodeEnumSerializer();

class _$BookmarksRenameFolder200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<BookmarksRenameFolder200ResponseCodeEnum> {
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
    BookmarksRenameFolder200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'BookmarksRenameFolder200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    BookmarksRenameFolder200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  BookmarksRenameFolder200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => BookmarksRenameFolder200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$BookmarksRenameFolder200Response
    extends BookmarksRenameFolder200Response {
  @override
  final BookmarkFolderResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$BookmarksRenameFolder200Response([
    void Function(BookmarksRenameFolder200ResponseBuilder)? updates,
  ]) => (BookmarksRenameFolder200ResponseBuilder()..update(updates))._build();

  _$BookmarksRenameFolder200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  BookmarksRenameFolder200Response rebuild(
    void Function(BookmarksRenameFolder200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  BookmarksRenameFolder200ResponseBuilder toBuilder() =>
      BookmarksRenameFolder200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BookmarksRenameFolder200Response &&
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
    return (newBuiltValueToStringHelper(r'BookmarksRenameFolder200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class BookmarksRenameFolder200ResponseBuilder
    implements
        Builder<
          BookmarksRenameFolder200Response,
          BookmarksRenameFolder200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$BookmarksRenameFolder200Response? _$v;

  BookmarkFolderResponseDtoBuilder? _data;
  BookmarkFolderResponseDtoBuilder get data =>
      _$this._data ??= BookmarkFolderResponseDtoBuilder();
  set data(covariant BookmarkFolderResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  BookmarksRenameFolder200ResponseBuilder() {
    BookmarksRenameFolder200Response._defaults(this);
  }

  BookmarksRenameFolder200ResponseBuilder get _$this {
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
  void replace(covariant BookmarksRenameFolder200Response other) {
    _$v = other as _$BookmarksRenameFolder200Response;
  }

  @override
  void update(void Function(BookmarksRenameFolder200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BookmarksRenameFolder200Response build() => _build();

  _$BookmarksRenameFolder200Response _build() {
    _$BookmarksRenameFolder200Response _$result;
    try {
      _$result =
          _$v ??
          _$BookmarksRenameFolder200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'BookmarksRenameFolder200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'BookmarksRenameFolder200Response',
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
          r'BookmarksRenameFolder200Response',
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
