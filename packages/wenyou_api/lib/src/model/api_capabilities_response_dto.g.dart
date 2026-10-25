// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_capabilities_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ApiCapabilitiesResponseDto extends ApiCapabilitiesResponseDto {
  @override
  final bool? textFontV2Supported;
  @override
  final bool? textFontV2WriteEnabled;
  @override
  final bool? textFontV1Supported;
  @override
  final bool? textFontV1WriteEnabled;
  @override
  final bool? textColorV1Supported;
  @override
  final bool? textColorV1WriteEnabled;
  @override
  final bool? rpIdentityProfileSupported;
  @override
  final bool? roleMentionsV6Supported;
  @override
  final bool? roleMentionsV6WriteEnabled;
  @override
  final bool stickers;
  @override
  final bool directMessages;
  @override
  final bool pushNotifications;

  factory _$ApiCapabilitiesResponseDto([
    void Function(ApiCapabilitiesResponseDtoBuilder)? updates,
  ]) => (ApiCapabilitiesResponseDtoBuilder()..update(updates))._build();

  _$ApiCapabilitiesResponseDto._({
    this.textFontV2Supported,
    this.textFontV2WriteEnabled,
    this.textFontV1Supported,
    this.textFontV1WriteEnabled,
    this.textColorV1Supported,
    this.textColorV1WriteEnabled,
    this.rpIdentityProfileSupported,
    this.roleMentionsV6Supported,
    this.roleMentionsV6WriteEnabled,
    required this.stickers,
    required this.directMessages,
    required this.pushNotifications,
  }) : super._();
  @override
  ApiCapabilitiesResponseDto rebuild(
    void Function(ApiCapabilitiesResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ApiCapabilitiesResponseDtoBuilder toBuilder() =>
      ApiCapabilitiesResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ApiCapabilitiesResponseDto &&
        textFontV2Supported == other.textFontV2Supported &&
        textFontV2WriteEnabled == other.textFontV2WriteEnabled &&
        textFontV1Supported == other.textFontV1Supported &&
        textFontV1WriteEnabled == other.textFontV1WriteEnabled &&
        textColorV1Supported == other.textColorV1Supported &&
        textColorV1WriteEnabled == other.textColorV1WriteEnabled &&
        rpIdentityProfileSupported == other.rpIdentityProfileSupported &&
        roleMentionsV6Supported == other.roleMentionsV6Supported &&
        roleMentionsV6WriteEnabled == other.roleMentionsV6WriteEnabled &&
        stickers == other.stickers &&
        directMessages == other.directMessages &&
        pushNotifications == other.pushNotifications;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, textFontV2Supported.hashCode);
    _$hash = $jc(_$hash, textFontV2WriteEnabled.hashCode);
    _$hash = $jc(_$hash, textFontV1Supported.hashCode);
    _$hash = $jc(_$hash, textFontV1WriteEnabled.hashCode);
    _$hash = $jc(_$hash, textColorV1Supported.hashCode);
    _$hash = $jc(_$hash, textColorV1WriteEnabled.hashCode);
    _$hash = $jc(_$hash, rpIdentityProfileSupported.hashCode);
    _$hash = $jc(_$hash, roleMentionsV6Supported.hashCode);
    _$hash = $jc(_$hash, roleMentionsV6WriteEnabled.hashCode);
    _$hash = $jc(_$hash, stickers.hashCode);
    _$hash = $jc(_$hash, directMessages.hashCode);
    _$hash = $jc(_$hash, pushNotifications.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ApiCapabilitiesResponseDto')
          ..add('textFontV2Supported', textFontV2Supported)
          ..add('textFontV2WriteEnabled', textFontV2WriteEnabled)
          ..add('textFontV1Supported', textFontV1Supported)
          ..add('textFontV1WriteEnabled', textFontV1WriteEnabled)
          ..add('textColorV1Supported', textColorV1Supported)
          ..add('textColorV1WriteEnabled', textColorV1WriteEnabled)
          ..add('rpIdentityProfileSupported', rpIdentityProfileSupported)
          ..add('roleMentionsV6Supported', roleMentionsV6Supported)
          ..add('roleMentionsV6WriteEnabled', roleMentionsV6WriteEnabled)
          ..add('stickers', stickers)
          ..add('directMessages', directMessages)
          ..add('pushNotifications', pushNotifications))
        .toString();
  }
}

class ApiCapabilitiesResponseDtoBuilder
    implements
        Builder<ApiCapabilitiesResponseDto, ApiCapabilitiesResponseDtoBuilder> {
  _$ApiCapabilitiesResponseDto? _$v;

  bool? _textFontV2Supported;
  bool? get textFontV2Supported => _$this._textFontV2Supported;
  set textFontV2Supported(bool? textFontV2Supported) =>
      _$this._textFontV2Supported = textFontV2Supported;

  bool? _textFontV2WriteEnabled;
  bool? get textFontV2WriteEnabled => _$this._textFontV2WriteEnabled;
  set textFontV2WriteEnabled(bool? textFontV2WriteEnabled) =>
      _$this._textFontV2WriteEnabled = textFontV2WriteEnabled;

  bool? _textFontV1Supported;
  bool? get textFontV1Supported => _$this._textFontV1Supported;
  set textFontV1Supported(bool? textFontV1Supported) =>
      _$this._textFontV1Supported = textFontV1Supported;

  bool? _textFontV1WriteEnabled;
  bool? get textFontV1WriteEnabled => _$this._textFontV1WriteEnabled;
  set textFontV1WriteEnabled(bool? textFontV1WriteEnabled) =>
      _$this._textFontV1WriteEnabled = textFontV1WriteEnabled;

  bool? _textColorV1Supported;
  bool? get textColorV1Supported => _$this._textColorV1Supported;
  set textColorV1Supported(bool? textColorV1Supported) =>
      _$this._textColorV1Supported = textColorV1Supported;

  bool? _textColorV1WriteEnabled;
  bool? get textColorV1WriteEnabled => _$this._textColorV1WriteEnabled;
  set textColorV1WriteEnabled(bool? textColorV1WriteEnabled) =>
      _$this._textColorV1WriteEnabled = textColorV1WriteEnabled;

  bool? _rpIdentityProfileSupported;
  bool? get rpIdentityProfileSupported => _$this._rpIdentityProfileSupported;
  set rpIdentityProfileSupported(bool? rpIdentityProfileSupported) =>
      _$this._rpIdentityProfileSupported = rpIdentityProfileSupported;

  bool? _roleMentionsV6Supported;
  bool? get roleMentionsV6Supported => _$this._roleMentionsV6Supported;
  set roleMentionsV6Supported(bool? roleMentionsV6Supported) =>
      _$this._roleMentionsV6Supported = roleMentionsV6Supported;

  bool? _roleMentionsV6WriteEnabled;
  bool? get roleMentionsV6WriteEnabled => _$this._roleMentionsV6WriteEnabled;
  set roleMentionsV6WriteEnabled(bool? roleMentionsV6WriteEnabled) =>
      _$this._roleMentionsV6WriteEnabled = roleMentionsV6WriteEnabled;

  bool? _stickers;
  bool? get stickers => _$this._stickers;
  set stickers(bool? stickers) => _$this._stickers = stickers;

  bool? _directMessages;
  bool? get directMessages => _$this._directMessages;
  set directMessages(bool? directMessages) =>
      _$this._directMessages = directMessages;

  bool? _pushNotifications;
  bool? get pushNotifications => _$this._pushNotifications;
  set pushNotifications(bool? pushNotifications) =>
      _$this._pushNotifications = pushNotifications;

  ApiCapabilitiesResponseDtoBuilder() {
    ApiCapabilitiesResponseDto._defaults(this);
  }

  ApiCapabilitiesResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _textFontV2Supported = $v.textFontV2Supported;
      _textFontV2WriteEnabled = $v.textFontV2WriteEnabled;
      _textFontV1Supported = $v.textFontV1Supported;
      _textFontV1WriteEnabled = $v.textFontV1WriteEnabled;
      _textColorV1Supported = $v.textColorV1Supported;
      _textColorV1WriteEnabled = $v.textColorV1WriteEnabled;
      _rpIdentityProfileSupported = $v.rpIdentityProfileSupported;
      _roleMentionsV6Supported = $v.roleMentionsV6Supported;
      _roleMentionsV6WriteEnabled = $v.roleMentionsV6WriteEnabled;
      _stickers = $v.stickers;
      _directMessages = $v.directMessages;
      _pushNotifications = $v.pushNotifications;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ApiCapabilitiesResponseDto other) {
    _$v = other as _$ApiCapabilitiesResponseDto;
  }

  @override
  void update(void Function(ApiCapabilitiesResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ApiCapabilitiesResponseDto build() => _build();

  _$ApiCapabilitiesResponseDto _build() {
    final _$result =
        _$v ??
        _$ApiCapabilitiesResponseDto._(
          textFontV2Supported: textFontV2Supported,
          textFontV2WriteEnabled: textFontV2WriteEnabled,
          textFontV1Supported: textFontV1Supported,
          textFontV1WriteEnabled: textFontV1WriteEnabled,
          textColorV1Supported: textColorV1Supported,
          textColorV1WriteEnabled: textColorV1WriteEnabled,
          rpIdentityProfileSupported: rpIdentityProfileSupported,
          roleMentionsV6Supported: roleMentionsV6Supported,
          roleMentionsV6WriteEnabled: roleMentionsV6WriteEnabled,
          stickers: BuiltValueNullFieldError.checkNotNull(
            stickers,
            r'ApiCapabilitiesResponseDto',
            'stickers',
          ),
          directMessages: BuiltValueNullFieldError.checkNotNull(
            directMessages,
            r'ApiCapabilitiesResponseDto',
            'directMessages',
          ),
          pushNotifications: BuiltValueNullFieldError.checkNotNull(
            pushNotifications,
            r'ApiCapabilitiesResponseDto',
            'pushNotifications',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
