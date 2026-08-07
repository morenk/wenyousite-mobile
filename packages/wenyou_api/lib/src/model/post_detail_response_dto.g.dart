// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_detail_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostDetailResponseDtoKindEnum _$postDetailResponseDtoKindEnum_BODY =
    const PostDetailResponseDtoKindEnum._('BODY');
const PostDetailResponseDtoKindEnum _$postDetailResponseDtoKindEnum_FLOOR =
    const PostDetailResponseDtoKindEnum._('FLOOR');
const PostDetailResponseDtoKindEnum
_$postDetailResponseDtoKindEnum_unknownDefaultOpenApi =
    const PostDetailResponseDtoKindEnum._('unknownDefaultOpenApi');

PostDetailResponseDtoKindEnum _$postDetailResponseDtoKindEnumValueOf(
  String name,
) {
  switch (name) {
    case 'BODY':
      return _$postDetailResponseDtoKindEnum_BODY;
    case 'FLOOR':
      return _$postDetailResponseDtoKindEnum_FLOOR;
    case 'unknownDefaultOpenApi':
      return _$postDetailResponseDtoKindEnum_unknownDefaultOpenApi;
    default:
      return _$postDetailResponseDtoKindEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<PostDetailResponseDtoKindEnum>
_$postDetailResponseDtoKindEnumValues = BuiltSet<PostDetailResponseDtoKindEnum>(
  const <PostDetailResponseDtoKindEnum>[
    _$postDetailResponseDtoKindEnum_BODY,
    _$postDetailResponseDtoKindEnum_FLOOR,
    _$postDetailResponseDtoKindEnum_unknownDefaultOpenApi,
  ],
);

Serializer<PostDetailResponseDtoKindEnum>
_$postDetailResponseDtoKindEnumSerializer =
    _$PostDetailResponseDtoKindEnumSerializer();

class _$PostDetailResponseDtoKindEnumSerializer
    implements PrimitiveSerializer<PostDetailResponseDtoKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'BODY': 'BODY',
    'FLOOR': 'FLOOR',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'BODY': 'BODY',
    'FLOOR': 'FLOOR',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[PostDetailResponseDtoKindEnum];
  @override
  final String wireName = 'PostDetailResponseDtoKindEnum';

  @override
  Object serialize(
    Serializers serializers,
    PostDetailResponseDtoKindEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  PostDetailResponseDtoKindEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => PostDetailResponseDtoKindEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$PostDetailResponseDto extends PostDetailResponseDto {
  @override
  final String id;
  @override
  final String threadId;
  @override
  final String subthreadId;
  @override
  final String authorId;
  @override
  final PostDetailResponseDtoKindEnum kind;
  @override
  final num? floorNumber;
  @override
  final String? parentPostId;
  @override
  final String? replyToPostId;
  @override
  final String? clientRequestId;
  @override
  final String content;
  @override
  final BuiltList<DiceRollResponseDto> diceRolls;
  @override
  final num version;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final PostAuthorResponseDto author;
  @override
  final PostThreadResponseDto thread;
  @override
  final PostSubthreadResponseDto subthread;
  @override
  final ParentPostResponseDto? parentPost;
  @override
  final PostCountResponseDto count;

  factory _$PostDetailResponseDto([
    void Function(PostDetailResponseDtoBuilder)? updates,
  ]) => (PostDetailResponseDtoBuilder()..update(updates))._build();

  _$PostDetailResponseDto._({
    required this.id,
    required this.threadId,
    required this.subthreadId,
    required this.authorId,
    required this.kind,
    this.floorNumber,
    this.parentPostId,
    this.replyToPostId,
    this.clientRequestId,
    required this.content,
    required this.diceRolls,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.author,
    required this.thread,
    required this.subthread,
    this.parentPost,
    required this.count,
  }) : super._();
  @override
  PostDetailResponseDto rebuild(
    void Function(PostDetailResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  PostDetailResponseDtoBuilder toBuilder() =>
      PostDetailResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostDetailResponseDto &&
        id == other.id &&
        threadId == other.threadId &&
        subthreadId == other.subthreadId &&
        authorId == other.authorId &&
        kind == other.kind &&
        floorNumber == other.floorNumber &&
        parentPostId == other.parentPostId &&
        replyToPostId == other.replyToPostId &&
        clientRequestId == other.clientRequestId &&
        content == other.content &&
        diceRolls == other.diceRolls &&
        version == other.version &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        deletedAt == other.deletedAt &&
        author == other.author &&
        thread == other.thread &&
        subthread == other.subthread &&
        parentPost == other.parentPost &&
        count == other.count;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, threadId.hashCode);
    _$hash = $jc(_$hash, subthreadId.hashCode);
    _$hash = $jc(_$hash, authorId.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, floorNumber.hashCode);
    _$hash = $jc(_$hash, parentPostId.hashCode);
    _$hash = $jc(_$hash, replyToPostId.hashCode);
    _$hash = $jc(_$hash, clientRequestId.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, diceRolls.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jc(_$hash, author.hashCode);
    _$hash = $jc(_$hash, thread.hashCode);
    _$hash = $jc(_$hash, subthread.hashCode);
    _$hash = $jc(_$hash, parentPost.hashCode);
    _$hash = $jc(_$hash, count.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostDetailResponseDto')
          ..add('id', id)
          ..add('threadId', threadId)
          ..add('subthreadId', subthreadId)
          ..add('authorId', authorId)
          ..add('kind', kind)
          ..add('floorNumber', floorNumber)
          ..add('parentPostId', parentPostId)
          ..add('replyToPostId', replyToPostId)
          ..add('clientRequestId', clientRequestId)
          ..add('content', content)
          ..add('diceRolls', diceRolls)
          ..add('version', version)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('deletedAt', deletedAt)
          ..add('author', author)
          ..add('thread', thread)
          ..add('subthread', subthread)
          ..add('parentPost', parentPost)
          ..add('count', count))
        .toString();
  }
}

class PostDetailResponseDtoBuilder
    implements Builder<PostDetailResponseDto, PostDetailResponseDtoBuilder> {
  _$PostDetailResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _threadId;
  String? get threadId => _$this._threadId;
  set threadId(String? threadId) => _$this._threadId = threadId;

  String? _subthreadId;
  String? get subthreadId => _$this._subthreadId;
  set subthreadId(String? subthreadId) => _$this._subthreadId = subthreadId;

  String? _authorId;
  String? get authorId => _$this._authorId;
  set authorId(String? authorId) => _$this._authorId = authorId;

  PostDetailResponseDtoKindEnum? _kind;
  PostDetailResponseDtoKindEnum? get kind => _$this._kind;
  set kind(PostDetailResponseDtoKindEnum? kind) => _$this._kind = kind;

  num? _floorNumber;
  num? get floorNumber => _$this._floorNumber;
  set floorNumber(num? floorNumber) => _$this._floorNumber = floorNumber;

  String? _parentPostId;
  String? get parentPostId => _$this._parentPostId;
  set parentPostId(String? parentPostId) => _$this._parentPostId = parentPostId;

  String? _replyToPostId;
  String? get replyToPostId => _$this._replyToPostId;
  set replyToPostId(String? replyToPostId) =>
      _$this._replyToPostId = replyToPostId;

  String? _clientRequestId;
  String? get clientRequestId => _$this._clientRequestId;
  set clientRequestId(String? clientRequestId) =>
      _$this._clientRequestId = clientRequestId;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  ListBuilder<DiceRollResponseDto>? _diceRolls;
  ListBuilder<DiceRollResponseDto> get diceRolls =>
      _$this._diceRolls ??= ListBuilder<DiceRollResponseDto>();
  set diceRolls(ListBuilder<DiceRollResponseDto>? diceRolls) =>
      _$this._diceRolls = diceRolls;

  num? _version;
  num? get version => _$this._version;
  set version(num? version) => _$this._version = version;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  PostAuthorResponseDtoBuilder? _author;
  PostAuthorResponseDtoBuilder get author =>
      _$this._author ??= PostAuthorResponseDtoBuilder();
  set author(PostAuthorResponseDtoBuilder? author) => _$this._author = author;

  PostThreadResponseDtoBuilder? _thread;
  PostThreadResponseDtoBuilder get thread =>
      _$this._thread ??= PostThreadResponseDtoBuilder();
  set thread(PostThreadResponseDtoBuilder? thread) => _$this._thread = thread;

  PostSubthreadResponseDtoBuilder? _subthread;
  PostSubthreadResponseDtoBuilder get subthread =>
      _$this._subthread ??= PostSubthreadResponseDtoBuilder();
  set subthread(PostSubthreadResponseDtoBuilder? subthread) =>
      _$this._subthread = subthread;

  ParentPostResponseDtoBuilder? _parentPost;
  ParentPostResponseDtoBuilder get parentPost =>
      _$this._parentPost ??= ParentPostResponseDtoBuilder();
  set parentPost(ParentPostResponseDtoBuilder? parentPost) =>
      _$this._parentPost = parentPost;

  PostCountResponseDtoBuilder? _count;
  PostCountResponseDtoBuilder get count =>
      _$this._count ??= PostCountResponseDtoBuilder();
  set count(PostCountResponseDtoBuilder? count) => _$this._count = count;

  PostDetailResponseDtoBuilder() {
    PostDetailResponseDto._defaults(this);
  }

  PostDetailResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _threadId = $v.threadId;
      _subthreadId = $v.subthreadId;
      _authorId = $v.authorId;
      _kind = $v.kind;
      _floorNumber = $v.floorNumber;
      _parentPostId = $v.parentPostId;
      _replyToPostId = $v.replyToPostId;
      _clientRequestId = $v.clientRequestId;
      _content = $v.content;
      _diceRolls = $v.diceRolls.toBuilder();
      _version = $v.version;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _deletedAt = $v.deletedAt;
      _author = $v.author.toBuilder();
      _thread = $v.thread.toBuilder();
      _subthread = $v.subthread.toBuilder();
      _parentPost = $v.parentPost?.toBuilder();
      _count = $v.count.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostDetailResponseDto other) {
    _$v = other as _$PostDetailResponseDto;
  }

  @override
  void update(void Function(PostDetailResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostDetailResponseDto build() => _build();

  _$PostDetailResponseDto _build() {
    _$PostDetailResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$PostDetailResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'PostDetailResponseDto',
              'id',
            ),
            threadId: BuiltValueNullFieldError.checkNotNull(
              threadId,
              r'PostDetailResponseDto',
              'threadId',
            ),
            subthreadId: BuiltValueNullFieldError.checkNotNull(
              subthreadId,
              r'PostDetailResponseDto',
              'subthreadId',
            ),
            authorId: BuiltValueNullFieldError.checkNotNull(
              authorId,
              r'PostDetailResponseDto',
              'authorId',
            ),
            kind: BuiltValueNullFieldError.checkNotNull(
              kind,
              r'PostDetailResponseDto',
              'kind',
            ),
            floorNumber: floorNumber,
            parentPostId: parentPostId,
            replyToPostId: replyToPostId,
            clientRequestId: clientRequestId,
            content: BuiltValueNullFieldError.checkNotNull(
              content,
              r'PostDetailResponseDto',
              'content',
            ),
            diceRolls: diceRolls.build(),
            version: BuiltValueNullFieldError.checkNotNull(
              version,
              r'PostDetailResponseDto',
              'version',
            ),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'PostDetailResponseDto',
              'createdAt',
            ),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt,
              r'PostDetailResponseDto',
              'updatedAt',
            ),
            deletedAt: deletedAt,
            author: author.build(),
            thread: thread.build(),
            subthread: subthread.build(),
            parentPost: _parentPost?.build(),
            count: count.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'diceRolls';
        diceRolls.build();

        _$failedField = 'author';
        author.build();
        _$failedField = 'thread';
        thread.build();
        _$failedField = 'subthread';
        subthread.build();
        _$failedField = 'parentPost';
        _parentPost?.build();
        _$failedField = 'count';
        count.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'PostDetailResponseDto',
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
