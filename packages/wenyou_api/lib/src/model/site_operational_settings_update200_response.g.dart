// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_operational_settings_update200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SiteOperationalSettingsUpdate200ResponseCodeEnum
_$siteOperationalSettingsUpdate200ResponseCodeEnum_number0 =
    const SiteOperationalSettingsUpdate200ResponseCodeEnum._('number0');
const SiteOperationalSettingsUpdate200ResponseCodeEnum
_$siteOperationalSettingsUpdate200ResponseCodeEnum_unknownDefaultOpenApi =
    const SiteOperationalSettingsUpdate200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

SiteOperationalSettingsUpdate200ResponseCodeEnum
_$siteOperationalSettingsUpdate200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$siteOperationalSettingsUpdate200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$siteOperationalSettingsUpdate200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$siteOperationalSettingsUpdate200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<SiteOperationalSettingsUpdate200ResponseCodeEnum>
_$siteOperationalSettingsUpdate200ResponseCodeEnumValues =
    BuiltSet<SiteOperationalSettingsUpdate200ResponseCodeEnum>(const <
      SiteOperationalSettingsUpdate200ResponseCodeEnum
    >[
      _$siteOperationalSettingsUpdate200ResponseCodeEnum_number0,
      _$siteOperationalSettingsUpdate200ResponseCodeEnum_unknownDefaultOpenApi,
    ]);

Serializer<SiteOperationalSettingsUpdate200ResponseCodeEnum>
_$siteOperationalSettingsUpdate200ResponseCodeEnumSerializer =
    _$SiteOperationalSettingsUpdate200ResponseCodeEnumSerializer();

class _$SiteOperationalSettingsUpdate200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<SiteOperationalSettingsUpdate200ResponseCodeEnum> {
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
    SiteOperationalSettingsUpdate200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'SiteOperationalSettingsUpdate200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    SiteOperationalSettingsUpdate200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SiteOperationalSettingsUpdate200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SiteOperationalSettingsUpdate200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$SiteOperationalSettingsUpdate200Response
    extends SiteOperationalSettingsUpdate200Response {
  @override
  final SiteOperationalSettingsResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$SiteOperationalSettingsUpdate200Response([
    void Function(SiteOperationalSettingsUpdate200ResponseBuilder)? updates,
  ]) => (SiteOperationalSettingsUpdate200ResponseBuilder()..update(updates))
      ._build();

  _$SiteOperationalSettingsUpdate200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  SiteOperationalSettingsUpdate200Response rebuild(
    void Function(SiteOperationalSettingsUpdate200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SiteOperationalSettingsUpdate200ResponseBuilder toBuilder() =>
      SiteOperationalSettingsUpdate200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SiteOperationalSettingsUpdate200Response &&
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
            r'SiteOperationalSettingsUpdate200Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class SiteOperationalSettingsUpdate200ResponseBuilder
    implements
        Builder<
          SiteOperationalSettingsUpdate200Response,
          SiteOperationalSettingsUpdate200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$SiteOperationalSettingsUpdate200Response? _$v;

  SiteOperationalSettingsResponseDtoBuilder? _data;
  SiteOperationalSettingsResponseDtoBuilder get data =>
      _$this._data ??= SiteOperationalSettingsResponseDtoBuilder();
  set data(covariant SiteOperationalSettingsResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  SiteOperationalSettingsUpdate200ResponseBuilder() {
    SiteOperationalSettingsUpdate200Response._defaults(this);
  }

  SiteOperationalSettingsUpdate200ResponseBuilder get _$this {
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
  void replace(covariant SiteOperationalSettingsUpdate200Response other) {
    _$v = other as _$SiteOperationalSettingsUpdate200Response;
  }

  @override
  void update(
    void Function(SiteOperationalSettingsUpdate200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  SiteOperationalSettingsUpdate200Response build() => _build();

  _$SiteOperationalSettingsUpdate200Response _build() {
    _$SiteOperationalSettingsUpdate200Response _$result;
    try {
      _$result =
          _$v ??
          _$SiteOperationalSettingsUpdate200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'SiteOperationalSettingsUpdate200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'SiteOperationalSettingsUpdate200Response',
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
          r'SiteOperationalSettingsUpdate200Response',
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
