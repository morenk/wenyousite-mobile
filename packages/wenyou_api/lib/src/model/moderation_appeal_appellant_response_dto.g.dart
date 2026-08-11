// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moderation_appeal_appellant_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ModerationAppealAppellantResponseDto
    extends ModerationAppealAppellantResponseDto {
  @override
  final String id;
  @override
  final String username;

  factory _$ModerationAppealAppellantResponseDto([
    void Function(ModerationAppealAppellantResponseDtoBuilder)? updates,
  ]) =>
      (ModerationAppealAppellantResponseDtoBuilder()..update(updates))._build();

  _$ModerationAppealAppellantResponseDto._({
    required this.id,
    required this.username,
  }) : super._();
  @override
  ModerationAppealAppellantResponseDto rebuild(
    void Function(ModerationAppealAppellantResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ModerationAppealAppellantResponseDtoBuilder toBuilder() =>
      ModerationAppealAppellantResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ModerationAppealAppellantResponseDto &&
        id == other.id &&
        username == other.username;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ModerationAppealAppellantResponseDto')
          ..add('id', id)
          ..add('username', username))
        .toString();
  }
}

class ModerationAppealAppellantResponseDtoBuilder
    implements
        Builder<
          ModerationAppealAppellantResponseDto,
          ModerationAppealAppellantResponseDtoBuilder
        > {
  _$ModerationAppealAppellantResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  ModerationAppealAppellantResponseDtoBuilder() {
    ModerationAppealAppellantResponseDto._defaults(this);
  }

  ModerationAppealAppellantResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _username = $v.username;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ModerationAppealAppellantResponseDto other) {
    _$v = other as _$ModerationAppealAppellantResponseDto;
  }

  @override
  void update(
    void Function(ModerationAppealAppellantResponseDtoBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  ModerationAppealAppellantResponseDto build() => _build();

  _$ModerationAppealAppellantResponseDto _build() {
    final _$result =
        _$v ??
        _$ModerationAppealAppellantResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'ModerationAppealAppellantResponseDto',
            'id',
          ),
          username: BuiltValueNullFieldError.checkNotNull(
            username,
            r'ModerationAppealAppellantResponseDto',
            'username',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
