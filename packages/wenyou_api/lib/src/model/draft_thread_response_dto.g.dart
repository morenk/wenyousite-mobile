// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_thread_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DraftThreadResponseDtoStatusEnum
_$draftThreadResponseDtoStatusEnum_RECRUITING =
    const DraftThreadResponseDtoStatusEnum._('RECRUITING');
const DraftThreadResponseDtoStatusEnum
_$draftThreadResponseDtoStatusEnum_CLOSED =
    const DraftThreadResponseDtoStatusEnum._('CLOSED');
const DraftThreadResponseDtoStatusEnum
_$draftThreadResponseDtoStatusEnum_FINISHED =
    const DraftThreadResponseDtoStatusEnum._('FINISHED');
const DraftThreadResponseDtoStatusEnum
_$draftThreadResponseDtoStatusEnum_unknownDefaultOpenApi =
    const DraftThreadResponseDtoStatusEnum._('unknownDefaultOpenApi');

DraftThreadResponseDtoStatusEnum _$draftThreadResponseDtoStatusEnumValueOf(
  String name,
) {
  switch (name) {
    case 'RECRUITING':
      return _$draftThreadResponseDtoStatusEnum_RECRUITING;
    case 'CLOSED':
      return _$draftThreadResponseDtoStatusEnum_CLOSED;
    case 'FINISHED':
      return _$draftThreadResponseDtoStatusEnum_FINISHED;
    case 'unknownDefaultOpenApi':
      return _$draftThreadResponseDtoStatusEnum_unknownDefaultOpenApi;
    default:
      return _$draftThreadResponseDtoStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<DraftThreadResponseDtoStatusEnum>
_$draftThreadResponseDtoStatusEnumValues =
    BuiltSet<DraftThreadResponseDtoStatusEnum>(
      const <DraftThreadResponseDtoStatusEnum>[
        _$draftThreadResponseDtoStatusEnum_RECRUITING,
        _$draftThreadResponseDtoStatusEnum_CLOSED,
        _$draftThreadResponseDtoStatusEnum_FINISHED,
        _$draftThreadResponseDtoStatusEnum_unknownDefaultOpenApi,
      ],
    );

const DraftThreadResponseDtoVisibilityEnum
_$draftThreadResponseDtoVisibilityEnum_PUBLIC =
    const DraftThreadResponseDtoVisibilityEnum._('PUBLIC');
const DraftThreadResponseDtoVisibilityEnum
_$draftThreadResponseDtoVisibilityEnum_PRIVATE =
    const DraftThreadResponseDtoVisibilityEnum._('PRIVATE');
const DraftThreadResponseDtoVisibilityEnum
_$draftThreadResponseDtoVisibilityEnum_unknownDefaultOpenApi =
    const DraftThreadResponseDtoVisibilityEnum._('unknownDefaultOpenApi');

DraftThreadResponseDtoVisibilityEnum
_$draftThreadResponseDtoVisibilityEnumValueOf(String name) {
  switch (name) {
    case 'PUBLIC':
      return _$draftThreadResponseDtoVisibilityEnum_PUBLIC;
    case 'PRIVATE':
      return _$draftThreadResponseDtoVisibilityEnum_PRIVATE;
    case 'unknownDefaultOpenApi':
      return _$draftThreadResponseDtoVisibilityEnum_unknownDefaultOpenApi;
    default:
      return _$draftThreadResponseDtoVisibilityEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<DraftThreadResponseDtoVisibilityEnum>
_$draftThreadResponseDtoVisibilityEnumValues =
    BuiltSet<DraftThreadResponseDtoVisibilityEnum>(
      const <DraftThreadResponseDtoVisibilityEnum>[
        _$draftThreadResponseDtoVisibilityEnum_PUBLIC,
        _$draftThreadResponseDtoVisibilityEnum_PRIVATE,
        _$draftThreadResponseDtoVisibilityEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<DraftThreadResponseDtoStatusEnum>
_$draftThreadResponseDtoStatusEnumSerializer =
    _$DraftThreadResponseDtoStatusEnumSerializer();
Serializer<DraftThreadResponseDtoVisibilityEnum>
_$draftThreadResponseDtoVisibilityEnumSerializer =
    _$DraftThreadResponseDtoVisibilityEnumSerializer();

class _$DraftThreadResponseDtoStatusEnumSerializer
    implements PrimitiveSerializer<DraftThreadResponseDtoStatusEnum> {
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
  final Iterable<Type> types = const <Type>[DraftThreadResponseDtoStatusEnum];
  @override
  final String wireName = 'DraftThreadResponseDtoStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    DraftThreadResponseDtoStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  DraftThreadResponseDtoStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DraftThreadResponseDtoStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$DraftThreadResponseDtoVisibilityEnumSerializer
    implements PrimitiveSerializer<DraftThreadResponseDtoVisibilityEnum> {
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
    DraftThreadResponseDtoVisibilityEnum,
  ];
  @override
  final String wireName = 'DraftThreadResponseDtoVisibilityEnum';

  @override
  Object serialize(
    Serializers serializers,
    DraftThreadResponseDtoVisibilityEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  DraftThreadResponseDtoVisibilityEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DraftThreadResponseDtoVisibilityEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$DraftThreadResponseDto extends DraftThreadResponseDto {
  @override
  final String id;
  @override
  final String title;
  @override
  final String? category;
  @override
  final ThreadCategoryInfoDto? categoryInfo;
  @override
  final DraftThreadResponseDtoStatusEnum status;
  @override
  final DraftThreadResponseDtoVisibilityEnum visibility;
  @override
  final bool published;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final String? defaultSubthreadId;
  @override
  final DraftDefaultSubthreadResponseDto? defaultSubthread;
  @override
  final BuiltList<ThreadTagRelationResponseDto> topicTags;
  @override
  final DraftThreadCountResponseDto count;

  factory _$DraftThreadResponseDto([
    void Function(DraftThreadResponseDtoBuilder)? updates,
  ]) => (DraftThreadResponseDtoBuilder()..update(updates))._build();

  _$DraftThreadResponseDto._({
    required this.id,
    required this.title,
    this.category,
    this.categoryInfo,
    required this.status,
    required this.visibility,
    required this.published,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.defaultSubthreadId,
    this.defaultSubthread,
    required this.topicTags,
    required this.count,
  }) : super._();
  @override
  DraftThreadResponseDto rebuild(
    void Function(DraftThreadResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DraftThreadResponseDtoBuilder toBuilder() =>
      DraftThreadResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DraftThreadResponseDto &&
        id == other.id &&
        title == other.title &&
        category == other.category &&
        categoryInfo == other.categoryInfo &&
        status == other.status &&
        visibility == other.visibility &&
        published == other.published &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        deletedAt == other.deletedAt &&
        defaultSubthreadId == other.defaultSubthreadId &&
        defaultSubthread == other.defaultSubthread &&
        topicTags == other.topicTags &&
        count == other.count;
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
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jc(_$hash, defaultSubthreadId.hashCode);
    _$hash = $jc(_$hash, defaultSubthread.hashCode);
    _$hash = $jc(_$hash, topicTags.hashCode);
    _$hash = $jc(_$hash, count.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DraftThreadResponseDto')
          ..add('id', id)
          ..add('title', title)
          ..add('category', category)
          ..add('categoryInfo', categoryInfo)
          ..add('status', status)
          ..add('visibility', visibility)
          ..add('published', published)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('deletedAt', deletedAt)
          ..add('defaultSubthreadId', defaultSubthreadId)
          ..add('defaultSubthread', defaultSubthread)
          ..add('topicTags', topicTags)
          ..add('count', count))
        .toString();
  }
}

class DraftThreadResponseDtoBuilder
    implements Builder<DraftThreadResponseDto, DraftThreadResponseDtoBuilder> {
  _$DraftThreadResponseDto? _$v;

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

  DraftThreadResponseDtoStatusEnum? _status;
  DraftThreadResponseDtoStatusEnum? get status => _$this._status;
  set status(DraftThreadResponseDtoStatusEnum? status) =>
      _$this._status = status;

  DraftThreadResponseDtoVisibilityEnum? _visibility;
  DraftThreadResponseDtoVisibilityEnum? get visibility => _$this._visibility;
  set visibility(DraftThreadResponseDtoVisibilityEnum? visibility) =>
      _$this._visibility = visibility;

  bool? _published;
  bool? get published => _$this._published;
  set published(bool? published) => _$this._published = published;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  String? _defaultSubthreadId;
  String? get defaultSubthreadId => _$this._defaultSubthreadId;
  set defaultSubthreadId(String? defaultSubthreadId) =>
      _$this._defaultSubthreadId = defaultSubthreadId;

  DraftDefaultSubthreadResponseDtoBuilder? _defaultSubthread;
  DraftDefaultSubthreadResponseDtoBuilder get defaultSubthread =>
      _$this._defaultSubthread ??= DraftDefaultSubthreadResponseDtoBuilder();
  set defaultSubthread(
    DraftDefaultSubthreadResponseDtoBuilder? defaultSubthread,
  ) => _$this._defaultSubthread = defaultSubthread;

  ListBuilder<ThreadTagRelationResponseDto>? _topicTags;
  ListBuilder<ThreadTagRelationResponseDto> get topicTags =>
      _$this._topicTags ??= ListBuilder<ThreadTagRelationResponseDto>();
  set topicTags(ListBuilder<ThreadTagRelationResponseDto>? topicTags) =>
      _$this._topicTags = topicTags;

  DraftThreadCountResponseDtoBuilder? _count;
  DraftThreadCountResponseDtoBuilder get count =>
      _$this._count ??= DraftThreadCountResponseDtoBuilder();
  set count(DraftThreadCountResponseDtoBuilder? count) => _$this._count = count;

  DraftThreadResponseDtoBuilder() {
    DraftThreadResponseDto._defaults(this);
  }

  DraftThreadResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _category = $v.category;
      _categoryInfo = $v.categoryInfo?.toBuilder();
      _status = $v.status;
      _visibility = $v.visibility;
      _published = $v.published;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _deletedAt = $v.deletedAt;
      _defaultSubthreadId = $v.defaultSubthreadId;
      _defaultSubthread = $v.defaultSubthread?.toBuilder();
      _topicTags = $v.topicTags.toBuilder();
      _count = $v.count.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DraftThreadResponseDto other) {
    _$v = other as _$DraftThreadResponseDto;
  }

  @override
  void update(void Function(DraftThreadResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DraftThreadResponseDto build() => _build();

  _$DraftThreadResponseDto _build() {
    _$DraftThreadResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$DraftThreadResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'DraftThreadResponseDto',
              'id',
            ),
            title: BuiltValueNullFieldError.checkNotNull(
              title,
              r'DraftThreadResponseDto',
              'title',
            ),
            category: category,
            categoryInfo: _categoryInfo?.build(),
            status: BuiltValueNullFieldError.checkNotNull(
              status,
              r'DraftThreadResponseDto',
              'status',
            ),
            visibility: BuiltValueNullFieldError.checkNotNull(
              visibility,
              r'DraftThreadResponseDto',
              'visibility',
            ),
            published: BuiltValueNullFieldError.checkNotNull(
              published,
              r'DraftThreadResponseDto',
              'published',
            ),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'DraftThreadResponseDto',
              'createdAt',
            ),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt,
              r'DraftThreadResponseDto',
              'updatedAt',
            ),
            deletedAt: deletedAt,
            defaultSubthreadId: defaultSubthreadId,
            defaultSubthread: _defaultSubthread?.build(),
            topicTags: topicTags.build(),
            count: count.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'categoryInfo';
        _categoryInfo?.build();

        _$failedField = 'defaultSubthread';
        _defaultSubthread?.build();
        _$failedField = 'topicTags';
        topicTags.build();
        _$failedField = 'count';
        count.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'DraftThreadResponseDto',
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
