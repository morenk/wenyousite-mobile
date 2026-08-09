// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revoke_sanction_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RevokeSanctionDto extends RevokeSanctionDto {
  @override
  final String reason;

  factory _$RevokeSanctionDto([
    void Function(RevokeSanctionDtoBuilder)? updates,
  ]) => (RevokeSanctionDtoBuilder()..update(updates))._build();

  _$RevokeSanctionDto._({required this.reason}) : super._();
  @override
  RevokeSanctionDto rebuild(void Function(RevokeSanctionDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RevokeSanctionDtoBuilder toBuilder() =>
      RevokeSanctionDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RevokeSanctionDto && reason == other.reason;
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
      r'RevokeSanctionDto',
    )..add('reason', reason)).toString();
  }
}

class RevokeSanctionDtoBuilder
    implements Builder<RevokeSanctionDto, RevokeSanctionDtoBuilder> {
  _$RevokeSanctionDto? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  RevokeSanctionDtoBuilder() {
    RevokeSanctionDto._defaults(this);
  }

  RevokeSanctionDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RevokeSanctionDto other) {
    _$v = other as _$RevokeSanctionDto;
  }

  @override
  void update(void Function(RevokeSanctionDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RevokeSanctionDto build() => _build();

  _$RevokeSanctionDto _build() {
    final _$result =
        _$v ??
        _$RevokeSanctionDto._(
          reason: BuiltValueNullFieldError.checkNotNull(
            reason,
            r'RevokeSanctionDto',
            'reason',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
