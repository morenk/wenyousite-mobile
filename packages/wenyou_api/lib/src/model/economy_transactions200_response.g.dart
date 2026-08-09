// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'economy_transactions200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const EconomyTransactions200ResponseCodeEnum
_$economyTransactions200ResponseCodeEnum_number0 =
    const EconomyTransactions200ResponseCodeEnum._('number0');
const EconomyTransactions200ResponseCodeEnum
_$economyTransactions200ResponseCodeEnum_unknownDefaultOpenApi =
    const EconomyTransactions200ResponseCodeEnum._('unknownDefaultOpenApi');

EconomyTransactions200ResponseCodeEnum
_$economyTransactions200ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'number0':
      return _$economyTransactions200ResponseCodeEnum_number0;
    case 'unknownDefaultOpenApi':
      return _$economyTransactions200ResponseCodeEnum_unknownDefaultOpenApi;
    default:
      return _$economyTransactions200ResponseCodeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<EconomyTransactions200ResponseCodeEnum>
_$economyTransactions200ResponseCodeEnumValues =
    BuiltSet<EconomyTransactions200ResponseCodeEnum>(
      const <EconomyTransactions200ResponseCodeEnum>[
        _$economyTransactions200ResponseCodeEnum_number0,
        _$economyTransactions200ResponseCodeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<EconomyTransactions200ResponseCodeEnum>
_$economyTransactions200ResponseCodeEnumSerializer =
    _$EconomyTransactions200ResponseCodeEnumSerializer();

class _$EconomyTransactions200ResponseCodeEnumSerializer
    implements PrimitiveSerializer<EconomyTransactions200ResponseCodeEnum> {
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
    EconomyTransactions200ResponseCodeEnum,
  ];
  @override
  final String wireName = 'EconomyTransactions200ResponseCodeEnum';

  @override
  Object serialize(
    Serializers serializers,
    EconomyTransactions200ResponseCodeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  EconomyTransactions200ResponseCodeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => EconomyTransactions200ResponseCodeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$EconomyTransactions200Response extends EconomyTransactions200Response {
  @override
  final BuiltList<WalletTransactionResponseDto> data;
  @override
  final ApiPaginationMeta meta;
  @override
  final ApiSuccessEnvelopeCodeEnum code;
  @override
  final String message;

  factory _$EconomyTransactions200Response([
    void Function(EconomyTransactions200ResponseBuilder)? updates,
  ]) => (EconomyTransactions200ResponseBuilder()..update(updates))._build();

  _$EconomyTransactions200Response._({
    required this.data,
    required this.meta,
    required this.code,
    required this.message,
  }) : super._();
  @override
  EconomyTransactions200Response rebuild(
    void Function(EconomyTransactions200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  EconomyTransactions200ResponseBuilder toBuilder() =>
      EconomyTransactions200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EconomyTransactions200Response &&
        data == other.data &&
        meta == other.meta &&
        code == other.code &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, meta.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EconomyTransactions200Response')
          ..add('data', data)
          ..add('meta', meta)
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class EconomyTransactions200ResponseBuilder
    implements
        Builder<
          EconomyTransactions200Response,
          EconomyTransactions200ResponseBuilder
        >,
        ApiPaginatedSuccessEnvelopeBuilder {
  _$EconomyTransactions200Response? _$v;

  ListBuilder<WalletTransactionResponseDto>? _data;
  ListBuilder<WalletTransactionResponseDto> get data =>
      _$this._data ??= ListBuilder<WalletTransactionResponseDto>();
  set data(covariant ListBuilder<WalletTransactionResponseDto>? data) =>
      _$this._data = data;

  ApiPaginationMetaBuilder? _meta;
  ApiPaginationMetaBuilder get meta =>
      _$this._meta ??= ApiPaginationMetaBuilder();
  set meta(covariant ApiPaginationMetaBuilder? meta) => _$this._meta = meta;

  ApiSuccessEnvelopeCodeEnum? _code;
  ApiSuccessEnvelopeCodeEnum? get code => _$this._code;
  set code(covariant ApiSuccessEnvelopeCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(covariant String? message) => _$this._message = message;

  EconomyTransactions200ResponseBuilder() {
    EconomyTransactions200Response._defaults(this);
  }

  EconomyTransactions200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _meta = $v.meta.toBuilder();
      _code = $v.code;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant EconomyTransactions200Response other) {
    _$v = other as _$EconomyTransactions200Response;
  }

  @override
  void update(void Function(EconomyTransactions200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EconomyTransactions200Response build() => _build();

  _$EconomyTransactions200Response _build() {
    _$EconomyTransactions200Response _$result;
    try {
      _$result =
          _$v ??
          _$EconomyTransactions200Response._(
            data: data.build(),
            meta: meta.build(),
            code: BuiltValueNullFieldError.checkNotNull(
              code,
              r'EconomyTransactions200Response',
              'code',
            ),
            message: BuiltValueNullFieldError.checkNotNull(
              message,
              r'EconomyTransactions200Response',
              'message',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
        _$failedField = 'meta';
        meta.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'EconomyTransactions200Response',
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
