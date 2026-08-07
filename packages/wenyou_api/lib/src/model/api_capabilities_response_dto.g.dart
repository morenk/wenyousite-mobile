// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_capabilities_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ApiCapabilitiesResponseDto extends ApiCapabilitiesResponseDto {
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
        stickers == other.stickers &&
        directMessages == other.directMessages &&
        pushNotifications == other.pushNotifications;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, stickers.hashCode);
    _$hash = $jc(_$hash, directMessages.hashCode);
    _$hash = $jc(_$hash, pushNotifications.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ApiCapabilitiesResponseDto')
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
