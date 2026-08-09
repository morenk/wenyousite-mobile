// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moment_root_comment_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MomentRootCommentResponseDto extends MomentRootCommentResponseDto {
  @override
  final String id;
  @override
  final String momentId;
  @override
  final PostAuthorResponseDto author;
  @override
  final String? content;
  @override
  final MomentMediaResponseDto? media;
  @override
  final MomentStickerResponseDto? sticker;
  @override
  final String? parentCommentId;
  @override
  final MomentReplyTargetResponseDto? replyToComment;
  @override
  final bool deleted;
  @override
  final bool canDelete;
  @override
  final DateTime createdAt;
  @override
  final num replyCount;
  @override
  final BuiltList<MomentCommentResponseDto> replies;

  factory _$MomentRootCommentResponseDto([
    void Function(MomentRootCommentResponseDtoBuilder)? updates,
  ]) => (MomentRootCommentResponseDtoBuilder()..update(updates))._build();

  _$MomentRootCommentResponseDto._({
    required this.id,
    required this.momentId,
    required this.author,
    this.content,
    this.media,
    this.sticker,
    this.parentCommentId,
    this.replyToComment,
    required this.deleted,
    required this.canDelete,
    required this.createdAt,
    required this.replyCount,
    required this.replies,
  }) : super._();
  @override
  MomentRootCommentResponseDto rebuild(
    void Function(MomentRootCommentResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MomentRootCommentResponseDtoBuilder toBuilder() =>
      MomentRootCommentResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentRootCommentResponseDto &&
        id == other.id &&
        momentId == other.momentId &&
        author == other.author &&
        content == other.content &&
        media == other.media &&
        sticker == other.sticker &&
        parentCommentId == other.parentCommentId &&
        replyToComment == other.replyToComment &&
        deleted == other.deleted &&
        canDelete == other.canDelete &&
        createdAt == other.createdAt &&
        replyCount == other.replyCount &&
        replies == other.replies;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, momentId.hashCode);
    _$hash = $jc(_$hash, author.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, media.hashCode);
    _$hash = $jc(_$hash, sticker.hashCode);
    _$hash = $jc(_$hash, parentCommentId.hashCode);
    _$hash = $jc(_$hash, replyToComment.hashCode);
    _$hash = $jc(_$hash, deleted.hashCode);
    _$hash = $jc(_$hash, canDelete.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, replyCount.hashCode);
    _$hash = $jc(_$hash, replies.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MomentRootCommentResponseDto')
          ..add('id', id)
          ..add('momentId', momentId)
          ..add('author', author)
          ..add('content', content)
          ..add('media', media)
          ..add('sticker', sticker)
          ..add('parentCommentId', parentCommentId)
          ..add('replyToComment', replyToComment)
          ..add('deleted', deleted)
          ..add('canDelete', canDelete)
          ..add('createdAt', createdAt)
          ..add('replyCount', replyCount)
          ..add('replies', replies))
        .toString();
  }
}

class MomentRootCommentResponseDtoBuilder
    implements
        Builder<
          MomentRootCommentResponseDto,
          MomentRootCommentResponseDtoBuilder
        > {
  _$MomentRootCommentResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _momentId;
  String? get momentId => _$this._momentId;
  set momentId(String? momentId) => _$this._momentId = momentId;

  PostAuthorResponseDtoBuilder? _author;
  PostAuthorResponseDtoBuilder get author =>
      _$this._author ??= PostAuthorResponseDtoBuilder();
  set author(PostAuthorResponseDtoBuilder? author) => _$this._author = author;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  MomentMediaResponseDtoBuilder? _media;
  MomentMediaResponseDtoBuilder get media =>
      _$this._media ??= MomentMediaResponseDtoBuilder();
  set media(MomentMediaResponseDtoBuilder? media) => _$this._media = media;

  MomentStickerResponseDtoBuilder? _sticker;
  MomentStickerResponseDtoBuilder get sticker =>
      _$this._sticker ??= MomentStickerResponseDtoBuilder();
  set sticker(MomentStickerResponseDtoBuilder? sticker) =>
      _$this._sticker = sticker;

  String? _parentCommentId;
  String? get parentCommentId => _$this._parentCommentId;
  set parentCommentId(String? parentCommentId) =>
      _$this._parentCommentId = parentCommentId;

  MomentReplyTargetResponseDtoBuilder? _replyToComment;
  MomentReplyTargetResponseDtoBuilder get replyToComment =>
      _$this._replyToComment ??= MomentReplyTargetResponseDtoBuilder();
  set replyToComment(MomentReplyTargetResponseDtoBuilder? replyToComment) =>
      _$this._replyToComment = replyToComment;

  bool? _deleted;
  bool? get deleted => _$this._deleted;
  set deleted(bool? deleted) => _$this._deleted = deleted;

  bool? _canDelete;
  bool? get canDelete => _$this._canDelete;
  set canDelete(bool? canDelete) => _$this._canDelete = canDelete;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  num? _replyCount;
  num? get replyCount => _$this._replyCount;
  set replyCount(num? replyCount) => _$this._replyCount = replyCount;

  ListBuilder<MomentCommentResponseDto>? _replies;
  ListBuilder<MomentCommentResponseDto> get replies =>
      _$this._replies ??= ListBuilder<MomentCommentResponseDto>();
  set replies(ListBuilder<MomentCommentResponseDto>? replies) =>
      _$this._replies = replies;

  MomentRootCommentResponseDtoBuilder() {
    MomentRootCommentResponseDto._defaults(this);
  }

  MomentRootCommentResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _momentId = $v.momentId;
      _author = $v.author.toBuilder();
      _content = $v.content;
      _media = $v.media?.toBuilder();
      _sticker = $v.sticker?.toBuilder();
      _parentCommentId = $v.parentCommentId;
      _replyToComment = $v.replyToComment?.toBuilder();
      _deleted = $v.deleted;
      _canDelete = $v.canDelete;
      _createdAt = $v.createdAt;
      _replyCount = $v.replyCount;
      _replies = $v.replies.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MomentRootCommentResponseDto other) {
    _$v = other as _$MomentRootCommentResponseDto;
  }

  @override
  void update(void Function(MomentRootCommentResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MomentRootCommentResponseDto build() => _build();

  _$MomentRootCommentResponseDto _build() {
    _$MomentRootCommentResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$MomentRootCommentResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'MomentRootCommentResponseDto',
              'id',
            ),
            momentId: BuiltValueNullFieldError.checkNotNull(
              momentId,
              r'MomentRootCommentResponseDto',
              'momentId',
            ),
            author: author.build(),
            content: content,
            media: _media?.build(),
            sticker: _sticker?.build(),
            parentCommentId: parentCommentId,
            replyToComment: _replyToComment?.build(),
            deleted: BuiltValueNullFieldError.checkNotNull(
              deleted,
              r'MomentRootCommentResponseDto',
              'deleted',
            ),
            canDelete: BuiltValueNullFieldError.checkNotNull(
              canDelete,
              r'MomentRootCommentResponseDto',
              'canDelete',
            ),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'MomentRootCommentResponseDto',
              'createdAt',
            ),
            replyCount: BuiltValueNullFieldError.checkNotNull(
              replyCount,
              r'MomentRootCommentResponseDto',
              'replyCount',
            ),
            replies: replies.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'author';
        author.build();

        _$failedField = 'media';
        _media?.build();
        _$failedField = 'sticker';
        _sticker?.build();

        _$failedField = 'replyToComment';
        _replyToComment?.build();

        _$failedField = 'replies';
        replies.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'MomentRootCommentResponseDto',
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
