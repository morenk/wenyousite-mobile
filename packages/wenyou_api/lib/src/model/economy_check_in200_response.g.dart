// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'economy_check_in200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const EconomyCheckIn200ResponseCodeEnum
_$economyCheckIn200ResponseCodeEnum_number0 =
    const EconomyCheckIn200ResponseCodeEnum._('number0');
const EconomyCheckIn200ResponseCodeEnum
_$economyCheckIn200ResponseCodeEnum_unknownDefaultOpenApi =
    const EconomyCheckIn200ResponseCodeEnum._('unknownDefaultOpenApi');

EconomyCheckIn200ResponseCodeEnum _$economyCheckIn200ResponseCodeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'number0':
      return _$economyCheckIn200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$economyCheckIn200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$economyCheckIn200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<EconomyCheckIn200ResponseCodeEnum>
_$economyCheckIn200ResponseCodeEnumValues =
    BuiltSet<EconomyCheckIn200ResponseCodeEnum>(
      const <EconomyCheckIn200ResponseCodeEnum>[
        _$economyCheckIn200ResponseCodeEnum_number0,
        _$economyCheckIn200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<EconomyCheckIn200ResponseCodeEnum>
_$economyCheckIn200ResponseCodeEnumSerializer =
    _$EconomyCheckIn200ResponseCodeEnumSerializer();

class _$EconomyCheckIn200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<EconomyCheckIn200ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number0': 0,
    'unknownDefaultOpenApi': 11184809,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'number0',
    11184809: 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[EconomyCheckIn200ResponseCodeEnum];
  @override
  final String wireName = 'EconomyCheckIn200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    EconomyCheckIn200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  EconomyCheckIn200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => EconomyCheckIn200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$EconomyCheckIn200Response extends EconomyCheckIn200Response {
  @override
  final DailyCheckInResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$EconomyCheckIn200Response([
    void Function(EconomyCheckIn200ResponseBuilder)? updates,
  ]) => (EconomyCheckIn200ResponseBuilder()..update(updates))._build();

  _$EconomyCheckIn200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  EconomyCheckIn200Response rebuild(
    void Function(EconomyCheckIn200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  EconomyCheckIn200ResponseBuilder toBuilder() =>
      EconomyCheckIn200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EconomyCheckIn200Response &&
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
    return (newBuiltValueToStringHelper(r'EconomyCheckIn200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class EconomyCheckIn200ResponseBuilder
    implements
        Builder<EconomyCheckIn200Response, EconomyCheckIn200ResponseBuilder>,
        ApiSuccessEnvelopeBuilder {
  _$EconomyCheckIn200Response? _$v;

  DailyCheckInResponseDtoBuilder? _data;
  DailyCheckInResponseDtoBuilder get data =>
      _$this._data ??= DailyCheckInResponseDtoBuilder();
  set data(covariant DailyCheckInResponseDtoBuilder? data) =>
      _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  EconomyCheckIn200ResponseBuilder() {
    EconomyCheckIn200Response._defaults(this);
  }

  EconomyCheckIn200ResponseBuilder get _$this {
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
  void replace(covariant EconomyCheckIn200Response other) {
    _$v = other as _$EconomyCheckIn200Response;
  }

  @override
  void update(void Function(EconomyCheckIn200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EconomyCheckIn200Response build() => _build();

  _$EconomyCheckIn200Response _build() {
    _$EconomyCheckIn200Response _$result;
    try {
      _$result =
          _$v ??
          _$EconomyCheckIn200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'EconomyCheckIn200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'EconomyCheckIn200Response',
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
          r'EconomyCheckIn200Response',
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
