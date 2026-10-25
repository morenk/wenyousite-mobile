// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_enabled_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FontEnabledDto extends FontEnabledDto {
  @override
  final bool enabled;
  @override
  final int expectedFamilyRevision;
  @override
  final int expectedCatalogRevision;

  factory _$FontEnabledDto([void Function(FontEnabledDtoBuilder)? updates]) =>
      (FontEnabledDtoBuilder()..update(updates))._build();

  _$FontEnabledDto._({
    required this.enabled,
    required this.expectedFamilyRevision,
    required this.expectedCatalogRevision,
  }) : super._();
  @override
  FontEnabledDto rebuild(void Function(FontEnabledDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FontEnabledDtoBuilder toBuilder() => FontEnabledDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FontEnabledDto &&
        enabled == other.enabled &&
        expectedFamilyRevision == other.expectedFamilyRevision &&
        expectedCatalogRevision == other.expectedCatalogRevision;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, expectedFamilyRevision.hashCode);
    _$hash = $jc(_$hash, expectedCatalogRevision.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FontEnabledDto')
          ..add('enabled', enabled)
          ..add('expectedFamilyRevision', expectedFamilyRevision)
          ..add('expectedCatalogRevision', expectedCatalogRevision))
        .toString();
  }
}

class FontEnabledDtoBuilder
    implements Builder<FontEnabledDto, FontEnabledDtoBuilder> {
  _$FontEnabledDto? _$v;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  int? _expectedFamilyRevision;
  int? get expectedFamilyRevision => _$this._expectedFamilyRevision;
  set expectedFamilyRevision(int? expectedFamilyRevision) =>
      _$this._expectedFamilyRevision = expectedFamilyRevision;

  int? _expectedCatalogRevision;
  int? get expectedCatalogRevision => _$this._expectedCatalogRevision;
  set expectedCatalogRevision(int? expectedCatalogRevision) =>
      _$this._expectedCatalogRevision = expectedCatalogRevision;

  FontEnabledDtoBuilder() {
    FontEnabledDto._defaults(this);
  }

  FontEnabledDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _enabled = $v.enabled;
      _expectedFamilyRevision = $v.expectedFamilyRevision;
      _expectedCatalogRevision = $v.expectedCatalogRevision;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FontEnabledDto other) {
    _$v = other as _$FontEnabledDto;
  }

  @override
  void update(void Function(FontEnabledDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FontEnabledDto build() => _build();

  _$FontEnabledDto _build() {
    final _$result =
        _$v ??
        _$FontEnabledDto._(
          enabled: BuiltValueNullFieldError.checkNotNull(
            enabled,
            r'FontEnabledDto',
            'enabled',
          ),
          expectedFamilyRevision: BuiltValueNullFieldError.checkNotNull(
            expectedFamilyRevision,
            r'FontEnabledDto',
            'expectedFamilyRevision',
          ),
          expectedCatalogRevision: BuiltValueNullFieldError.checkNotNull(
            expectedCatalogRevision,
            r'FontEnabledDto',
            'expectedCatalogRevision',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
