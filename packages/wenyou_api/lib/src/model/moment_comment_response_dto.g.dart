// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moment_comment_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MomentCommentResponseDto extends MomentCommentResponseDto {
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

  factory _$MomentCommentResponseDto([
    void Function(MomentCommentResponseDtoBuilder)? updates,
  ]) => (MomentCommentResponseDtoBuilder()..update(updates))._build();

  _$MomentCommentResponseDto._({
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
  }) : super._();
  @override
  MomentCommentResponseDto rebuild(
    void Function(MomentCommentResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MomentCommentResponseDtoBuilder toBuilder() =>
      MomentCommentResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentCommentResponseDto &&
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
        createdAt == other.createdAt;
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
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MomentCommentResponseDto')
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
          ..add('createdAt', createdAt))
        .toString();
  }
}

class MomentCommentResponseDtoBuilder
    implements
        Builder<MomentCommentResponseDto, MomentCommentResponseDtoBuilder> {
  _$MomentCommentResponseDto? _$v;

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

  MomentCommentResponseDtoBuilder() {
    MomentCommentResponseDto._defaults(this);
  }

  MomentCommentResponseDtoBuilder get _$this {
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
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MomentCommentResponseDto other) {
    _$v = other as _$MomentCommentResponseDto;
  }

  @override
  void update(void Function(MomentCommentResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MomentCommentResponseDto build() => _build();

  _$MomentCommentResponseDto _build() {
    _$MomentCommentResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$MomentCommentResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'MomentCommentResponseDto',
              'id',
            ),
            momentId: BuiltValueNullFieldError.checkNotNull(
              momentId,
              r'MomentCommentResponseDto',
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
              r'MomentCommentResponseDto',
              'deleted',
            ),
            canDelete: BuiltValueNullFieldError.checkNotNull(
              canDelete,
              r'MomentCommentResponseDto',
              'canDelete',
            ),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'MomentCommentResponseDto',
              'createdAt',
            ),
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
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'MomentCommentResponseDto',
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
