// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_withdraw_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FontWithdrawDto extends FontWithdrawDto {
  @override
  final int expectedCatalogRevision;
  @override
  final String reason;

  factory _$FontWithdrawDto([void Function(FontWithdrawDtoBuilder)? updates]) =>
      (FontWithdrawDtoBuilder()..update(updates))._build();

  _$FontWithdrawDto._({
    required this.expectedCatalogRevision,
    required this.reason,
  }) : super._();
  @override
  FontWithdrawDto rebuild(void Function(FontWithdrawDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FontWithdrawDtoBuilder toBuilder() => FontWithdrawDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FontWithdrawDto &&
        expectedCatalogRevision == other.expectedCatalogRevision &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, expectedCatalogRevision.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FontWithdrawDto')
          ..add('expectedCatalogRevision', expectedCatalogRevision)
          ..add('reason', reason))
        .toString();
  }
}

class FontWithdrawDtoBuilder
    implements Builder<FontWithdrawDto, FontWithdrawDtoBuilder> {
  _$FontWithdrawDto? _$v;

  int? _expectedCatalogRevision;
  int? get expectedCatalogRevision => _$this._expectedCatalogRevision;
  set expectedCatalogRevision(int? expectedCatalogRevision) =>
      _$this._expectedCatalogRevision = expectedCatalogRevision;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  FontWithdrawDtoBuilder() {
    FontWithdrawDto._defaults(this);
  }

  FontWithdrawDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _expectedCatalogRevision = $v.expectedCatalogRevision;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FontWithdrawDto other) {
    _$v = other as _$FontWithdrawDto;
  }

  @override
  void update(void Function(FontWithdrawDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FontWithdrawDto build() => _build();

  _$FontWithdrawDto _build() {
    final _$result =
        _$v ??
        _$FontWithdrawDto._(
          expectedCatalogRevision: BuiltValueNullFieldError.checkNotNull(
            expectedCatalogRevision,
            r'FontWithdrawDto',
            'expectedCatalogRevision',
          ),
          reason: BuiltValueNullFieldError.checkNotNull(
            reason,
            r'FontWithdrawDto',
            'reason',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
