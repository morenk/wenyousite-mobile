// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_site_settings_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateSiteSettingsDto extends UpdateSiteSettingsDto {
  @override
  final DateTime? registrationPausedUntil;
  @override
  final DateTime? contentWritesPausedUntil;
  @override
  final String? maintenanceTitle;
  @override
  final String? maintenanceContent;
  @override
  final DateTime? maintenanceStartsAt;
  @override
  final DateTime? maintenanceEndsAt;

  factory _$UpdateSiteSettingsDto([
    void Function(UpdateSiteSettingsDtoBuilder)? updates,
  ]) => (UpdateSiteSettingsDtoBuilder()..update(updates))._build();

  _$UpdateSiteSettingsDto._({
    this.registrationPausedUntil,
    this.contentWritesPausedUntil,
    this.maintenanceTitle,
    this.maintenanceContent,
    this.maintenanceStartsAt,
    this.maintenanceEndsAt,
  }) : super._();
  @override
  UpdateSiteSettingsDto rebuild(
    void Function(UpdateSiteSettingsDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UpdateSiteSettingsDtoBuilder toBuilder() =>
      UpdateSiteSettingsDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateSiteSettingsDto &&
        registrationPausedUntil == other.registrationPausedUntil &&
        contentWritesPausedUntil == other.contentWritesPausedUntil &&
        maintenanceTitle == other.maintenanceTitle &&
        maintenanceContent == other.maintenanceContent &&
        maintenanceStartsAt == other.maintenanceStartsAt &&
        maintenanceEndsAt == other.maintenanceEndsAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, registrationPausedUntil.hashCode);
    _$hash = $jc(_$hash, contentWritesPausedUntil.hashCode);
    _$hash = $jc(_$hash, maintenanceTitle.hashCode);
    _$hash = $jc(_$hash, maintenanceContent.hashCode);
    _$hash = $jc(_$hash, maintenanceStartsAt.hashCode);
    _$hash = $jc(_$hash, maintenanceEndsAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateSiteSettingsDto')
          ..add('registrationPausedUntil', registrationPausedUntil)
          ..add('contentWritesPausedUntil', contentWritesPausedUntil)
          ..add('maintenanceTitle', maintenanceTitle)
          ..add('maintenanceContent', maintenanceContent)
          ..add('maintenanceStartsAt', maintenanceStartsAt)
          ..add('maintenanceEndsAt', maintenanceEndsAt))
        .toString();
  }
}

class UpdateSiteSettingsDtoBuilder
    implements Builder<UpdateSiteSettingsDto, UpdateSiteSettingsDtoBuilder> {
  _$UpdateSiteSettingsDto? _$v;

  DateTime? _registrationPausedUntil;
  DateTime? get registrationPausedUntil => _$this._registrationPausedUntil;
  set registrationPausedUntil(DateTime? registrationPausedUntil) =>
      _$this._registrationPausedUntil = registrationPausedUntil;

  DateTime? _contentWritesPausedUntil;
  DateTime? get contentWritesPausedUntil => _$this._contentWritesPausedUntil;
  set contentWritesPausedUntil(DateTime? contentWritesPausedUntil) =>
      _$this._contentWritesPausedUntil = contentWritesPausedUntil;

  String? _maintenanceTitle;
  String? get maintenanceTitle => _$this._maintenanceTitle;
  set maintenanceTitle(String? maintenanceTitle) =>
      _$this._maintenanceTitle = maintenanceTitle;

  String? _maintenanceContent;
  String? get maintenanceContent => _$this._maintenanceContent;
  set maintenanceContent(String? maintenanceContent) =>
      _$this._maintenanceContent = maintenanceContent;

  DateTime? _maintenanceStartsAt;
  DateTime? get maintenanceStartsAt => _$this._maintenanceStartsAt;
  set maintenanceStartsAt(DateTime? maintenanceStartsAt) =>
      _$this._maintenanceStartsAt = maintenanceStartsAt;

  DateTime? _maintenanceEndsAt;
  DateTime? get maintenanceEndsAt => _$this._maintenanceEndsAt;
  set maintenanceEndsAt(DateTime? maintenanceEndsAt) =>
      _$this._maintenanceEndsAt = maintenanceEndsAt;

  UpdateSiteSettingsDtoBuilder() {
    UpdateSiteSettingsDto._defaults(this);
  }

  UpdateSiteSettingsDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _registrationPausedUntil = $v.registrationPausedUntil;
      _contentWritesPausedUntil = $v.contentWritesPausedUntil;
      _maintenanceTitle = $v.maintenanceTitle;
      _maintenanceContent = $v.maintenanceContent;
      _maintenanceStartsAt = $v.maintenanceStartsAt;
      _maintenanceEndsAt = $v.maintenanceEndsAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateSiteSettingsDto other) {
    _$v = other as _$UpdateSiteSettingsDto;
  }

  @override
  void update(void Function(UpdateSiteSettingsDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateSiteSettingsDto build() => _build();

  _$UpdateSiteSettingsDto _build() {
    final _$result =
        _$v ??
        _$UpdateSiteSettingsDto._(
          registrationPausedUntil: registrationPausedUntil,
          contentWritesPausedUntil: contentWritesPausedUntil,
          maintenanceTitle: maintenanceTitle,
          maintenanceContent: maintenanceContent,
          maintenanceStartsAt: maintenanceStartsAt,
          maintenanceEndsAt: maintenanceEndsAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
