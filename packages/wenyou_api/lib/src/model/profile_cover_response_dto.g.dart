// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_cover_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProfileCoverResponseDto extends ProfileCoverResponseDto {
  @override
  final String url;
  @override
  final String? mediumUrl;
  @override
  final num? width;
  @override
  final num? height;

  factory _$ProfileCoverResponseDto([
    void Function(ProfileCoverResponseDtoBuilder)? updates,
  ]) => (ProfileCoverResponseDtoBuilder()..update(updates))._build();

  _$ProfileCoverResponseDto._({
    required this.url,
    this.mediumUrl,
    this.width,
    this.height,
  }) : super._();
  @override
  ProfileCoverResponseDto rebuild(
    void Function(ProfileCoverResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ProfileCoverResponseDtoBuilder toBuilder() =>
      ProfileCoverResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProfileCoverResponseDto &&
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
    return (newBuiltValueToStringHelper(r'ProfileCoverResponseDto')
          ..add('url', url)
          ..add('mediumUrl', mediumUrl)
          ..add('width', width)
          ..add('height', height))
        .toString();
  }
}

class ProfileCoverResponseDtoBuilder
    implements
        Builder<ProfileCoverResponseDto, ProfileCoverResponseDtoBuilder> {
  _$ProfileCoverResponseDto? _$v;

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

  ProfileCoverResponseDtoBuilder() {
    ProfileCoverResponseDto._defaults(this);
  }

  ProfileCoverResponseDtoBuilder get _$this {
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
  void replace(ProfileCoverResponseDto other) {
    _$v = other as _$ProfileCoverResponseDto;
  }

  @override
  void update(void Function(ProfileCoverResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProfileCoverResponseDto build() => _build();

  _$ProfileCoverResponseDto _build() {
    final _$result =
        _$v ??
        _$ProfileCoverResponseDto._(
          url: BuiltValueNullFieldError.checkNotNull(
            url,
            r'ProfileCoverResponseDto',
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
