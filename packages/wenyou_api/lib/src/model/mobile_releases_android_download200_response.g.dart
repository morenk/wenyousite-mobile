// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mobile_releases_android_download200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MobileReleasesAndroidDownload200ResponseCodeEnum
_$mobileReleasesAndroidDownload200ResponseCodeEnum_number0 =
    const MobileReleasesAndroidDownload200ResponseCodeEnum._('number0');
const MobileReleasesAndroidDownload200ResponseCodeEnum
_$mobileReleasesAndroidDownload200ResponseCodeEnum_unknownDefaultOpenApi =
    const MobileReleasesAndroidDownload200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

MobileReleasesAndroidDownload200ResponseCodeEnum
_$mobileReleasesAndroidDownload200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$mobileReleasesAndroidDownload200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$mobileReleasesAndroidDownload200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$mobileReleasesAndroidDownload200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MobileReleasesAndroidDownload200ResponseCodeEnum>
_$mobileReleasesAndroidDownload200ResponseCodeEnumValues =
    BuiltSet<MobileReleasesAndroidDownload200ResponseCodeEnum>(const <
      MobileReleasesAndroidDownload200ResponseCodeEnum
    >[
      _$mobileReleasesAndroidDownload200ResponseCodeEnum_number0,
      _$mobileReleasesAndroidDownload200ResponseCodeEnum_unknownDefaultOpenApi,
    ]);

Serializer<MobileReleasesAndroidDownload200ResponseCodeEnum>
_$mobileReleasesAndroidDownload200ResponseCodeEnumSerializer =
    _$MobileReleasesAndroidDownload200ResponseCodeEnumSerializer();

class _$MobileReleasesAndroidDownload200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<MobileReleasesAndroidDownload200ResponseCodeEnum> {
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
    MobileReleasesAndroidDownload200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'MobileReleasesAndroidDownload200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MobileReleasesAndroidDownload200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MobileReleasesAndroidDownload200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MobileReleasesAndroidDownload200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MobileReleasesAndroidDownload200Response
    extends MobileReleasesAndroidDownload200Response {
  @override
  final AndroidDownloadInfoDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$MobileReleasesAndroidDownload200Response([
    void Function(MobileReleasesAndroidDownload200ResponseBuilder)? updates,
  ]) => (MobileReleasesAndroidDownload200ResponseBuilder()..update(updates))
      ._build();

  _$MobileReleasesAndroidDownload200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  MobileReleasesAndroidDownload200Response rebuild(
    void Function(MobileReleasesAndroidDownload200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MobileReleasesAndroidDownload200ResponseBuilder toBuilder() =>
      MobileReleasesAndroidDownload200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MobileReleasesAndroidDownload200Response &&
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
    return (newBuiltValueToStringHelper(
            r'MobileReleasesAndroidDownload200Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class MobileReleasesAndroidDownload200ResponseBuilder
    implements
        Builder<
          MobileReleasesAndroidDownload200Response,
          MobileReleasesAndroidDownload200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$MobileReleasesAndroidDownload200Response? _$v;

  AndroidDownloadInfoDtoBuilder? _data;
  AndroidDownloadInfoDtoBuilder get data =>
      _$this._data ??= AndroidDownloadInfoDtoBuilder();
  set data(covariant AndroidDownloadInfoDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  MobileReleasesAndroidDownload200ResponseBuilder() {
    MobileReleasesAndroidDownload200Response._defaults(this);
  }

  MobileReleasesAndroidDownload200ResponseBuilder get _$this {
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
  void replace(covariant MobileReleasesAndroidDownload200Response other) {
    _$v = other as _$MobileReleasesAndroidDownload200Response;
  }

  @override
  void update(
    void Function(MobileReleasesAndroidDownload200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  MobileReleasesAndroidDownload200Response build() => _build();

  _$MobileReleasesAndroidDownload200Response _build() {
    _$MobileReleasesAndroidDownload200Response _$result;
    try {
      _$result =
          _$v ??
          _$MobileReleasesAndroidDownload200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'MobileReleasesAndroidDownload200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'MobileReleasesAndroidDownload200Response',
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
          r'MobileReleasesAndroidDownload200Response',
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
