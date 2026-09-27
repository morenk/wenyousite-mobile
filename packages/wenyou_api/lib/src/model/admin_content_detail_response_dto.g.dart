// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_content_detail_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminContentDetailResponseDtoTypeEnum
_$adminContentDetailResponseDtoTypeEnum_thread =
    const AdminContentDetailResponseDtoTypeEnum._('thread');
const AdminContentDetailResponseDtoTypeEnum
_$adminContentDetailResponseDtoTypeEnum_post =
    const AdminContentDetailResponseDtoTypeEnum._('post');
const AdminContentDetailResponseDtoTypeEnum
_$adminContentDetailResponseDtoTypeEnum_moment =
    const AdminContentDetailResponseDtoTypeEnum._('moment');
const AdminContentDetailResponseDtoTypeEnum
_$adminContentDetailResponseDtoTypeEnum_momentComment =
    const AdminContentDetailResponseDtoTypeEnum._('momentComment');
const AdminContentDetailResponseDtoTypeEnum
_$adminContentDetailResponseDtoTypeEnum_unknownDefaultOpenApi =
    const AdminContentDetailResponseDtoTypeEnum._('unknownDefaultOpenApi');

AdminContentDetailResponseDtoTypeEnum
_$adminContentDetailResponseDtoTypeEnumValueOf(String name) {
  switch (name) {
    case 'thread':
      return _$adminContentDetailResponseDtoTypeEnum_thread;
    case 'post':
      return _$adminContentDetailResponseDtoTypeEnum_post;
    case 'moment':
      return _$adminContentDetailResponseDtoTypeEnum_moment;
    case 'momentComment':
      return _$adminContentDetailResponseDtoTypeEnum_momentComment;
    case 'unknownDefaultOpenApi':
      return _$adminContentDetailResponseDtoTypeEnum_unknownDefaultOpenApi;
    default:
      return _$adminContentDetailResponseDtoTypeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminContentDetailResponseDtoTypeEnum>
_$adminContentDetailResponseDtoTypeEnumValues =
    BuiltSet<AdminContentDetailResponseDtoTypeEnum>(
      const <AdminContentDetailResponseDtoTypeEnum>[
        _$adminContentDetailResponseDtoTypeEnum_thread,
        _$adminContentDetailResponseDtoTypeEnum_post,
        _$adminContentDetailResponseDtoTypeEnum_moment,
        _$adminContentDetailResponseDtoTypeEnum_momentComment,
        _$adminContentDetailResponseDtoTypeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminContentDetailResponseDtoTypeEnum>
_$adminContentDetailResponseDtoTypeEnumSerializer =
    _$AdminContentDetailResponseDtoTypeEnumSerializer();

class _$AdminContentDetailResponseDtoTypeEnumSerializer
    implements PrimitiveSerializer<AdminContentDetailResponseDtoTypeEnum> {
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
  final Iterable<Type> types = const <Type>[
    AdminContentDetailResponseDtoTypeEnum,
  ];
  @override
  final String wireName = 'AdminContentDetailResponseDtoTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminContentDetailResponseDtoTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminContentDetailResponseDtoTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminContentDetailResponseDtoTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminContentDetailResponseDto extends AdminContentDetailResponseDto {
  @override
  final String id;
  @override
  final AdminContentDetailResponseDtoTypeEnum type;
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
  @override
  final String content;
  @override
  final BuiltList<String> mediaIds;
  @override
  final BuiltList<AdminContentMediaDto> media;
  @override
  final BuiltList<AdminAuditLogResponseDto> auditLogs;

  factory _$AdminContentDetailResponseDto([
    void Function(AdminContentDetailResponseDtoBuilder)? updates,
  ]) => (AdminContentDetailResponseDtoBuilder()..update(updates))._build();

  _$AdminContentDetailResponseDto._({
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
    required this.content,
    required this.mediaIds,
    required this.media,
    required this.auditLogs,
  }) : super._();
  @override
  AdminContentDetailResponseDto rebuild(
    void Function(AdminContentDetailResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminContentDetailResponseDtoBuilder toBuilder() =>
      AdminContentDetailResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminContentDetailResponseDto &&
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
        version == other.version &&
        content == other.content &&
        mediaIds == other.mediaIds &&
        media == other.media &&
        auditLogs == other.auditLogs;
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
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, mediaIds.hashCode);
    _$hash = $jc(_$hash, media.hashCode);
    _$hash = $jc(_$hash, auditLogs.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminContentDetailResponseDto')
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
          ..add('version', version)
          ..add('content', content)
          ..add('mediaIds', mediaIds)
          ..add('media', media)
          ..add('auditLogs', auditLogs))
        .toString();
  }
}

class AdminContentDetailResponseDtoBuilder
    implements
        Builder<
          AdminContentDetailResponseDto,
          AdminContentDetailResponseDtoBuilder
        > {
  _$AdminContentDetailResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  AdminContentDetailResponseDtoTypeEnum? _type;
  AdminContentDetailResponseDtoTypeEnum? get type => _$this._type;
  set type(AdminContentDetailResponseDtoTypeEnum? type) => _$this._type = type;

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

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  ListBuilder<String>? _mediaIds;
  ListBuilder<String> get mediaIds =>
      _$this._mediaIds ??= ListBuilder<String>();
  set mediaIds(ListBuilder<String>? mediaIds) => _$this._mediaIds = mediaIds;

  ListBuilder<AdminContentMediaDto>? _media;
  ListBuilder<AdminContentMediaDto> get media =>
      _$this._media ??= ListBuilder<AdminContentMediaDto>();
  set media(ListBuilder<AdminContentMediaDto>? media) => _$this._media = media;

  ListBuilder<AdminAuditLogResponseDto>? _auditLogs;
  ListBuilder<AdminAuditLogResponseDto> get auditLogs =>
      _$this._auditLogs ??= ListBuilder<AdminAuditLogResponseDto>();
  set auditLogs(ListBuilder<AdminAuditLogResponseDto>? auditLogs) =>
      _$this._auditLogs = auditLogs;

  AdminContentDetailResponseDtoBuilder() {
    AdminContentDetailResponseDto._defaults(this);
  }

  AdminContentDetailResponseDtoBuilder get _$this {
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
      _content = $v.content;
      _mediaIds = $v.mediaIds.toBuilder();
      _media = $v.media.toBuilder();
      _auditLogs = $v.auditLogs.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminContentDetailResponseDto other) {
    _$v = other as _$AdminContentDetailResponseDto;
  }

  @override
  void update(void Function(AdminContentDetailResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminContentDetailResponseDto build() => _build();

  _$AdminContentDetailResponseDto _build() {
    _$AdminContentDetailResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$AdminContentDetailResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'AdminContentDetailResponseDto',
              'id',
            ),
            type: BuiltValueNullFieldError.checkNotNull(
              type,
              r'AdminContentDetailResponseDto',
              'type',
            ),
            title: title,
            summary: BuiltValueNullFieldError.checkNotNull(
              summary,
              r'AdminContentDetailResponseDto',
              'summary',
            ),
            author: author.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'AdminContentDetailResponseDto',
              'createdAt',
            ),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt,
              r'AdminContentDetailResponseDto',
              'updatedAt',
            ),
            hidden: BuiltValueNullFieldError.checkNotNull(
              hidden,
              r'AdminContentDetailResponseDto',
              'hidden',
            ),
            parentHidden: BuiltValueNullFieldError.checkNotNull(
              parentHidden,
              r'AdminContentDetailResponseDto',
              'parentHidden',
            ),
            canRestore: BuiltValueNullFieldError.checkNotNull(
              canRestore,
              r'AdminContentDetailResponseDto',
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
            content: BuiltValueNullFieldError.checkNotNull(
              content,
              r'AdminContentDetailResponseDto',
              'content',
            ),
            mediaIds: mediaIds.build(),
            media: media.build(),
            auditLogs: auditLogs.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'author';
        author.build();

        _$failedField = 'tags';
        tags.build();

        _$failedField = 'mediaIds';
        mediaIds.build();
        _$failedField = 'media';
        media.build();
        _$failedField = 'auditLogs';
        auditLogs.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AdminContentDetailResponseDto',
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
