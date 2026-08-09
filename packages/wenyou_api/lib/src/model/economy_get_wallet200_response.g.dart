// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'economy_get_wallet200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const EconomyGetWallet200ResponseCodeEnum
_$economyGetWallet200ResponseCodeEnum_number0 =
    const EconomyGetWallet200ResponseCodeEnum._('number0');
const EconomyGetWallet200ResponseCodeEnum
_$economyGetWallet200ResponseCodeEnum_unknownDefaultOpenApi =
    const EconomyGetWallet200ResponseCodeEnum._('unknownDefaultOpenApi');

EconomyGetWallet200ResponseCodeEnum
_$economyGetWallet200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$economyGetWallet200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$economyGetWallet200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$economyGetWallet200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<EconomyGetWallet200ResponseCodeEnum>
_$economyGetWallet200ResponseCodeEnumValues =
    BuiltSet<EconomyGetWallet200ResponseCodeEnum>(
      const <EconomyGetWallet200ResponseCodeEnum>[
        _$economyGetWallet200ResponseCodeEnum_number0,
        _$economyGetWallet200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<EconomyGetWallet200ResponseCodeEnum>
_$economyGetWallet200ResponseCodeEnumSerializer =
    _$EconomyGetWallet200ResponseCodeEnumSerializer();

class _$EconomyGetWallet200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<EconomyGetWallet200ResponseCodeEnum> {
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
    EconomyGetWallet200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'EconomyGetWallet200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    EconomyGetWallet200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  EconomyGetWallet200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => EconomyGetWallet200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$EconomyGetWallet200Response extends EconomyGetWallet200Response {
  @override
  final WalletResponseDto data;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$EconomyGetWallet200Response([
    void Function(EconomyGetWallet200ResponseBuilder)? updates,
  ]) => (EconomyGetWallet200ResponseBuilder()..update(updates))._build();

  _$EconomyGetWallet200Response._({
    required this.data,
    required this.code,
    required this.message,
  }) : super._();
  @override
  EconomyGetWallet200Response rebuild(
    void Function(EconomyGetWallet200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  EconomyGetWallet200ResponseBuilder toBuilder() =>
      EconomyGetWallet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EconomyGetWallet200Response &&
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
    return (newBuiltValueToStringHelper(r'EconomyGetWallet200Response')
          ..add('data', data)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class EconomyGetWallet200ResponseBuilder
    implements
        Builder<
          EconomyGetWallet200Response,
          EconomyGetWallet200ResponseBuilder
        >,
        ApiSuccessEnvelopeBuilder {
  _$EconomyGetWallet200Response? _$v;

  WalletResponseDtoBuilder? _data;
  WalletResponseDtoBuilder get data =>
      _$this._data ??= WalletResponseDtoBuilder();
  set data(covariant WalletResponseDtoBuilder? data) => _$this._data = data;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  EconomyGetWallet200ResponseBuilder() {
    EconomyGetWallet200Response._defaults(this);
  }

  EconomyGetWallet200ResponseBuilder get _$this {
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
  void replace(covariant EconomyGetWallet200Response other) {
    _$v = other as _$EconomyGetWallet200Response;
  }

  @override
  void update(void Function(EconomyGetWallet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EconomyGetWallet200Response build() => _build();

  _$EconomyGetWallet200Response _build() {
    _$EconomyGetWallet200Response _$result;
    try {
      _$result =
          _$v ??
          _$EconomyGetWallet200Response._(
            data: data.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'EconomyGetWallet200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'EconomyGetWallet200Response',
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
          r'EconomyGetWallet200Response',
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
