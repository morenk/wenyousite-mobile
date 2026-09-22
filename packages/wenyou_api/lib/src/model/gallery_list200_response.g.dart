// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_list200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GalleryList200ResponseCodeEnum _$galleryList200ResponseCodeEnum_number0 =
    const GalleryList200ResponseCodeEnum._('number0');
const GalleryList200ResponseCodeEnum
_$galleryList200ResponseCodeEnum_unknownDefaultOpenApi =
    const GalleryList200ResponseCodeEnum._('unknownDefaultOpenApi');

GalleryList200ResponseCodeEnum _$galleryList200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$galleryList200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$galleryList200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$galleryList200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<GalleryList200ResponseCodeEnum>
_$galleryList200ResponseCodeEnumValues =
    BuiltSet<GalleryList200ResponseCodeEnum>(
      const <GalleryList200ResponseCodeEnum>[
        _$galleryList200ResponseCodeEnum_number0,
        _$galleryList200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<GalleryList200ResponseCodeEnum>
_$galleryList200ResponseCodeEnumSerializer =
    _$GalleryList200ResponseCodeEnumSerializer();

class _$GalleryList200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<GalleryList200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[GalleryList200ResponseCodeEnum];
  @override
  final String wireName = 'GalleryList200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    GalleryList200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  GalleryList200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => GalleryList200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$GalleryList200Response extends GalleryList200Response {
  @override
  final GalleryPageDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$GalleryList200Response([
    void Function(GalleryList200ResponseBuilder)? updates,
  ]) => (GalleryList200ResponseBuilder()..update(updates))._build();

  _$GalleryList200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  GalleryList200Response rebuild(
    void Function(GalleryList200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GalleryList200ResponseBuilder toBuilder() =>
      GalleryList200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GalleryList200Response &&
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
    return (newBuiltValueToStringHelper(r'GalleryList200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class GalleryList200ResponseBuilder
    implements
        Builder<GalleryList200Response, GalleryList200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$GalleryList200Response? _$v;

  GalleryPageDtoBuilder? _data;
  GalleryPageDtoBuilder get data => _$this._data ??= GalleryPageDtoBuilder();
  set data(covariant GalleryPageDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  GalleryList200ResponseBuilder() {
    GalleryList200Response._defaults(this);
  }

  GalleryList200ResponseBuilder get _$this {
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
  void replace(covariant GalleryList200Response other) {
    _$v = other as _$GalleryList200Response;
  }

  @override
  void update(void Function(GalleryList200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GalleryList200Response build() => _build();

  _$GalleryList200Response _build() {
    _$GalleryList200Response _$result;
    try {
      _$result =
          _$v ??
          _$GalleryList200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'GalleryList200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'GalleryList200Response',
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
          r'GalleryList200Response',
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
