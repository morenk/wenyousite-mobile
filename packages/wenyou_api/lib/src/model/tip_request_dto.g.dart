// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tip_request_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TipRequestDto extends TipRequestDto {
  @override
  final String amount;
  @override
  final String clientRequestId;

  factory _$TipRequestDto([void Function(TipRequestDtoBuilder)? updates]) =>
      (TipRequestDtoBuilder()..update(updates))._build();

  _$TipRequestDto._({required this.amount, required this.clientRequestId})
    : super._();
  @override
  TipRequestDto rebuild(void Function(TipRequestDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TipRequestDtoBuilder toBuilder() => TipRequestDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TipRequestDto &&
        amount == other.amount &&
        clientRequestId == other.clientRequestId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, clientRequestId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TipRequestDto')
          ..add('amount', amount)
          ..add('clientRequestId', clientRequestId))
        .toString();
  }
}

class TipRequestDtoBuilder
    implements Builder<TipRequestDto, TipRequestDtoBuilder> {
  _$TipRequestDto? _$v;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  String? _clientRequestId;
  String? get clientRequestId => _$this._clientRequestId;
  set clientRequestId(String? clientRequestId) =>
      _$this._clientRequestId = clientRequestId;

  TipRequestDtoBuilder() {
    TipRequestDto._defaults(this);
  }

  TipRequestDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _amount = $v.amount;
      _clientRequestId = $v.clientRequestId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TipRequestDto other) {
    _$v = other as _$TipRequestDto;
  }

  @override
  void update(void Function(TipRequestDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TipRequestDto build() => _build();

  _$TipRequestDto _build() {
    final _$result =
        _$v ??
        _$TipRequestDto._(
          amount: BuiltValueNullFieldError.checkNotNull(
            amount,
            r'TipRequestDto',
            'amount',
          ),
          clientRequestId: BuiltValueNullFieldError.checkNotNull(
            clientRequestId,
            r'TipRequestDto',
            'clientRequestId',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
