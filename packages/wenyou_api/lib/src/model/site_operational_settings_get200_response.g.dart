// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_operational_settings_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SiteOperationalSettingsGet200ResponseCodeEnum
_$siteOperationalSettingsGet200ResponseCodeEnum_number0 =
    const SiteOperationalSettingsGet200ResponseCodeEnum._('number0');
const SiteOperationalSettingsGet200ResponseCodeEnum
_$siteOperationalSettingsGet200ResponseCodeEnum_unknownDefaultOpenApi =
    const SiteOperationalSettingsGet200ResponseCodeEnum._(
      'unknownDefaultOpenApi',
    );

SiteOperationalSettingsGet200ResponseCodeEnum
_$siteOperationalSettingsGet200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$siteOperationalSettingsGet200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$siteOperationalSettingsGet200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$siteOperationalSettingsGet200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<SiteOperationalSettingsGet200ResponseCodeEnum>
_$siteOperationalSettingsGet200ResponseCodeEnumValues =
    BuiltSet<SiteOperationalSettingsGet200ResponseCodeEnum>(
      const <SiteOperationalSettingsGet200ResponseCodeEnum>[
        _$siteOperationalSettingsGet200ResponseCodeEnum_number0,
        _$siteOperationalSettingsGet200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<SiteOperationalSettingsGet200ResponseCodeEnum>
_$siteOperationalSettingsGet200ResponseCodeEnumSerializer =
    _$SiteOperationalSettingsGet200ResponseCodeEnumSerializer();

class _$SiteOperationalSettingsGet200ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<SiteOperationalSettingsGet200ResponseCodeEnum> {
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
    SiteOperationalSettingsGet200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'SiteOperationalSettingsGet200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    SiteOperationalSettingsGet200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SiteOperationalSettingsGet200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SiteOperationalSettingsGet200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$SiteOperationalSettingsGet200Response
    extends SiteOperationalSettingsGet200Response {
  @override
  final SiteOperationalSettingsResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$SiteOperationalSettingsGet200Response([
    void Function(SiteOperationalSettingsGet200ResponseBuilder)? updates,
  ]) => (SiteOperationalSettingsGet200ResponseBuilder()..update(updates))
      ._build();

  _$SiteOperationalSettingsGet200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  SiteOperationalSettingsGet200Response rebuild(
    void Function(SiteOperationalSettingsGet200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SiteOperationalSettingsGet200ResponseBuilder toBuilder() =>
      SiteOperationalSettingsGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SiteOperationalSettingsGet200Response &&
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
            r'SiteOperationalSettingsGet200Response',
          )
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class SiteOperationalSettingsGet200ResponseBuilder
    implements
        Builder<
          SiteOperationalSettingsGet200Response,
          SiteOperationalSettingsGet200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$SiteOperationalSettingsGet200Response? _$v;

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

  SiteOperationalSettingsGet200ResponseBuilder() {
    SiteOperationalSettingsGet200Response._defaults(this);
  }

  SiteOperationalSettingsGet200ResponseBuilder get _$this {
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
  void replace(covariant SiteOperationalSettingsGet200Response other) {
    _$v = other as _$SiteOperationalSettingsGet200Response;
  }

  @override
  void update(
    void Function(SiteOperationalSettingsGet200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  SiteOperationalSettingsGet200Response build() => _build();

  _$SiteOperationalSettingsGet200Response _build() {
    _$SiteOperationalSettingsGet200Response _$result;
    try {
      _$result =
          _$v ??
          _$SiteOperationalSettingsGet200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'SiteOperationalSettingsGet200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'SiteOperationalSettingsGet200Response',
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
          r'SiteOperationalSettingsGet200Response',
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
