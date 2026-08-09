// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moment_card_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MomentCardResponseDtoCoverTypeEnum
_$momentCardResponseDtoCoverTypeEnum_IMAGE =
    const MomentCardResponseDtoCoverTypeEnum._('IMAGE');
const MomentCardResponseDtoCoverTypeEnum
_$momentCardResponseDtoCoverTypeEnum_TEXT =
    const MomentCardResponseDtoCoverTypeEnum._('TEXT');
const MomentCardResponseDtoCoverTypeEnum
_$momentCardResponseDtoCoverTypeEnum_unknownDefaultOpenApi =
    const MomentCardResponseDtoCoverTypeEnum._('unknownDefaultOpenApi');

MomentCardResponseDtoCoverTypeEnum _$momentCardResponseDtoCoverTypeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'IMAGE':
      return _$momentCardResponseDtoCoverTypeEnum_IMAGE;
    case 'TEXT':
      return _$momentCardResponseDtoCoverTypeEnum_TEXT;
    case 'unknownDefaultOpenApi':
      return _$momentCardResponseDtoCoverTypeEnum_unknownDefaultOpenApi;
    default:
      return _$momentCardResponseDtoCoverTypeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MomentCardResponseDtoCoverTypeEnum>
_$momentCardResponseDtoCoverTypeEnumValues =
    BuiltSet<MomentCardResponseDtoCoverTypeEnum>(
      const <MomentCardResponseDtoCoverTypeEnum>[
        _$momentCardResponseDtoCoverTypeEnum_IMAGE,
        _$momentCardResponseDtoCoverTypeEnum_TEXT,
        _$momentCardResponseDtoCoverTypeEnum_unknownDefaultOpenApi,
      ],
    );

const MomentCardResponseDtoTextCoverThemeEnum
_$momentCardResponseDtoTextCoverThemeEnum_ROSE =
    const MomentCardResponseDtoTextCoverThemeEnum._('ROSE');
const MomentCardResponseDtoTextCoverThemeEnum
_$momentCardResponseDtoTextCoverThemeEnum_LILAC =
    const MomentCardResponseDtoTextCoverThemeEnum._('LILAC');
const MomentCardResponseDtoTextCoverThemeEnum
_$momentCardResponseDtoTextCoverThemeEnum_MINT =
    const MomentCardResponseDtoTextCoverThemeEnum._('MINT');
const MomentCardResponseDtoTextCoverThemeEnum
_$momentCardResponseDtoTextCoverThemeEnum_AMBER =
    const MomentCardResponseDtoTextCoverThemeEnum._('AMBER');
const MomentCardResponseDtoTextCoverThemeEnum
_$momentCardResponseDtoTextCoverThemeEnum_unknownDefaultOpenApi =
    const MomentCardResponseDtoTextCoverThemeEnum._('unknownDefaultOpenApi');

MomentCardResponseDtoTextCoverThemeEnum
_$momentCardResponseDtoTextCoverThemeEnumValueOf(String name) {
  switch (name) {
    case 'ROSE':
      return _$momentCardResponseDtoTextCoverThemeEnum_ROSE;
    case 'LILAC':
      return _$momentCardResponseDtoTextCoverThemeEnum_LILAC;
    case 'MINT':
      return _$momentCardResponseDtoTextCoverThemeEnum_MINT;
    case 'AMBER':
      return _$momentCardResponseDtoTextCoverThemeEnum_AMBER;
    case 'unknownDefaultOpenApi':
      return _$momentCardResponseDtoTextCoverThemeEnum_unknownDefaultOpenApi;
    default:
      return _$momentCardResponseDtoTextCoverThemeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MomentCardResponseDtoTextCoverThemeEnum>
_$momentCardResponseDtoTextCoverThemeEnumValues =
    BuiltSet<MomentCardResponseDtoTextCoverThemeEnum>(
      const <MomentCardResponseDtoTextCoverThemeEnum>[
        _$momentCardResponseDtoTextCoverThemeEnum_ROSE,
        _$momentCardResponseDtoTextCoverThemeEnum_LILAC,
        _$momentCardResponseDtoTextCoverThemeEnum_MINT,
        _$momentCardResponseDtoTextCoverThemeEnum_AMBER,
        _$momentCardResponseDtoTextCoverThemeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<MomentCardResponseDtoCoverTypeEnum>
_$momentCardResponseDtoCoverTypeEnumSerializer =
    _$MomentCardResponseDtoCoverTypeEnumSerializer();
Serializer<MomentCardResponseDtoTextCoverThemeEnum>
_$momentCardResponseDtoTextCoverThemeEnumSerializer =
    _$MomentCardResponseDtoTextCoverThemeEnumSerializer();

class _$MomentCardResponseDtoCoverTypeEnumSerializer
    implements PrimitiveSerializer<MomentCardResponseDtoCoverTypeEnum> {
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
  final Iterable<Type> types = const <Type>[MomentCardResponseDtoCoverTypeEnum];
  @override
  final String wireName = 'MomentCardResponseDtoCoverTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MomentCardResponseDtoCoverTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MomentCardResponseDtoCoverTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MomentCardResponseDtoCoverTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MomentCardResponseDtoTextCoverThemeEnumSerializer
    implements PrimitiveSerializer<MomentCardResponseDtoTextCoverThemeEnum> {
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
    MomentCardResponseDtoTextCoverThemeEnum,
  ];
  @override
  final String wireName = 'MomentCardResponseDtoTextCoverThemeEnum';

  @override
  Object serialize(
    Serializers serializers,
    MomentCardResponseDtoTextCoverThemeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MomentCardResponseDtoTextCoverThemeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MomentCardResponseDtoTextCoverThemeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MomentCardResponseDto extends MomentCardResponseDto {
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
  final MomentCardResponseDtoCoverTypeEnum coverType;
  @override
  final MomentCardResponseDtoTextCoverThemeEnum textCoverTheme;
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
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$MomentCardResponseDto([
    void Function(MomentCardResponseDtoBuilder)? updates,
  ]) => (MomentCardResponseDtoBuilder()..update(updates))._build();

  _$MomentCardResponseDto._({
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
    required this.createdAt,
    required this.updatedAt,
  }) : super._();
  @override
  MomentCardResponseDto rebuild(
    void Function(MomentCardResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MomentCardResponseDtoBuilder toBuilder() =>
      MomentCardResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentCardResponseDto &&
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
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
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
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MomentCardResponseDto')
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
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class MomentCardResponseDtoBuilder
    implements Builder<MomentCardResponseDto, MomentCardResponseDtoBuilder> {
  _$MomentCardResponseDto? _$v;

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

  MomentCardResponseDtoCoverTypeEnum? _coverType;
  MomentCardResponseDtoCoverTypeEnum? get coverType => _$this._coverType;
  set coverType(MomentCardResponseDtoCoverTypeEnum? coverType) =>
      _$this._coverType = coverType;

  MomentCardResponseDtoTextCoverThemeEnum? _textCoverTheme;
  MomentCardResponseDtoTextCoverThemeEnum? get textCoverTheme =>
      _$this._textCoverTheme;
  set textCoverTheme(MomentCardResponseDtoTextCoverThemeEnum? textCoverTheme) =>
      _$this._textCoverTheme = textCoverTheme;

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

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  MomentCardResponseDtoBuilder() {
    MomentCardResponseDto._defaults(this);
  }

  MomentCardResponseDtoBuilder get _$this {
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
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MomentCardResponseDto other) {
    _$v = other as _$MomentCardResponseDto;
  }

  @override
  void update(void Function(MomentCardResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MomentCardResponseDto build() => _build();

  _$MomentCardResponseDto _build() {
    _$MomentCardResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$MomentCardResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'MomentCardResponseDto',
              'id',
            ),
            authorId: BuiltValueNullFieldError.checkNotNull(
              authorId,
              r'MomentCardResponseDto',
              'authorId',
            ),
            author: author.build(),
            title: BuiltValueNullFieldError.checkNotNull(
              title,
              r'MomentCardResponseDto',
              'title',
            ),
            contentExcerpt: BuiltValueNullFieldError.checkNotNull(
              contentExcerpt,
              r'MomentCardResponseDto',
              'contentExcerpt',
            ),
            coverType: BuiltValueNullFieldError.checkNotNull(
              coverType,
              r'MomentCardResponseDto',
              'coverType',
            ),
            textCoverTheme: BuiltValueNullFieldError.checkNotNull(
              textCoverTheme,
              r'MomentCardResponseDto',
              'textCoverTheme',
            ),
            coverMedia: _coverMedia?.build(),
            imageCount: BuiltValueNullFieldError.checkNotNull(
              imageCount,
              r'MomentCardResponseDto',
              'imageCount',
            ),
            likeCount: BuiltValueNullFieldError.checkNotNull(
              likeCount,
              r'MomentCardResponseDto',
              'likeCount',
            ),
            commentCount: BuiltValueNullFieldError.checkNotNull(
              commentCount,
              r'MomentCardResponseDto',
              'commentCount',
            ),
            bookmarkCount: BuiltValueNullFieldError.checkNotNull(
              bookmarkCount,
              r'MomentCardResponseDto',
              'bookmarkCount',
            ),
            tipTotal: BuiltValueNullFieldError.checkNotNull(
              tipTotal,
              r'MomentCardResponseDto',
              'tipTotal',
            ),
            viewerLiked: BuiltValueNullFieldError.checkNotNull(
              viewerLiked,
              r'MomentCardResponseDto',
              'viewerLiked',
            ),
            viewerBookmarked: BuiltValueNullFieldError.checkNotNull(
              viewerBookmarked,
              r'MomentCardResponseDto',
              'viewerBookmarked',
            ),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'MomentCardResponseDto',
              'createdAt',
            ),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt,
              r'MomentCardResponseDto',
              'updatedAt',
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
          r'MomentCardResponseDto',
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
