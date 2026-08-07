// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subthread_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SubthreadResponseDtoPostingPolicyEnum
_$subthreadResponseDtoPostingPolicyEnum_PARTICIPANTS =
    const SubthreadResponseDtoPostingPolicyEnum._('PARTICIPANTS');
const SubthreadResponseDtoPostingPolicyEnum
_$subthreadResponseDtoPostingPolicyEnum_COLLABORATORS =
    const SubthreadResponseDtoPostingPolicyEnum._('COLLABORATORS');
const SubthreadResponseDtoPostingPolicyEnum
_$subthreadResponseDtoPostingPolicyEnum_PLAYERS =
    const SubthreadResponseDtoPostingPolicyEnum._('PLAYERS');
const SubthreadResponseDtoPostingPolicyEnum
_$subthreadResponseDtoPostingPolicyEnum_unknownDefaultOpenApi =
    const SubthreadResponseDtoPostingPolicyEnum._('unknownDefaultOpenApi');

SubthreadResponseDtoPostingPolicyEnum
_$subthreadResponseDtoPostingPolicyEnumValueOf(String name) {
  switch (name) {
    case 'PARTICIPANTS':
      return _$subthreadResponseDtoPostingPolicyEnum_PARTICIPANTS;
    case 'COLLABORATORS':
      return _$subthreadResponseDtoPostingPolicyEnum_COLLABORATORS;
    case 'PLAYERS':
      return _$subthreadResponseDtoPostingPolicyEnum_PLAYERS;
    case 'unknownDefaultOpenApi':
      return _$subthreadResponseDtoPostingPolicyEnum_unknownDefaultOpenApi;
    default:
      return _$subthreadResponseDtoPostingPolicyEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<SubthreadResponseDtoPostingPolicyEnum>
_$subthreadResponseDtoPostingPolicyEnumValues =
    BuiltSet<SubthreadResponseDtoPostingPolicyEnum>(
      const <SubthreadResponseDtoPostingPolicyEnum>[
        _$subthreadResponseDtoPostingPolicyEnum_PARTICIPANTS,
        _$subthreadResponseDtoPostingPolicyEnum_COLLABORATORS,
        _$subthreadResponseDtoPostingPolicyEnum_PLAYERS,
        _$subthreadResponseDtoPostingPolicyEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<SubthreadResponseDtoPostingPolicyEnum>
_$subthreadResponseDtoPostingPolicyEnumSerializer =
    _$SubthreadResponseDtoPostingPolicyEnumSerializer();

class _$SubthreadResponseDtoPostingPolicyEnumSerializer
    implements PrimitiveSerializer<SubthreadResponseDtoPostingPolicyEnum> {
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
    SubthreadResponseDtoPostingPolicyEnum,
  ];
  @override
  final String wireName = 'SubthreadResponseDtoPostingPolicyEnum';

  @override
  Object serialize(
    Serializers serializers,
    SubthreadResponseDtoPostingPolicyEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SubthreadResponseDtoPostingPolicyEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SubthreadResponseDtoPostingPolicyEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$SubthreadResponseDto extends SubthreadResponseDto {
  @override
  final String id;
  @override
  final String threadId;
  @override
  final String title;
  @override
  final num sortOrder;
  @override
  final SubthreadResponseDtoPostingPolicyEnum postingPolicy;
  @override
  final num version;
  @override
  final DateTime? lastPostAt;
  @override
  final DateTime? deletedAt;
  @override
  final DateTime createdAt;
  @override
  final SubthreadCountResponseDto count;
  @override
  final SubthreadThreadReferenceResponseDto? thread;

  factory _$SubthreadResponseDto([
    void Function(SubthreadResponseDtoBuilder)? updates,
  ]) => (SubthreadResponseDtoBuilder()..update(updates))._build();

  _$SubthreadResponseDto._({
    required this.id,
    required this.threadId,
    required this.title,
    required this.sortOrder,
    required this.postingPolicy,
    required this.version,
    this.lastPostAt,
    this.deletedAt,
    required this.createdAt,
    required this.count,
    this.thread,
  }) : super._();
  @override
  SubthreadResponseDto rebuild(
    void Function(SubthreadResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SubthreadResponseDtoBuilder toBuilder() =>
      SubthreadResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SubthreadResponseDto &&
        id == other.id &&
        threadId == other.threadId &&
        title == other.title &&
        sortOrder == other.sortOrder &&
        postingPolicy == other.postingPolicy &&
        version == other.version &&
        lastPostAt == other.lastPostAt &&
        deletedAt == other.deletedAt &&
        createdAt == other.createdAt &&
        count == other.count &&
        thread == other.thread;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, threadId.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, sortOrder.hashCode);
    _$hash = $jc(_$hash, postingPolicy.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, lastPostAt.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, count.hashCode);
    _$hash = $jc(_$hash, thread.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SubthreadResponseDto')
          ..add('id', id)
          ..add('threadId', threadId)
          ..add('title', title)
          ..add('sortOrder', sortOrder)
          ..add('postingPolicy', postingPolicy)
          ..add('version', version)
          ..add('lastPostAt', lastPostAt)
          ..add('deletedAt', deletedAt)
          ..add('createdAt', createdAt)
          ..add('count', count)
          ..add('thread', thread))
        .toString();
  }
}

class SubthreadResponseDtoBuilder
    implements Builder<SubthreadResponseDto, SubthreadResponseDtoBuilder> {
  _$SubthreadResponseDto? _$v;

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

  SubthreadResponseDtoPostingPolicyEnum? _postingPolicy;
  SubthreadResponseDtoPostingPolicyEnum? get postingPolicy =>
      _$this._postingPolicy;
  set postingPolicy(SubthreadResponseDtoPostingPolicyEnum? postingPolicy) =>
      _$this._postingPolicy = postingPolicy;

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

  SubthreadCountResponseDtoBuilder? _count;
  SubthreadCountResponseDtoBuilder get count =>
      _$this._count ??= SubthreadCountResponseDtoBuilder();
  set count(SubthreadCountResponseDtoBuilder? count) => _$this._count = count;

  SubthreadThreadReferenceResponseDtoBuilder? _thread;
  SubthreadThreadReferenceResponseDtoBuilder get thread =>
      _$this._thread ??= SubthreadThreadReferenceResponseDtoBuilder();
  set thread(SubthreadThreadReferenceResponseDtoBuilder? thread) =>
      _$this._thread = thread;

  SubthreadResponseDtoBuilder() {
    SubthreadResponseDto._defaults(this);
  }

  SubthreadResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _threadId = $v.threadId;
      _title = $v.title;
      _sortOrder = $v.sortOrder;
      _postingPolicy = $v.postingPolicy;
      _version = $v.version;
      _lastPostAt = $v.lastPostAt;
      _deletedAt = $v.deletedAt;
      _createdAt = $v.createdAt;
      _count = $v.count.toBuilder();
      _thread = $v.thread?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SubthreadResponseDto other) {
    _$v = other as _$SubthreadResponseDto;
  }

  @override
  void update(void Function(SubthreadResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SubthreadResponseDto build() => _build();

  _$SubthreadResponseDto _build() {
    _$SubthreadResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$SubthreadResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'SubthreadResponseDto',
              'id',
            ),
            threadId: BuiltValueNullFieldError.checkNotNull(
              threadId,
              r'SubthreadResponseDto',
              'threadId',
            ),
            title: BuiltValueNullFieldError.checkNotNull(
              title,
              r'SubthreadResponseDto',
              'title',
            ),
            sortOrder: BuiltValueNullFieldError.checkNotNull(
              sortOrder,
              r'SubthreadResponseDto',
              'sortOrder',
            ),
            postingPolicy: BuiltValueNullFieldError.checkNotNull(
              postingPolicy,
              r'SubthreadResponseDto',
              'postingPolicy',
            ),
            version: BuiltValueNullFieldError.checkNotNull(
              version,
              r'SubthreadResponseDto',
              'version',
            ),
            lastPostAt: lastPostAt,
            deletedAt: deletedAt,
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'SubthreadResponseDto',
              'createdAt',
            ),
            count: count.build(),
            thread: _thread?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'count';
        count.build();
        _$failedField = 'thread';
        _thread?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SubthreadResponseDto',
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
