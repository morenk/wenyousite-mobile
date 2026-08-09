// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WalletResponseDto extends WalletResponseDto {
  @override
  final String balance;
  @override
  final String receivedTipTotal;
  @override
  final num receivedTipCount;

  factory _$WalletResponseDto([
    void Function(WalletResponseDtoBuilder)? updates,
  ]) => (WalletResponseDtoBuilder()..update(updates))._build();

  _$WalletResponseDto._({
    required this.balance,
    required this.receivedTipTotal,
    required this.receivedTipCount,
  }) : super._();
  @override
  WalletResponseDto rebuild(void Function(WalletResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WalletResponseDtoBuilder toBuilder() =>
      WalletResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WalletResponseDto &&
        balance == other.balance &&
        receivedTipTotal == other.receivedTipTotal &&
        receivedTipCount == other.receivedTipCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, balance.hashCode);
    _$hash = $jc(_$hash, receivedTipTotal.hashCode);
    _$hash = $jc(_$hash, receivedTipCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WalletResponseDto')
          ..add('balance', balance)
          ..add('receivedTipTotal', receivedTipTotal)
          ..add('receivedTipCount', receivedTipCount))
        .toString();
  }
}

class WalletResponseDtoBuilder
    implements Builder<WalletResponseDto, WalletResponseDtoBuilder> {
  _$WalletResponseDto? _$v;

  String? _balance;
  String? get balance => _$this._balance;
  set balance(String? balance) => _$this._balance = balance;

  String? _receivedTipTotal;
  String? get receivedTipTotal => _$this._receivedTipTotal;
  set receivedTipTotal(String? receivedTipTotal) =>
      _$this._receivedTipTotal = receivedTipTotal;

  num? _receivedTipCount;
  num? get receivedTipCount => _$this._receivedTipCount;
  set receivedTipCount(num? receivedTipCount) =>
      _$this._receivedTipCount = receivedTipCount;

  WalletResponseDtoBuilder() {
    WalletResponseDto._defaults(this);
  }

  WalletResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _balance = $v.balance;
      _receivedTipTotal = $v.receivedTipTotal;
      _receivedTipCount = $v.receivedTipCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WalletResponseDto other) {
    _$v = other as _$WalletResponseDto;
  }

  @override
  void update(void Function(WalletResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WalletResponseDto build() => _build();

  _$WalletResponseDto _build() {
    final _$result =
        _$v ??
        _$WalletResponseDto._(
          balance: BuiltValueNullFieldError.checkNotNull(
            balance,
            r'WalletResponseDto',
            'balance',
          ),
          receivedTipTotal: BuiltValueNullFieldError.checkNotNull(
            receivedTipTotal,
            r'WalletResponseDto',
            'receivedTipTotal',
          ),
          receivedTipCount: BuiltValueNullFieldError.checkNotNull(
            receivedTipCount,
            r'WalletResponseDto',
            'receivedTipCount',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
