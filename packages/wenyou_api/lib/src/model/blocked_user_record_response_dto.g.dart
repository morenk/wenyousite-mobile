// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blocked_user_record_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BlockedUserRecordResponseDto extends BlockedUserRecordResponseDto {
  @override
  final String id;
  @override
  final String blockerId;
  @override
  final String blockedId;
  @override
  final DateTime createdAt;
  @override
  final PostAuthorResponseDto blocked;

  factory _$BlockedUserRecordResponseDto([
    void Function(BlockedUserRecordResponseDtoBuilder)? updates,
  ]) => (BlockedUserRecordResponseDtoBuilder()..update(updates))._build();

  _$BlockedUserRecordResponseDto._({
    required this.id,
    required this.blockerId,
    required this.blockedId,
    required this.createdAt,
    required this.blocked,
  }) : super._();
  @override
  BlockedUserRecordResponseDto rebuild(
    void Function(BlockedUserRecordResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  BlockedUserRecordResponseDtoBuilder toBuilder() =>
      BlockedUserRecordResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BlockedUserRecordResponseDto &&
        id == other.id &&
        blockerId == other.blockerId &&
        blockedId == other.blockedId &&
        createdAt == other.createdAt &&
        blocked == other.blocked;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, blockerId.hashCode);
    _$hash = $jc(_$hash, blockedId.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, blocked.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BlockedUserRecordResponseDto')
          ..add('id', id)
          ..add('blockerId', blockerId)
          ..add('blockedId', blockedId)
          ..add('createdAt', createdAt)
          ..add('blocked', blocked))
        .toString();
  }
}

class BlockedUserRecordResponseDtoBuilder
    implements
        Builder<
          BlockedUserRecordResponseDto,
          BlockedUserRecordResponseDtoBuilder
        > {
  _$BlockedUserRecordResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _blockerId;
  String? get blockerId => _$this._blockerId;
  set blockerId(String? blockerId) => _$this._blockerId = blockerId;

  String? _blockedId;
  String? get blockedId => _$this._blockedId;
  set blockedId(String? blockedId) => _$this._blockedId = blockedId;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  PostAuthorResponseDtoBuilder? _blocked;
  PostAuthorResponseDtoBuilder get blocked =>
      _$this._blocked ??= PostAuthorResponseDtoBuilder();
  set blocked(PostAuthorResponseDtoBuilder? blocked) =>
      _$this._blocked = blocked;

  BlockedUserRecordResponseDtoBuilder() {
    BlockedUserRecordResponseDto._defaults(this);
  }

  BlockedUserRecordResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _blockerId = $v.blockerId;
      _blockedId = $v.blockedId;
      _createdAt = $v.createdAt;
      _blocked = $v.blocked.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BlockedUserRecordResponseDto other) {
    _$v = other as _$BlockedUserRecordResponseDto;
  }

  @override
  void update(void Function(BlockedUserRecordResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BlockedUserRecordResponseDto build() => _build();

  _$BlockedUserRecordResponseDto _build() {
    _$BlockedUserRecordResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$BlockedUserRecordResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'BlockedUserRecordResponseDto',
              'id',
            ),
            blockerId: BuiltValueNullFieldError.checkNotNull(
              blockerId,
              r'BlockedUserRecordResponseDto',
              'blockerId',
            ),
            blockedId: BuiltValueNullFieldError.checkNotNull(
              blockedId,
              r'BlockedUserRecordResponseDto',
              'blockedId',
            ),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'BlockedUserRecordResponseDto',
              'createdAt',
            ),
            blocked: blocked.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'blocked';
        blocked.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'BlockedUserRecordResponseDto',
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
