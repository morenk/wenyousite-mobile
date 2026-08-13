// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_profile_cover_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SetProfileCoverDto extends SetProfileCoverDto {
  @override
  final String mediaId;

  factory _$SetProfileCoverDto([
    void Function(SetProfileCoverDtoBuilder)? updates,
  ]) => (SetProfileCoverDtoBuilder()..update(updates))._build();

  _$SetProfileCoverDto._({required this.mediaId}) : super._();
  @override
  SetProfileCoverDto rebuild(
    void Function(SetProfileCoverDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SetProfileCoverDtoBuilder toBuilder() =>
      SetProfileCoverDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SetProfileCoverDto && mediaId == other.mediaId;
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
      r'SetProfileCoverDto',
    )..add('mediaId', mediaId)).toString();
  }
}

class SetProfileCoverDtoBuilder
    implements Builder<SetProfileCoverDto, SetProfileCoverDtoBuilder> {
  _$SetProfileCoverDto? _$v;

  String? _mediaId;
  String? get mediaId => _$this._mediaId;
  set mediaId(String? mediaId) => _$this._mediaId = mediaId;

  SetProfileCoverDtoBuilder() {
    SetProfileCoverDto._defaults(this);
  }

  SetProfileCoverDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _mediaId = $v.mediaId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SetProfileCoverDto other) {
    _$v = other as _$SetProfileCoverDto;
  }

  @override
  void update(void Function(SetProfileCoverDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SetProfileCoverDto build() => _build();

  _$SetProfileCoverDto _build() {
    final _$result =
        _$v ??
        _$SetProfileCoverDto._(
          mediaId: BuiltValueNullFieldError.checkNotNull(
            mediaId,
            r'SetProfileCoverDto',
            'mediaId',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
