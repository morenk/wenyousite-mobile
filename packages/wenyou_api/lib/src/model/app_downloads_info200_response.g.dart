// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_downloads_info200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AppDownloadsInfo200ResponseCodeEnum
_$appDownloadsInfo200ResponseCodeEnum_number0 =
    const AppDownloadsInfo200ResponseCodeEnum._('number0');
const AppDownloadsInfo200ResponseCodeEnum
_$appDownloadsInfo200ResponseCodeEnum_unknownDefaultOpenApi =
    const AppDownloadsInfo200ResponseCodeEnum._('unknownDefaultOpenApi');

AppDownloadsInfo200ResponseCodeEnum
_$appDownloadsInfo200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$appDownloadsInfo200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$appDownloadsInfo200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$appDownloadsInfo200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AppDownloadsInfo200ResponseCodeEnum>
_$appDownloadsInfo200ResponseCodeEnumValues =
    BuiltSet<AppDownloadsInfo200ResponseCodeEnum>(
      const <AppDownloadsInfo200ResponseCodeEnum>[
        _$appDownloadsInfo200ResponseCodeEnum_number0,
        _$appDownloadsInfo200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AppDownloadsInfo200ResponseCodeEnum>
_$appDownloadsInfo200ResponseCodeEnumSerializer =
    _$AppDownloadsInfo200ResponseCodeEnumSerializer();

class _$AppDownloadsInfo200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AppDownloadsInfo200ResponseCodeEnum> {
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
    AppDownloadsInfo200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'AppDownloadsInfo200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AppDownloadsInfo200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AppDownloadsInfo200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AppDownloadsInfo200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AppDownloadsInfo200Response extends AppDownloadsInfo200Response {
  @override
  final AndroidDownloadInfoDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$AppDownloadsInfo200Response([
    void Function(AppDownloadsInfo200ResponseBuilder)? updates,
  ]) => (AppDownloadsInfo200ResponseBuilder()..update(updates))._build();

  _$AppDownloadsInfo200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  AppDownloadsInfo200Response rebuild(
    void Function(AppDownloadsInfo200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AppDownloadsInfo200ResponseBuilder toBuilder() =>
      AppDownloadsInfo200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AppDownloadsInfo200Response &&
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
    return (newBuiltValueToStringHelper(r'AppDownloadsInfo200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class AppDownloadsInfo200ResponseBuilder
    implements
        Builder<
          AppDownloadsInfo200Response,
          AppDownloadsInfo200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$AppDownloadsInfo200Response? _$v;

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

  AppDownloadsInfo200ResponseBuilder() {
    AppDownloadsInfo200Response._defaults(this);
  }

  AppDownloadsInfo200ResponseBuilder get _$this {
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
  void replace(covariant AppDownloadsInfo200Response other) {
    _$v = other as _$AppDownloadsInfo200Response;
  }

  @override
  void update(void Function(AppDownloadsInfo200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AppDownloadsInfo200Response build() => _build();

  _$AppDownloadsInfo200Response _build() {
    _$AppDownloadsInfo200Response _$result;
    try {
      _$result =
          _$v ??
          _$AppDownloadsInfo200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'AppDownloadsInfo200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'AppDownloadsInfo200Response',
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
          r'AppDownloadsInfo200Response',
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
