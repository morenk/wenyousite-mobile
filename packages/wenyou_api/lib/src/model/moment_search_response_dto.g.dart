// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moment_search_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MomentSearchResponseDtoCoverTypeEnum
_$momentSearchResponseDtoCoverTypeEnum_IMAGE =
    const MomentSearchResponseDtoCoverTypeEnum._('IMAGE');
const MomentSearchResponseDtoCoverTypeEnum
_$momentSearchResponseDtoCoverTypeEnum_TEXT =
    const MomentSearchResponseDtoCoverTypeEnum._('TEXT');
const MomentSearchResponseDtoCoverTypeEnum
_$momentSearchResponseDtoCoverTypeEnum_unknownDefaultOpenApi =
    const MomentSearchResponseDtoCoverTypeEnum._('unknownDefaultOpenApi');

MomentSearchResponseDtoCoverTypeEnum
_$momentSearchResponseDtoCoverTypeEnumValueOf(String name) {
  switch (name) {
    case 'IMAGE':
      return _$momentSearchResponseDtoCoverTypeEnum_IMAGE;
    case 'TEXT':
      return _$momentSearchResponseDtoCoverTypeEnum_TEXT;
    case 'unknownDefaultOpenApi':
      return _$momentSearchResponseDtoCoverTypeEnum_unknownDefaultOpenApi;
    default:
      return _$momentSearchResponseDtoCoverTypeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MomentSearchResponseDtoCoverTypeEnum>
_$momentSearchResponseDtoCoverTypeEnumValues =
    BuiltSet<MomentSearchResponseDtoCoverTypeEnum>(
      const <MomentSearchResponseDtoCoverTypeEnum>[
        _$momentSearchResponseDtoCoverTypeEnum_IMAGE,
        _$momentSearchResponseDtoCoverTypeEnum_TEXT,
        _$momentSearchResponseDtoCoverTypeEnum_unknownDefaultOpenApi,
      ],
    );

const MomentSearchResponseDtoTextCoverThemeEnum
_$momentSearchResponseDtoTextCoverThemeEnum_ROSE =
    const MomentSearchResponseDtoTextCoverThemeEnum._('ROSE');
const MomentSearchResponseDtoTextCoverThemeEnum
_$momentSearchResponseDtoTextCoverThemeEnum_LILAC =
    const MomentSearchResponseDtoTextCoverThemeEnum._('LILAC');
const MomentSearchResponseDtoTextCoverThemeEnum
_$momentSearchResponseDtoTextCoverThemeEnum_MINT =
    const MomentSearchResponseDtoTextCoverThemeEnum._('MINT');
const MomentSearchResponseDtoTextCoverThemeEnum
_$momentSearchResponseDtoTextCoverThemeEnum_AMBER =
    const MomentSearchResponseDtoTextCoverThemeEnum._('AMBER');
const MomentSearchResponseDtoTextCoverThemeEnum
_$momentSearchResponseDtoTextCoverThemeEnum_unknownDefaultOpenApi =
    const MomentSearchResponseDtoTextCoverThemeEnum._('unknownDefaultOpenApi');

MomentSearchResponseDtoTextCoverThemeEnum
_$momentSearchResponseDtoTextCoverThemeEnumValueOf(String name) {
  switch (name) {
    case 'ROSE':
      return _$momentSearchResponseDtoTextCoverThemeEnum_ROSE;
    case 'LILAC':
      return _$momentSearchResponseDtoTextCoverThemeEnum_LILAC;
    case 'MINT':
      return _$momentSearchResponseDtoTextCoverThemeEnum_MINT;
    case 'AMBER':
      return _$momentSearchResponseDtoTextCoverThemeEnum_AMBER;
    case 'unknownDefaultOpenApi':
      return _$momentSearchResponseDtoTextCoverThemeEnum_unknownDefaultOpenApi;
    default:
      return _$momentSearchResponseDtoTextCoverThemeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MomentSearchResponseDtoTextCoverThemeEnum>
_$momentSearchResponseDtoTextCoverThemeEnumValues =
    BuiltSet<MomentSearchResponseDtoTextCoverThemeEnum>(
      const <MomentSearchResponseDtoTextCoverThemeEnum>[
        _$momentSearchResponseDtoTextCoverThemeEnum_ROSE,
        _$momentSearchResponseDtoTextCoverThemeEnum_LILAC,
        _$momentSearchResponseDtoTextCoverThemeEnum_MINT,
        _$momentSearchResponseDtoTextCoverThemeEnum_AMBER,
        _$momentSearchResponseDtoTextCoverThemeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<MomentSearchResponseDtoCoverTypeEnum>
_$momentSearchResponseDtoCoverTypeEnumSerializer =
    _$MomentSearchResponseDtoCoverTypeEnumSerializer();
Serializer<MomentSearchResponseDtoTextCoverThemeEnum>
_$momentSearchResponseDtoTextCoverThemeEnumSerializer =
    _$MomentSearchResponseDtoTextCoverThemeEnumSerializer();

class _$MomentSearchResponseDtoCoverTypeEnumSerializer
    implements PrimitiveSerializer<MomentSearchResponseDtoCoverTypeEnum> {
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
    MomentSearchResponseDtoCoverTypeEnum,
  ];
  @override
  final String wireName = 'MomentSearchResponseDtoCoverTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MomentSearchResponseDtoCoverTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MomentSearchResponseDtoCoverTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MomentSearchResponseDtoCoverTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MomentSearchResponseDtoTextCoverThemeEnumSerializer
    implements PrimitiveSerializer<MomentSearchResponseDtoTextCoverThemeEnum> {
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
    MomentSearchResponseDtoTextCoverThemeEnum,
  ];
  @override
  final String wireName = 'MomentSearchResponseDtoTextCoverThemeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MomentSearchResponseDtoTextCoverThemeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MomentSearchResponseDtoTextCoverThemeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MomentSearchResponseDtoTextCoverThemeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MomentSearchResponseDto extends MomentSearchResponseDto {
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
  final MomentSearchResponseDtoCoverTypeEnum coverType;
  @override
  final MomentSearchResponseDtoTextCoverThemeEnum textCoverTheme;
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
  final num? relevance;

  factory _$MomentSearchResponseDto([
    void Function(MomentSearchResponseDtoBuilder)? updates,
  ]) => (MomentSearchResponseDtoBuilder()..update(updates))._build();

  _$MomentSearchResponseDto._({
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
    this.relevance,
  }) : super._();
  @override
  MomentSearchResponseDto rebuild(
    void Function(MomentSearchResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MomentSearchResponseDtoBuilder toBuilder() =>
      MomentSearchResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentSearchResponseDto &&
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
        relevance == other.relevance;
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
    _$hash = $jc(_$hash, relevance.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MomentSearchResponseDto')
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
          ..add('relevance', relevance))
        .toString();
  }
}

class MomentSearchResponseDtoBuilder
    implements
        Builder<MomentSearchResponseDto, MomentSearchResponseDtoBuilder> {
  _$MomentSearchResponseDto? _$v;

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

  MomentSearchResponseDtoCoverTypeEnum? _coverType;
  MomentSearchResponseDtoCoverTypeEnum? get coverType => _$this._coverType;
  set coverType(MomentSearchResponseDtoCoverTypeEnum? coverType) =>
      _$this._coverType = coverType;

  MomentSearchResponseDtoTextCoverThemeEnum? _textCoverTheme;
  MomentSearchResponseDtoTextCoverThemeEnum? get textCoverTheme =>
      _$this._textCoverTheme;
  set textCoverTheme(
    MomentSearchResponseDtoTextCoverThemeEnum? textCoverTheme,
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

  num? _relevance;
  num? get relevance => _$this._relevance;
  set relevance(num? relevance) => _$this._relevance = relevance;

  MomentSearchResponseDtoBuilder() {
    MomentSearchResponseDto._defaults(this);
  }

  MomentSearchResponseDtoBuilder get _$this {
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
      _relevance = $v.relevance;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MomentSearchResponseDto other) {
    _$v = other as _$MomentSearchResponseDto;
  }

  @override
  void update(void Function(MomentSearchResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MomentSearchResponseDto build() => _build();

  _$MomentSearchResponseDto _build() {
    _$MomentSearchResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$MomentSearchResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'MomentSearchResponseDto',
              'id',
            ),
            authorId: BuiltValueNullFieldError.checkNotNull(
              authorId,
              r'MomentSearchResponseDto',
              'authorId',
            ),
            author: author.build(),
            title: BuiltValueNullFieldError.checkNotNull(
              title,
              r'MomentSearchResponseDto',
              'title',
            ),
            contentExcerpt: BuiltValueNullFieldError.checkNotNull(
              contentExcerpt,
              r'MomentSearchResponseDto',
              'contentExcerpt',
            ),
            coverType: BuiltValueNullFieldError.checkNotNull(
              coverType,
              r'MomentSearchResponseDto',
              'coverType',
            ),
            textCoverTheme: BuiltValueNullFieldError.checkNotNull(
              textCoverTheme,
              r'MomentSearchResponseDto',
              'textCoverTheme',
            ),
            coverMedia: _coverMedia?.build(),
            imageCount: BuiltValueNullFieldError.checkNotNull(
              imageCount,
              r'MomentSearchResponseDto',
              'imageCount',
            ),
            likeCount: BuiltValueNullFieldError.checkNotNull(
              likeCount,
              r'MomentSearchResponseDto',
              'likeCount',
            ),
            commentCount: BuiltValueNullFieldError.checkNotNull(
              commentCount,
              r'MomentSearchResponseDto',
              'commentCount',
            ),
            bookmarkCount: BuiltValueNullFieldError.checkNotNull(
              bookmarkCount,
              r'MomentSearchResponseDto',
              'bookmarkCount',
            ),
            tipTotal: BuiltValueNullFieldError.checkNotNull(
              tipTotal,
              r'MomentSearchResponseDto',
              'tipTotal',
            ),
            viewerLiked: BuiltValueNullFieldError.checkNotNull(
              viewerLiked,
              r'MomentSearchResponseDto',
              'viewerLiked',
            ),
            viewerBookmarked: BuiltValueNullFieldError.checkNotNull(
              viewerBookmarked,
              r'MomentSearchResponseDto',
              'viewerBookmarked',
            ),
            canInteract: canInteract,
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'MomentSearchResponseDto',
              'createdAt',
            ),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt,
              r'MomentSearchResponseDto',
              'updatedAt',
            ),
            relevance: relevance,
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
          r'MomentSearchResponseDto',
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
