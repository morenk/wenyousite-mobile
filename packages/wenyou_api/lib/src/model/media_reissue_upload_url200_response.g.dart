// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_reissue_upload_url200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MediaReissueUploadUrl200ResponseCodeEnum
_$mediaReissueUploadUrl200ResponseCodeEnum_number0 =
    const MediaReissueUploadUrl200ResponseCodeEnum._('number0');
const MediaReissueUploadUrl200ResponseCodeEnum
_$mediaReissueUploadUrl200ResponseCodeEnum_unknownDefaultOpenApi =
    const MediaReissueUploadUrl200ResponseCodeEnum._('unknownDefaultOpenApi');

MediaReissueUploadUrl200ResponseCodeEnum
_$mediaReissueUploadUrl200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$mediaReissueUploadUrl200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$mediaReissueUploadUrl200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$mediaReissueUploadUrl200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MediaReissueUploadUrl200ResponseCodeEnum>
_$mediaReissueUploadUrl200ResponseCodeEnumValues =
    BuiltSet<MediaReissueUploadUrl200ResponseCodeEnum>(
      const <MediaReissueUploadUrl200ResponseCodeEnum>[
        _$mediaReissueUploadUrl200ResponseCodeEnum_number0,
        _$mediaReissueUploadUrl200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<MediaReissueUploadUrl200ResponseCodeEnum>
_$mediaReissueUploadUrl200ResponseCodeEnumSerializer =
    _$MediaReissueUploadUrl200ResponseCodeEnumSerializer();

class _$MediaReissueUploadUrl200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<MediaReissueUploadUrl200ResponseCodeEnum> {
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
    MediaReissueUploadUrl200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'MediaReissueUploadUrl200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MediaReissueUploadUrl200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MediaReissueUploadUrl200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MediaReissueUploadUrl200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MediaReissueUploadUrl200Response
    extends MediaReissueUploadUrl200Response {
  @override
  final UploadUrlResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$MediaReissueUploadUrl200Response([
    void Function(MediaReissueUploadUrl200ResponseBuilder)? updates,
  ]) => (MediaReissueUploadUrl200ResponseBuilder()..update(updates))._build();

  _$MediaReissueUploadUrl200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  MediaReissueUploadUrl200Response rebuild(
    void Function(MediaReissueUploadUrl200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MediaReissueUploadUrl200ResponseBuilder toBuilder() =>
      MediaReissueUploadUrl200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MediaReissueUploadUrl200Response &&
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
    return (newBuiltValueToStringHelper(r'MediaReissueUploadUrl200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class MediaReissueUploadUrl200ResponseBuilder
    implements
        Builder<
          MediaReissueUploadUrl200Response,
          MediaReissueUploadUrl200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$MediaReissueUploadUrl200Response? _$v;

  UploadUrlResponseDtoBuilder? _data;
  UploadUrlResponseDtoBuilder get data =>
      _$this._data ??= UploadUrlResponseDtoBuilder();
  set data(covariant UploadUrlResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  MediaReissueUploadUrl200ResponseBuilder() {
    MediaReissueUploadUrl200Response._defaults(this);
  }

  MediaReissueUploadUrl200ResponseBuilder get _$this {
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
  void replace(covariant MediaReissueUploadUrl200Response other) {
    _$v = other as _$MediaReissueUploadUrl200Response;
  }

  @override
  void update(void Function(MediaReissueUploadUrl200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MediaReissueUploadUrl200Response build() => _build();

  _$MediaReissueUploadUrl200Response _build() {
    _$MediaReissueUploadUrl200Response _$result;
    try {
      _$result =
          _$v ??
          _$MediaReissueUploadUrl200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'MediaReissueUploadUrl200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'MediaReissueUploadUrl200Response',
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
          r'MediaReissueUploadUrl200Response',
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
