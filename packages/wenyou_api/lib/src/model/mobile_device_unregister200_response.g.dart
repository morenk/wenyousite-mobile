// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mobile_device_unregister200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MobileDeviceUnregister200ResponseCodeEnum
_$mobileDeviceUnregister200ResponseCodeEnum_number0 =
    const MobileDeviceUnregister200ResponseCodeEnum._('number0');
const MobileDeviceUnregister200ResponseCodeEnum
_$mobileDeviceUnregister200ResponseCodeEnum_unknownDefaultOpenApi =
    const MobileDeviceUnregister200ResponseCodeEnum._('unknownDefaultOpenApi');

MobileDeviceUnregister200ResponseCodeEnum
_$mobileDeviceUnregister200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$mobileDeviceUnregister200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$mobileDeviceUnregister200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$mobileDeviceUnregister200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MobileDeviceUnregister200ResponseCodeEnum>
_$mobileDeviceUnregister200ResponseCodeEnumValues =
    BuiltSet<MobileDeviceUnregister200ResponseCodeEnum>(
      const <MobileDeviceUnregister200ResponseCodeEnum>[
        _$mobileDeviceUnregister200ResponseCodeEnum_number0,
        _$mobileDeviceUnregister200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<MobileDeviceUnregister200ResponseCodeEnum>
_$mobileDeviceUnregister200ResponseCodeEnumSerializer =
    _$MobileDeviceUnregister200ResponseCodeEnumSerializer();

class _$MobileDeviceUnregister200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<MobileDeviceUnregister200ResponseCodeEnum> {
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
    MobileDeviceUnregister200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'MobileDeviceUnregister200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MobileDeviceUnregister200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MobileDeviceUnregister200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MobileDeviceUnregister200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MobileDeviceUnregister200Response
    extends MobileDeviceUnregister200Response {
  @override
  final MessageResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$MobileDeviceUnregister200Response([
    void Function(MobileDeviceUnregister200ResponseBuilder)? updates,
  ]) => (MobileDeviceUnregister200ResponseBuilder()..update(updates))._build();

  _$MobileDeviceUnregister200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  MobileDeviceUnregister200Response rebuild(
    void Function(MobileDeviceUnregister200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MobileDeviceUnregister200ResponseBuilder toBuilder() =>
      MobileDeviceUnregister200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MobileDeviceUnregister200Response &&
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
    return (newBuiltValueToStringHelper(r'MobileDeviceUnregister200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class MobileDeviceUnregister200ResponseBuilder
    implements
        Builder<
          MobileDeviceUnregister200Response,
          MobileDeviceUnregister200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$MobileDeviceUnregister200Response? _$v;

  MessageResponseDtoBuilder? _data;
  MessageResponseDtoBuilder get data =>
      _$this._data ??= MessageResponseDtoBuilder();
  set data(covariant MessageResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  MobileDeviceUnregister200ResponseBuilder() {
    MobileDeviceUnregister200Response._defaults(this);
  }

  MobileDeviceUnregister200ResponseBuilder get _$this {
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
  void replace(covariant MobileDeviceUnregister200Response other) {
    _$v = other as _$MobileDeviceUnregister200Response;
  }

  @override
  void update(
    void Function(MobileDeviceUnregister200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  MobileDeviceUnregister200Response build() => _build();

  _$MobileDeviceUnregister200Response _build() {
    _$MobileDeviceUnregister200Response _$result;
    try {
      _$result =
          _$v ??
          _$MobileDeviceUnregister200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'MobileDeviceUnregister200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'MobileDeviceUnregister200Response',
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
          r'MobileDeviceUnregister200Response',
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
