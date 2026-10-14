// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_thread_identity_enabled_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SetThreadIdentityEnabledDto extends SetThreadIdentityEnabledDto {
  @override
  final bool enabled;

  factory _$SetThreadIdentityEnabledDto([
    void Function(SetThreadIdentityEnabledDtoBuilder)? updates,
  ]) => (SetThreadIdentityEnabledDtoBuilder()..update(updates))._build();

  _$SetThreadIdentityEnabledDto._({required this.enabled}) : super._();
  @override
  SetThreadIdentityEnabledDto rebuild(
    void Function(SetThreadIdentityEnabledDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SetThreadIdentityEnabledDtoBuilder toBuilder() =>
      SetThreadIdentityEnabledDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SetThreadIdentityEnabledDto && enabled == other.enabled;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'SetThreadIdentityEnabledDto',
    )..add('enabled', enabled)).toString();
  }
}

class SetThreadIdentityEnabledDtoBuilder
    implements
        Builder<
          SetThreadIdentityEnabledDto,
          SetThreadIdentityEnabledDtoBuilder
        > {
  _$SetThreadIdentityEnabledDto? _$v;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  SetThreadIdentityEnabledDtoBuilder() {
    SetThreadIdentityEnabledDto._defaults(this);
  }

  SetThreadIdentityEnabledDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _enabled = $v.enabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SetThreadIdentityEnabledDto other) {
    _$v = other as _$SetThreadIdentityEnabledDto;
  }

  @override
  void update(void Function(SetThreadIdentityEnabledDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SetThreadIdentityEnabledDto build() => _build();

  _$SetThreadIdentityEnabledDto _build() {
    final _$result =
        _$v ??
        _$SetThreadIdentityEnabledDto._(
          enabled: BuiltValueNullFieldError.checkNotNull(
            enabled,
            r'SetThreadIdentityEnabledDto',
            'enabled',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
