// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_super_admin_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TransferSuperAdminDto extends TransferSuperAdminDto {
  @override
  final String reason;
  @override
  final String userId;

  factory _$TransferSuperAdminDto([
    void Function(TransferSuperAdminDtoBuilder)? updates,
  ]) => (TransferSuperAdminDtoBuilder()..update(updates))._build();

  _$TransferSuperAdminDto._({required this.reason, required this.userId})
    : super._();
  @override
  TransferSuperAdminDto rebuild(
    void Function(TransferSuperAdminDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  TransferSuperAdminDtoBuilder toBuilder() =>
      TransferSuperAdminDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TransferSuperAdminDto &&
        reason == other.reason &&
        userId == other.userId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TransferSuperAdminDto')
          ..add('reason', reason)
          ..add('userId', userId))
        .toString();
  }
}

class TransferSuperAdminDtoBuilder
    implements Builder<TransferSuperAdminDto, TransferSuperAdminDtoBuilder> {
  _$TransferSuperAdminDto? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  TransferSuperAdminDtoBuilder() {
    TransferSuperAdminDto._defaults(this);
  }

  TransferSuperAdminDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _userId = $v.userId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TransferSuperAdminDto other) {
    _$v = other as _$TransferSuperAdminDto;
  }

  @override
  void update(void Function(TransferSuperAdminDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TransferSuperAdminDto build() => _build();

  _$TransferSuperAdminDto _build() {
    final _$result =
        _$v ??
        _$TransferSuperAdminDto._(
          reason: BuiltValueNullFieldError.checkNotNull(
            reason,
            r'TransferSuperAdminDto',
            'reason',
          ),
          userId: BuiltValueNullFieldError.checkNotNull(
            userId,
            r'TransferSuperAdminDto',
            'userId',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
