// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_detail_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ThreadDetailResponseDtoStatusEnum
_$threadDetailResponseDtoStatusEnum_RECRUITING =
    const ThreadDetailResponseDtoStatusEnum._('RECRUITING');
const ThreadDetailResponseDtoStatusEnum
_$threadDetailResponseDtoStatusEnum_CLOSED =
    const ThreadDetailResponseDtoStatusEnum._('CLOSED');
const ThreadDetailResponseDtoStatusEnum
_$threadDetailResponseDtoStatusEnum_FINISHED =
    const ThreadDetailResponseDtoStatusEnum._('FINISHED');
const ThreadDetailResponseDtoStatusEnum
_$threadDetailResponseDtoStatusEnum_unknownDefaultOpenApi =
    const ThreadDetailResponseDtoStatusEnum._('unknownDefaultOpenApi');

ThreadDetailResponseDtoStatusEnum _$threadDetailResponseDtoStatusEnumValueOf(
  String name,
) {
  switch (name) {
    case 'RECRUITING':
      return _$threadDetailResponseDtoStatusEnum_RECRUITING;
    case 'CLOSED':
      return _$threadDetailResponseDtoStatusEnum_CLOSED;
    case 'FINISHED':
      return _$threadDetailResponseDtoStatusEnum_FINISHED;
    case 'unknownDefaultOpenApi':
      return _$threadDetailResponseDtoStatusEnum_unknownDefaultOpenApi;
    default:
      return _$threadDetailResponseDtoStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadDetailResponseDtoStatusEnum>
_$threadDetailResponseDtoStatusEnumValues =
    BuiltSet<ThreadDetailResponseDtoStatusEnum>(
      const <ThreadDetailResponseDtoStatusEnum>[
        _$threadDetailResponseDtoStatusEnum_RECRUITING,
        _$threadDetailResponseDtoStatusEnum_CLOSED,
        _$threadDetailResponseDtoStatusEnum_FINISHED,
        _$threadDetailResponseDtoStatusEnum_unknownDefaultOpenApi,
      ],
    );

const ThreadDetailResponseDtoVisibilityEnum
_$threadDetailResponseDtoVisibilityEnum_PUBLIC =
    const ThreadDetailResponseDtoVisibilityEnum._('PUBLIC');
const ThreadDetailResponseDtoVisibilityEnum
_$threadDetailResponseDtoVisibilityEnum_PRIVATE =
    const ThreadDetailResponseDtoVisibilityEnum._('PRIVATE');
const ThreadDetailResponseDtoVisibilityEnum
_$threadDetailResponseDtoVisibilityEnum_unknownDefaultOpenApi =
    const ThreadDetailResponseDtoVisibilityEnum._('unknownDefaultOpenApi');

ThreadDetailResponseDtoVisibilityEnum
_$threadDetailResponseDtoVisibilityEnumValueOf(String name) {
  switch (name) {
    case 'PUBLIC':
      return _$threadDetailResponseDtoVisibilityEnum_PUBLIC;
    case 'PRIVATE':
      return _$threadDetailResponseDtoVisibilityEnum_PRIVATE;
    case 'unknownDefaultOpenApi':
      return _$threadDetailResponseDtoVisibilityEnum_unknownDefaultOpenApi;
    default:
      return _$threadDetailResponseDtoVisibilityEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadDetailResponseDtoVisibilityEnum>
_$threadDetailResponseDtoVisibilityEnumValues =
    BuiltSet<ThreadDetailResponseDtoVisibilityEnum>(
      const <ThreadDetailResponseDtoVisibilityEnum>[
        _$threadDetailResponseDtoVisibilityEnum_PUBLIC,
        _$threadDetailResponseDtoVisibilityEnum_PRIVATE,
        _$threadDetailResponseDtoVisibilityEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ThreadDetailResponseDtoStatusEnum>
_$threadDetailResponseDtoStatusEnumSerializer =
    _$ThreadDetailResponseDtoStatusEnumSerializer();
Serializer<ThreadDetailResponseDtoVisibilityEnum>
_$threadDetailResponseDtoVisibilityEnumSerializer =
    _$ThreadDetailResponseDtoVisibilityEnumSerializer();

class _$ThreadDetailResponseDtoStatusEnumSerializer
    implements PrimitiveSerializer<ThreadDetailResponseDtoStatusEnum> {
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
  final Iterable<Type> types = const <Type>[ThreadDetailResponseDtoStatusEnum];
  @override
  final String wireName = 'ThreadDetailResponseDtoStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadDetailResponseDtoStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadDetailResponseDtoStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadDetailResponseDtoStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadDetailResponseDtoVisibilityEnumSerializer
    implements PrimitiveSerializer<ThreadDetailResponseDtoVisibilityEnum> {
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
    ThreadDetailResponseDtoVisibilityEnum,
  ];
  @override
  final String wireName = 'ThreadDetailResponseDtoVisibilityEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadDetailResponseDtoVisibilityEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadDetailResponseDtoVisibilityEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadDetailResponseDtoVisibilityEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadDetailResponseDto extends ThreadDetailResponseDto {
  @override
  final String id;
  @override
  final String? title;
  @override
  final String ownerId;
  @override
  final String? category;
  @override
  final ThreadCategoryInfoDto? categoryInfo;
  @override
  final ThreadDetailResponseDtoStatusEnum status;
  @override
  final ThreadDetailResponseDtoVisibilityEnum visibility;
  @override
  final bool published;
  @override
  final DateTime? publishedAt;
  @override
  final bool pinned;
  @override
  final DateTime? pinnedAt;
  @override
  final num viewCount;
  @override
  final num version;
  @override
  final num likeCount;
  @override
  final String tipTotal;
  @override
  final String? defaultSubthreadId;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final PostAuthorResponseDto owner;
  @override
  final BuiltList<ThreadSubthreadResponseDto> subthreads;
  @override
  final BuiltList<ThreadTagRelationResponseDto> topicTags;
  @override
  final ThreadCountResponseDto count;
  @override
  final bool? isBookmarked;
  @override
  final String? bookmarkId;
  @override
  final String? bookmarkFolderId;
  @override
  final bool? isLiked;
  @override
  final CurrentThreadMembershipResponseDto? currentMembership;
  @override
  final ThreadCapabilitiesResponseDto? capabilities;

  factory _$ThreadDetailResponseDto([
    void Function(ThreadDetailResponseDtoBuilder)? updates,
  ]) => (ThreadDetailResponseDtoBuilder()..update(updates))._build();

  _$ThreadDetailResponseDto._({
    required this.id,
    this.title,
    required this.ownerId,
    this.category,
    this.categoryInfo,
    required this.status,
    required this.visibility,
    required this.published,
    this.publishedAt,
    required this.pinned,
    this.pinnedAt,
    required this.viewCount,
    required this.version,
    required this.likeCount,
    required this.tipTotal,
    this.defaultSubthreadId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.owner,
    required this.subthreads,
    required this.topicTags,
    required this.count,
    this.isBookmarked,
    this.bookmarkId,
    this.bookmarkFolderId,
    this.isLiked,
    this.currentMembership,
    this.capabilities,
  }) : super._();
  @override
  ThreadDetailResponseDto rebuild(
    void Function(ThreadDetailResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadDetailResponseDtoBuilder toBuilder() =>
      ThreadDetailResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadDetailResponseDto &&
        id == other.id &&
        title == other.title &&
        ownerId == other.ownerId &&
        category == other.category &&
        categoryInfo == other.categoryInfo &&
        status == other.status &&
        visibility == other.visibility &&
        published == other.published &&
        publishedAt == other.publishedAt &&
        pinned == other.pinned &&
        pinnedAt == other.pinnedAt &&
        viewCount == other.viewCount &&
        version == other.version &&
        likeCount == other.likeCount &&
        tipTotal == other.tipTotal &&
        defaultSubthreadId == other.defaultSubthreadId &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        deletedAt == other.deletedAt &&
        owner == other.owner &&
        subthreads == other.subthreads &&
        topicTags == other.topicTags &&
        count == other.count &&
        isBookmarked == other.isBookmarked &&
        bookmarkId == other.bookmarkId &&
        bookmarkFolderId == other.bookmarkFolderId &&
        isLiked == other.isLiked &&
        currentMembership == other.currentMembership &&
        capabilities == other.capabilities;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, ownerId.hashCode);
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, categoryInfo.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, visibility.hashCode);
    _$hash = $jc(_$hash, published.hashCode);
    _$hash = $jc(_$hash, publishedAt.hashCode);
    _$hash = $jc(_$hash, pinned.hashCode);
    _$hash = $jc(_$hash, pinnedAt.hashCode);
    _$hash = $jc(_$hash, viewCount.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, likeCount.hashCode);
    _$hash = $jc(_$hash, tipTotal.hashCode);
    _$hash = $jc(_$hash, defaultSubthreadId.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jc(_$hash, owner.hashCode);
    _$hash = $jc(_$hash, subthreads.hashCode);
    _$hash = $jc(_$hash, topicTags.hashCode);
    _$hash = $jc(_$hash, count.hashCode);
    _$hash = $jc(_$hash, isBookmarked.hashCode);
    _$hash = $jc(_$hash, bookmarkId.hashCode);
    _$hash = $jc(_$hash, bookmarkFolderId.hashCode);
    _$hash = $jc(_$hash, isLiked.hashCode);
    _$hash = $jc(_$hash, currentMembership.hashCode);
    _$hash = $jc(_$hash, capabilities.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ThreadDetailResponseDto')
          ..add('id', id)
          ..add('title', title)
          ..add('ownerId', ownerId)
          ..add('category', category)
          ..add('categoryInfo', categoryInfo)
          ..add('status', status)
          ..add('visibility', visibility)
          ..add('published', published)
          ..add('publishedAt', publishedAt)
          ..add('pinned', pinned)
          ..add('pinnedAt', pinnedAt)
          ..add('viewCount', viewCount)
          ..add('version', version)
          ..add('likeCount', likeCount)
          ..add('tipTotal', tipTotal)
          ..add('defaultSubthreadId', defaultSubthreadId)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('deletedAt', deletedAt)
          ..add('owner', owner)
          ..add('subthreads', subthreads)
          ..add('topicTags', topicTags)
          ..add('count', count)
          ..add('isBookmarked', isBookmarked)
          ..add('bookmarkId', bookmarkId)
          ..add('bookmarkFolderId', bookmarkFolderId)
          ..add('isLiked', isLiked)
          ..add('currentMembership', currentMembership)
          ..add('capabilities', capabilities))
        .toString();
  }
}

class ThreadDetailResponseDtoBuilder
    implements
        Builder<ThreadDetailResponseDto, ThreadDetailResponseDtoBuilder> {
  _$ThreadDetailResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _ownerId;
  String? get ownerId => _$this._ownerId;
  set ownerId(String? ownerId) => _$this._ownerId = ownerId;

  String? _category;
  String? get category => _$this._category;
  set category(String? category) => _$this._category = category;

  ThreadCategoryInfoDtoBuilder? _categoryInfo;
  ThreadCategoryInfoDtoBuilder get categoryInfo =>
      _$this._categoryInfo ??= ThreadCategoryInfoDtoBuilder();
  set categoryInfo(ThreadCategoryInfoDtoBuilder? categoryInfo) =>
      _$this._categoryInfo = categoryInfo;

  ThreadDetailResponseDtoStatusEnum? _status;
  ThreadDetailResponseDtoStatusEnum? get status => _$this._status;
  set status(ThreadDetailResponseDtoStatusEnum? status) =>
      _$this._status = status;

  ThreadDetailResponseDtoVisibilityEnum? _visibility;
  ThreadDetailResponseDtoVisibilityEnum? get visibility => _$this._visibility;
  set visibility(ThreadDetailResponseDtoVisibilityEnum? visibility) =>
      _$this._visibility = visibility;

  bool? _published;
  bool? get published => _$this._published;
  set published(bool? published) => _$this._published = published;

  DateTime? _publishedAt;
  DateTime? get publishedAt => _$this._publishedAt;
  set publishedAt(DateTime? publishedAt) => _$this._publishedAt = publishedAt;

  bool? _pinned;
  bool? get pinned => _$this._pinned;
  set pinned(bool? pinned) => _$this._pinned = pinned;

  DateTime? _pinnedAt;
  DateTime? get pinnedAt => _$this._pinnedAt;
  set pinnedAt(DateTime? pinnedAt) => _$this._pinnedAt = pinnedAt;

  num? _viewCount;
  num? get viewCount => _$this._viewCount;
  set viewCount(num? viewCount) => _$this._viewCount = viewCount;

  num? _version;
  num? get version => _$this._version;
  set version(num? version) => _$this._version = version;

  num? _likeCount;
  num? get likeCount => _$this._likeCount;
  set likeCount(num? likeCount) => _$this._likeCount = likeCount;

  String? _tipTotal;
  String? get tipTotal => _$this._tipTotal;
  set tipTotal(String? tipTotal) => _$this._tipTotal = tipTotal;

  String? _defaultSubthreadId;
  String? get defaultSubthreadId => _$this._defaultSubthreadId;
  set defaultSubthreadId(String? defaultSubthreadId) =>
      _$this._defaultSubthreadId = defaultSubthreadId;

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

  ListBuilder<ThreadSubthreadResponseDto>? _subthreads;
  ListBuilder<ThreadSubthreadResponseDto> get subthreads =>
      _$this._subthreads ??= ListBuilder<ThreadSubthreadResponseDto>();
  set subthreads(ListBuilder<ThreadSubthreadResponseDto>? subthreads) =>
      _$this._subthreads = subthreads;

  ListBuilder<ThreadTagRelationResponseDto>? _topicTags;
  ListBuilder<ThreadTagRelationResponseDto> get topicTags =>
      _$this._topicTags ??= ListBuilder<ThreadTagRelationResponseDto>();
  set topicTags(ListBuilder<ThreadTagRelationResponseDto>? topicTags) =>
      _$this._topicTags = topicTags;

  ThreadCountResponseDtoBuilder? _count;
  ThreadCountResponseDtoBuilder get count =>
      _$this._count ??= ThreadCountResponseDtoBuilder();
  set count(ThreadCountResponseDtoBuilder? count) => _$this._count = count;

  bool? _isBookmarked;
  bool? get isBookmarked => _$this._isBookmarked;
  set isBookmarked(bool? isBookmarked) => _$this._isBookmarked = isBookmarked;

  String? _bookmarkId;
  String? get bookmarkId => _$this._bookmarkId;
  set bookmarkId(String? bookmarkId) => _$this._bookmarkId = bookmarkId;

  String? _bookmarkFolderId;
  String? get bookmarkFolderId => _$this._bookmarkFolderId;
  set bookmarkFolderId(String? bookmarkFolderId) =>
      _$this._bookmarkFolderId = bookmarkFolderId;

  bool? _isLiked;
  bool? get isLiked => _$this._isLiked;
  set isLiked(bool? isLiked) => _$this._isLiked = isLiked;

  CurrentThreadMembershipResponseDtoBuilder? _currentMembership;
  CurrentThreadMembershipResponseDtoBuilder get currentMembership =>
      _$this._currentMembership ??= CurrentThreadMembershipResponseDtoBuilder();
  set currentMembership(
    CurrentThreadMembershipResponseDtoBuilder? currentMembership,
  ) => _$this._currentMembership = currentMembership;

  ThreadCapabilitiesResponseDtoBuilder? _capabilities;
  ThreadCapabilitiesResponseDtoBuilder get capabilities =>
      _$this._capabilities ??= ThreadCapabilitiesResponseDtoBuilder();
  set capabilities(ThreadCapabilitiesResponseDtoBuilder? capabilities) =>
      _$this._capabilities = capabilities;

  ThreadDetailResponseDtoBuilder() {
    ThreadDetailResponseDto._defaults(this);
  }

  ThreadDetailResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _ownerId = $v.ownerId;
      _category = $v.category;
      _categoryInfo = $v.categoryInfo?.toBuilder();
      _status = $v.status;
      _visibility = $v.visibility;
      _published = $v.published;
      _publishedAt = $v.publishedAt;
      _pinned = $v.pinned;
      _pinnedAt = $v.pinnedAt;
      _viewCount = $v.viewCount;
      _version = $v.version;
      _likeCount = $v.likeCount;
      _tipTotal = $v.tipTotal;
      _defaultSubthreadId = $v.defaultSubthreadId;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _deletedAt = $v.deletedAt;
      _owner = $v.owner.toBuilder();
      _subthreads = $v.subthreads.toBuilder();
      _topicTags = $v.topicTags.toBuilder();
      _count = $v.count.toBuilder();
      _isBookmarked = $v.isBookmarked;
      _bookmarkId = $v.bookmarkId;
      _bookmarkFolderId = $v.bookmarkFolderId;
      _isLiked = $v.isLiked;
      _currentMembership = $v.currentMembership?.toBuilder();
      _capabilities = $v.capabilities?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ThreadDetailResponseDto other) {
    _$v = other as _$ThreadDetailResponseDto;
  }

  @override
  void update(void Function(ThreadDetailResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadDetailResponseDto build() => _build();

  _$ThreadDetailResponseDto _build() {
    _$ThreadDetailResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$ThreadDetailResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'ThreadDetailResponseDto',
              'id',
            ),
            title: title,
            ownerId: BuiltValueNullFieldError.checkNotNull(
              ownerId,
              r'ThreadDetailResponseDto',
              'ownerId',
            ),
            category: category,
            categoryInfo: _categoryInfo?.build(),
            status: BuiltValueNullFieldError.checkNotNull(
              status,
              r'ThreadDetailResponseDto',
              'status',
            ),
            visibility: BuiltValueNullFieldError.checkNotNull(
              visibility,
              r'ThreadDetailResponseDto',
              'visibility',
            ),
            published: BuiltValueNullFieldError.checkNotNull(
              published,
              r'ThreadDetailResponseDto',
              'published',
            ),
            publishedAt: publishedAt,
            pinned: BuiltValueNullFieldError.checkNotNull(
              pinned,
              r'ThreadDetailResponseDto',
              'pinned',
            ),
            pinnedAt: pinnedAt,
            viewCount: BuiltValueNullFieldError.checkNotNull(
              viewCount,
              r'ThreadDetailResponseDto',
              'viewCount',
            ),
            version: BuiltValueNullFieldError.checkNotNull(
              version,
              r'ThreadDetailResponseDto',
              'version',
            ),
            likeCount: BuiltValueNullFieldError.checkNotNull(
              likeCount,
              r'ThreadDetailResponseDto',
              'likeCount',
            ),
            tipTotal: BuiltValueNullFieldError.checkNotNull(
              tipTotal,
              r'ThreadDetailResponseDto',
              'tipTotal',
            ),
            defaultSubthreadId: defaultSubthreadId,
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'ThreadDetailResponseDto',
              'createdAt',
            ),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt,
              r'ThreadDetailResponseDto',
              'updatedAt',
            ),
            deletedAt: deletedAt,
            owner: owner.build(),
            subthreads: subthreads.build(),
            topicTags: topicTags.build(),
            count: count.build(),
            isBookmarked: isBookmarked,
            bookmarkId: bookmarkId,
            bookmarkFolderId: bookmarkFolderId,
            isLiked: isLiked,
            currentMembership: _currentMembership?.build(),
            capabilities: _capabilities?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'categoryInfo';
        _categoryInfo?.build();

        _$failedField = 'owner';
        owner.build();
        _$failedField = 'subthreads';
        subthreads.build();
        _$failedField = 'topicTags';
        topicTags.build();
        _$failedField = 'count';
        count.build();

        _$failedField = 'currentMembership';
        _currentMembership?.build();
        _$failedField = 'capabilities';
        _capabilities?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'ThreadDetailResponseDto',
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
