// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_follow_record_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserFollowRecordResponseDto extends UserFollowRecordResponseDto {
  @override
  final String id;
  @override
  final String followerId;
  @override
  final String followingId;
  @override
  final DateTime createdAt;
  @override
  final PostAuthorResponseDto? following;
  @override
  final PostAuthorResponseDto? follower;

  factory _$UserFollowRecordResponseDto([
    void Function(UserFollowRecordResponseDtoBuilder)? updates,
  ]) => (UserFollowRecordResponseDtoBuilder()..update(updates))._build();

  _$UserFollowRecordResponseDto._({
    required this.id,
    required this.followerId,
    required this.followingId,
    required this.createdAt,
    this.following,
    this.follower,
  }) : super._();
  @override
  UserFollowRecordResponseDto rebuild(
    void Function(UserFollowRecordResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UserFollowRecordResponseDtoBuilder toBuilder() =>
      UserFollowRecordResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserFollowRecordResponseDto &&
        id == other.id &&
        followerId == other.followerId &&
        followingId == other.followingId &&
        createdAt == other.createdAt &&
        following == other.following &&
        follower == other.follower;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, followerId.hashCode);
    _$hash = $jc(_$hash, followingId.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, following.hashCode);
    _$hash = $jc(_$hash, follower.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserFollowRecordResponseDto')
          ..add('id', id)
          ..add('followerId', followerId)
          ..add('followingId', followingId)
          ..add('createdAt', createdAt)
          ..add('following', following)
          ..add('follower', follower))
        .toString();
  }
}

class UserFollowRecordResponseDtoBuilder
    implements
        Builder<
          UserFollowRecordResponseDto,
          UserFollowRecordResponseDtoBuilder
        > {
  _$UserFollowRecordResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _followerId;
  String? get followerId => _$this._followerId;
  set followerId(String? followerId) => _$this._followerId = followerId;

  String? _followingId;
  String? get followingId => _$this._followingId;
  set followingId(String? followingId) => _$this._followingId = followingId;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  PostAuthorResponseDtoBuilder? _following;
  PostAuthorResponseDtoBuilder get following =>
      _$this._following ??= PostAuthorResponseDtoBuilder();
  set following(PostAuthorResponseDtoBuilder? following) =>
      _$this._following = following;

  PostAuthorResponseDtoBuilder? _follower;
  PostAuthorResponseDtoBuilder get follower =>
      _$this._follower ??= PostAuthorResponseDtoBuilder();
  set follower(PostAuthorResponseDtoBuilder? follower) =>
      _$this._follower = follower;

  UserFollowRecordResponseDtoBuilder() {
    UserFollowRecordResponseDto._defaults(this);
  }

  UserFollowRecordResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _followerId = $v.followerId;
      _followingId = $v.followingId;
      _createdAt = $v.createdAt;
      _following = $v.following?.toBuilder();
      _follower = $v.follower?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserFollowRecordResponseDto other) {
    _$v = other as _$UserFollowRecordResponseDto;
  }

  @override
  void update(void Function(UserFollowRecordResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserFollowRecordResponseDto build() => _build();

  _$UserFollowRecordResponseDto _build() {
    _$UserFollowRecordResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$UserFollowRecordResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'UserFollowRecordResponseDto',
              'id',
            ),
            followerId: BuiltValueNullFieldError.checkNotNull(
              followerId,
              r'UserFollowRecordResponseDto',
              'followerId',
            ),
            followingId: BuiltValueNullFieldError.checkNotNull(
              followingId,
              r'UserFollowRecordResponseDto',
              'followingId',
            ),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'UserFollowRecordResponseDto',
              'createdAt',
            ),
            following: _following?.build(),
            follower: _follower?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'following';
        _following?.build();
        _$failedField = 'follower';
        _follower?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'UserFollowRecordResponseDto',
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
