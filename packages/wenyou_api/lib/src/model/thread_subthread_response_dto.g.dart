// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_subthread_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ThreadSubthreadResponseDtoPostingPolicyEnum
_$threadSubthreadResponseDtoPostingPolicyEnum_PARTICIPANTS =
    const ThreadSubthreadResponseDtoPostingPolicyEnum._('PARTICIPANTS');
const ThreadSubthreadResponseDtoPostingPolicyEnum
_$threadSubthreadResponseDtoPostingPolicyEnum_COLLABORATORS =
    const ThreadSubthreadResponseDtoPostingPolicyEnum._('COLLABORATORS');
const ThreadSubthreadResponseDtoPostingPolicyEnum
_$threadSubthreadResponseDtoPostingPolicyEnum_PLAYERS =
    const ThreadSubthreadResponseDtoPostingPolicyEnum._('PLAYERS');
const ThreadSubthreadResponseDtoPostingPolicyEnum
_$threadSubthreadResponseDtoPostingPolicyEnum_unknownDefaultOpenApi =
    const ThreadSubthreadResponseDtoPostingPolicyEnum._(
      'unknownDefaultOpenApi',
    );

ThreadSubthreadResponseDtoPostingPolicyEnum
_$threadSubthreadResponseDtoPostingPolicyEnumValueOf(String name) {
  switch (name) {
    case 'PARTICIPANTS':
      return _$threadSubthreadResponseDtoPostingPolicyEnum_PARTICIPANTS;
    case 'COLLABORATORS':
      return _$threadSubthreadResponseDtoPostingPolicyEnum_COLLABORATORS;
    case 'PLAYERS':
      return _$threadSubthreadResponseDtoPostingPolicyEnum_PLAYERS;
    case 'unknownDefaultOpenApi':
      return _$threadSubthreadResponseDtoPostingPolicyEnum_unknownDefaultOpenApi;
    default:
      return _$threadSubthreadResponseDtoPostingPolicyEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadSubthreadResponseDtoPostingPolicyEnum>
_$threadSubthreadResponseDtoPostingPolicyEnumValues =
    BuiltSet<ThreadSubthreadResponseDtoPostingPolicyEnum>(
      const <ThreadSubthreadResponseDtoPostingPolicyEnum>[
        _$threadSubthreadResponseDtoPostingPolicyEnum_PARTICIPANTS,
        _$threadSubthreadResponseDtoPostingPolicyEnum_COLLABORATORS,
        _$threadSubthreadResponseDtoPostingPolicyEnum_PLAYERS,
        _$threadSubthreadResponseDtoPostingPolicyEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ThreadSubthreadResponseDtoPostingPolicyEnum>
_$threadSubthreadResponseDtoPostingPolicyEnumSerializer =
    _$ThreadSubthreadResponseDtoPostingPolicyEnumSerializer();

class _$ThreadSubthreadResponseDtoPostingPolicyEnumSerializer
    implements
        PrimitiveSerializer<ThreadSubthreadResponseDtoPostingPolicyEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'PARTICIPANTS': 'PARTICIPANTS',
    'COLLABORATORS': 'COLLABORATORS',
    'PLAYERS': 'PLAYERS',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'PARTICIPANTS': 'PARTICIPANTS',
    'COLLABORATORS': 'COLLABORATORS',
    'PLAYERS': 'PLAYERS',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    ThreadSubthreadResponseDtoPostingPolicyEnum,
  ];
  @override
  final String wireName = 'ThreadSubthreadResponseDtoPostingPolicyEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadSubthreadResponseDtoPostingPolicyEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadSubthreadResponseDtoPostingPolicyEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadSubthreadResponseDtoPostingPolicyEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadSubthreadResponseDto extends ThreadSubthreadResponseDto {
  @override
  final String id;
  @override
  final String threadId;
  @override
  final String title;
  @override
  final num sortOrder;
  @override
  final ThreadSubthreadResponseDtoPostingPolicyEnum postingPolicy;
  @override
  final PostingCapabilityResponseDto postingCapability;
  @override
  final num version;
  @override
  final DateTime? lastPostAt;
  @override
  final DateTime? deletedAt;
  @override
  final DateTime createdAt;
  @override
  final ThreadBodyPostResponseDto? bodyPost;
  @override
  final ThreadSubthreadCountResponseDto count;

  factory _$ThreadSubthreadResponseDto([
    void Function(ThreadSubthreadResponseDtoBuilder)? updates,
  ]) => (ThreadSubthreadResponseDtoBuilder()..update(updates))._build();

  _$ThreadSubthreadResponseDto._({
    required this.id,
    required this.threadId,
    required this.title,
    required this.sortOrder,
    required this.postingPolicy,
    required this.postingCapability,
    required this.version,
    this.lastPostAt,
    this.deletedAt,
    required this.createdAt,
    this.bodyPost,
    required this.count,
  }) : super._();
  @override
  ThreadSubthreadResponseDto rebuild(
    void Function(ThreadSubthreadResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadSubthreadResponseDtoBuilder toBuilder() =>
      ThreadSubthreadResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadSubthreadResponseDto &&
        id == other.id &&
        threadId == other.threadId &&
        title == other.title &&
        sortOrder == other.sortOrder &&
        postingPolicy == other.postingPolicy &&
        postingCapability == other.postingCapability &&
        version == other.version &&
        lastPostAt == other.lastPostAt &&
        deletedAt == other.deletedAt &&
        createdAt == other.createdAt &&
        bodyPost == other.bodyPost &&
        count == other.count;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, threadId.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, sortOrder.hashCode);
    _$hash = $jc(_$hash, postingPolicy.hashCode);
    _$hash = $jc(_$hash, postingCapability.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, lastPostAt.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, bodyPost.hashCode);
    _$hash = $jc(_$hash, count.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ThreadSubthreadResponseDto')
          ..add('id', id)
          ..add('threadId', threadId)
          ..add('title', title)
          ..add('sortOrder', sortOrder)
          ..add('postingPolicy', postingPolicy)
          ..add('postingCapability', postingCapability)
          ..add('version', version)
          ..add('lastPostAt', lastPostAt)
          ..add('deletedAt', deletedAt)
          ..add('createdAt', createdAt)
          ..add('bodyPost', bodyPost)
          ..add('count', count))
        .toString();
  }
}

class ThreadSubthreadResponseDtoBuilder
    implements
        Builder<ThreadSubthreadResponseDto, ThreadSubthreadResponseDtoBuilder> {
  _$ThreadSubthreadResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _threadId;
  String? get threadId => _$this._threadId;
  set threadId(String? threadId) => _$this._threadId = threadId;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  num? _sortOrder;
  num? get sortOrder => _$this._sortOrder;
  set sortOrder(num? sortOrder) => _$this._sortOrder = sortOrder;

  ThreadSubthreadResponseDtoPostingPolicyEnum? _postingPolicy;
  ThreadSubthreadResponseDtoPostingPolicyEnum? get postingPolicy =>
      _$this._postingPolicy;
  set postingPolicy(
    ThreadSubthreadResponseDtoPostingPolicyEnum? postingPolicy,
  ) => _$this._postingPolicy = postingPolicy;

  PostingCapabilityResponseDtoBuilder? _postingCapability;
  PostingCapabilityResponseDtoBuilder get postingCapability =>
      _$this._postingCapability ??= PostingCapabilityResponseDtoBuilder();
  set postingCapability(
    PostingCapabilityResponseDtoBuilder? postingCapability,
  ) => _$this._postingCapability = postingCapability;

  num? _version;
  num? get version => _$this._version;
  set version(num? version) => _$this._version = version;

  DateTime? _lastPostAt;
  DateTime? get lastPostAt => _$this._lastPostAt;
  set lastPostAt(DateTime? lastPostAt) => _$this._lastPostAt = lastPostAt;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  ThreadBodyPostResponseDtoBuilder? _bodyPost;
  ThreadBodyPostResponseDtoBuilder get bodyPost =>
      _$this._bodyPost ??= ThreadBodyPostResponseDtoBuilder();
  set bodyPost(ThreadBodyPostResponseDtoBuilder? bodyPost) =>
      _$this._bodyPost = bodyPost;

  ThreadSubthreadCountResponseDtoBuilder? _count;
  ThreadSubthreadCountResponseDtoBuilder get count =>
      _$this._count ??= ThreadSubthreadCountResponseDtoBuilder();
  set count(ThreadSubthreadCountResponseDtoBuilder? count) =>
      _$this._count = count;

  ThreadSubthreadResponseDtoBuilder() {
    ThreadSubthreadResponseDto._defaults(this);
  }

  ThreadSubthreadResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _threadId = $v.threadId;
      _title = $v.title;
      _sortOrder = $v.sortOrder;
      _postingPolicy = $v.postingPolicy;
      _postingCapability = $v.postingCapability.toBuilder();
      _version = $v.version;
      _lastPostAt = $v.lastPostAt;
      _deletedAt = $v.deletedAt;
      _createdAt = $v.createdAt;
      _bodyPost = $v.bodyPost?.toBuilder();
      _count = $v.count.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ThreadSubthreadResponseDto other) {
    _$v = other as _$ThreadSubthreadResponseDto;
  }

  @override
  void update(void Function(ThreadSubthreadResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadSubthreadResponseDto build() => _build();

  _$ThreadSubthreadResponseDto _build() {
    _$ThreadSubthreadResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$ThreadSubthreadResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'ThreadSubthreadResponseDto',
              'id',
            ),
            threadId: BuiltValueNullFieldError.checkNotNull(
              threadId,
              r'ThreadSubthreadResponseDto',
              'threadId',
            ),
            title: BuiltValueNullFieldError.checkNotNull(
              title,
              r'ThreadSubthreadResponseDto',
              'title',
            ),
            sortOrder: BuiltValueNullFieldError.checkNotNull(
              sortOrder,
              r'ThreadSubthreadResponseDto',
              'sortOrder',
            ),
            postingPolicy: BuiltValueNullFieldError.checkNotNull(
              postingPolicy,
              r'ThreadSubthreadResponseDto',
              'postingPolicy',
            ),
            postingCapability: postingCapability.build(),
            version: BuiltValueNullFieldError.checkNotNull(
              version,
              r'ThreadSubthreadResponseDto',
              'version',
            ),
            lastPostAt: lastPostAt,
            deletedAt: deletedAt,
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'ThreadSubthreadResponseDto',
              'createdAt',
            ),
            bodyPost: _bodyPost?.build(),
            count: count.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'postingCapability';
        postingCapability.build();

        _$failedField = 'bodyPost';
        _bodyPost?.build();
        _$failedField = 'count';
        count.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'ThreadSubthreadResponseDto',
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
