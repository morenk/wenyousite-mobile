// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_confirm_upload200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MediaConfirmUpload200ResponseCodeEnum
_$mediaConfirmUpload200ResponseCodeEnum_number0 =
    const MediaConfirmUpload200ResponseCodeEnum._('number0');
const MediaConfirmUpload200ResponseCodeEnum
_$mediaConfirmUpload200ResponseCodeEnum_unknownDefaultOpenApi =
    const MediaConfirmUpload200ResponseCodeEnum._('unknownDefaultOpenApi');

MediaConfirmUpload200ResponseCodeEnum
_$mediaConfirmUpload200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$mediaConfirmUpload200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$mediaConfirmUpload200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$mediaConfirmUpload200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MediaConfirmUpload200ResponseCodeEnum>
_$mediaConfirmUpload200ResponseCodeEnumValues =
    BuiltSet<MediaConfirmUpload200ResponseCodeEnum>(
      const <MediaConfirmUpload200ResponseCodeEnum>[
        _$mediaConfirmUpload200ResponseCodeEnum_number0,
        _$mediaConfirmUpload200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<MediaConfirmUpload200ResponseCodeEnum>
_$mediaConfirmUpload200ResponseCodeEnumSerializer =
    _$MediaConfirmUpload200ResponseCodeEnumSerializer();

class _$MediaConfirmUpload200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<MediaConfirmUpload200ResponseCodeEnum> {
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
    MediaConfirmUpload200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'MediaConfirmUpload200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MediaConfirmUpload200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MediaConfirmUpload200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MediaConfirmUpload200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MediaConfirmUpload200Response extends MediaConfirmUpload200Response {
  @override
  final ConfirmUploadResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$MediaConfirmUpload200Response([
    void Function(MediaConfirmUpload200ResponseBuilder)? updates,
  ]) => (MediaConfirmUpload200ResponseBuilder()..update(updates))._build();

  _$MediaConfirmUpload200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  MediaConfirmUpload200Response rebuild(
    void Function(MediaConfirmUpload200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MediaConfirmUpload200ResponseBuilder toBuilder() =>
      MediaConfirmUpload200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MediaConfirmUpload200Response &&
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
    return (newBuiltValueToStringHelper(r'MediaConfirmUpload200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class MediaConfirmUpload200ResponseBuilder
    implements
        Builder<
          MediaConfirmUpload200Response,
          MediaConfirmUpload200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$MediaConfirmUpload200Response? _$v;

  ConfirmUploadResponseDtoBuilder? _data;
  ConfirmUploadResponseDtoBuilder get data =>
      _$this._data ??= ConfirmUploadResponseDtoBuilder();
  set data(covariant ConfirmUploadResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  MediaConfirmUpload200ResponseBuilder() {
    MediaConfirmUpload200Response._defaults(this);
  }

  MediaConfirmUpload200ResponseBuilder get _$this {
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
  void replace(covariant MediaConfirmUpload200Response other) {
    _$v = other as _$MediaConfirmUpload200Response;
  }

  @override
  void update(void Function(MediaConfirmUpload200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MediaConfirmUpload200Response build() => _build();

  _$MediaConfirmUpload200Response _build() {
    _$MediaConfirmUpload200Response _$result;
    try {
      _$result =
          _$v ??
          _$MediaConfirmUpload200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'MediaConfirmUpload200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'MediaConfirmUpload200Response',
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
          r'MediaConfirmUpload200Response',
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
