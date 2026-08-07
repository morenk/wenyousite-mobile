// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mention_candidates_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MentionCandidatesResponseDto extends MentionCandidatesResponseDto {
  @override
  final BuiltList<MentionCandidateDto> users;
  @override
  final bool canMentionAllPlayers;

  factory _$MentionCandidatesResponseDto([
    void Function(MentionCandidatesResponseDtoBuilder)? updates,
  ]) => (MentionCandidatesResponseDtoBuilder()..update(updates))._build();

  _$MentionCandidatesResponseDto._({
    required this.users,
    required this.canMentionAllPlayers,
  }) : super._();
  @override
  MentionCandidatesResponseDto rebuild(
    void Function(MentionCandidatesResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MentionCandidatesResponseDtoBuilder toBuilder() =>
      MentionCandidatesResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MentionCandidatesResponseDto &&
        users == other.users &&
        canMentionAllPlayers == other.canMentionAllPlayers;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, users.hashCode);
    _$hash = $jc(_$hash, canMentionAllPlayers.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MentionCandidatesResponseDto')
          ..add('users', users)
          ..add('canMentionAllPlayers', canMentionAllPlayers))
        .toString();
  }
}

class MentionCandidatesResponseDtoBuilder
    implements
        Builder<
          MentionCandidatesResponseDto,
          MentionCandidatesResponseDtoBuilder
        > {
  _$MentionCandidatesResponseDto? _$v;

  ListBuilder<MentionCandidateDto>? _users;
  ListBuilder<MentionCandidateDto> get users =>
      _$this._users ??= ListBuilder<MentionCandidateDto>();
  set users(ListBuilder<MentionCandidateDto>? users) => _$this._users = users;

  bool? _canMentionAllPlayers;
  bool? get canMentionAllPlayers => _$this._canMentionAllPlayers;
  set canMentionAllPlayers(bool? canMentionAllPlayers) =>
      _$this._canMentionAllPlayers = canMentionAllPlayers;

  MentionCandidatesResponseDtoBuilder() {
    MentionCandidatesResponseDto._defaults(this);
  }

  MentionCandidatesResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _users = $v.users.toBuilder();
      _canMentionAllPlayers = $v.canMentionAllPlayers;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MentionCandidatesResponseDto other) {
    _$v = other as _$MentionCandidatesResponseDto;
  }

  @override
  void update(void Function(MentionCandidatesResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MentionCandidatesResponseDto build() => _build();

  _$MentionCandidatesResponseDto _build() {
    _$MentionCandidatesResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$MentionCandidatesResponseDto._(
            users: users.build(),
            canMentionAllPlayers: BuiltValueNullFieldError.checkNotNull(
              canMentionAllPlayers,
              r'MentionCandidatesResponseDto',
              'canMentionAllPlayers',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'users';
        users.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'MentionCandidatesResponseDto',
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
