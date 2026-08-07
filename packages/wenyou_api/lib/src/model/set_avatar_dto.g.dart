// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_avatar_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SetAvatarDto extends SetAvatarDto {
  @override
  final String mediaId;

  factory _$SetAvatarDto([void Function(SetAvatarDtoBuilder)? updates]) =>
      (SetAvatarDtoBuilder()..update(updates))._build();

  _$SetAvatarDto._({required this.mediaId}) : super._();
  @override
  SetAvatarDto rebuild(void Function(SetAvatarDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SetAvatarDtoBuilder toBuilder() => SetAvatarDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SetAvatarDto && mediaId == other.mediaId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, mediaId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'SetAvatarDto',
    )..add('mediaId', mediaId)).toString();
  }
}

class SetAvatarDtoBuilder
    implements Builder<SetAvatarDto, SetAvatarDtoBuilder> {
  _$SetAvatarDto? _$v;

  String? _mediaId;
  String? get mediaId => _$this._mediaId;
  set mediaId(String? mediaId) => _$this._mediaId = mediaId;

  SetAvatarDtoBuilder() {
    SetAvatarDto._defaults(this);
  }

  SetAvatarDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _mediaId = $v.mediaId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SetAvatarDto other) {
    _$v = other as _$SetAvatarDto;
  }

  @override
  void update(void Function(SetAvatarDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SetAvatarDto build() => _build();

  _$SetAvatarDto _build() {
    final _$result =
        _$v ??
        _$SetAvatarDto._(
          mediaId: BuiltValueNullFieldError.checkNotNull(
            mediaId,
            r'SetAvatarDto',
            'mediaId',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
