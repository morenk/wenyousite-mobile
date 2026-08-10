// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmarks_create_folder201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BookmarksCreateFolder201ResponseCodeEnum
_$bookmarksCreateFolder201ResponseCodeEnum_number0 =
    const BookmarksCreateFolder201ResponseCodeEnum._('number0');
const BookmarksCreateFolder201ResponseCodeEnum
_$bookmarksCreateFolder201ResponseCodeEnum_unknownDefaultOpenApi =
    const BookmarksCreateFolder201ResponseCodeEnum._('unknownDefaultOpenApi');

BookmarksCreateFolder201ResponseCodeEnum
_$bookmarksCreateFolder201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$bookmarksCreateFolder201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$bookmarksCreateFolder201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$bookmarksCreateFolder201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<BookmarksCreateFolder201ResponseCodeEnum>
_$bookmarksCreateFolder201ResponseCodeEnumValues =
    BuiltSet<BookmarksCreateFolder201ResponseCodeEnum>(
      const <BookmarksCreateFolder201ResponseCodeEnum>[
        _$bookmarksCreateFolder201ResponseCodeEnum_number0,
        _$bookmarksCreateFolder201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<BookmarksCreateFolder201ResponseCodeEnum>
_$bookmarksCreateFolder201ResponseCodeEnumSerializer =
    _$BookmarksCreateFolder201ResponseCodeEnumSerializer();

class _$BookmarksCreateFolder201ResponseCodeEnumSerializer
    implements PrimitiveSerializer<BookmarksCreateFolder201ResponseCodeEnum> {
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
    BookmarksCreateFolder201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'BookmarksCreateFolder201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    BookmarksCreateFolder201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  BookmarksCreateFolder201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => BookmarksCreateFolder201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$BookmarksCreateFolder201Response
    extends BookmarksCreateFolder201Response {
  @override
  final BookmarkFolderResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$BookmarksCreateFolder201Response([
    void Function(BookmarksCreateFolder201ResponseBuilder)? updates,
  ]) => (BookmarksCreateFolder201ResponseBuilder()..update(updates))._build();

  _$BookmarksCreateFolder201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  BookmarksCreateFolder201Response rebuild(
    void Function(BookmarksCreateFolder201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  BookmarksCreateFolder201ResponseBuilder toBuilder() =>
      BookmarksCreateFolder201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BookmarksCreateFolder201Response &&
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
    return (newBuiltValueToStringHelper(r'BookmarksCreateFolder201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class BookmarksCreateFolder201ResponseBuilder
    implements
        Builder<
          BookmarksCreateFolder201Response,
          BookmarksCreateFolder201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$BookmarksCreateFolder201Response? _$v;

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

  BookmarksCreateFolder201ResponseBuilder() {
    BookmarksCreateFolder201Response._defaults(this);
  }

  BookmarksCreateFolder201ResponseBuilder get _$this {
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
  void replace(covariant BookmarksCreateFolder201Response other) {
    _$v = other as _$BookmarksCreateFolder201Response;
  }

  @override
  void update(void Function(BookmarksCreateFolder201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BookmarksCreateFolder201Response build() => _build();

  _$BookmarksCreateFolder201Response _build() {
    _$BookmarksCreateFolder201Response _$result;
    try {
      _$result =
          _$v ??
          _$BookmarksCreateFolder201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'BookmarksCreateFolder201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'BookmarksCreateFolder201Response',
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
          r'BookmarksCreateFolder201Response',
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
