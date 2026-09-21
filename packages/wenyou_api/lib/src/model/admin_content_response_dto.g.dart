// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_content_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminContentResponseDtoTypeEnum _$adminContentResponseDtoTypeEnum_thread =
    const AdminContentResponseDtoTypeEnum._('thread');
const AdminContentResponseDtoTypeEnum _$adminContentResponseDtoTypeEnum_post =
    const AdminContentResponseDtoTypeEnum._('post');
const AdminContentResponseDtoTypeEnum _$adminContentResponseDtoTypeEnum_moment =
    const AdminContentResponseDtoTypeEnum._('moment');
const AdminContentResponseDtoTypeEnum
_$adminContentResponseDtoTypeEnum_momentComment =
    const AdminContentResponseDtoTypeEnum._('momentComment');
const AdminContentResponseDtoTypeEnum
_$adminContentResponseDtoTypeEnum_unknownDefaultOpenApi =
    const AdminContentResponseDtoTypeEnum._('unknownDefaultOpenApi');

AdminContentResponseDtoTypeEnum _$adminContentResponseDtoTypeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'thread':
      return _$adminContentResponseDtoTypeEnum_thread;
    case 'post':
      return _$adminContentResponseDtoTypeEnum_post;
    case 'moment':
      return _$adminContentResponseDtoTypeEnum_moment;
    case 'momentComment':
      return _$adminContentResponseDtoTypeEnum_momentComment;
    case 'unknownDefaultOpenApi':
      return _$adminContentResponseDtoTypeEnum_unknownDefaultOpenApi;
    default:
      return _$adminContentResponseDtoTypeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminContentResponseDtoTypeEnum>
_$adminContentResponseDtoTypeEnumValues =
    BuiltSet<AdminContentResponseDtoTypeEnum>(
      const <AdminContentResponseDtoTypeEnum>[
        _$adminContentResponseDtoTypeEnum_thread,
        _$adminContentResponseDtoTypeEnum_post,
        _$adminContentResponseDtoTypeEnum_moment,
        _$adminContentResponseDtoTypeEnum_momentComment,
        _$adminContentResponseDtoTypeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminContentResponseDtoTypeEnum>
_$adminContentResponseDtoTypeEnumSerializer =
    _$AdminContentResponseDtoTypeEnumSerializer();

class _$AdminContentResponseDtoTypeEnumSerializer
    implements PrimitiveSerializer<AdminContentResponseDtoTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'thread': 'thread',
    'post': 'post',
    'moment': 'moment',
    'momentComment': 'moment_comment',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'thread': 'thread',
    'post': 'post',
    'moment': 'moment',
    'moment_comment': 'momentComment',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[AdminContentResponseDtoTypeEnum];
  @override
  final String wireName = 'AdminContentResponseDtoTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminContentResponseDtoTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminContentResponseDtoTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminContentResponseDtoTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminContentResponseDto extends AdminContentResponseDto {
  @override
  final String id;
  @override
  final AdminContentResponseDtoTypeEnum type;
  @override
  final String? title;
  @override
  final String summary;
  @override
  final AdminHiddenContentUserResponseDto author;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final bool hidden;
  @override
  final bool parentHidden;
  @override
  final bool canRestore;
  @override
  final String? restoreBlockedReason;
  @override
  final String? threadId;
  @override
  final String? parentPostId;
  @override
  final String? momentId;
  @override
  final String? parentCommentId;
  @override
  final String? category;
  @override
  final BuiltList<AdminContentTagDto> tags;
  @override
  final num? version;

  factory _$AdminContentResponseDto([
    void Function(AdminContentResponseDtoBuilder)? updates,
  ]) => (AdminContentResponseDtoBuilder()..update(updates))._build();

  _$AdminContentResponseDto._({
    required this.id,
    required this.type,
    this.title,
    required this.summary,
    required this.author,
    required this.createdAt,
    required this.updatedAt,
    required this.hidden,
    required this.parentHidden,
    required this.canRestore,
    this.restoreBlockedReason,
    this.threadId,
    this.parentPostId,
    this.momentId,
    this.parentCommentId,
    this.category,
    required this.tags,
    this.version,
  }) : super._();
  @override
  AdminContentResponseDto rebuild(
    void Function(AdminContentResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminContentResponseDtoBuilder toBuilder() =>
      AdminContentResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminContentResponseDto &&
        id == other.id &&
        type == other.type &&
        title == other.title &&
        summary == other.summary &&
        author == other.author &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        hidden == other.hidden &&
        parentHidden == other.parentHidden &&
        canRestore == other.canRestore &&
        restoreBlockedReason == other.restoreBlockedReason &&
        threadId == other.threadId &&
        parentPostId == other.parentPostId &&
        momentId == other.momentId &&
        parentCommentId == other.parentCommentId &&
        category == other.category &&
        tags == other.tags &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, summary.hashCode);
    _$hash = $jc(_$hash, author.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, hidden.hashCode);
    _$hash = $jc(_$hash, parentHidden.hashCode);
    _$hash = $jc(_$hash, canRestore.hashCode);
    _$hash = $jc(_$hash, restoreBlockedReason.hashCode);
    _$hash = $jc(_$hash, threadId.hashCode);
    _$hash = $jc(_$hash, parentPostId.hashCode);
    _$hash = $jc(_$hash, momentId.hashCode);
    _$hash = $jc(_$hash, parentCommentId.hashCode);
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, tags.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminContentResponseDto')
          ..add('id', id)
          ..add('type', type)
          ..add('title', title)
          ..add('summary', summary)
          ..add('author', author)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('hidden', hidden)
          ..add('parentHidden', parentHidden)
          ..add('canRestore', canRestore)
          ..add('restoreBlockedReason', restoreBlockedReason)
          ..add('threadId', threadId)
          ..add('parentPostId', parentPostId)
          ..add('momentId', momentId)
          ..add('parentCommentId', parentCommentId)
          ..add('category', category)
          ..add('tags', tags)
          ..add('version', version))
        .toString();
  }
}

class AdminContentResponseDtoBuilder
    implements
        Builder<AdminContentResponseDto, AdminContentResponseDtoBuilder> {
  _$AdminContentResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  AdminContentResponseDtoTypeEnum? _type;
  AdminContentResponseDtoTypeEnum? get type => _$this._type;
  set type(AdminContentResponseDtoTypeEnum? type) => _$this._type = type;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _summary;
  String? get summary => _$this._summary;
  set summary(String? summary) => _$this._summary = summary;

  AdminHiddenContentUserResponseDtoBuilder? _author;
  AdminHiddenContentUserResponseDtoBuilder get author =>
      _$this._author ??= AdminHiddenContentUserResponseDtoBuilder();
  set author(AdminHiddenContentUserResponseDtoBuilder? author) =>
      _$this._author = author;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  bool? _hidden;
  bool? get hidden => _$this._hidden;
  set hidden(bool? hidden) => _$this._hidden = hidden;

  bool? _parentHidden;
  bool? get parentHidden => _$this._parentHidden;
  set parentHidden(bool? parentHidden) => _$this._parentHidden = parentHidden;

  bool? _canRestore;
  bool? get canRestore => _$this._canRestore;
  set canRestore(bool? canRestore) => _$this._canRestore = canRestore;

  String? _restoreBlockedReason;
  String? get restoreBlockedReason => _$this._restoreBlockedReason;
  set restoreBlockedReason(String? restoreBlockedReason) =>
      _$this._restoreBlockedReason = restoreBlockedReason;

  String? _threadId;
  String? get threadId => _$this._threadId;
  set threadId(String? threadId) => _$this._threadId = threadId;

  String? _parentPostId;
  String? get parentPostId => _$this._parentPostId;
  set parentPostId(String? parentPostId) => _$this._parentPostId = parentPostId;

  String? _momentId;
  String? get momentId => _$this._momentId;
  set momentId(String? momentId) => _$this._momentId = momentId;

  String? _parentCommentId;
  String? get parentCommentId => _$this._parentCommentId;
  set parentCommentId(String? parentCommentId) =>
      _$this._parentCommentId = parentCommentId;

  String? _category;
  String? get category => _$this._category;
  set category(String? category) => _$this._category = category;

  ListBuilder<AdminContentTagDto>? _tags;
  ListBuilder<AdminContentTagDto> get tags =>
      _$this._tags ??= ListBuilder<AdminContentTagDto>();
  set tags(ListBuilder<AdminContentTagDto>? tags) => _$this._tags = tags;

  num? _version;
  num? get version => _$this._version;
  set version(num? version) => _$this._version = version;

  AdminContentResponseDtoBuilder() {
    AdminContentResponseDto._defaults(this);
  }

  AdminContentResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _type = $v.type;
      _title = $v.title;
      _summary = $v.summary;
      _author = $v.author.toBuilder();
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _hidden = $v.hidden;
      _parentHidden = $v.parentHidden;
      _canRestore = $v.canRestore;
      _restoreBlockedReason = $v.restoreBlockedReason;
      _threadId = $v.threadId;
      _parentPostId = $v.parentPostId;
      _momentId = $v.momentId;
      _parentCommentId = $v.parentCommentId;
      _category = $v.category;
      _tags = $v.tags.toBuilder();
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminContentResponseDto other) {
    _$v = other as _$AdminContentResponseDto;
  }

  @override
  void update(void Function(AdminContentResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminContentResponseDto build() => _build();

  _$AdminContentResponseDto _build() {
    _$AdminContentResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$AdminContentResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'AdminContentResponseDto',
              'id',
            ),
            type: BuiltValueNullFieldError.checkNotNull(
              type,
              r'AdminContentResponseDto',
              'type',
            ),
            title: title,
            summary: BuiltValueNullFieldError.checkNotNull(
              summary,
              r'AdminContentResponseDto',
              'summary',
            ),
            author: author.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'AdminContentResponseDto',
              'createdAt',
            ),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt,
              r'AdminContentResponseDto',
              'updatedAt',
            ),
            hidden: BuiltValueNullFieldError.checkNotNull(
              hidden,
              r'AdminContentResponseDto',
              'hidden',
            ),
            parentHidden: BuiltValueNullFieldError.checkNotNull(
              parentHidden,
              r'AdminContentResponseDto',
              'parentHidden',
            ),
            canRestore: BuiltValueNullFieldError.checkNotNull(
              canRestore,
              r'AdminContentResponseDto',
              'canRestore',
            ),
            restoreBlockedReason: restoreBlockedReason,
            threadId: threadId,
            parentPostId: parentPostId,
            momentId: momentId,
            parentCommentId: parentCommentId,
            category: category,
            tags: tags.build(),
            version: version,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'author';
        author.build();

        _$failedField = 'tags';
        tags.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AdminContentResponseDto',
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
