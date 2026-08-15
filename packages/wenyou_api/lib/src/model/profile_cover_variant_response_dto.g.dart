// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_cover_variant_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProfileCoverVariantResponseDto extends ProfileCoverVariantResponseDto {
  @override
  final String url;
  @override
  final String? mediumUrl;
  @override
  final num? width;
  @override
  final num? height;

  factory _$ProfileCoverVariantResponseDto([
    void Function(ProfileCoverVariantResponseDtoBuilder)? updates,
  ]) => (ProfileCoverVariantResponseDtoBuilder()..update(updates))._build();

  _$ProfileCoverVariantResponseDto._({
    required this.url,
    this.mediumUrl,
    this.width,
    this.height,
  }) : super._();
  @override
  ProfileCoverVariantResponseDto rebuild(
    void Function(ProfileCoverVariantResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ProfileCoverVariantResponseDtoBuilder toBuilder() =>
      ProfileCoverVariantResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProfileCoverVariantResponseDto &&
        url == other.url &&
        mediumUrl == other.mediumUrl &&
        width == other.width &&
        height == other.height;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jc(_$hash, mediumUrl.hashCode);
    _$hash = $jc(_$hash, width.hashCode);
    _$hash = $jc(_$hash, height.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProfileCoverVariantResponseDto')
          ..add('url', url)
          ..add('mediumUrl', mediumUrl)
          ..add('width', width)
          ..add('height', height))
        .toString();
  }
}

class ProfileCoverVariantResponseDtoBuilder
    implements
        Builder<
          ProfileCoverVariantResponseDto,
          ProfileCoverVariantResponseDtoBuilder
        > {
  _$ProfileCoverVariantResponseDto? _$v;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  String? _mediumUrl;
  String? get mediumUrl => _$this._mediumUrl;
  set mediumUrl(String? mediumUrl) => _$this._mediumUrl = mediumUrl;

  num? _width;
  num? get width => _$this._width;
  set width(num? width) => _$this._width = width;

  num? _height;
  num? get height => _$this._height;
  set height(num? height) => _$this._height = height;

  ProfileCoverVariantResponseDtoBuilder() {
    ProfileCoverVariantResponseDto._defaults(this);
  }

  ProfileCoverVariantResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _url = $v.url;
      _mediumUrl = $v.mediumUrl;
      _width = $v.width;
      _height = $v.height;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProfileCoverVariantResponseDto other) {
    _$v = other as _$ProfileCoverVariantResponseDto;
  }

  @override
  void update(void Function(ProfileCoverVariantResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProfileCoverVariantResponseDto build() => _build();

  _$ProfileCoverVariantResponseDto _build() {
    final _$result =
        _$v ??
        _$ProfileCoverVariantResponseDto._(
          url: BuiltValueNullFieldError.checkNotNull(
            url,
            r'ProfileCoverVariantResponseDto',
            'url',
          ),
          mediumUrl: mediumUrl,
          width: width,
          height: height,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
