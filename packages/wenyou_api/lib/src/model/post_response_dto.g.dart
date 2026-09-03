// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostResponseDtoKindEnum _$postResponseDtoKindEnum_BODY =
    const PostResponseDtoKindEnum._('BODY');
const PostResponseDtoKindEnum _$postResponseDtoKindEnum_FLOOR =
    const PostResponseDtoKindEnum._('FLOOR');
const PostResponseDtoKindEnum _$postResponseDtoKindEnum_unknownDefaultOpenApi =
    const PostResponseDtoKindEnum._('unknownDefaultOpenApi');

PostResponseDtoKindEnum _$postResponseDtoKindEnumValueOf(String name) {
  switch (name) {
    case 'BODY':
      return _$postResponseDtoKindEnum_BODY;
    case 'FLOOR':
      return _$postResponseDtoKindEnum_FLOOR;
    case 'unknownDefaultOpenApi':
      return _$postResponseDtoKindEnum_unknownDefaultOpenApi;
    default:
      return _$postResponseDtoKindEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<PostResponseDtoKindEnum> _$postResponseDtoKindEnumValues =
    BuiltSet<PostResponseDtoKindEnum>(const <PostResponseDtoKindEnum>[
      _$postResponseDtoKindEnum_BODY,
      _$postResponseDtoKindEnum_FLOOR,
      _$postResponseDtoKindEnum_unknownDefaultOpenApi,
    ]);

Serializer<PostResponseDtoKindEnum> _$postResponseDtoKindEnumSerializer =
    _$PostResponseDtoKindEnumSerializer();

class _$PostResponseDtoKindEnumSerializer
    implements PrimitiveSerializer<PostResponseDtoKindEnum> {
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
  final Iterable<Type> types = const <Type>[PostResponseDtoKindEnum];
  @override
  final String wireName = 'PostResponseDtoKindEnum';

  @override
  Object serialize(
    Serializers serializers,
    PostResponseDtoKindEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  PostResponseDtoKindEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => PostResponseDtoKindEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$PostResponseDto extends PostResponseDto {
  @override
  final String id;
  @override
  final String threadId;
  @override
  final String subthreadId;
  @override
  final String authorId;
  @override
  final PostResponseDtoKindEnum kind;
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
  final DateTime? pinnedAt;
  @override
  final DateTime? deletedAt;
  @override
  final PostAuthorResponseDto author;

  factory _$PostResponseDto([void Function(PostResponseDtoBuilder)? updates]) =>
      (PostResponseDtoBuilder()..update(updates))._build();

  _$PostResponseDto._({
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
    this.pinnedAt,
    this.deletedAt,
    required this.author,
  }) : super._();
  @override
  PostResponseDto rebuild(void Function(PostResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostResponseDtoBuilder toBuilder() => PostResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostResponseDto &&
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
        pinnedAt == other.pinnedAt &&
        deletedAt == other.deletedAt &&
        author == other.author;
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
    _$hash = $jc(_$hash, pinnedAt.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jc(_$hash, author.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostResponseDto')
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
          ..add('pinnedAt', pinnedAt)
          ..add('deletedAt', deletedAt)
          ..add('author', author))
        .toString();
  }
}

class PostResponseDtoBuilder
    implements Builder<PostResponseDto, PostResponseDtoBuilder> {
  _$PostResponseDto? _$v;

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

  PostResponseDtoKindEnum? _kind;
  PostResponseDtoKindEnum? get kind => _$this._kind;
  set kind(PostResponseDtoKindEnum? kind) => _$this._kind = kind;

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

  DateTime? _pinnedAt;
  DateTime? get pinnedAt => _$this._pinnedAt;
  set pinnedAt(DateTime? pinnedAt) => _$this._pinnedAt = pinnedAt;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  PostAuthorResponseDtoBuilder? _author;
  PostAuthorResponseDtoBuilder get author =>
      _$this._author ??= PostAuthorResponseDtoBuilder();
  set author(PostAuthorResponseDtoBuilder? author) => _$this._author = author;

  PostResponseDtoBuilder() {
    PostResponseDto._defaults(this);
  }

  PostResponseDtoBuilder get _$this {
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
      _pinnedAt = $v.pinnedAt;
      _deletedAt = $v.deletedAt;
      _author = $v.author.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostResponseDto other) {
    _$v = other as _$PostResponseDto;
  }

  @override
  void update(void Function(PostResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostResponseDto build() => _build();

  _$PostResponseDto _build() {
    _$PostResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$PostResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'PostResponseDto',
              'id',
            ),
            threadId: BuiltValueNullFieldError.checkNotNull(
              threadId,
              r'PostResponseDto',
              'threadId',
            ),
            subthreadId: BuiltValueNullFieldError.checkNotNull(
              subthreadId,
              r'PostResponseDto',
              'subthreadId',
            ),
            authorId: BuiltValueNullFieldError.checkNotNull(
              authorId,
              r'PostResponseDto',
              'authorId',
            ),
            kind: BuiltValueNullFieldError.checkNotNull(
              kind,
              r'PostResponseDto',
              'kind',
            ),
            floorNumber: floorNumber,
            parentPostId: parentPostId,
            replyToPostId: replyToPostId,
            clientRequestId: clientRequestId,
            content: BuiltValueNullFieldError.checkNotNull(
              content,
              r'PostResponseDto',
              'content',
            ),
            diceRolls: diceRolls.build(),
            version: BuiltValueNullFieldError.checkNotNull(
              version,
              r'PostResponseDto',
              'version',
            ),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'PostResponseDto',
              'createdAt',
            ),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt,
              r'PostResponseDto',
              'updatedAt',
            ),
            pinnedAt: pinnedAt,
            deletedAt: deletedAt,
            author: author.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'diceRolls';
        diceRolls.build();

        _$failedField = 'author';
        author.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'PostResponseDto',
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
