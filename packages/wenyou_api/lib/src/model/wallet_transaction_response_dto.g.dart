// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_transaction_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const WalletTransactionResponseDtoTypeEnum
_$walletTransactionResponseDtoTypeEnum_DAILY_CHECK_IN =
    const WalletTransactionResponseDtoTypeEnum._('DAILY_CHECK_IN');
const WalletTransactionResponseDtoTypeEnum
_$walletTransactionResponseDtoTypeEnum_TIP =
    const WalletTransactionResponseDtoTypeEnum._('TIP');
const WalletTransactionResponseDtoTypeEnum
_$walletTransactionResponseDtoTypeEnum_unknownDefaultOpenApi =
    const WalletTransactionResponseDtoTypeEnum._('unknownDefaultOpenApi');

WalletTransactionResponseDtoTypeEnum
_$walletTransactionResponseDtoTypeEnumValueOf(String name) {
  switch (name) {
    case 'DAILY_CHECK_IN':
      return _$walletTransactionResponseDtoTypeEnum_DAILY_CHECK_IN;
    case 'TIP':
      return _$walletTransactionResponseDtoTypeEnum_TIP;
    case 'unknownDefaultOpenApi':
      return _$walletTransactionResponseDtoTypeEnum_unknownDefaultOpenApi;
    default:
      return _$walletTransactionResponseDtoTypeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<WalletTransactionResponseDtoTypeEnum>
_$walletTransactionResponseDtoTypeEnumValues =
    BuiltSet<WalletTransactionResponseDtoTypeEnum>(
      const <WalletTransactionResponseDtoTypeEnum>[
        _$walletTransactionResponseDtoTypeEnum_DAILY_CHECK_IN,
        _$walletTransactionResponseDtoTypeEnum_TIP,
        _$walletTransactionResponseDtoTypeEnum_unknownDefaultOpenApi,
      ],
    );

const WalletTransactionResponseDtoDirectionEnum
_$walletTransactionResponseDtoDirectionEnum_INCOME =
    const WalletTransactionResponseDtoDirectionEnum._('INCOME');
const WalletTransactionResponseDtoDirectionEnum
_$walletTransactionResponseDtoDirectionEnum_EXPENSE =
    const WalletTransactionResponseDtoDirectionEnum._('EXPENSE');
const WalletTransactionResponseDtoDirectionEnum
_$walletTransactionResponseDtoDirectionEnum_unknownDefaultOpenApi =
    const WalletTransactionResponseDtoDirectionEnum._('unknownDefaultOpenApi');

WalletTransactionResponseDtoDirectionEnum
_$walletTransactionResponseDtoDirectionEnumValueOf(String name) {
  switch (name) {
    case 'INCOME':
      return _$walletTransactionResponseDtoDirectionEnum_INCOME;
    case 'EXPENSE':
      return _$walletTransactionResponseDtoDirectionEnum_EXPENSE;
    case 'unknownDefaultOpenApi':
      return _$walletTransactionResponseDtoDirectionEnum_unknownDefaultOpenApi;
    default:
      return _$walletTransactionResponseDtoDirectionEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<WalletTransactionResponseDtoDirectionEnum>
_$walletTransactionResponseDtoDirectionEnumValues =
    BuiltSet<WalletTransactionResponseDtoDirectionEnum>(
      const <WalletTransactionResponseDtoDirectionEnum>[
        _$walletTransactionResponseDtoDirectionEnum_INCOME,
        _$walletTransactionResponseDtoDirectionEnum_EXPENSE,
        _$walletTransactionResponseDtoDirectionEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<WalletTransactionResponseDtoTypeEnum>
_$walletTransactionResponseDtoTypeEnumSerializer =
    _$WalletTransactionResponseDtoTypeEnumSerializer();
Serializer<WalletTransactionResponseDtoDirectionEnum>
_$walletTransactionResponseDtoDirectionEnumSerializer =
    _$WalletTransactionResponseDtoDirectionEnumSerializer();

class _$WalletTransactionResponseDtoTypeEnumSerializer
    implements PrimitiveSerializer<WalletTransactionResponseDtoTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'DAILY_CHECK_IN': 'DAILY_CHECK_IN',
    'TIP': 'TIP',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'DAILY_CHECK_IN': 'DAILY_CHECK_IN',
    'TIP': 'TIP',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    WalletTransactionResponseDtoTypeEnum,
  ];
  @override
  final String wireName = 'WalletTransactionResponseDtoTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    WalletTransactionResponseDtoTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  WalletTransactionResponseDtoTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => WalletTransactionResponseDtoTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$WalletTransactionResponseDtoDirectionEnumSerializer
    implements PrimitiveSerializer<WalletTransactionResponseDtoDirectionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'INCOME': 'INCOME',
    'EXPENSE': 'EXPENSE',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'INCOME': 'INCOME',
    'EXPENSE': 'EXPENSE',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    WalletTransactionResponseDtoDirectionEnum,
  ];
  @override
  final String wireName = 'WalletTransactionResponseDtoDirectionEnum';

  @override
  Object serialize(
    Serializers serializers,
    WalletTransactionResponseDtoDirectionEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  WalletTransactionResponseDtoDirectionEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => WalletTransactionResponseDtoDirectionEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$WalletTransactionResponseDto extends WalletTransactionResponseDto {
  @override
  final String id;
  @override
  final WalletTransactionResponseDtoTypeEnum type;
  @override
  final WalletTransactionResponseDtoDirectionEnum direction;
  @override
  final String amount;
  @override
  final String grossAmount;
  @override
  final String recipientAmount;
  @override
  final String platformAmount;
  @override
  final String balanceAfter;
  @override
  final PostAuthorResponseDto? counterparty;
  @override
  final WalletTransactionTargetResponseDto target;
  @override
  final DateTime createdAt;

  factory _$WalletTransactionResponseDto([
    void Function(WalletTransactionResponseDtoBuilder)? updates,
  ]) => (WalletTransactionResponseDtoBuilder()..update(updates))._build();

  _$WalletTransactionResponseDto._({
    required this.id,
    required this.type,
    required this.direction,
    required this.amount,
    required this.grossAmount,
    required this.recipientAmount,
    required this.platformAmount,
    required this.balanceAfter,
    this.counterparty,
    required this.target,
    required this.createdAt,
  }) : super._();
  @override
  WalletTransactionResponseDto rebuild(
    void Function(WalletTransactionResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  WalletTransactionResponseDtoBuilder toBuilder() =>
      WalletTransactionResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WalletTransactionResponseDto &&
        id == other.id &&
        type == other.type &&
        direction == other.direction &&
        amount == other.amount &&
        grossAmount == other.grossAmount &&
        recipientAmount == other.recipientAmount &&
        platformAmount == other.platformAmount &&
        balanceAfter == other.balanceAfter &&
        counterparty == other.counterparty &&
        target == other.target &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, direction.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, grossAmount.hashCode);
    _$hash = $jc(_$hash, recipientAmount.hashCode);
    _$hash = $jc(_$hash, platformAmount.hashCode);
    _$hash = $jc(_$hash, balanceAfter.hashCode);
    _$hash = $jc(_$hash, counterparty.hashCode);
    _$hash = $jc(_$hash, target.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WalletTransactionResponseDto')
          ..add('id', id)
          ..add('type', type)
          ..add('direction', direction)
          ..add('amount', amount)
          ..add('grossAmount', grossAmount)
          ..add('recipientAmount', recipientAmount)
          ..add('platformAmount', platformAmount)
          ..add('balanceAfter', balanceAfter)
          ..add('counterparty', counterparty)
          ..add('target', target)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class WalletTransactionResponseDtoBuilder
    implements
        Builder<
          WalletTransactionResponseDto,
          WalletTransactionResponseDtoBuilder
        > {
  _$WalletTransactionResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  WalletTransactionResponseDtoTypeEnum? _type;
  WalletTransactionResponseDtoTypeEnum? get type => _$this._type;
  set type(WalletTransactionResponseDtoTypeEnum? type) => _$this._type = type;

  WalletTransactionResponseDtoDirectionEnum? _direction;
  WalletTransactionResponseDtoDirectionEnum? get direction => _$this._direction;
  set direction(WalletTransactionResponseDtoDirectionEnum? direction) =>
      _$this._direction = direction;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  String? _grossAmount;
  String? get grossAmount => _$this._grossAmount;
  set grossAmount(String? grossAmount) => _$this._grossAmount = grossAmount;

  String? _recipientAmount;
  String? get recipientAmount => _$this._recipientAmount;
  set recipientAmount(String? recipientAmount) =>
      _$this._recipientAmount = recipientAmount;

  String? _platformAmount;
  String? get platformAmount => _$this._platformAmount;
  set platformAmount(String? platformAmount) =>
      _$this._platformAmount = platformAmount;

  String? _balanceAfter;
  String? get balanceAfter => _$this._balanceAfter;
  set balanceAfter(String? balanceAfter) => _$this._balanceAfter = balanceAfter;

  PostAuthorResponseDtoBuilder? _counterparty;
  PostAuthorResponseDtoBuilder get counterparty =>
      _$this._counterparty ??= PostAuthorResponseDtoBuilder();
  set counterparty(PostAuthorResponseDtoBuilder? counterparty) =>
      _$this._counterparty = counterparty;

  WalletTransactionTargetResponseDtoBuilder? _target;
  WalletTransactionTargetResponseDtoBuilder get target =>
      _$this._target ??= WalletTransactionTargetResponseDtoBuilder();
  set target(WalletTransactionTargetResponseDtoBuilder? target) =>
      _$this._target = target;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  WalletTransactionResponseDtoBuilder() {
    WalletTransactionResponseDto._defaults(this);
  }

  WalletTransactionResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _type = $v.type;
      _direction = $v.direction;
      _amount = $v.amount;
      _grossAmount = $v.grossAmount;
      _recipientAmount = $v.recipientAmount;
      _platformAmount = $v.platformAmount;
      _balanceAfter = $v.balanceAfter;
      _counterparty = $v.counterparty?.toBuilder();
      _target = $v.target.toBuilder();
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WalletTransactionResponseDto other) {
    _$v = other as _$WalletTransactionResponseDto;
  }

  @override
  void update(void Function(WalletTransactionResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WalletTransactionResponseDto build() => _build();

  _$WalletTransactionResponseDto _build() {
    _$WalletTransactionResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$WalletTransactionResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'WalletTransactionResponseDto',
              'id',
            ),
            type: BuiltValueNullFieldError.checkNotNull(
              type,
              r'WalletTransactionResponseDto',
              'type',
            ),
            direction: BuiltValueNullFieldError.checkNotNull(
              direction,
              r'WalletTransactionResponseDto',
              'direction',
            ),
            amount: BuiltValueNullFieldError.checkNotNull(
              amount,
              r'WalletTransactionResponseDto',
              'amount',
            ),
            grossAmount: BuiltValueNullFieldError.checkNotNull(
              grossAmount,
              r'WalletTransactionResponseDto',
              'grossAmount',
            ),
            recipientAmount: BuiltValueNullFieldError.checkNotNull(
              recipientAmount,
              r'WalletTransactionResponseDto',
              'recipientAmount',
            ),
            platformAmount: BuiltValueNullFieldError.checkNotNull(
              platformAmount,
              r'WalletTransactionResponseDto',
              'platformAmount',
            ),
            balanceAfter: BuiltValueNullFieldError.checkNotNull(
              balanceAfter,
              r'WalletTransactionResponseDto',
              'balanceAfter',
            ),
            counterparty: _counterparty?.build(),
            target: target.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'WalletTransactionResponseDto',
              'createdAt',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'counterparty';
        _counterparty?.build();
        _$failedField = 'target';
        target.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'WalletTransactionResponseDto',
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
