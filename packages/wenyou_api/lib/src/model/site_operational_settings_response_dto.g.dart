// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_operational_settings_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SiteOperationalSettingsResponseDto
    extends SiteOperationalSettingsResponseDto {
  @override
  final String id;
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
  @override
  final DateTime updatedAt;

  factory _$SiteOperationalSettingsResponseDto([
    void Function(SiteOperationalSettingsResponseDtoBuilder)? updates,
  ]) => (SiteOperationalSettingsResponseDtoBuilder()..update(updates))._build();

  _$SiteOperationalSettingsResponseDto._({
    required this.id,
    this.registrationPausedUntil,
    this.contentWritesPausedUntil,
    this.maintenanceTitle,
    this.maintenanceContent,
    this.maintenanceStartsAt,
    this.maintenanceEndsAt,
    required this.updatedAt,
  }) : super._();
  @override
  SiteOperationalSettingsResponseDto rebuild(
    void Function(SiteOperationalSettingsResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SiteOperationalSettingsResponseDtoBuilder toBuilder() =>
      SiteOperationalSettingsResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SiteOperationalSettingsResponseDto &&
        id == other.id &&
        registrationPausedUntil == other.registrationPausedUntil &&
        contentWritesPausedUntil == other.contentWritesPausedUntil &&
        maintenanceTitle == other.maintenanceTitle &&
        maintenanceContent == other.maintenanceContent &&
        maintenanceStartsAt == other.maintenanceStartsAt &&
        maintenanceEndsAt == other.maintenanceEndsAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, registrationPausedUntil.hashCode);
    _$hash = $jc(_$hash, contentWritesPausedUntil.hashCode);
    _$hash = $jc(_$hash, maintenanceTitle.hashCode);
    _$hash = $jc(_$hash, maintenanceContent.hashCode);
    _$hash = $jc(_$hash, maintenanceStartsAt.hashCode);
    _$hash = $jc(_$hash, maintenanceEndsAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SiteOperationalSettingsResponseDto')
          ..add('id', id)
          ..add('registrationPausedUntil', registrationPausedUntil)
          ..add('contentWritesPausedUntil', contentWritesPausedUntil)
          ..add('maintenanceTitle', maintenanceTitle)
          ..add('maintenanceContent', maintenanceContent)
          ..add('maintenanceStartsAt', maintenanceStartsAt)
          ..add('maintenanceEndsAt', maintenanceEndsAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class SiteOperationalSettingsResponseDtoBuilder
    implements
        Builder<
          SiteOperationalSettingsResponseDto,
          SiteOperationalSettingsResponseDtoBuilder
        > {
  _$SiteOperationalSettingsResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

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

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  SiteOperationalSettingsResponseDtoBuilder() {
    SiteOperationalSettingsResponseDto._defaults(this);
  }

  SiteOperationalSettingsResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _registrationPausedUntil = $v.registrationPausedUntil;
      _contentWritesPausedUntil = $v.contentWritesPausedUntil;
      _maintenanceTitle = $v.maintenanceTitle;
      _maintenanceContent = $v.maintenanceContent;
      _maintenanceStartsAt = $v.maintenanceStartsAt;
      _maintenanceEndsAt = $v.maintenanceEndsAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SiteOperationalSettingsResponseDto other) {
    _$v = other as _$SiteOperationalSettingsResponseDto;
  }

  @override
  void update(
    void Function(SiteOperationalSettingsResponseDtoBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  SiteOperationalSettingsResponseDto build() => _build();

  _$SiteOperationalSettingsResponseDto _build() {
    final _$result =
        _$v ??
        _$SiteOperationalSettingsResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'SiteOperationalSettingsResponseDto',
            'id',
          ),
          registrationPausedUntil: registrationPausedUntil,
          contentWritesPausedUntil: contentWritesPausedUntil,
          maintenanceTitle: maintenanceTitle,
          maintenanceContent: maintenanceContent,
          maintenanceStartsAt: maintenanceStartsAt,
          maintenanceEndsAt: maintenanceEndsAt,
          updatedAt: BuiltValueNullFieldError.checkNotNull(
            updatedAt,
            r'SiteOperationalSettingsResponseDto',
            'updatedAt',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
