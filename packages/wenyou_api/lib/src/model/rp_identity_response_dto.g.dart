// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rp_identity_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RpIdentityResponseDto extends RpIdentityResponseDto {
  @override
  final String id;
  @override
  final String nickname;
  @override
  final String? avatar;
  @override
  final MediaDisplayResponseDto? avatarDisplay;

  factory _$RpIdentityResponseDto([
    void Function(RpIdentityResponseDtoBuilder)? updates,
  ]) => (RpIdentityResponseDtoBuilder()..update(updates))._build();

  _$RpIdentityResponseDto._({
    required this.id,
    required this.nickname,
    this.avatar,
    this.avatarDisplay,
  }) : super._();
  @override
  RpIdentityResponseDto rebuild(
    void Function(RpIdentityResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  RpIdentityResponseDtoBuilder toBuilder() =>
      RpIdentityResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RpIdentityResponseDto &&
        id == other.id &&
        nickname == other.nickname &&
        avatar == other.avatar &&
        avatarDisplay == other.avatarDisplay;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, nickname.hashCode);
    _$hash = $jc(_$hash, avatar.hashCode);
    _$hash = $jc(_$hash, avatarDisplay.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RpIdentityResponseDto')
          ..add('id', id)
          ..add('nickname', nickname)
          ..add('avatar', avatar)
          ..add('avatarDisplay', avatarDisplay))
        .toString();
  }
}

class RpIdentityResponseDtoBuilder
    implements Builder<RpIdentityResponseDto, RpIdentityResponseDtoBuilder> {
  _$RpIdentityResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _nickname;
  String? get nickname => _$this._nickname;
  set nickname(String? nickname) => _$this._nickname = nickname;

  String? _avatar;
  String? get avatar => _$this._avatar;
  set avatar(String? avatar) => _$this._avatar = avatar;

  MediaDisplayResponseDtoBuilder? _avatarDisplay;
  MediaDisplayResponseDtoBuilder get avatarDisplay =>
      _$this._avatarDisplay ??= MediaDisplayResponseDtoBuilder();
  set avatarDisplay(MediaDisplayResponseDtoBuilder? avatarDisplay) =>
      _$this._avatarDisplay = avatarDisplay;

  RpIdentityResponseDtoBuilder() {
    RpIdentityResponseDto._defaults(this);
  }

  RpIdentityResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _nickname = $v.nickname;
      _avatar = $v.avatar;
      _avatarDisplay = $v.avatarDisplay?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RpIdentityResponseDto other) {
    _$v = other as _$RpIdentityResponseDto;
  }

  @override
  void update(void Function(RpIdentityResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RpIdentityResponseDto build() => _build();

  _$RpIdentityResponseDto _build() {
    _$RpIdentityResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$RpIdentityResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'RpIdentityResponseDto',
              'id',
            ),
            nickname: BuiltValueNullFieldError.checkNotNull(
              nickname,
              r'RpIdentityResponseDto',
              'nickname',
            ),
            avatar: avatar,
            avatarDisplay: _avatarDisplay?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'avatarDisplay';
        _avatarDisplay?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'RpIdentityResponseDto',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
