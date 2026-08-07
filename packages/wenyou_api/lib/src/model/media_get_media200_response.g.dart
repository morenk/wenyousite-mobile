// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_get_media200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MediaGetMedia200ResponseCodeEnum
_$mediaGetMedia200ResponseCodeEnum_number0 =
    const MediaGetMedia200ResponseCodeEnum._('number0');
const MediaGetMedia200ResponseCodeEnum
_$mediaGetMedia200ResponseCodeEnum_unknownDefaultOpenApi =
    const MediaGetMedia200ResponseCodeEnum._('unknownDefaultOpenApi');

MediaGetMedia200ResponseCodeEnum _$mediaGetMedia200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$mediaGetMedia200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$mediaGetMedia200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$mediaGetMedia200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MediaGetMedia200ResponseCodeEnum>
_$mediaGetMedia200ResponseCodeEnumValues =
    BuiltSet<MediaGetMedia200ResponseCodeEnum>(
      const <MediaGetMedia200ResponseCodeEnum>[
        _$mediaGetMedia200ResponseCodeEnum_number0,
        _$mediaGetMedia200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<MediaGetMedia200ResponseCodeEnum>
_$mediaGetMedia200ResponseCodeEnumSerializer =
    _$MediaGetMedia200ResponseCodeEnumSerializer();

class _$MediaGetMedia200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<MediaGetMedia200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[MediaGetMedia200ResponseCodeEnum];
  @override
  final String wireName = 'MediaGetMedia200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MediaGetMedia200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MediaGetMedia200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MediaGetMedia200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MediaGetMedia200Response extends MediaGetMedia200Response {
  @override
  final MediaResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$MediaGetMedia200Response([
    void Function(MediaGetMedia200ResponseBuilder)? updates,
  ]) => (MediaGetMedia200ResponseBuilder()..update(updates))._build();

  _$MediaGetMedia200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  MediaGetMedia200Response rebuild(
    void Function(MediaGetMedia200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MediaGetMedia200ResponseBuilder toBuilder() =>
      MediaGetMedia200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MediaGetMedia200Response &&
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
    return (newBuiltValueToStringHelper(r'MediaGetMedia200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class MediaGetMedia200ResponseBuilder
    implements
        Builder<MediaGetMedia200Response, MediaGetMedia200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$MediaGetMedia200Response? _$v;

  MediaResponseDtoBuilder? _data;
  MediaResponseDtoBuilder get data =>
      _$this._data ??= MediaResponseDtoBuilder();
  set data(covariant MediaResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  MediaGetMedia200ResponseBuilder() {
    MediaGetMedia200Response._defaults(this);
  }

  MediaGetMedia200ResponseBuilder get _$this {
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
  void replace(covariant MediaGetMedia200Response other) {
    _$v = other as _$MediaGetMedia200Response;
  }

  @override
  void update(void Function(MediaGetMedia200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MediaGetMedia200Response build() => _build();

  _$MediaGetMedia200Response _build() {
    _$MediaGetMedia200Response _$result;
    try {
      _$result =
          _$v ??
          _$MediaGetMedia200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'MediaGetMedia200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'MediaGetMedia200Response',
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
          r'MediaGetMedia200Response',
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
