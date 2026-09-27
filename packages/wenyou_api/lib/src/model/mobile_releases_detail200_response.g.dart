// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mobile_releases_detail200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MobileReleasesDetail200ResponseCodeEnum
_$mobileReleasesDetail200ResponseCodeEnum_number0 =
    const MobileReleasesDetail200ResponseCodeEnum._('number0');
const MobileReleasesDetail200ResponseCodeEnum
_$mobileReleasesDetail200ResponseCodeEnum_unknownDefaultOpenApi =
    const MobileReleasesDetail200ResponseCodeEnum._('unknownDefaultOpenApi');

MobileReleasesDetail200ResponseCodeEnum
_$mobileReleasesDetail200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$mobileReleasesDetail200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$mobileReleasesDetail200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$mobileReleasesDetail200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MobileReleasesDetail200ResponseCodeEnum>
_$mobileReleasesDetail200ResponseCodeEnumValues =
    BuiltSet<MobileReleasesDetail200ResponseCodeEnum>(
      const <MobileReleasesDetail200ResponseCodeEnum>[
        _$mobileReleasesDetail200ResponseCodeEnum_number0,
        _$mobileReleasesDetail200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<MobileReleasesDetail200ResponseCodeEnum>
_$mobileReleasesDetail200ResponseCodeEnumSerializer =
    _$MobileReleasesDetail200ResponseCodeEnumSerializer();

class _$MobileReleasesDetail200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<MobileReleasesDetail200ResponseCodeEnum> {
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
    MobileReleasesDetail200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'MobileReleasesDetail200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MobileReleasesDetail200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MobileReleasesDetail200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MobileReleasesDetail200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MobileReleasesDetail200Response
    extends MobileReleasesDetail200Response {
  @override
  final PublicMobileReleaseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$MobileReleasesDetail200Response([
    void Function(MobileReleasesDetail200ResponseBuilder)? updates,
  ]) => (MobileReleasesDetail200ResponseBuilder()..update(updates))._build();

  _$MobileReleasesDetail200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  MobileReleasesDetail200Response rebuild(
    void Function(MobileReleasesDetail200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MobileReleasesDetail200ResponseBuilder toBuilder() =>
      MobileReleasesDetail200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MobileReleasesDetail200Response &&
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
    return (newBuiltValueToStringHelper(r'MobileReleasesDetail200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class MobileReleasesDetail200ResponseBuilder
    implements
        Builder<
          MobileReleasesDetail200Response,
          MobileReleasesDetail200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$MobileReleasesDetail200Response? _$v;

  PublicMobileReleaseDtoBuilder? _data;
  PublicMobileReleaseDtoBuilder get data =>
      _$this._data ??= PublicMobileReleaseDtoBuilder();
  set data(covariant PublicMobileReleaseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  MobileReleasesDetail200ResponseBuilder() {
    MobileReleasesDetail200Response._defaults(this);
  }

  MobileReleasesDetail200ResponseBuilder get _$this {
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
  void replace(covariant MobileReleasesDetail200Response other) {
    _$v = other as _$MobileReleasesDetail200Response;
  }

  @override
  void update(void Function(MobileReleasesDetail200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MobileReleasesDetail200Response build() => _build();

  _$MobileReleasesDetail200Response _build() {
    _$MobileReleasesDetail200Response _$result;
    try {
      _$result =
          _$v ??
          _$MobileReleasesDetail200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'MobileReleasesDetail200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'MobileReleasesDetail200Response',
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
          r'MobileReleasesDetail200Response',
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
