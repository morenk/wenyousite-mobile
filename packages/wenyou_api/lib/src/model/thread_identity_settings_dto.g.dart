// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_identity_settings_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ThreadIdentitySettingsDto extends ThreadIdentitySettingsDto {
  @override
  final bool enabled;

  factory _$ThreadIdentitySettingsDto([
    void Function(ThreadIdentitySettingsDtoBuilder)? updates,
  ]) => (ThreadIdentitySettingsDtoBuilder()..update(updates))._build();

  _$ThreadIdentitySettingsDto._({required this.enabled}) : super._();
  @override
  ThreadIdentitySettingsDto rebuild(
    void Function(ThreadIdentitySettingsDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadIdentitySettingsDtoBuilder toBuilder() =>
      ThreadIdentitySettingsDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadIdentitySettingsDto && enabled == other.enabled;
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
      r'ThreadIdentitySettingsDto',
    )..add('enabled', enabled)).toString();
  }
}

class ThreadIdentitySettingsDtoBuilder
    implements
        Builder<ThreadIdentitySettingsDto, ThreadIdentitySettingsDtoBuilder> {
  _$ThreadIdentitySettingsDto? _$v;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  ThreadIdentitySettingsDtoBuilder() {
    ThreadIdentitySettingsDto._defaults(this);
  }

  ThreadIdentitySettingsDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _enabled = $v.enabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ThreadIdentitySettingsDto other) {
    _$v = other as _$ThreadIdentitySettingsDto;
  }

  @override
  void update(void Function(ThreadIdentitySettingsDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadIdentitySettingsDto build() => _build();

  _$ThreadIdentitySettingsDto _build() {
    final _$result =
        _$v ??
        _$ThreadIdentitySettingsDto._(
          enabled: BuiltValueNullFieldError.checkNotNull(
            enabled,
            r'ThreadIdentitySettingsDto',
            'enabled',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
