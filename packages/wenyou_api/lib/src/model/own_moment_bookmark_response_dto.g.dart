// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'own_moment_bookmark_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OwnMomentBookmarkResponseDtoCoverTypeEnum
_$ownMomentBookmarkResponseDtoCoverTypeEnum_IMAGE =
    const OwnMomentBookmarkResponseDtoCoverTypeEnum._('IMAGE');
const OwnMomentBookmarkResponseDtoCoverTypeEnum
_$ownMomentBookmarkResponseDtoCoverTypeEnum_TEXT =
    const OwnMomentBookmarkResponseDtoCoverTypeEnum._('TEXT');
const OwnMomentBookmarkResponseDtoCoverTypeEnum
_$ownMomentBookmarkResponseDtoCoverTypeEnum_unknownDefaultOpenApi =
    const OwnMomentBookmarkResponseDtoCoverTypeEnum._('unknownDefaultOpenApi');

OwnMomentBookmarkResponseDtoCoverTypeEnum
_$ownMomentBookmarkResponseDtoCoverTypeEnumValueOf(String name) {
  switch (name) {
    case 'IMAGE':
      return _$ownMomentBookmarkResponseDtoCoverTypeEnum_IMAGE;
    case 'TEXT':
      return _$ownMomentBookmarkResponseDtoCoverTypeEnum_TEXT;
    case 'unknownDefaultOpenApi':
      return _$ownMomentBookmarkResponseDtoCoverTypeEnum_unknownDefaultOpenApi;
    default:
      return _$ownMomentBookmarkResponseDtoCoverTypeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<OwnMomentBookmarkResponseDtoCoverTypeEnum>
_$ownMomentBookmarkResponseDtoCoverTypeEnumValues =
    BuiltSet<OwnMomentBookmarkResponseDtoCoverTypeEnum>(
      const <OwnMomentBookmarkResponseDtoCoverTypeEnum>[
        _$ownMomentBookmarkResponseDtoCoverTypeEnum_IMAGE,
        _$ownMomentBookmarkResponseDtoCoverTypeEnum_TEXT,
        _$ownMomentBookmarkResponseDtoCoverTypeEnum_unknownDefaultOpenApi,
      ],
    );

const OwnMomentBookmarkResponseDtoTextCoverThemeEnum
_$ownMomentBookmarkResponseDtoTextCoverThemeEnum_ROSE =
    const OwnMomentBookmarkResponseDtoTextCoverThemeEnum._('ROSE');
const OwnMomentBookmarkResponseDtoTextCoverThemeEnum
_$ownMomentBookmarkResponseDtoTextCoverThemeEnum_LILAC =
    const OwnMomentBookmarkResponseDtoTextCoverThemeEnum._('LILAC');
const OwnMomentBookmarkResponseDtoTextCoverThemeEnum
_$ownMomentBookmarkResponseDtoTextCoverThemeEnum_MINT =
    const OwnMomentBookmarkResponseDtoTextCoverThemeEnum._('MINT');
const OwnMomentBookmarkResponseDtoTextCoverThemeEnum
_$ownMomentBookmarkResponseDtoTextCoverThemeEnum_AMBER =
    const OwnMomentBookmarkResponseDtoTextCoverThemeEnum._('AMBER');
const OwnMomentBookmarkResponseDtoTextCoverThemeEnum
_$ownMomentBookmarkResponseDtoTextCoverThemeEnum_unknownDefaultOpenApi =
    const OwnMomentBookmarkResponseDtoTextCoverThemeEnum._(
      'unknownDefaultOpenApi',
    );

OwnMomentBookmarkResponseDtoTextCoverThemeEnum
_$ownMomentBookmarkResponseDtoTextCoverThemeEnumValueOf(String name) {
  switch (name) {
    case 'ROSE':
      return _$ownMomentBookmarkResponseDtoTextCoverThemeEnum_ROSE;
    case 'LILAC':
      return _$ownMomentBookmarkResponseDtoTextCoverThemeEnum_LILAC;
    case 'MINT':
      return _$ownMomentBookmarkResponseDtoTextCoverThemeEnum_MINT;
    case 'AMBER':
      return _$ownMomentBookmarkResponseDtoTextCoverThemeEnum_AMBER;
    case 'unknownDefaultOpenApi':
      return _$ownMomentBookmarkResponseDtoTextCoverThemeEnum_unknownDefaultOpenApi;
    default:
      return _$ownMomentBookmarkResponseDtoTextCoverThemeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<OwnMomentBookmarkResponseDtoTextCoverThemeEnum>
_$ownMomentBookmarkResponseDtoTextCoverThemeEnumValues =
    BuiltSet<OwnMomentBookmarkResponseDtoTextCoverThemeEnum>(
      const <OwnMomentBookmarkResponseDtoTextCoverThemeEnum>[
        _$ownMomentBookmarkResponseDtoTextCoverThemeEnum_ROSE,
        _$ownMomentBookmarkResponseDtoTextCoverThemeEnum_LILAC,
        _$ownMomentBookmarkResponseDtoTextCoverThemeEnum_MINT,
        _$ownMomentBookmarkResponseDtoTextCoverThemeEnum_AMBER,
        _$ownMomentBookmarkResponseDtoTextCoverThemeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<OwnMomentBookmarkResponseDtoCoverTypeEnum>
_$ownMomentBookmarkResponseDtoCoverTypeEnumSerializer =
    _$OwnMomentBookmarkResponseDtoCoverTypeEnumSerializer();
Serializer<OwnMomentBookmarkResponseDtoTextCoverThemeEnum>
_$ownMomentBookmarkResponseDtoTextCoverThemeEnumSerializer =
    _$OwnMomentBookmarkResponseDtoTextCoverThemeEnumSerializer();

class _$OwnMomentBookmarkResponseDtoCoverTypeEnumSerializer
    implements PrimitiveSerializer<OwnMomentBookmarkResponseDtoCoverTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'IMAGE': 'IMAGE',
    'TEXT': 'TEXT',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'IMAGE': 'IMAGE',
    'TEXT': 'TEXT',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    OwnMomentBookmarkResponseDtoCoverTypeEnum,
  ];
  @override
  final String wireName = 'OwnMomentBookmarkResponseDtoCoverTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    OwnMomentBookmarkResponseDtoCoverTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  OwnMomentBookmarkResponseDtoCoverTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => OwnMomentBookmarkResponseDtoCoverTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$OwnMomentBookmarkResponseDtoTextCoverThemeEnumSerializer
    implements
        PrimitiveSerializer<OwnMomentBookmarkResponseDtoTextCoverThemeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ROSE': 'ROSE',
    'LILAC': 'LILAC',
    'MINT': 'MINT',
    'AMBER': 'AMBER',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ROSE': 'ROSE',
    'LILAC': 'LILAC',
    'MINT': 'MINT',
    'AMBER': 'AMBER',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    OwnMomentBookmarkResponseDtoTextCoverThemeEnum,
  ];
  @override
  final String wireName = 'OwnMomentBookmarkResponseDtoTextCoverThemeEnum';

  @override
  Object serialize(
    Serializers serializers,
    OwnMomentBookmarkResponseDtoTextCoverThemeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  OwnMomentBookmarkResponseDtoTextCoverThemeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => OwnMomentBookmarkResponseDtoTextCoverThemeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$OwnMomentBookmarkResponseDto extends OwnMomentBookmarkResponseDto {
  @override
  final String id;
  @override
  final String authorId;
  @override
  final PostAuthorResponseDto author;
  @override
  final String title;
  @override
  final String contentExcerpt;
  @override
  final OwnMomentBookmarkResponseDtoCoverTypeEnum coverType;
  @override
  final OwnMomentBookmarkResponseDtoTextCoverThemeEnum textCoverTheme;
  @override
  final MomentMediaResponseDto? coverMedia;
  @override
  final num imageCount;
  @override
  final num likeCount;
  @override
  final num commentCount;
  @override
  final num bookmarkCount;
  @override
  final String tipTotal;
  @override
  final bool viewerLiked;
  @override
  final bool viewerBookmarked;
  @override
  final bool? canInteract;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String bookmarkFolderId;

  factory _$OwnMomentBookmarkResponseDto([
    void Function(OwnMomentBookmarkResponseDtoBuilder)? updates,
  ]) => (OwnMomentBookmarkResponseDtoBuilder()..update(updates))._build();

  _$OwnMomentBookmarkResponseDto._({
    required this.id,
    required this.authorId,
    required this.author,
    required this.title,
    required this.contentExcerpt,
    required this.coverType,
    required this.textCoverTheme,
    this.coverMedia,
    required this.imageCount,
    required this.likeCount,
    required this.commentCount,
    required this.bookmarkCount,
    required this.tipTotal,
    required this.viewerLiked,
    required this.viewerBookmarked,
    this.canInteract,
    required this.createdAt,
    required this.updatedAt,
    required this.bookmarkFolderId,
  }) : super._();
  @override
  OwnMomentBookmarkResponseDto rebuild(
    void Function(OwnMomentBookmarkResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  OwnMomentBookmarkResponseDtoBuilder toBuilder() =>
      OwnMomentBookmarkResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OwnMomentBookmarkResponseDto &&
        id == other.id &&
        authorId == other.authorId &&
        author == other.author &&
        title == other.title &&
        contentExcerpt == other.contentExcerpt &&
        coverType == other.coverType &&
        textCoverTheme == other.textCoverTheme &&
        coverMedia == other.coverMedia &&
        imageCount == other.imageCount &&
        likeCount == other.likeCount &&
        commentCount == other.commentCount &&
        bookmarkCount == other.bookmarkCount &&
        tipTotal == other.tipTotal &&
        viewerLiked == other.viewerLiked &&
        viewerBookmarked == other.viewerBookmarked &&
        canInteract == other.canInteract &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        bookmarkFolderId == other.bookmarkFolderId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, authorId.hashCode);
    _$hash = $jc(_$hash, author.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, contentExcerpt.hashCode);
    _$hash = $jc(_$hash, coverType.hashCode);
    _$hash = $jc(_$hash, textCoverTheme.hashCode);
    _$hash = $jc(_$hash, coverMedia.hashCode);
    _$hash = $jc(_$hash, imageCount.hashCode);
    _$hash = $jc(_$hash, likeCount.hashCode);
    _$hash = $jc(_$hash, commentCount.hashCode);
    _$hash = $jc(_$hash, bookmarkCount.hashCode);
    _$hash = $jc(_$hash, tipTotal.hashCode);
    _$hash = $jc(_$hash, viewerLiked.hashCode);
    _$hash = $jc(_$hash, viewerBookmarked.hashCode);
    _$hash = $jc(_$hash, canInteract.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, bookmarkFolderId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OwnMomentBookmarkResponseDto')
          ..add('id', id)
          ..add('authorId', authorId)
          ..add('author', author)
          ..add('title', title)
          ..add('contentExcerpt', contentExcerpt)
          ..add('coverType', coverType)
          ..add('textCoverTheme', textCoverTheme)
          ..add('coverMedia', coverMedia)
          ..add('imageCount', imageCount)
          ..add('likeCount', likeCount)
          ..add('commentCount', commentCount)
          ..add('bookmarkCount', bookmarkCount)
          ..add('tipTotal', tipTotal)
          ..add('viewerLiked', viewerLiked)
          ..add('viewerBookmarked', viewerBookmarked)
          ..add('canInteract', canInteract)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('bookmarkFolderId', bookmarkFolderId))
        .toString();
  }
}

class OwnMomentBookmarkResponseDtoBuilder
    implements
        Builder<
          OwnMomentBookmarkResponseDto,
          OwnMomentBookmarkResponseDtoBuilder
        > {
  _$OwnMomentBookmarkResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _authorId;
  String? get authorId => _$this._authorId;
  set authorId(String? authorId) => _$this._authorId = authorId;

  PostAuthorResponseDtoBuilder? _author;
  PostAuthorResponseDtoBuilder get author =>
      _$this._author ??= PostAuthorResponseDtoBuilder();
  set author(PostAuthorResponseDtoBuilder? author) => _$this._author = author;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _contentExcerpt;
  String? get contentExcerpt => _$this._contentExcerpt;
  set contentExcerpt(String? contentExcerpt) =>
      _$this._contentExcerpt = contentExcerpt;

  OwnMomentBookmarkResponseDtoCoverTypeEnum? _coverType;
  OwnMomentBookmarkResponseDtoCoverTypeEnum? get coverType => _$this._coverType;
  set coverType(OwnMomentBookmarkResponseDtoCoverTypeEnum? coverType) =>
      _$this._coverType = coverType;

  OwnMomentBookmarkResponseDtoTextCoverThemeEnum? _textCoverTheme;
  OwnMomentBookmarkResponseDtoTextCoverThemeEnum? get textCoverTheme =>
      _$this._textCoverTheme;
  set textCoverTheme(
    OwnMomentBookmarkResponseDtoTextCoverThemeEnum? textCoverTheme,
  ) => _$this._textCoverTheme = textCoverTheme;

  MomentMediaResponseDtoBuilder? _coverMedia;
  MomentMediaResponseDtoBuilder get coverMedia =>
      _$this._coverMedia ??= MomentMediaResponseDtoBuilder();
  set coverMedia(MomentMediaResponseDtoBuilder? coverMedia) =>
      _$this._coverMedia = coverMedia;

  num? _imageCount;
  num? get imageCount => _$this._imageCount;
  set imageCount(num? imageCount) => _$this._imageCount = imageCount;

  num? _likeCount;
  num? get likeCount => _$this._likeCount;
  set likeCount(num? likeCount) => _$this._likeCount = likeCount;

  num? _commentCount;
  num? get commentCount => _$this._commentCount;
  set commentCount(num? commentCount) => _$this._commentCount = commentCount;

  num? _bookmarkCount;
  num? get bookmarkCount => _$this._bookmarkCount;
  set bookmarkCount(num? bookmarkCount) =>
      _$this._bookmarkCount = bookmarkCount;

  String? _tipTotal;
  String? get tipTotal => _$this._tipTotal;
  set tipTotal(String? tipTotal) => _$this._tipTotal = tipTotal;

  bool? _viewerLiked;
  bool? get viewerLiked => _$this._viewerLiked;
  set viewerLiked(bool? viewerLiked) => _$this._viewerLiked = viewerLiked;

  bool? _viewerBookmarked;
  bool? get viewerBookmarked => _$this._viewerBookmarked;
  set viewerBookmarked(bool? viewerBookmarked) =>
      _$this._viewerBookmarked = viewerBookmarked;

  bool? _canInteract;
  bool? get canInteract => _$this._canInteract;
  set canInteract(bool? canInteract) => _$this._canInteract = canInteract;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  String? _bookmarkFolderId;
  String? get bookmarkFolderId => _$this._bookmarkFolderId;
  set bookmarkFolderId(String? bookmarkFolderId) =>
      _$this._bookmarkFolderId = bookmarkFolderId;

  OwnMomentBookmarkResponseDtoBuilder() {
    OwnMomentBookmarkResponseDto._defaults(this);
  }

  OwnMomentBookmarkResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _authorId = $v.authorId;
      _author = $v.author.toBuilder();
      _title = $v.title;
      _contentExcerpt = $v.contentExcerpt;
      _coverType = $v.coverType;
      _textCoverTheme = $v.textCoverTheme;
      _coverMedia = $v.coverMedia?.toBuilder();
      _imageCount = $v.imageCount;
      _likeCount = $v.likeCount;
      _commentCount = $v.commentCount;
      _bookmarkCount = $v.bookmarkCount;
      _tipTotal = $v.tipTotal;
      _viewerLiked = $v.viewerLiked;
      _viewerBookmarked = $v.viewerBookmarked;
      _canInteract = $v.canInteract;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _bookmarkFolderId = $v.bookmarkFolderId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OwnMomentBookmarkResponseDto other) {
    _$v = other as _$OwnMomentBookmarkResponseDto;
  }

  @override
  void update(void Function(OwnMomentBookmarkResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OwnMomentBookmarkResponseDto build() => _build();

  _$OwnMomentBookmarkResponseDto _build() {
    _$OwnMomentBookmarkResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$OwnMomentBookmarkResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'OwnMomentBookmarkResponseDto',
              'id',
            ),
            authorId: BuiltValueNullFieldError.checkNotNull(
              authorId,
              r'OwnMomentBookmarkResponseDto',
              'authorId',
            ),
            author: author.build(),
            title: BuiltValueNullFieldError.checkNotNull(
              title,
              r'OwnMomentBookmarkResponseDto',
              'title',
            ),
            contentExcerpt: BuiltValueNullFieldError.checkNotNull(
              contentExcerpt,
              r'OwnMomentBookmarkResponseDto',
              'contentExcerpt',
            ),
            coverType: BuiltValueNullFieldError.checkNotNull(
              coverType,
              r'OwnMomentBookmarkResponseDto',
              'coverType',
            ),
            textCoverTheme: BuiltValueNullFieldError.checkNotNull(
              textCoverTheme,
              r'OwnMomentBookmarkResponseDto',
              'textCoverTheme',
            ),
            coverMedia: _coverMedia?.build(),
            imageCount: BuiltValueNullFieldError.checkNotNull(
              imageCount,
              r'OwnMomentBookmarkResponseDto',
              'imageCount',
            ),
            likeCount: BuiltValueNullFieldError.checkNotNull(
              likeCount,
              r'OwnMomentBookmarkResponseDto',
              'likeCount',
            ),
            commentCount: BuiltValueNullFieldError.checkNotNull(
              commentCount,
              r'OwnMomentBookmarkResponseDto',
              'commentCount',
            ),
            bookmarkCount: BuiltValueNullFieldError.checkNotNull(
              bookmarkCount,
              r'OwnMomentBookmarkResponseDto',
              'bookmarkCount',
            ),
            tipTotal: BuiltValueNullFieldError.checkNotNull(
              tipTotal,
              r'OwnMomentBookmarkResponseDto',
              'tipTotal',
            ),
            viewerLiked: BuiltValueNullFieldError.checkNotNull(
              viewerLiked,
              r'OwnMomentBookmarkResponseDto',
              'viewerLiked',
            ),
            viewerBookmarked: BuiltValueNullFieldError.checkNotNull(
              viewerBookmarked,
              r'OwnMomentBookmarkResponseDto',
              'viewerBookmarked',
            ),
            canInteract: canInteract,
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'OwnMomentBookmarkResponseDto',
              'createdAt',
            ),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt,
              r'OwnMomentBookmarkResponseDto',
              'updatedAt',
            ),
            bookmarkFolderId: BuiltValueNullFieldError.checkNotNull(
              bookmarkFolderId,
              r'OwnMomentBookmarkResponseDto',
              'bookmarkFolderId',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'author';
        author.build();

        _$failedField = 'coverMedia';
        _coverMedia?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'OwnMomentBookmarkResponseDto',
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
