// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_thread_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BookmarkThreadResponseDtoStatusEnum
_$bookmarkThreadResponseDtoStatusEnum_RECRUITING =
    const BookmarkThreadResponseDtoStatusEnum._('RECRUITING');
const BookmarkThreadResponseDtoStatusEnum
_$bookmarkThreadResponseDtoStatusEnum_CLOSED =
    const BookmarkThreadResponseDtoStatusEnum._('CLOSED');
const BookmarkThreadResponseDtoStatusEnum
_$bookmarkThreadResponseDtoStatusEnum_FINISHED =
    const BookmarkThreadResponseDtoStatusEnum._('FINISHED');
const BookmarkThreadResponseDtoStatusEnum
_$bookmarkThreadResponseDtoStatusEnum_unknownDefaultOpenApi =
    const BookmarkThreadResponseDtoStatusEnum._('unknownDefaultOpenApi');

BookmarkThreadResponseDtoStatusEnum
_$bookmarkThreadResponseDtoStatusEnumValueOf(String name) {
  switch (name) {
    case 'RECRUITING':
      return _$bookmarkThreadResponseDtoStatusEnum_RECRUITING;
    case 'CLOSED':
      return _$bookmarkThreadResponseDtoStatusEnum_CLOSED;
    case 'FINISHED':
      return _$bookmarkThreadResponseDtoStatusEnum_FINISHED;
    case 'unknownDefaultOpenApi':
      return _$bookmarkThreadResponseDtoStatusEnum_unknownDefaultOpenApi;
    default:
      return _$bookmarkThreadResponseDtoStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<BookmarkThreadResponseDtoStatusEnum>
_$bookmarkThreadResponseDtoStatusEnumValues =
    BuiltSet<BookmarkThreadResponseDtoStatusEnum>(
      const <BookmarkThreadResponseDtoStatusEnum>[
        _$bookmarkThreadResponseDtoStatusEnum_RECRUITING,
        _$bookmarkThreadResponseDtoStatusEnum_CLOSED,
        _$bookmarkThreadResponseDtoStatusEnum_FINISHED,
        _$bookmarkThreadResponseDtoStatusEnum_unknownDefaultOpenApi,
      ],
    );

const BookmarkThreadResponseDtoVisibilityEnum
_$bookmarkThreadResponseDtoVisibilityEnum_PUBLIC =
    const BookmarkThreadResponseDtoVisibilityEnum._('PUBLIC');
const BookmarkThreadResponseDtoVisibilityEnum
_$bookmarkThreadResponseDtoVisibilityEnum_PRIVATE =
    const BookmarkThreadResponseDtoVisibilityEnum._('PRIVATE');
const BookmarkThreadResponseDtoVisibilityEnum
_$bookmarkThreadResponseDtoVisibilityEnum_unknownDefaultOpenApi =
    const BookmarkThreadResponseDtoVisibilityEnum._('unknownDefaultOpenApi');

BookmarkThreadResponseDtoVisibilityEnum
_$bookmarkThreadResponseDtoVisibilityEnumValueOf(String name) {
  switch (name) {
    case 'PUBLIC':
      return _$bookmarkThreadResponseDtoVisibilityEnum_PUBLIC;
    case 'PRIVATE':
      return _$bookmarkThreadResponseDtoVisibilityEnum_PRIVATE;
    case 'unknownDefaultOpenApi':
      return _$bookmarkThreadResponseDtoVisibilityEnum_unknownDefaultOpenApi;
    default:
      return _$bookmarkThreadResponseDtoVisibilityEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<BookmarkThreadResponseDtoVisibilityEnum>
_$bookmarkThreadResponseDtoVisibilityEnumValues =
    BuiltSet<BookmarkThreadResponseDtoVisibilityEnum>(
      const <BookmarkThreadResponseDtoVisibilityEnum>[
        _$bookmarkThreadResponseDtoVisibilityEnum_PUBLIC,
        _$bookmarkThreadResponseDtoVisibilityEnum_PRIVATE,
        _$bookmarkThreadResponseDtoVisibilityEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<BookmarkThreadResponseDtoStatusEnum>
_$bookmarkThreadResponseDtoStatusEnumSerializer =
    _$BookmarkThreadResponseDtoStatusEnumSerializer();
Serializer<BookmarkThreadResponseDtoVisibilityEnum>
_$bookmarkThreadResponseDtoVisibilityEnumSerializer =
    _$BookmarkThreadResponseDtoVisibilityEnumSerializer();

class _$BookmarkThreadResponseDtoStatusEnumSerializer
    implements PrimitiveSerializer<BookmarkThreadResponseDtoStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'RECRUITING': 'RECRUITING',
    'CLOSED': 'CLOSED',
    'FINISHED': 'FINISHED',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'RECRUITING': 'RECRUITING',
    'CLOSED': 'CLOSED',
    'FINISHED': 'FINISHED',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    BookmarkThreadResponseDtoStatusEnum,
  ];
  @override
  final String wireName = 'BookmarkThreadResponseDtoStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    BookmarkThreadResponseDtoStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  BookmarkThreadResponseDtoStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => BookmarkThreadResponseDtoStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$BookmarkThreadResponseDtoVisibilityEnumSerializer
    implements PrimitiveSerializer<BookmarkThreadResponseDtoVisibilityEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'PUBLIC': 'PUBLIC',
    'PRIVATE': 'PRIVATE',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'PUBLIC': 'PUBLIC',
    'PRIVATE': 'PRIVATE',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    BookmarkThreadResponseDtoVisibilityEnum,
  ];
  @override
  final String wireName = 'BookmarkThreadResponseDtoVisibilityEnum';

  @override
  Object serialize(
    Serializers serializers,
    BookmarkThreadResponseDtoVisibilityEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  BookmarkThreadResponseDtoVisibilityEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => BookmarkThreadResponseDtoVisibilityEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$BookmarkThreadResponseDto extends BookmarkThreadResponseDto {
  @override
  final String id;
  @override
  final String title;
  @override
  final String? category;
  @override
  final BookmarkThreadResponseDtoStatusEnum status;
  @override
  final BookmarkThreadResponseDtoVisibilityEnum visibility;
  @override
  final bool published;
  @override
  final bool pinned;
  @override
  final String tipTotal;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final PostAuthorResponseDto owner;
  @override
  final ThreadListDefaultSubthreadResponseDto? defaultSubthread;
  @override
  final BuiltList<ThreadTagRelationResponseDto> topicTags;
  @override
  final ThreadListCountResponseDto count;
  @override
  final String preview;
  @override
  final BuiltList<String> coverImages;

  factory _$BookmarkThreadResponseDto([
    void Function(BookmarkThreadResponseDtoBuilder)? updates,
  ]) => (BookmarkThreadResponseDtoBuilder()..update(updates))._build();

  _$BookmarkThreadResponseDto._({
    required this.id,
    required this.title,
    this.category,
    required this.status,
    required this.visibility,
    required this.published,
    required this.pinned,
    required this.tipTotal,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.owner,
    this.defaultSubthread,
    required this.topicTags,
    required this.count,
    required this.preview,
    required this.coverImages,
  }) : super._();
  @override
  BookmarkThreadResponseDto rebuild(
    void Function(BookmarkThreadResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  BookmarkThreadResponseDtoBuilder toBuilder() =>
      BookmarkThreadResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BookmarkThreadResponseDto &&
        id == other.id &&
        title == other.title &&
        category == other.category &&
        status == other.status &&
        visibility == other.visibility &&
        published == other.published &&
        pinned == other.pinned &&
        tipTotal == other.tipTotal &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        deletedAt == other.deletedAt &&
        owner == other.owner &&
        defaultSubthread == other.defaultSubthread &&
        topicTags == other.topicTags &&
        count == other.count &&
        preview == other.preview &&
        coverImages == other.coverImages;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, visibility.hashCode);
    _$hash = $jc(_$hash, published.hashCode);
    _$hash = $jc(_$hash, pinned.hashCode);
    _$hash = $jc(_$hash, tipTotal.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jc(_$hash, owner.hashCode);
    _$hash = $jc(_$hash, defaultSubthread.hashCode);
    _$hash = $jc(_$hash, topicTags.hashCode);
    _$hash = $jc(_$hash, count.hashCode);
    _$hash = $jc(_$hash, preview.hashCode);
    _$hash = $jc(_$hash, coverImages.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BookmarkThreadResponseDto')
          ..add('id', id)
          ..add('title', title)
          ..add('category', category)
          ..add('status', status)
          ..add('visibility', visibility)
          ..add('published', published)
          ..add('pinned', pinned)
          ..add('tipTotal', tipTotal)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('deletedAt', deletedAt)
          ..add('owner', owner)
          ..add('defaultSubthread', defaultSubthread)
          ..add('topicTags', topicTags)
          ..add('count', count)
          ..add('preview', preview)
          ..add('coverImages', coverImages))
        .toString();
  }
}

class BookmarkThreadResponseDtoBuilder
    implements
        Builder<BookmarkThreadResponseDto, BookmarkThreadResponseDtoBuilder> {
  _$BookmarkThreadResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _category;
  String? get category => _$this._category;
  set category(String? category) => _$this._category = category;

  BookmarkThreadResponseDtoStatusEnum? _status;
  BookmarkThreadResponseDtoStatusEnum? get status => _$this._status;
  set status(BookmarkThreadResponseDtoStatusEnum? status) =>
      _$this._status = status;

  BookmarkThreadResponseDtoVisibilityEnum? _visibility;
  BookmarkThreadResponseDtoVisibilityEnum? get visibility => _$this._visibility;
  set visibility(BookmarkThreadResponseDtoVisibilityEnum? visibility) =>
      _$this._visibility = visibility;

  bool? _published;
  bool? get published => _$this._published;
  set published(bool? published) => _$this._published = published;

  bool? _pinned;
  bool? get pinned => _$this._pinned;
  set pinned(bool? pinned) => _$this._pinned = pinned;

  String? _tipTotal;
  String? get tipTotal => _$this._tipTotal;
  set tipTotal(String? tipTotal) => _$this._tipTotal = tipTotal;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  PostAuthorResponseDtoBuilder? _owner;
  PostAuthorResponseDtoBuilder get owner =>
      _$this._owner ??= PostAuthorResponseDtoBuilder();
  set owner(PostAuthorResponseDtoBuilder? owner) => _$this._owner = owner;

  ThreadListDefaultSubthreadResponseDtoBuilder? _defaultSubthread;
  ThreadListDefaultSubthreadResponseDtoBuilder get defaultSubthread =>
      _$this._defaultSubthread ??=
          ThreadListDefaultSubthreadResponseDtoBuilder();
  set defaultSubthread(
    ThreadListDefaultSubthreadResponseDtoBuilder? defaultSubthread,
  ) => _$this._defaultSubthread = defaultSubthread;

  ListBuilder<ThreadTagRelationResponseDto>? _topicTags;
  ListBuilder<ThreadTagRelationResponseDto> get topicTags =>
      _$this._topicTags ??= ListBuilder<ThreadTagRelationResponseDto>();
  set topicTags(ListBuilder<ThreadTagRelationResponseDto>? topicTags) =>
      _$this._topicTags = topicTags;

  ThreadListCountResponseDtoBuilder? _count;
  ThreadListCountResponseDtoBuilder get count =>
      _$this._count ??= ThreadListCountResponseDtoBuilder();
  set count(ThreadListCountResponseDtoBuilder? count) => _$this._count = count;

  String? _preview;
  String? get preview => _$this._preview;
  set preview(String? preview) => _$this._preview = preview;

  ListBuilder<String>? _coverImages;
  ListBuilder<String> get coverImages =>
      _$this._coverImages ??= ListBuilder<String>();
  set coverImages(ListBuilder<String>? coverImages) =>
      _$this._coverImages = coverImages;

  BookmarkThreadResponseDtoBuilder() {
    BookmarkThreadResponseDto._defaults(this);
  }

  BookmarkThreadResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _category = $v.category;
      _status = $v.status;
      _visibility = $v.visibility;
      _published = $v.published;
      _pinned = $v.pinned;
      _tipTotal = $v.tipTotal;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _deletedAt = $v.deletedAt;
      _owner = $v.owner.toBuilder();
      _defaultSubthread = $v.defaultSubthread?.toBuilder();
      _topicTags = $v.topicTags.toBuilder();
      _count = $v.count.toBuilder();
      _preview = $v.preview;
      _coverImages = $v.coverImages.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BookmarkThreadResponseDto other) {
    _$v = other as _$BookmarkThreadResponseDto;
  }

  @override
  void update(void Function(BookmarkThreadResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BookmarkThreadResponseDto build() => _build();

  _$BookmarkThreadResponseDto _build() {
    _$BookmarkThreadResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$BookmarkThreadResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'BookmarkThreadResponseDto',
              'id',
            ),
            title: BuiltValueNullFieldError.checkNotNull(
              title,
              r'BookmarkThreadResponseDto',
              'title',
            ),
            category: category,
            status: BuiltValueNullFieldError.checkNotNull(
              status,
              r'BookmarkThreadResponseDto',
              'status',
            ),
            visibility: BuiltValueNullFieldError.checkNotNull(
              visibility,
              r'BookmarkThreadResponseDto',
              'visibility',
            ),
            published: BuiltValueNullFieldError.checkNotNull(
              published,
              r'BookmarkThreadResponseDto',
              'published',
            ),
            pinned: BuiltValueNullFieldError.checkNotNull(
              pinned,
              r'BookmarkThreadResponseDto',
              'pinned',
            ),
            tipTotal: BuiltValueNullFieldError.checkNotNull(
              tipTotal,
              r'BookmarkThreadResponseDto',
              'tipTotal',
            ),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'BookmarkThreadResponseDto',
              'createdAt',
            ),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt,
              r'BookmarkThreadResponseDto',
              'updatedAt',
            ),
            deletedAt: deletedAt,
            owner: owner.build(),
            defaultSubthread: _defaultSubthread?.build(),
            topicTags: topicTags.build(),
            count: count.build(),
            preview: BuiltValueNullFieldError.checkNotNull(
              preview,
              r'BookmarkThreadResponseDto',
              'preview',
            ),
            coverImages: coverImages.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'owner';
        owner.build();
        _$failedField = 'defaultSubthread';
        _defaultSubthread?.build();
        _$failedField = 'topicTags';
        topicTags.build();
        _$failedField = 'count';
        count.build();

        _$failedField = 'coverImages';
        coverImages.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'BookmarkThreadResponseDto',
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
