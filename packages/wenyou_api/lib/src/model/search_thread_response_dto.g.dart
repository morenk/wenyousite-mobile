// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_thread_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SearchThreadResponseDtoStatusEnum
_$searchThreadResponseDtoStatusEnum_RECRUITING =
    const SearchThreadResponseDtoStatusEnum._('RECRUITING');
const SearchThreadResponseDtoStatusEnum
_$searchThreadResponseDtoStatusEnum_CLOSED =
    const SearchThreadResponseDtoStatusEnum._('CLOSED');
const SearchThreadResponseDtoStatusEnum
_$searchThreadResponseDtoStatusEnum_FINISHED =
    const SearchThreadResponseDtoStatusEnum._('FINISHED');
const SearchThreadResponseDtoStatusEnum
_$searchThreadResponseDtoStatusEnum_unknownDefaultOpenApi =
    const SearchThreadResponseDtoStatusEnum._('unknownDefaultOpenApi');

SearchThreadResponseDtoStatusEnum _$searchThreadResponseDtoStatusEnumValueOf(
  String name,
) {
  switch (name) {
    case 'RECRUITING':
      return _$searchThreadResponseDtoStatusEnum_RECRUITING;
    case 'CLOSED':
      return _$searchThreadResponseDtoStatusEnum_CLOSED;
    case 'FINISHED':
      return _$searchThreadResponseDtoStatusEnum_FINISHED;
    case 'unknownDefaultOpenApi':
      return _$searchThreadResponseDtoStatusEnum_unknownDefaultOpenApi;
    default:
      return _$searchThreadResponseDtoStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<SearchThreadResponseDtoStatusEnum>
_$searchThreadResponseDtoStatusEnumValues =
    BuiltSet<SearchThreadResponseDtoStatusEnum>(
      const <SearchThreadResponseDtoStatusEnum>[
        _$searchThreadResponseDtoStatusEnum_RECRUITING,
        _$searchThreadResponseDtoStatusEnum_CLOSED,
        _$searchThreadResponseDtoStatusEnum_FINISHED,
        _$searchThreadResponseDtoStatusEnum_unknownDefaultOpenApi,
      ],
    );

const SearchThreadResponseDtoVisibilityEnum
_$searchThreadResponseDtoVisibilityEnum_PUBLIC =
    const SearchThreadResponseDtoVisibilityEnum._('PUBLIC');
const SearchThreadResponseDtoVisibilityEnum
_$searchThreadResponseDtoVisibilityEnum_PRIVATE =
    const SearchThreadResponseDtoVisibilityEnum._('PRIVATE');
const SearchThreadResponseDtoVisibilityEnum
_$searchThreadResponseDtoVisibilityEnum_unknownDefaultOpenApi =
    const SearchThreadResponseDtoVisibilityEnum._('unknownDefaultOpenApi');

SearchThreadResponseDtoVisibilityEnum
_$searchThreadResponseDtoVisibilityEnumValueOf(String name) {
  switch (name) {
    case 'PUBLIC':
      return _$searchThreadResponseDtoVisibilityEnum_PUBLIC;
    case 'PRIVATE':
      return _$searchThreadResponseDtoVisibilityEnum_PRIVATE;
    case 'unknownDefaultOpenApi':
      return _$searchThreadResponseDtoVisibilityEnum_unknownDefaultOpenApi;
    default:
      return _$searchThreadResponseDtoVisibilityEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<SearchThreadResponseDtoVisibilityEnum>
_$searchThreadResponseDtoVisibilityEnumValues =
    BuiltSet<SearchThreadResponseDtoVisibilityEnum>(
      const <SearchThreadResponseDtoVisibilityEnum>[
        _$searchThreadResponseDtoVisibilityEnum_PUBLIC,
        _$searchThreadResponseDtoVisibilityEnum_PRIVATE,
        _$searchThreadResponseDtoVisibilityEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<SearchThreadResponseDtoStatusEnum>
_$searchThreadResponseDtoStatusEnumSerializer =
    _$SearchThreadResponseDtoStatusEnumSerializer();
Serializer<SearchThreadResponseDtoVisibilityEnum>
_$searchThreadResponseDtoVisibilityEnumSerializer =
    _$SearchThreadResponseDtoVisibilityEnumSerializer();

class _$SearchThreadResponseDtoStatusEnumSerializer
    implements PrimitiveSerializer<SearchThreadResponseDtoStatusEnum> {
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
  final Iterable<Type> types = const <Type>[SearchThreadResponseDtoStatusEnum];
  @override
  final String wireName = 'SearchThreadResponseDtoStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    SearchThreadResponseDtoStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SearchThreadResponseDtoStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SearchThreadResponseDtoStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$SearchThreadResponseDtoVisibilityEnumSerializer
    implements PrimitiveSerializer<SearchThreadResponseDtoVisibilityEnum> {
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
    SearchThreadResponseDtoVisibilityEnum,
  ];
  @override
  final String wireName = 'SearchThreadResponseDtoVisibilityEnum';

  @override
  Object serialize(
    Serializers serializers,
    SearchThreadResponseDtoVisibilityEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SearchThreadResponseDtoVisibilityEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SearchThreadResponseDtoVisibilityEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$SearchThreadResponseDto extends SearchThreadResponseDto {
  @override
  final String id;
  @override
  final String title;
  @override
  final String? category;
  @override
  final SearchThreadResponseDtoStatusEnum status;
  @override
  final SearchThreadResponseDtoVisibilityEnum visibility;
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
  final String? preview;
  @override
  final BuiltList<String> coverImages;
  @override
  final num? relevance;

  factory _$SearchThreadResponseDto([
    void Function(SearchThreadResponseDtoBuilder)? updates,
  ]) => (SearchThreadResponseDtoBuilder()..update(updates))._build();

  _$SearchThreadResponseDto._({
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
    this.preview,
    required this.coverImages,
    this.relevance,
  }) : super._();
  @override
  SearchThreadResponseDto rebuild(
    void Function(SearchThreadResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SearchThreadResponseDtoBuilder toBuilder() =>
      SearchThreadResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SearchThreadResponseDto &&
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
        coverImages == other.coverImages &&
        relevance == other.relevance;
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
    _$hash = $jc(_$hash, relevance.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SearchThreadResponseDto')
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
          ..add('coverImages', coverImages)
          ..add('relevance', relevance))
        .toString();
  }
}

class SearchThreadResponseDtoBuilder
    implements
        Builder<SearchThreadResponseDto, SearchThreadResponseDtoBuilder> {
  _$SearchThreadResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _category;
  String? get category => _$this._category;
  set category(String? category) => _$this._category = category;

  SearchThreadResponseDtoStatusEnum? _status;
  SearchThreadResponseDtoStatusEnum? get status => _$this._status;
  set status(SearchThreadResponseDtoStatusEnum? status) =>
      _$this._status = status;

  SearchThreadResponseDtoVisibilityEnum? _visibility;
  SearchThreadResponseDtoVisibilityEnum? get visibility => _$this._visibility;
  set visibility(SearchThreadResponseDtoVisibilityEnum? visibility) =>
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

  num? _relevance;
  num? get relevance => _$this._relevance;
  set relevance(num? relevance) => _$this._relevance = relevance;

  SearchThreadResponseDtoBuilder() {
    SearchThreadResponseDto._defaults(this);
  }

  SearchThreadResponseDtoBuilder get _$this {
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
      _relevance = $v.relevance;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SearchThreadResponseDto other) {
    _$v = other as _$SearchThreadResponseDto;
  }

  @override
  void update(void Function(SearchThreadResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SearchThreadResponseDto build() => _build();

  _$SearchThreadResponseDto _build() {
    _$SearchThreadResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$SearchThreadResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'SearchThreadResponseDto',
              'id',
            ),
            title: BuiltValueNullFieldError.checkNotNull(
              title,
              r'SearchThreadResponseDto',
              'title',
            ),
            category: category,
            status: BuiltValueNullFieldError.checkNotNull(
              status,
              r'SearchThreadResponseDto',
              'status',
            ),
            visibility: BuiltValueNullFieldError.checkNotNull(
              visibility,
              r'SearchThreadResponseDto',
              'visibility',
            ),
            published: BuiltValueNullFieldError.checkNotNull(
              published,
              r'SearchThreadResponseDto',
              'published',
            ),
            pinned: BuiltValueNullFieldError.checkNotNull(
              pinned,
              r'SearchThreadResponseDto',
              'pinned',
            ),
            tipTotal: BuiltValueNullFieldError.checkNotNull(
              tipTotal,
              r'SearchThreadResponseDto',
              'tipTotal',
            ),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'SearchThreadResponseDto',
              'createdAt',
            ),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt,
              r'SearchThreadResponseDto',
              'updatedAt',
            ),
            deletedAt: deletedAt,
            owner: owner.build(),
            defaultSubthread: _defaultSubthread?.build(),
            topicTags: topicTags.build(),
            count: count.build(),
            preview: preview,
            coverImages: coverImages.build(),
            relevance: relevance,
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
          r'SearchThreadResponseDto',
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
