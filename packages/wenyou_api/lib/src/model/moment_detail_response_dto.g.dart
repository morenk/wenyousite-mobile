// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moment_detail_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MomentDetailResponseDtoCoverTypeEnum
_$momentDetailResponseDtoCoverTypeEnum_IMAGE =
    const MomentDetailResponseDtoCoverTypeEnum._('IMAGE');
const MomentDetailResponseDtoCoverTypeEnum
_$momentDetailResponseDtoCoverTypeEnum_TEXT =
    const MomentDetailResponseDtoCoverTypeEnum._('TEXT');
const MomentDetailResponseDtoCoverTypeEnum
_$momentDetailResponseDtoCoverTypeEnum_unknownDefaultOpenApi =
    const MomentDetailResponseDtoCoverTypeEnum._('unknownDefaultOpenApi');

MomentDetailResponseDtoCoverTypeEnum
_$momentDetailResponseDtoCoverTypeEnumValueOf(String name) {
  switch (name) {
    case 'IMAGE':
      return _$momentDetailResponseDtoCoverTypeEnum_IMAGE;
    case 'TEXT':
      return _$momentDetailResponseDtoCoverTypeEnum_TEXT;
    case 'unknownDefaultOpenApi':
      return _$momentDetailResponseDtoCoverTypeEnum_unknownDefaultOpenApi;
    default:
      return _$momentDetailResponseDtoCoverTypeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MomentDetailResponseDtoCoverTypeEnum>
_$momentDetailResponseDtoCoverTypeEnumValues =
    BuiltSet<MomentDetailResponseDtoCoverTypeEnum>(
      const <MomentDetailResponseDtoCoverTypeEnum>[
        _$momentDetailResponseDtoCoverTypeEnum_IMAGE,
        _$momentDetailResponseDtoCoverTypeEnum_TEXT,
        _$momentDetailResponseDtoCoverTypeEnum_unknownDefaultOpenApi,
      ],
    );

const MomentDetailResponseDtoTextCoverThemeEnum
_$momentDetailResponseDtoTextCoverThemeEnum_ROSE =
    const MomentDetailResponseDtoTextCoverThemeEnum._('ROSE');
const MomentDetailResponseDtoTextCoverThemeEnum
_$momentDetailResponseDtoTextCoverThemeEnum_LILAC =
    const MomentDetailResponseDtoTextCoverThemeEnum._('LILAC');
const MomentDetailResponseDtoTextCoverThemeEnum
_$momentDetailResponseDtoTextCoverThemeEnum_MINT =
    const MomentDetailResponseDtoTextCoverThemeEnum._('MINT');
const MomentDetailResponseDtoTextCoverThemeEnum
_$momentDetailResponseDtoTextCoverThemeEnum_AMBER =
    const MomentDetailResponseDtoTextCoverThemeEnum._('AMBER');
const MomentDetailResponseDtoTextCoverThemeEnum
_$momentDetailResponseDtoTextCoverThemeEnum_unknownDefaultOpenApi =
    const MomentDetailResponseDtoTextCoverThemeEnum._('unknownDefaultOpenApi');

MomentDetailResponseDtoTextCoverThemeEnum
_$momentDetailResponseDtoTextCoverThemeEnumValueOf(String name) {
  switch (name) {
    case 'ROSE':
      return _$momentDetailResponseDtoTextCoverThemeEnum_ROSE;
    case 'LILAC':
      return _$momentDetailResponseDtoTextCoverThemeEnum_LILAC;
    case 'MINT':
      return _$momentDetailResponseDtoTextCoverThemeEnum_MINT;
    case 'AMBER':
      return _$momentDetailResponseDtoTextCoverThemeEnum_AMBER;
    case 'unknownDefaultOpenApi':
      return _$momentDetailResponseDtoTextCoverThemeEnum_unknownDefaultOpenApi;
    default:
      return _$momentDetailResponseDtoTextCoverThemeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MomentDetailResponseDtoTextCoverThemeEnum>
_$momentDetailResponseDtoTextCoverThemeEnumValues =
    BuiltSet<MomentDetailResponseDtoTextCoverThemeEnum>(
      const <MomentDetailResponseDtoTextCoverThemeEnum>[
        _$momentDetailResponseDtoTextCoverThemeEnum_ROSE,
        _$momentDetailResponseDtoTextCoverThemeEnum_LILAC,
        _$momentDetailResponseDtoTextCoverThemeEnum_MINT,
        _$momentDetailResponseDtoTextCoverThemeEnum_AMBER,
        _$momentDetailResponseDtoTextCoverThemeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<MomentDetailResponseDtoCoverTypeEnum>
_$momentDetailResponseDtoCoverTypeEnumSerializer =
    _$MomentDetailResponseDtoCoverTypeEnumSerializer();
Serializer<MomentDetailResponseDtoTextCoverThemeEnum>
_$momentDetailResponseDtoTextCoverThemeEnumSerializer =
    _$MomentDetailResponseDtoTextCoverThemeEnumSerializer();

class _$MomentDetailResponseDtoCoverTypeEnumSerializer
    implements PrimitiveSerializer<MomentDetailResponseDtoCoverTypeEnum> {
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
    MomentDetailResponseDtoCoverTypeEnum,
  ];
  @override
  final String wireName = 'MomentDetailResponseDtoCoverTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MomentDetailResponseDtoCoverTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MomentDetailResponseDtoCoverTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MomentDetailResponseDtoCoverTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MomentDetailResponseDtoTextCoverThemeEnumSerializer
    implements PrimitiveSerializer<MomentDetailResponseDtoTextCoverThemeEnum> {
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
    MomentDetailResponseDtoTextCoverThemeEnum,
  ];
  @override
  final String wireName = 'MomentDetailResponseDtoTextCoverThemeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MomentDetailResponseDtoTextCoverThemeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MomentDetailResponseDtoTextCoverThemeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MomentDetailResponseDtoTextCoverThemeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MomentDetailResponseDto extends MomentDetailResponseDto {
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
  final MomentDetailResponseDtoCoverTypeEnum coverType;
  @override
  final MomentDetailResponseDtoTextCoverThemeEnum textCoverTheme;
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
  final String content;
  @override
  final BuiltList<MomentMediaResponseDto> images;
  @override
  final num version;
  @override
  final bool canEdit;
  @override
  final bool canDelete;

  factory _$MomentDetailResponseDto([
    void Function(MomentDetailResponseDtoBuilder)? updates,
  ]) => (MomentDetailResponseDtoBuilder()..update(updates))._build();

  _$MomentDetailResponseDto._({
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
    required this.content,
    required this.images,
    required this.version,
    required this.canEdit,
    required this.canDelete,
  }) : super._();
  @override
  MomentDetailResponseDto rebuild(
    void Function(MomentDetailResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MomentDetailResponseDtoBuilder toBuilder() =>
      MomentDetailResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentDetailResponseDto &&
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
        content == other.content &&
        images == other.images &&
        version == other.version &&
        canEdit == other.canEdit &&
        canDelete == other.canDelete;
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
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, images.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, canEdit.hashCode);
    _$hash = $jc(_$hash, canDelete.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MomentDetailResponseDto')
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
          ..add('content', content)
          ..add('images', images)
          ..add('version', version)
          ..add('canEdit', canEdit)
          ..add('canDelete', canDelete))
        .toString();
  }
}

class MomentDetailResponseDtoBuilder
    implements
        Builder<MomentDetailResponseDto, MomentDetailResponseDtoBuilder> {
  _$MomentDetailResponseDto? _$v;

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

  MomentDetailResponseDtoCoverTypeEnum? _coverType;
  MomentDetailResponseDtoCoverTypeEnum? get coverType => _$this._coverType;
  set coverType(MomentDetailResponseDtoCoverTypeEnum? coverType) =>
      _$this._coverType = coverType;

  MomentDetailResponseDtoTextCoverThemeEnum? _textCoverTheme;
  MomentDetailResponseDtoTextCoverThemeEnum? get textCoverTheme =>
      _$this._textCoverTheme;
  set textCoverTheme(
    MomentDetailResponseDtoTextCoverThemeEnum? textCoverTheme,
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

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  ListBuilder<MomentMediaResponseDto>? _images;
  ListBuilder<MomentMediaResponseDto> get images =>
      _$this._images ??= ListBuilder<MomentMediaResponseDto>();
  set images(ListBuilder<MomentMediaResponseDto>? images) =>
      _$this._images = images;

  num? _version;
  num? get version => _$this._version;
  set version(num? version) => _$this._version = version;

  bool? _canEdit;
  bool? get canEdit => _$this._canEdit;
  set canEdit(bool? canEdit) => _$this._canEdit = canEdit;

  bool? _canDelete;
  bool? get canDelete => _$this._canDelete;
  set canDelete(bool? canDelete) => _$this._canDelete = canDelete;

  MomentDetailResponseDtoBuilder() {
    MomentDetailResponseDto._defaults(this);
  }

  MomentDetailResponseDtoBuilder get _$this {
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
      _content = $v.content;
      _images = $v.images.toBuilder();
      _version = $v.version;
      _canEdit = $v.canEdit;
      _canDelete = $v.canDelete;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MomentDetailResponseDto other) {
    _$v = other as _$MomentDetailResponseDto;
  }

  @override
  void update(void Function(MomentDetailResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MomentDetailResponseDto build() => _build();

  _$MomentDetailResponseDto _build() {
    _$MomentDetailResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$MomentDetailResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'MomentDetailResponseDto',
              'id',
            ),
            authorId: BuiltValueNullFieldError.checkNotNull(
              authorId,
              r'MomentDetailResponseDto',
              'authorId',
            ),
            author: author.build(),
            title: BuiltValueNullFieldError.checkNotNull(
              title,
              r'MomentDetailResponseDto',
              'title',
            ),
            contentExcerpt: BuiltValueNullFieldError.checkNotNull(
              contentExcerpt,
              r'MomentDetailResponseDto',
              'contentExcerpt',
            ),
            coverType: BuiltValueNullFieldError.checkNotNull(
              coverType,
              r'MomentDetailResponseDto',
              'coverType',
            ),
            textCoverTheme: BuiltValueNullFieldError.checkNotNull(
              textCoverTheme,
              r'MomentDetailResponseDto',
              'textCoverTheme',
            ),
            coverMedia: _coverMedia?.build(),
            imageCount: BuiltValueNullFieldError.checkNotNull(
              imageCount,
              r'MomentDetailResponseDto',
              'imageCount',
            ),
            likeCount: BuiltValueNullFieldError.checkNotNull(
              likeCount,
              r'MomentDetailResponseDto',
              'likeCount',
            ),
            commentCount: BuiltValueNullFieldError.checkNotNull(
              commentCount,
              r'MomentDetailResponseDto',
              'commentCount',
            ),
            bookmarkCount: BuiltValueNullFieldError.checkNotNull(
              bookmarkCount,
              r'MomentDetailResponseDto',
              'bookmarkCount',
            ),
            tipTotal: BuiltValueNullFieldError.checkNotNull(
              tipTotal,
              r'MomentDetailResponseDto',
              'tipTotal',
            ),
            viewerLiked: BuiltValueNullFieldError.checkNotNull(
              viewerLiked,
              r'MomentDetailResponseDto',
              'viewerLiked',
            ),
            viewerBookmarked: BuiltValueNullFieldError.checkNotNull(
              viewerBookmarked,
              r'MomentDetailResponseDto',
              'viewerBookmarked',
            ),
            canInteract: canInteract,
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'MomentDetailResponseDto',
              'createdAt',
            ),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt,
              r'MomentDetailResponseDto',
              'updatedAt',
            ),
            content: BuiltValueNullFieldError.checkNotNull(
              content,
              r'MomentDetailResponseDto',
              'content',
            ),
            images: images.build(),
            version: BuiltValueNullFieldError.checkNotNull(
              version,
              r'MomentDetailResponseDto',
              'version',
            ),
            canEdit: BuiltValueNullFieldError.checkNotNull(
              canEdit,
              r'MomentDetailResponseDto',
              'canEdit',
            ),
            canDelete: BuiltValueNullFieldError.checkNotNull(
              canDelete,
              r'MomentDetailResponseDto',
              'canDelete',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'author';
        author.build();

        _$failedField = 'coverMedia';
        _coverMedia?.build();

        _$failedField = 'images';
        images.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'MomentDetailResponseDto',
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
