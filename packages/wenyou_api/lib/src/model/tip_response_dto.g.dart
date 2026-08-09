// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tip_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TipResponseDto extends TipResponseDto {
  @override
  final String transactionId;
  @override
  final String grossAmount;
  @override
  final String recipientAmount;
  @override
  final String platformAmount;
  @override
  final String balance;
  @override
  final String? threadTipTotal;
  @override
  final String? momentTipTotal;
  @override
  final String recipientTipTotal;
  @override
  final num recipientTipCount;

  factory _$TipResponseDto([void Function(TipResponseDtoBuilder)? updates]) =>
      (TipResponseDtoBuilder()..update(updates))._build();

  _$TipResponseDto._({
    required this.transactionId,
    required this.grossAmount,
    required this.recipientAmount,
    required this.platformAmount,
    required this.balance,
    this.threadTipTotal,
    this.momentTipTotal,
    required this.recipientTipTotal,
    required this.recipientTipCount,
  }) : super._();
  @override
  TipResponseDto rebuild(void Function(TipResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TipResponseDtoBuilder toBuilder() => TipResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TipResponseDto &&
        transactionId == other.transactionId &&
        grossAmount == other.grossAmount &&
        recipientAmount == other.recipientAmount &&
        platformAmount == other.platformAmount &&
        balance == other.balance &&
        threadTipTotal == other.threadTipTotal &&
        momentTipTotal == other.momentTipTotal &&
        recipientTipTotal == other.recipientTipTotal &&
        recipientTipCount == other.recipientTipCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, transactionId.hashCode);
    _$hash = $jc(_$hash, grossAmount.hashCode);
    _$hash = $jc(_$hash, recipientAmount.hashCode);
    _$hash = $jc(_$hash, platformAmount.hashCode);
    _$hash = $jc(_$hash, balance.hashCode);
    _$hash = $jc(_$hash, threadTipTotal.hashCode);
    _$hash = $jc(_$hash, momentTipTotal.hashCode);
    _$hash = $jc(_$hash, recipientTipTotal.hashCode);
    _$hash = $jc(_$hash, recipientTipCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TipResponseDto')
          ..add('transactionId', transactionId)
          ..add('grossAmount', grossAmount)
          ..add('recipientAmount', recipientAmount)
          ..add('platformAmount', platformAmount)
          ..add('balance', balance)
          ..add('threadTipTotal', threadTipTotal)
          ..add('momentTipTotal', momentTipTotal)
          ..add('recipientTipTotal', recipientTipTotal)
          ..add('recipientTipCount', recipientTipCount))
        .toString();
  }
}

class TipResponseDtoBuilder
    implements Builder<TipResponseDto, TipResponseDtoBuilder> {
  _$TipResponseDto? _$v;

  String? _transactionId;
  String? get transactionId => _$this._transactionId;
  set transactionId(String? transactionId) =>
      _$this._transactionId = transactionId;

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

  String? _balance;
  String? get balance => _$this._balance;
  set balance(String? balance) => _$this._balance = balance;

  String? _threadTipTotal;
  String? get threadTipTotal => _$this._threadTipTotal;
  set threadTipTotal(String? threadTipTotal) =>
      _$this._threadTipTotal = threadTipTotal;

  String? _momentTipTotal;
  String? get momentTipTotal => _$this._momentTipTotal;
  set momentTipTotal(String? momentTipTotal) =>
      _$this._momentTipTotal = momentTipTotal;

  String? _recipientTipTotal;
  String? get recipientTipTotal => _$this._recipientTipTotal;
  set recipientTipTotal(String? recipientTipTotal) =>
      _$this._recipientTipTotal = recipientTipTotal;

  num? _recipientTipCount;
  num? get recipientTipCount => _$this._recipientTipCount;
  set recipientTipCount(num? recipientTipCount) =>
      _$this._recipientTipCount = recipientTipCount;

  TipResponseDtoBuilder() {
    TipResponseDto._defaults(this);
  }

  TipResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _transactionId = $v.transactionId;
      _grossAmount = $v.grossAmount;
      _recipientAmount = $v.recipientAmount;
      _platformAmount = $v.platformAmount;
      _balance = $v.balance;
      _threadTipTotal = $v.threadTipTotal;
      _momentTipTotal = $v.momentTipTotal;
      _recipientTipTotal = $v.recipientTipTotal;
      _recipientTipCount = $v.recipientTipCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TipResponseDto other) {
    _$v = other as _$TipResponseDto;
  }

  @override
  void update(void Function(TipResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TipResponseDto build() => _build();

  _$TipResponseDto _build() {
    final _$result =
        _$v ??
        _$TipResponseDto._(
          transactionId: BuiltValueNullFieldError.checkNotNull(
            transactionId,
            r'TipResponseDto',
            'transactionId',
          ),
          grossAmount: BuiltValueNullFieldError.checkNotNull(
            grossAmount,
            r'TipResponseDto',
            'grossAmount',
          ),
          recipientAmount: BuiltValueNullFieldError.checkNotNull(
            recipientAmount,
            r'TipResponseDto',
            'recipientAmount',
          ),
          platformAmount: BuiltValueNullFieldError.checkNotNull(
            platformAmount,
            r'TipResponseDto',
            'platformAmount',
          ),
          balance: BuiltValueNullFieldError.checkNotNull(
            balance,
            r'TipResponseDto',
            'balance',
          ),
          threadTipTotal: threadTipTotal,
          momentTipTotal: momentTipTotal,
          recipientTipTotal: BuiltValueNullFieldError.checkNotNull(
            recipientTipTotal,
            r'TipResponseDto',
            'recipientTipTotal',
          ),
          recipientTipCount: BuiltValueNullFieldError.checkNotNull(
            recipientTipCount,
            r'TipResponseDto',
            'recipientTipCount',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
