// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_account_reason_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminAccountReasonDto extends AdminAccountReasonDto {
  @override
  final String reason;

  factory _$AdminAccountReasonDto([
    void Function(AdminAccountReasonDtoBuilder)? updates,
  ]) => (AdminAccountReasonDtoBuilder()..update(updates))._build();

  _$AdminAccountReasonDto._({required this.reason}) : super._();
  @override
  AdminAccountReasonDto rebuild(
    void Function(AdminAccountReasonDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminAccountReasonDtoBuilder toBuilder() =>
      AdminAccountReasonDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminAccountReasonDto && reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'AdminAccountReasonDto',
    )..add('reason', reason)).toString();
  }
}

class AdminAccountReasonDtoBuilder
    implements Builder<AdminAccountReasonDto, AdminAccountReasonDtoBuilder> {
  _$AdminAccountReasonDto? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  AdminAccountReasonDtoBuilder() {
    AdminAccountReasonDto._defaults(this);
  }

  AdminAccountReasonDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminAccountReasonDto other) {
    _$v = other as _$AdminAccountReasonDto;
  }

  @override
  void update(void Function(AdminAccountReasonDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminAccountReasonDto build() => _build();

  _$AdminAccountReasonDto _build() {
    final _$result =
        _$v ??
        _$AdminAccountReasonDto._(
          reason: BuiltValueNullFieldError.checkNotNull(
            reason,
            r'AdminAccountReasonDto',
            'reason',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
