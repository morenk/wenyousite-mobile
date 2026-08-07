// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmarks_remove200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BookmarksRemove200ResponseCodeEnum
_$bookmarksRemove200ResponseCodeEnum_number0 =
    const BookmarksRemove200ResponseCodeEnum._('number0');
const BookmarksRemove200ResponseCodeEnum
_$bookmarksRemove200ResponseCodeEnum_unknownDefaultOpenApi =
    const BookmarksRemove200ResponseCodeEnum._('unknownDefaultOpenApi');

BookmarksRemove200ResponseCodeEnum _$bookmarksRemove200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$bookmarksRemove200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$bookmarksRemove200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$bookmarksRemove200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<BookmarksRemove200ResponseCodeEnum>
_$bookmarksRemove200ResponseCodeEnumValues =
    BuiltSet<BookmarksRemove200ResponseCodeEnum>(
      const <BookmarksRemove200ResponseCodeEnum>[
        _$bookmarksRemove200ResponseCodeEnum_number0,
        _$bookmarksRemove200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<BookmarksRemove200ResponseCodeEnum>
_$bookmarksRemove200ResponseCodeEnumSerializer =
    _$BookmarksRemove200ResponseCodeEnumSerializer();

class _$BookmarksRemove200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<BookmarksRemove200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[BookmarksRemove200ResponseCodeEnum];
  @override
  final String wireName = 'BookmarksRemove200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    BookmarksRemove200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  BookmarksRemove200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => BookmarksRemove200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$BookmarksRemove200Response extends BookmarksRemove200Response {
  @override
  final MessageResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$BookmarksRemove200Response([
    void Function(BookmarksRemove200ResponseBuilder)? updates,
  ]) => (BookmarksRemove200ResponseBuilder()..update(updates))._build();

  _$BookmarksRemove200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  BookmarksRemove200Response rebuild(
    void Function(BookmarksRemove200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  BookmarksRemove200ResponseBuilder toBuilder() =>
      BookmarksRemove200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BookmarksRemove200Response &&
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
    return (newBuiltValueToStringHelper(r'BookmarksRemove200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class BookmarksRemove200ResponseBuilder
    implements
        Builder<BookmarksRemove200Response, BookmarksRemove200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$BookmarksRemove200Response? _$v;

  MessageResponseDtoBuilder? _data;
  MessageResponseDtoBuilder get data =>
      _$this._data ??= MessageResponseDtoBuilder();
  set data(covariant MessageResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  BookmarksRemove200ResponseBuilder() {
    BookmarksRemove200Response._defaults(this);
  }

  BookmarksRemove200ResponseBuilder get _$this {
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
  void replace(covariant BookmarksRemove200Response other) {
    _$v = other as _$BookmarksRemove200Response;
  }

  @override
  void update(void Function(BookmarksRemove200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BookmarksRemove200Response build() => _build();

  _$BookmarksRemove200Response _build() {
    _$BookmarksRemove200Response _$result;
    try {
      _$result =
          _$v ??
          _$BookmarksRemove200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'BookmarksRemove200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'BookmarksRemove200Response',
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
          r'BookmarksRemove200Response',
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
