// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mobile_platform_compatibility_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MobilePlatformCompatibilityDto extends MobilePlatformCompatibilityDto {
  @override
  final num? minimumSupportedBuild;
  @override
  final num? recommendedBuild;
  @override
  final String? updateUrl;

  factory _$MobilePlatformCompatibilityDto([
    void Function(MobilePlatformCompatibilityDtoBuilder)? updates,
  ]) => (MobilePlatformCompatibilityDtoBuilder()..update(updates))._build();

  _$MobilePlatformCompatibilityDto._({
    this.minimumSupportedBuild,
    this.recommendedBuild,
    this.updateUrl,
  }) : super._();
  @override
  MobilePlatformCompatibilityDto rebuild(
    void Function(MobilePlatformCompatibilityDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MobilePlatformCompatibilityDtoBuilder toBuilder() =>
      MobilePlatformCompatibilityDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MobilePlatformCompatibilityDto &&
        minimumSupportedBuild == other.minimumSupportedBuild &&
        recommendedBuild == other.recommendedBuild &&
        updateUrl == other.updateUrl;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, minimumSupportedBuild.hashCode);
    _$hash = $jc(_$hash, recommendedBuild.hashCode);
    _$hash = $jc(_$hash, updateUrl.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MobilePlatformCompatibilityDto')
          ..add('minimumSupportedBuild', minimumSupportedBuild)
          ..add('recommendedBuild', recommendedBuild)
          ..add('updateUrl', updateUrl))
        .toString();
  }
}

class MobilePlatformCompatibilityDtoBuilder
    implements
        Builder<
          MobilePlatformCompatibilityDto,
          MobilePlatformCompatibilityDtoBuilder
        > {
  _$MobilePlatformCompatibilityDto? _$v;

  num? _minimumSupportedBuild;
  num? get minimumSupportedBuild => _$this._minimumSupportedBuild;
  set minimumSupportedBuild(num? minimumSupportedBuild) =>
      _$this._minimumSupportedBuild = minimumSupportedBuild;

  num? _recommendedBuild;
  num? get recommendedBuild => _$this._recommendedBuild;
  set recommendedBuild(num? recommendedBuild) =>
      _$this._recommendedBuild = recommendedBuild;

  String? _updateUrl;
  String? get updateUrl => _$this._updateUrl;
  set updateUrl(String? updateUrl) => _$this._updateUrl = updateUrl;

  MobilePlatformCompatibilityDtoBuilder() {
    MobilePlatformCompatibilityDto._defaults(this);
  }

  MobilePlatformCompatibilityDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _minimumSupportedBuild = $v.minimumSupportedBuild;
      _recommendedBuild = $v.recommendedBuild;
      _updateUrl = $v.updateUrl;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MobilePlatformCompatibilityDto other) {
    _$v = other as _$MobilePlatformCompatibilityDto;
  }

  @override
  void update(void Function(MobilePlatformCompatibilityDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MobilePlatformCompatibilityDto build() => _build();

  _$MobilePlatformCompatibilityDto _build() {
    final _$result =
        _$v ??
        _$MobilePlatformCompatibilityDto._(
          minimumSupportedBuild: minimumSupportedBuild,
          recommendedBuild: recommendedBuild,
          updateUrl: updateUrl,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
