// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmarks_find_all200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BookmarksFindAll200ResponseCodeEnum
_$bookmarksFindAll200ResponseCodeEnum_number0 =
    const BookmarksFindAll200ResponseCodeEnum._('number0');
const BookmarksFindAll200ResponseCodeEnum
_$bookmarksFindAll200ResponseCodeEnum_unknownDefaultOpenApi =
    const BookmarksFindAll200ResponseCodeEnum._('unknownDefaultOpenApi');

BookmarksFindAll200ResponseCodeEnum
_$bookmarksFindAll200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$bookmarksFindAll200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$bookmarksFindAll200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$bookmarksFindAll200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<BookmarksFindAll200ResponseCodeEnum>
_$bookmarksFindAll200ResponseCodeEnumValues =
    BuiltSet<BookmarksFindAll200ResponseCodeEnum>(
      const <BookmarksFindAll200ResponseCodeEnum>[
        _$bookmarksFindAll200ResponseCodeEnum_number0,
        _$bookmarksFindAll200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<BookmarksFindAll200ResponseCodeEnum>
_$bookmarksFindAll200ResponseCodeEnumSerializer =
    _$BookmarksFindAll200ResponseCodeEnumSerializer();

class _$BookmarksFindAll200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<BookmarksFindAll200ResponseCodeEnum> {
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
    BookmarksFindAll200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'BookmarksFindAll200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    BookmarksFindAll200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  BookmarksFindAll200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => BookmarksFindAll200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$BookmarksFindAll200Response extends BookmarksFindAll200Response {
  @override
  final BuiltList<OwnBookmarkThreadResponseDto> data;
  @override
  final ApiPaginationMeta meta;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$BookmarksFindAll200Response([
    void Function(BookmarksFindAll200ResponseBuilder)? updates,
  ]) => (BookmarksFindAll200ResponseBuilder()..update(updates))._build();

  _$BookmarksFindAll200Response._({
    required this.data,
    required this.meta,
    required this.code,
    required this.message,
  }) : super._();
  @override
  BookmarksFindAll200Response rebuild(
    void Function(BookmarksFindAll200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  BookmarksFindAll200ResponseBuilder toBuilder() =>
      BookmarksFindAll200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BookmarksFindAll200Response &&
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
    return (newBuiltValueToStringHelper(r'BookmarksFindAll200Response')
          ..add('data', data)
          ..add('meta', meta)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class BookmarksFindAll200ResponseBuilder
    implements
        Builder<
          BookmarksFindAll200Response,
          BookmarksFindAll200ResponseBuilder
        >,
        ApiPaginatedSuccessEnvelopeBuilder {
  _$BookmarksFindAll200Response? _$v;

  ListBuilder<OwnBookmarkThreadResponseDto>? _data;
  ListBuilder<OwnBookmarkThreadResponseDto> get data =>
      _$this._data ??= ListBuilder<OwnBookmarkThreadResponseDto>();
  set data(covariant ListBuilder<OwnBookmarkThreadResponseDto>? data) =>
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

  BookmarksFindAll200ResponseBuilder() {
    BookmarksFindAll200Response._defaults(this);
  }

  BookmarksFindAll200ResponseBuilder get _$this {
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
  void replace(covariant BookmarksFindAll200Response other) {
    _$v = other as _$BookmarksFindAll200Response;
  }

  @override
  void update(void Function(BookmarksFindAll200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BookmarksFindAll200Response build() => _build();

  _$BookmarksFindAll200Response _build() {
    _$BookmarksFindAll200Response _$result;
    try {
      _$result =
          _$v ??
          _$BookmarksFindAll200Response._(
            data: data.build(),
            meta: meta.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'BookmarksFindAll200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'BookmarksFindAll200Response',
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
          r'BookmarksFindAll200Response',
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
