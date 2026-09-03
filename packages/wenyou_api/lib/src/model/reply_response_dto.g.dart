// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reply_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ReplyResponseDtoKindEnum _$replyResponseDtoKindEnum_BODY =
    const ReplyResponseDtoKindEnum._('BODY');
const ReplyResponseDtoKindEnum _$replyResponseDtoKindEnum_FLOOR =
    const ReplyResponseDtoKindEnum._('FLOOR');
const ReplyResponseDtoKindEnum
_$replyResponseDtoKindEnum_unknownDefaultOpenApi =
    const ReplyResponseDtoKindEnum._('unknownDefaultOpenApi');

ReplyResponseDtoKindEnum _$replyResponseDtoKindEnumValueOf(String name) {
  switch (name) {
    case 'BODY':
      return _$replyResponseDtoKindEnum_BODY;
    case 'FLOOR':
      return _$replyResponseDtoKindEnum_FLOOR;
    case 'unknownDefaultOpenApi':
      return _$replyResponseDtoKindEnum_unknownDefaultOpenApi;
    default:
      return _$replyResponseDtoKindEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ReplyResponseDtoKindEnum> _$replyResponseDtoKindEnumValues =
    BuiltSet<ReplyResponseDtoKindEnum>(const <ReplyResponseDtoKindEnum>[
      _$replyResponseDtoKindEnum_BODY,
      _$replyResponseDtoKindEnum_FLOOR,
      _$replyResponseDtoKindEnum_unknownDefaultOpenApi,
    ]);

Serializer<ReplyResponseDtoKindEnum> _$replyResponseDtoKindEnumSerializer =
    _$ReplyResponseDtoKindEnumSerializer();

class _$ReplyResponseDtoKindEnumSerializer
    implements PrimitiveSerializer<ReplyResponseDtoKindEnum> {
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
  final Iterable<Type> types = const <Type>[ReplyResponseDtoKindEnum];
  @override
  final String wireName = 'ReplyResponseDtoKindEnum';

  @override
  Object serialize(
    Serializers serializers,
    ReplyResponseDtoKindEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ReplyResponseDtoKindEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ReplyResponseDtoKindEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ReplyResponseDto extends ReplyResponseDto {
  @override
  final String id;
  @override
  final String threadId;
  @override
  final String subthreadId;
  @override
  final String authorId;
  @override
  final ReplyResponseDtoKindEnum kind;
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
  @override
  final ReplyTargetResponseDto? replyToPost;

  factory _$ReplyResponseDto([
    void Function(ReplyResponseDtoBuilder)? updates,
  ]) => (ReplyResponseDtoBuilder()..update(updates))._build();

  _$ReplyResponseDto._({
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
    this.replyToPost,
  }) : super._();
  @override
  ReplyResponseDto rebuild(void Function(ReplyResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReplyResponseDtoBuilder toBuilder() =>
      ReplyResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReplyResponseDto &&
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
        author == other.author &&
        replyToPost == other.replyToPost;
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
    _$hash = $jc(_$hash, replyToPost.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReplyResponseDto')
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
          ..add('author', author)
          ..add('replyToPost', replyToPost))
        .toString();
  }
}

class ReplyResponseDtoBuilder
    implements Builder<ReplyResponseDto, ReplyResponseDtoBuilder> {
  _$ReplyResponseDto? _$v;

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

  ReplyResponseDtoKindEnum? _kind;
  ReplyResponseDtoKindEnum? get kind => _$this._kind;
  set kind(ReplyResponseDtoKindEnum? kind) => _$this._kind = kind;

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

  ReplyTargetResponseDtoBuilder? _replyToPost;
  ReplyTargetResponseDtoBuilder get replyToPost =>
      _$this._replyToPost ??= ReplyTargetResponseDtoBuilder();
  set replyToPost(ReplyTargetResponseDtoBuilder? replyToPost) =>
      _$this._replyToPost = replyToPost;

  ReplyResponseDtoBuilder() {
    ReplyResponseDto._defaults(this);
  }

  ReplyResponseDtoBuilder get _$this {
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
      _replyToPost = $v.replyToPost?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReplyResponseDto other) {
    _$v = other as _$ReplyResponseDto;
  }

  @override
  void update(void Function(ReplyResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReplyResponseDto build() => _build();

  _$ReplyResponseDto _build() {
    _$ReplyResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$ReplyResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'ReplyResponseDto',
              'id',
            ),
            threadId: BuiltValueNullFieldError.checkNotNull(
              threadId,
              r'ReplyResponseDto',
              'threadId',
            ),
            subthreadId: BuiltValueNullFieldError.checkNotNull(
              subthreadId,
              r'ReplyResponseDto',
              'subthreadId',
            ),
            authorId: BuiltValueNullFieldError.checkNotNull(
              authorId,
              r'ReplyResponseDto',
              'authorId',
            ),
            kind: BuiltValueNullFieldError.checkNotNull(
              kind,
              r'ReplyResponseDto',
              'kind',
            ),
            floorNumber: floorNumber,
            parentPostId: parentPostId,
            replyToPostId: replyToPostId,
            clientRequestId: clientRequestId,
            content: BuiltValueNullFieldError.checkNotNull(
              content,
              r'ReplyResponseDto',
              'content',
            ),
            diceRolls: diceRolls.build(),
            version: BuiltValueNullFieldError.checkNotNull(
              version,
              r'ReplyResponseDto',
              'version',
            ),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'ReplyResponseDto',
              'createdAt',
            ),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt,
              r'ReplyResponseDto',
              'updatedAt',
            ),
            pinnedAt: pinnedAt,
            deletedAt: deletedAt,
            author: author.build(),
            replyToPost: _replyToPost?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'diceRolls';
        diceRolls.build();

        _$failedField = 'author';
        author.build();
        _$failedField = 'replyToPost';
        _replyToPost?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'ReplyResponseDto',
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
