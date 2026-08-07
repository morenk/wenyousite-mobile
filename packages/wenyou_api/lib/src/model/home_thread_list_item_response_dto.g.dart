// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_thread_list_item_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const HomeThreadListItemResponseDtoCategoryEnum
_$homeThreadListItemResponseDtoCategoryEnum_DEDUCTION =
    const HomeThreadListItemResponseDtoCategoryEnum._('DEDUCTION');
const HomeThreadListItemResponseDtoCategoryEnum
_$homeThreadListItemResponseDtoCategoryEnum_NATION =
    const HomeThreadListItemResponseDtoCategoryEnum._('NATION');
const HomeThreadListItemResponseDtoCategoryEnum
_$homeThreadListItemResponseDtoCategoryEnum_RPG =
    const HomeThreadListItemResponseDtoCategoryEnum._('RPG');
const HomeThreadListItemResponseDtoCategoryEnum
_$homeThreadListItemResponseDtoCategoryEnum_unknownDefaultOpenApi =
    const HomeThreadListItemResponseDtoCategoryEnum._('unknownDefaultOpenApi');

HomeThreadListItemResponseDtoCategoryEnum
_$homeThreadListItemResponseDtoCategoryEnumValueOf(String name) {
  switch (name) {
    case 'DEDUCTION':
      return _$homeThreadListItemResponseDtoCategoryEnum_DEDUCTION;
    case 'NATION':
      return _$homeThreadListItemResponseDtoCategoryEnum_NATION;
    case 'RPG':
      return _$homeThreadListItemResponseDtoCategoryEnum_RPG;
    case 'unknownDefaultOpenApi':
      return _$homeThreadListItemResponseDtoCategoryEnum_unknownDefaultOpenApi;
    default:
      return _$homeThreadListItemResponseDtoCategoryEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<HomeThreadListItemResponseDtoCategoryEnum>
_$homeThreadListItemResponseDtoCategoryEnumValues =
    BuiltSet<HomeThreadListItemResponseDtoCategoryEnum>(
      const <HomeThreadListItemResponseDtoCategoryEnum>[
        _$homeThreadListItemResponseDtoCategoryEnum_DEDUCTION,
        _$homeThreadListItemResponseDtoCategoryEnum_NATION,
        _$homeThreadListItemResponseDtoCategoryEnum_RPG,
        _$homeThreadListItemResponseDtoCategoryEnum_unknownDefaultOpenApi,
      ],
    );

const HomeThreadListItemResponseDtoStatusEnum
_$homeThreadListItemResponseDtoStatusEnum_RECRUITING =
    const HomeThreadListItemResponseDtoStatusEnum._('RECRUITING');
const HomeThreadListItemResponseDtoStatusEnum
_$homeThreadListItemResponseDtoStatusEnum_CLOSED =
    const HomeThreadListItemResponseDtoStatusEnum._('CLOSED');
const HomeThreadListItemResponseDtoStatusEnum
_$homeThreadListItemResponseDtoStatusEnum_FINISHED =
    const HomeThreadListItemResponseDtoStatusEnum._('FINISHED');
const HomeThreadListItemResponseDtoStatusEnum
_$homeThreadListItemResponseDtoStatusEnum_unknownDefaultOpenApi =
    const HomeThreadListItemResponseDtoStatusEnum._('unknownDefaultOpenApi');

HomeThreadListItemResponseDtoStatusEnum
_$homeThreadListItemResponseDtoStatusEnumValueOf(String name) {
  switch (name) {
    case 'RECRUITING':
      return _$homeThreadListItemResponseDtoStatusEnum_RECRUITING;
    case 'CLOSED':
      return _$homeThreadListItemResponseDtoStatusEnum_CLOSED;
    case 'FINISHED':
      return _$homeThreadListItemResponseDtoStatusEnum_FINISHED;
    case 'unknownDefaultOpenApi':
      return _$homeThreadListItemResponseDtoStatusEnum_unknownDefaultOpenApi;
    default:
      return _$homeThreadListItemResponseDtoStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<HomeThreadListItemResponseDtoStatusEnum>
_$homeThreadListItemResponseDtoStatusEnumValues =
    BuiltSet<HomeThreadListItemResponseDtoStatusEnum>(
      const <HomeThreadListItemResponseDtoStatusEnum>[
        _$homeThreadListItemResponseDtoStatusEnum_RECRUITING,
        _$homeThreadListItemResponseDtoStatusEnum_CLOSED,
        _$homeThreadListItemResponseDtoStatusEnum_FINISHED,
        _$homeThreadListItemResponseDtoStatusEnum_unknownDefaultOpenApi,
      ],
    );

const HomeThreadListItemResponseDtoVisibilityEnum
_$homeThreadListItemResponseDtoVisibilityEnum_PUBLIC =
    const HomeThreadListItemResponseDtoVisibilityEnum._('PUBLIC');
const HomeThreadListItemResponseDtoVisibilityEnum
_$homeThreadListItemResponseDtoVisibilityEnum_PRIVATE =
    const HomeThreadListItemResponseDtoVisibilityEnum._('PRIVATE');
const HomeThreadListItemResponseDtoVisibilityEnum
_$homeThreadListItemResponseDtoVisibilityEnum_unknownDefaultOpenApi =
    const HomeThreadListItemResponseDtoVisibilityEnum._(
      'unknownDefaultOpenApi',
    );

HomeThreadListItemResponseDtoVisibilityEnum
_$homeThreadListItemResponseDtoVisibilityEnumValueOf(String name) {
  switch (name) {
    case 'PUBLIC':
      return _$homeThreadListItemResponseDtoVisibilityEnum_PUBLIC;
    case 'PRIVATE':
      return _$homeThreadListItemResponseDtoVisibilityEnum_PRIVATE;
    case 'unknownDefaultOpenApi':
      return _$homeThreadListItemResponseDtoVisibilityEnum_unknownDefaultOpenApi;
    default:
      return _$homeThreadListItemResponseDtoVisibilityEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<HomeThreadListItemResponseDtoVisibilityEnum>
_$homeThreadListItemResponseDtoVisibilityEnumValues =
    BuiltSet<HomeThreadListItemResponseDtoVisibilityEnum>(
      const <HomeThreadListItemResponseDtoVisibilityEnum>[
        _$homeThreadListItemResponseDtoVisibilityEnum_PUBLIC,
        _$homeThreadListItemResponseDtoVisibilityEnum_PRIVATE,
        _$homeThreadListItemResponseDtoVisibilityEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<HomeThreadListItemResponseDtoCategoryEnum>
_$homeThreadListItemResponseDtoCategoryEnumSerializer =
    _$HomeThreadListItemResponseDtoCategoryEnumSerializer();
Serializer<HomeThreadListItemResponseDtoStatusEnum>
_$homeThreadListItemResponseDtoStatusEnumSerializer =
    _$HomeThreadListItemResponseDtoStatusEnumSerializer();
Serializer<HomeThreadListItemResponseDtoVisibilityEnum>
_$homeThreadListItemResponseDtoVisibilityEnumSerializer =
    _$HomeThreadListItemResponseDtoVisibilityEnumSerializer();

class _$HomeThreadListItemResponseDtoCategoryEnumSerializer
    implements PrimitiveSerializer<HomeThreadListItemResponseDtoCategoryEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'DEDUCTION': 'DEDUCTION',
    'NATION': 'NATION',
    'RPG': 'RPG',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'DEDUCTION': 'DEDUCTION',
    'NATION': 'NATION',
    'RPG': 'RPG',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    HomeThreadListItemResponseDtoCategoryEnum,
  ];
  @override
  final String wireName = 'HomeThreadListItemResponseDtoCategoryEnum';

  @override
  Object serialize(
    Serializers serializers,
    HomeThreadListItemResponseDtoCategoryEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  HomeThreadListItemResponseDtoCategoryEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => HomeThreadListItemResponseDtoCategoryEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$HomeThreadListItemResponseDtoStatusEnumSerializer
    implements PrimitiveSerializer<HomeThreadListItemResponseDtoStatusEnum> {
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
    HomeThreadListItemResponseDtoStatusEnum,
  ];
  @override
  final String wireName = 'HomeThreadListItemResponseDtoStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    HomeThreadListItemResponseDtoStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  HomeThreadListItemResponseDtoStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => HomeThreadListItemResponseDtoStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$HomeThreadListItemResponseDtoVisibilityEnumSerializer
    implements
        PrimitiveSerializer<HomeThreadListItemResponseDtoVisibilityEnum> {
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
    HomeThreadListItemResponseDtoVisibilityEnum,
  ];
  @override
  final String wireName = 'HomeThreadListItemResponseDtoVisibilityEnum';

  @override
  Object serialize(
    Serializers serializers,
    HomeThreadListItemResponseDtoVisibilityEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  HomeThreadListItemResponseDtoVisibilityEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => HomeThreadListItemResponseDtoVisibilityEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$HomeThreadListItemResponseDto extends HomeThreadListItemResponseDto {
  @override
  final String id;
  @override
  final String title;
  @override
  final HomeThreadListItemResponseDtoCategoryEnum category;
  @override
  final HomeThreadListItemResponseDtoStatusEnum status;
  @override
  final HomeThreadListItemResponseDtoVisibilityEnum visibility;
  @override
  final bool published;
  @override
  final bool pinned;
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

  factory _$HomeThreadListItemResponseDto([
    void Function(HomeThreadListItemResponseDtoBuilder)? updates,
  ]) => (HomeThreadListItemResponseDtoBuilder()..update(updates))._build();

  _$HomeThreadListItemResponseDto._({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.visibility,
    required this.published,
    required this.pinned,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.owner,
    this.defaultSubthread,
    required this.topicTags,
    required this.count,
    this.preview,
  }) : super._();
  @override
  HomeThreadListItemResponseDto rebuild(
    void Function(HomeThreadListItemResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  HomeThreadListItemResponseDtoBuilder toBuilder() =>
      HomeThreadListItemResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is HomeThreadListItemResponseDto &&
        id == other.id &&
        title == other.title &&
        category == other.category &&
        status == other.status &&
        visibility == other.visibility &&
        published == other.published &&
        pinned == other.pinned &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        deletedAt == other.deletedAt &&
        owner == other.owner &&
        defaultSubthread == other.defaultSubthread &&
        topicTags == other.topicTags &&
        count == other.count &&
        preview == other.preview;
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
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jc(_$hash, owner.hashCode);
    _$hash = $jc(_$hash, defaultSubthread.hashCode);
    _$hash = $jc(_$hash, topicTags.hashCode);
    _$hash = $jc(_$hash, count.hashCode);
    _$hash = $jc(_$hash, preview.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'HomeThreadListItemResponseDto')
          ..add('id', id)
          ..add('title', title)
          ..add('category', category)
          ..add('status', status)
          ..add('visibility', visibility)
          ..add('published', published)
          ..add('pinned', pinned)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('deletedAt', deletedAt)
          ..add('owner', owner)
          ..add('defaultSubthread', defaultSubthread)
          ..add('topicTags', topicTags)
          ..add('count', count)
          ..add('preview', preview))
        .toString();
  }
}

class HomeThreadListItemResponseDtoBuilder
    implements
        Builder<
          HomeThreadListItemResponseDto,
          HomeThreadListItemResponseDtoBuilder
        > {
  _$HomeThreadListItemResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  HomeThreadListItemResponseDtoCategoryEnum? _category;
  HomeThreadListItemResponseDtoCategoryEnum? get category => _$this._category;
  set category(HomeThreadListItemResponseDtoCategoryEnum? category) =>
      _$this._category = category;

  HomeThreadListItemResponseDtoStatusEnum? _status;
  HomeThreadListItemResponseDtoStatusEnum? get status => _$this._status;
  set status(HomeThreadListItemResponseDtoStatusEnum? status) =>
      _$this._status = status;

  HomeThreadListItemResponseDtoVisibilityEnum? _visibility;
  HomeThreadListItemResponseDtoVisibilityEnum? get visibility =>
      _$this._visibility;
  set visibility(HomeThreadListItemResponseDtoVisibilityEnum? visibility) =>
      _$this._visibility = visibility;

  bool? _published;
  bool? get published => _$this._published;
  set published(bool? published) => _$this._published = published;

  bool? _pinned;
  bool? get pinned => _$this._pinned;
  set pinned(bool? pinned) => _$this._pinned = pinned;

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

  HomeThreadListItemResponseDtoBuilder() {
    HomeThreadListItemResponseDto._defaults(this);
  }

  HomeThreadListItemResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _category = $v.category;
      _status = $v.status;
      _visibility = $v.visibility;
      _published = $v.published;
      _pinned = $v.pinned;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _deletedAt = $v.deletedAt;
      _owner = $v.owner.toBuilder();
      _defaultSubthread = $v.defaultSubthread?.toBuilder();
      _topicTags = $v.topicTags.toBuilder();
      _count = $v.count.toBuilder();
      _preview = $v.preview;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(HomeThreadListItemResponseDto other) {
    _$v = other as _$HomeThreadListItemResponseDto;
  }

  @override
  void update(void Function(HomeThreadListItemResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  HomeThreadListItemResponseDto build() => _build();

  _$HomeThreadListItemResponseDto _build() {
    _$HomeThreadListItemResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$HomeThreadListItemResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'HomeThreadListItemResponseDto',
              'id',
            ),
            title: BuiltValueNullFieldError.checkNotNull(
              title,
              r'HomeThreadListItemResponseDto',
              'title',
            ),
            category: BuiltValueNullFieldError.checkNotNull(
              category,
              r'HomeThreadListItemResponseDto',
              'category',
            ),
            status: BuiltValueNullFieldError.checkNotNull(
              status,
              r'HomeThreadListItemResponseDto',
              'status',
            ),
            visibility: BuiltValueNullFieldError.checkNotNull(
              visibility,
              r'HomeThreadListItemResponseDto',
              'visibility',
            ),
            published: BuiltValueNullFieldError.checkNotNull(
              published,
              r'HomeThreadListItemResponseDto',
              'published',
            ),
            pinned: BuiltValueNullFieldError.checkNotNull(
              pinned,
              r'HomeThreadListItemResponseDto',
              'pinned',
            ),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'HomeThreadListItemResponseDto',
              'createdAt',
            ),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt,
              r'HomeThreadListItemResponseDto',
              'updatedAt',
            ),
            deletedAt: deletedAt,
            owner: owner.build(),
            defaultSubthread: _defaultSubthread?.build(),
            topicTags: topicTags.build(),
            count: count.build(),
            preview: preview,
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
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'HomeThreadListItemResponseDto',
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
