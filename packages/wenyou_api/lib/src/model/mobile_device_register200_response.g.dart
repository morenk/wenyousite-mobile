// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mobile_device_register200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MobileDeviceRegister200ResponseCodeEnum
_$mobileDeviceRegister200ResponseCodeEnum_number0 =
    const MobileDeviceRegister200ResponseCodeEnum._('number0');
const MobileDeviceRegister200ResponseCodeEnum
_$mobileDeviceRegister200ResponseCodeEnum_unknownDefaultOpenApi =
    const MobileDeviceRegister200ResponseCodeEnum._('unknownDefaultOpenApi');

MobileDeviceRegister200ResponseCodeEnum
_$mobileDeviceRegister200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$mobileDeviceRegister200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$mobileDeviceRegister200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$mobileDeviceRegister200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MobileDeviceRegister200ResponseCodeEnum>
_$mobileDeviceRegister200ResponseCodeEnumValues =
    BuiltSet<MobileDeviceRegister200ResponseCodeEnum>(
      const <MobileDeviceRegister200ResponseCodeEnum>[
        _$mobileDeviceRegister200ResponseCodeEnum_number0,
        _$mobileDeviceRegister200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<MobileDeviceRegister200ResponseCodeEnum>
_$mobileDeviceRegister200ResponseCodeEnumSerializer =
    _$MobileDeviceRegister200ResponseCodeEnumSerializer();

class _$MobileDeviceRegister200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<MobileDeviceRegister200ResponseCodeEnum> {
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
    MobileDeviceRegister200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'MobileDeviceRegister200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MobileDeviceRegister200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MobileDeviceRegister200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MobileDeviceRegister200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MobileDeviceRegister200Response
    extends MobileDeviceRegister200Response {
  @override
  final MobileDeviceResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$MobileDeviceRegister200Response([
    void Function(MobileDeviceRegister200ResponseBuilder)? updates,
  ]) => (MobileDeviceRegister200ResponseBuilder()..update(updates))._build();

  _$MobileDeviceRegister200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  MobileDeviceRegister200Response rebuild(
    void Function(MobileDeviceRegister200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MobileDeviceRegister200ResponseBuilder toBuilder() =>
      MobileDeviceRegister200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MobileDeviceRegister200Response &&
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
    return (newBuiltValueToStringHelper(r'MobileDeviceRegister200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class MobileDeviceRegister200ResponseBuilder
    implements
        Builder<
          MobileDeviceRegister200Response,
          MobileDeviceRegister200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$MobileDeviceRegister200Response? _$v;

  MobileDeviceResponseDtoBuilder? _data;
  MobileDeviceResponseDtoBuilder get data =>
      _$this._data ??= MobileDeviceResponseDtoBuilder();
  set data(covariant MobileDeviceResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  MobileDeviceRegister200ResponseBuilder() {
    MobileDeviceRegister200Response._defaults(this);
  }

  MobileDeviceRegister200ResponseBuilder get _$this {
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
  void replace(covariant MobileDeviceRegister200Response other) {
    _$v = other as _$MobileDeviceRegister200Response;
  }

  @override
  void update(void Function(MobileDeviceRegister200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MobileDeviceRegister200Response build() => _build();

  _$MobileDeviceRegister200Response _build() {
    _$MobileDeviceRegister200Response _$result;
    try {
      _$result =
          _$v ??
          _$MobileDeviceRegister200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'MobileDeviceRegister200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'MobileDeviceRegister200Response',
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
          r'MobileDeviceRegister200Response',
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
