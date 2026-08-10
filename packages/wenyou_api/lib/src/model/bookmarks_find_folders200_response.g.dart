// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmarks_find_folders200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BookmarksFindFolders200ResponseCodeEnum
_$bookmarksFindFolders200ResponseCodeEnum_number0 =
    const BookmarksFindFolders200ResponseCodeEnum._('number0');
const BookmarksFindFolders200ResponseCodeEnum
_$bookmarksFindFolders200ResponseCodeEnum_unknownDefaultOpenApi =
    const BookmarksFindFolders200ResponseCodeEnum._('unknownDefaultOpenApi');

BookmarksFindFolders200ResponseCodeEnum
_$bookmarksFindFolders200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$bookmarksFindFolders200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$bookmarksFindFolders200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$bookmarksFindFolders200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<BookmarksFindFolders200ResponseCodeEnum>
_$bookmarksFindFolders200ResponseCodeEnumValues =
    BuiltSet<BookmarksFindFolders200ResponseCodeEnum>(
      const <BookmarksFindFolders200ResponseCodeEnum>[
        _$bookmarksFindFolders200ResponseCodeEnum_number0,
        _$bookmarksFindFolders200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<BookmarksFindFolders200ResponseCodeEnum>
_$bookmarksFindFolders200ResponseCodeEnumSerializer =
    _$BookmarksFindFolders200ResponseCodeEnumSerializer();

class _$BookmarksFindFolders200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<BookmarksFindFolders200ResponseCodeEnum> {
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
    BookmarksFindFolders200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'BookmarksFindFolders200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    BookmarksFindFolders200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  BookmarksFindFolders200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => BookmarksFindFolders200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$BookmarksFindFolders200Response
    extends BookmarksFindFolders200Response {
  @override
  final BuiltList<BookmarkFolderResponseDto> data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$BookmarksFindFolders200Response([
    void Function(BookmarksFindFolders200ResponseBuilder)? updates,
  ]) => (BookmarksFindFolders200ResponseBuilder()..update(updates))._build();

  _$BookmarksFindFolders200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  BookmarksFindFolders200Response rebuild(
    void Function(BookmarksFindFolders200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  BookmarksFindFolders200ResponseBuilder toBuilder() =>
      BookmarksFindFolders200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BookmarksFindFolders200Response &&
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
    return (newBuiltValueToStringHelper(r'BookmarksFindFolders200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class BookmarksFindFolders200ResponseBuilder
    implements
        Builder<
          BookmarksFindFolders200Response,
          BookmarksFindFolders200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$BookmarksFindFolders200Response? _$v;

  ListBuilder<BookmarkFolderResponseDto>? _data;
  ListBuilder<BookmarkFolderResponseDto> get data =>
      _$this._data ??= ListBuilder<BookmarkFolderResponseDto>();
  set data(covariant ListBuilder<BookmarkFolderResponseDto>? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  BookmarksFindFolders200ResponseBuilder() {
    BookmarksFindFolders200Response._defaults(this);
  }

  BookmarksFindFolders200ResponseBuilder get _$this {
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
  void replace(covariant BookmarksFindFolders200Response other) {
    _$v = other as _$BookmarksFindFolders200Response;
  }

  @override
  void update(void Function(BookmarksFindFolders200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BookmarksFindFolders200Response build() => _build();

  _$BookmarksFindFolders200Response _build() {
    _$BookmarksFindFolders200Response _$result;
    try {
      _$result =
          _$v ??
          _$BookmarksFindFolders200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'BookmarksFindFolders200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'BookmarksFindFolders200Response',
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
          r'BookmarksFindFolders200Response',
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
