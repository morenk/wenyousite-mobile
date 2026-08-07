// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_get_upload_url201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MediaGetUploadUrl201ResponseCodeEnum
_$mediaGetUploadUrl201ResponseCodeEnum_number0 =
    const MediaGetUploadUrl201ResponseCodeEnum._('number0');
const MediaGetUploadUrl201ResponseCodeEnum
_$mediaGetUploadUrl201ResponseCodeEnum_unknownDefaultOpenApi =
    const MediaGetUploadUrl201ResponseCodeEnum._('unknownDefaultOpenApi');

MediaGetUploadUrl201ResponseCodeEnum
_$mediaGetUploadUrl201ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$mediaGetUploadUrl201ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$mediaGetUploadUrl201ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$mediaGetUploadUrl201ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MediaGetUploadUrl201ResponseCodeEnum>
_$mediaGetUploadUrl201ResponseCodeEnumValues =
    BuiltSet<MediaGetUploadUrl201ResponseCodeEnum>(
      const <MediaGetUploadUrl201ResponseCodeEnum>[
        _$mediaGetUploadUrl201ResponseCodeEnum_number0,
        _$mediaGetUploadUrl201ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<MediaGetUploadUrl201ResponseCodeEnum>
_$mediaGetUploadUrl201ResponseCodeEnumSerializer =
    _$MediaGetUploadUrl201ResponseCodeEnumSerializer();

class _$MediaGetUploadUrl201ResponseCodeEnumSerializer
    implements PrimitiveSerializer<MediaGetUploadUrl201ResponseCodeEnum> {
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
    MediaGetUploadUrl201ResponseCodeEnum,
  ];
  @override
  final String wireName = 'MediaGetUploadUrl201ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MediaGetUploadUrl201ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MediaGetUploadUrl201ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MediaGetUploadUrl201ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MediaGetUploadUrl201Response extends MediaGetUploadUrl201Response {
  @override
  final UploadUrlResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$MediaGetUploadUrl201Response([
    void Function(MediaGetUploadUrl201ResponseBuilder)? updates,
  ]) => (MediaGetUploadUrl201ResponseBuilder()..update(updates))._build();

  _$MediaGetUploadUrl201Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  MediaGetUploadUrl201Response rebuild(
    void Function(MediaGetUploadUrl201ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MediaGetUploadUrl201ResponseBuilder toBuilder() =>
      MediaGetUploadUrl201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MediaGetUploadUrl201Response &&
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
    return (newBuiltValueToStringHelper(r'MediaGetUploadUrl201Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class MediaGetUploadUrl201ResponseBuilder
    implements
        Builder<
          MediaGetUploadUrl201Response,
          MediaGetUploadUrl201ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$MediaGetUploadUrl201Response? _$v;

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

  MediaGetUploadUrl201ResponseBuilder() {
    MediaGetUploadUrl201Response._defaults(this);
  }

  MediaGetUploadUrl201ResponseBuilder get _$this {
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
  void replace(covariant MediaGetUploadUrl201Response other) {
    _$v = other as _$MediaGetUploadUrl201Response;
  }

  @override
  void update(void Function(MediaGetUploadUrl201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MediaGetUploadUrl201Response build() => _build();

  _$MediaGetUploadUrl201Response _build() {
    _$MediaGetUploadUrl201Response _$result;
    try {
      _$result =
          _$v ??
          _$MediaGetUploadUrl201Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'MediaGetUploadUrl201Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'MediaGetUploadUrl201Response',
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
          r'MediaGetUploadUrl201Response',
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
