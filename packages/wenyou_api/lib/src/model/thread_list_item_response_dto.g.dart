// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_list_item_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ThreadListItemResponseDtoStatusEnum
_$threadListItemResponseDtoStatusEnum_RECRUITING =
    const ThreadListItemResponseDtoStatusEnum._('RECRUITING');
const ThreadListItemResponseDtoStatusEnum
_$threadListItemResponseDtoStatusEnum_CLOSED =
    const ThreadListItemResponseDtoStatusEnum._('CLOSED');
const ThreadListItemResponseDtoStatusEnum
_$threadListItemResponseDtoStatusEnum_FINISHED =
    const ThreadListItemResponseDtoStatusEnum._('FINISHED');
const ThreadListItemResponseDtoStatusEnum
_$threadListItemResponseDtoStatusEnum_unknownDefaultOpenApi =
    const ThreadListItemResponseDtoStatusEnum._('unknownDefaultOpenApi');

ThreadListItemResponseDtoStatusEnum
_$threadListItemResponseDtoStatusEnumValueOf(String name) {
  switch (name) {
    case 'RECRUITING':
      return _$threadListItemResponseDtoStatusEnum_RECRUITING;
    case 'CLOSED':
      return _$threadListItemResponseDtoStatusEnum_CLOSED;
    case 'FINISHED':
      return _$threadListItemResponseDtoStatusEnum_FINISHED;
    case 'unknownDefaultOpenApi':
      return _$threadListItemResponseDtoStatusEnum_unknownDefaultOpenApi;
    default:
      return _$threadListItemResponseDtoStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadListItemResponseDtoStatusEnum>
_$threadListItemResponseDtoStatusEnumValues =
    BuiltSet<ThreadListItemResponseDtoStatusEnum>(
      const <ThreadListItemResponseDtoStatusEnum>[
        _$threadListItemResponseDtoStatusEnum_RECRUITING,
        _$threadListItemResponseDtoStatusEnum_CLOSED,
        _$threadListItemResponseDtoStatusEnum_FINISHED,
        _$threadListItemResponseDtoStatusEnum_unknownDefaultOpenApi,
      ],
    );

const ThreadListItemResponseDtoVisibilityEnum
_$threadListItemResponseDtoVisibilityEnum_PUBLIC =
    const ThreadListItemResponseDtoVisibilityEnum._('PUBLIC');
const ThreadListItemResponseDtoVisibilityEnum
_$threadListItemResponseDtoVisibilityEnum_PRIVATE =
    const ThreadListItemResponseDtoVisibilityEnum._('PRIVATE');
const ThreadListItemResponseDtoVisibilityEnum
_$threadListItemResponseDtoVisibilityEnum_unknownDefaultOpenApi =
    const ThreadListItemResponseDtoVisibilityEnum._('unknownDefaultOpenApi');

ThreadListItemResponseDtoVisibilityEnum
_$threadListItemResponseDtoVisibilityEnumValueOf(String name) {
  switch (name) {
    case 'PUBLIC':
      return _$threadListItemResponseDtoVisibilityEnum_PUBLIC;
    case 'PRIVATE':
      return _$threadListItemResponseDtoVisibilityEnum_PRIVATE;
    case 'unknownDefaultOpenApi':
      return _$threadListItemResponseDtoVisibilityEnum_unknownDefaultOpenApi;
    default:
      return _$threadListItemResponseDtoVisibilityEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadListItemResponseDtoVisibilityEnum>
_$threadListItemResponseDtoVisibilityEnumValues =
    BuiltSet<ThreadListItemResponseDtoVisibilityEnum>(
      const <ThreadListItemResponseDtoVisibilityEnum>[
        _$threadListItemResponseDtoVisibilityEnum_PUBLIC,
        _$threadListItemResponseDtoVisibilityEnum_PRIVATE,
        _$threadListItemResponseDtoVisibilityEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ThreadListItemResponseDtoStatusEnum>
_$threadListItemResponseDtoStatusEnumSerializer =
    _$ThreadListItemResponseDtoStatusEnumSerializer();
Serializer<ThreadListItemResponseDtoVisibilityEnum>
_$threadListItemResponseDtoVisibilityEnumSerializer =
    _$ThreadListItemResponseDtoVisibilityEnumSerializer();

class _$ThreadListItemResponseDtoStatusEnumSerializer
    implements PrimitiveSerializer<ThreadListItemResponseDtoStatusEnum> {
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
    ThreadListItemResponseDtoStatusEnum,
  ];
  @override
  final String wireName = 'ThreadListItemResponseDtoStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadListItemResponseDtoStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadListItemResponseDtoStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadListItemResponseDtoStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadListItemResponseDtoVisibilityEnumSerializer
    implements PrimitiveSerializer<ThreadListItemResponseDtoVisibilityEnum> {
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
    ThreadListItemResponseDtoVisibilityEnum,
  ];
  @override
  final String wireName = 'ThreadListItemResponseDtoVisibilityEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadListItemResponseDtoVisibilityEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadListItemResponseDtoVisibilityEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadListItemResponseDtoVisibilityEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadListItemResponseDto extends ThreadListItemResponseDto {
  @override
  final String id;
  @override
  final String title;
  @override
  final String? category;
  @override
  final ThreadCategoryInfoDto? categoryInfo;
  @override
  final ThreadListItemResponseDtoStatusEnum status;
  @override
  final ThreadListItemResponseDtoVisibilityEnum visibility;
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

  factory _$ThreadListItemResponseDto([
    void Function(ThreadListItemResponseDtoBuilder)? updates,
  ]) => (ThreadListItemResponseDtoBuilder()..update(updates))._build();

  _$ThreadListItemResponseDto._({
    required this.id,
    required this.title,
    this.category,
    this.categoryInfo,
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
  ThreadListItemResponseDto rebuild(
    void Function(ThreadListItemResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadListItemResponseDtoBuilder toBuilder() =>
      ThreadListItemResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadListItemResponseDto &&
        id == other.id &&
        title == other.title &&
        category == other.category &&
        categoryInfo == other.categoryInfo &&
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
    _$hash = $jc(_$hash, categoryInfo.hashCode);
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
    return (newBuiltValueToStringHelper(r'ThreadListItemResponseDto')
          ..add('id', id)
          ..add('title', title)
          ..add('category', category)
          ..add('categoryInfo', categoryInfo)
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

class ThreadListItemResponseDtoBuilder
    implements
        Builder<ThreadListItemResponseDto, ThreadListItemResponseDtoBuilder> {
  _$ThreadListItemResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _category;
  String? get category => _$this._category;
  set category(String? category) => _$this._category = category;

  ThreadCategoryInfoDtoBuilder? _categoryInfo;
  ThreadCategoryInfoDtoBuilder get categoryInfo =>
      _$this._categoryInfo ??= ThreadCategoryInfoDtoBuilder();
  set categoryInfo(ThreadCategoryInfoDtoBuilder? categoryInfo) =>
      _$this._categoryInfo = categoryInfo;

  ThreadListItemResponseDtoStatusEnum? _status;
  ThreadListItemResponseDtoStatusEnum? get status => _$this._status;
  set status(ThreadListItemResponseDtoStatusEnum? status) =>
      _$this._status = status;

  ThreadListItemResponseDtoVisibilityEnum? _visibility;
  ThreadListItemResponseDtoVisibilityEnum? get visibility => _$this._visibility;
  set visibility(ThreadListItemResponseDtoVisibilityEnum? visibility) =>
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

  ThreadListItemResponseDtoBuilder() {
    ThreadListItemResponseDto._defaults(this);
  }

  ThreadListItemResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _category = $v.category;
      _categoryInfo = $v.categoryInfo?.toBuilder();
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
  void replace(ThreadListItemResponseDto other) {
    _$v = other as _$ThreadListItemResponseDto;
  }

  @override
  void update(void Function(ThreadListItemResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadListItemResponseDto build() => _build();

  _$ThreadListItemResponseDto _build() {
    _$ThreadListItemResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$ThreadListItemResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'ThreadListItemResponseDto',
              'id',
            ),
            title: BuiltValueNullFieldError.checkNotNull(
              title,
              r'ThreadListItemResponseDto',
              'title',
            ),
            category: category,
            categoryInfo: _categoryInfo?.build(),
            status: BuiltValueNullFieldError.checkNotNull(
              status,
              r'ThreadListItemResponseDto',
              'status',
            ),
            visibility: BuiltValueNullFieldError.checkNotNull(
              visibility,
              r'ThreadListItemResponseDto',
              'visibility',
            ),
            published: BuiltValueNullFieldError.checkNotNull(
              published,
              r'ThreadListItemResponseDto',
              'published',
            ),
            pinned: BuiltValueNullFieldError.checkNotNull(
              pinned,
              r'ThreadListItemResponseDto',
              'pinned',
            ),
            tipTotal: BuiltValueNullFieldError.checkNotNull(
              tipTotal,
              r'ThreadListItemResponseDto',
              'tipTotal',
            ),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'ThreadListItemResponseDto',
              'createdAt',
            ),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt,
              r'ThreadListItemResponseDto',
              'updatedAt',
            ),
            deletedAt: deletedAt,
            owner: owner.build(),
            defaultSubthread: _defaultSubthread?.build(),
            topicTags: topicTags.build(),
            count: count.build(),
            preview: BuiltValueNullFieldError.checkNotNull(
              preview,
              r'ThreadListItemResponseDto',
              'preview',
            ),
            coverImages: coverImages.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'categoryInfo';
        _categoryInfo?.build();

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
          r'ThreadListItemResponseDto',
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
