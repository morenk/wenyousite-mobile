// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'joined_thread_member_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const JoinedThreadMemberResponseDtoRoleEnum
_$joinedThreadMemberResponseDtoRoleEnum_OWNER =
    const JoinedThreadMemberResponseDtoRoleEnum._('OWNER');
const JoinedThreadMemberResponseDtoRoleEnum
_$joinedThreadMemberResponseDtoRoleEnum_COLLABORATOR =
    const JoinedThreadMemberResponseDtoRoleEnum._('COLLABORATOR');
const JoinedThreadMemberResponseDtoRoleEnum
_$joinedThreadMemberResponseDtoRoleEnum_PARTICIPANT =
    const JoinedThreadMemberResponseDtoRoleEnum._('PARTICIPANT');
const JoinedThreadMemberResponseDtoRoleEnum
_$joinedThreadMemberResponseDtoRoleEnum_unknownDefaultOpenApi =
    const JoinedThreadMemberResponseDtoRoleEnum._('unknownDefaultOpenApi');

JoinedThreadMemberResponseDtoRoleEnum
_$joinedThreadMemberResponseDtoRoleEnumValueOf(String name) {
  switch (name) {
    case 'OWNER':
      return _$joinedThreadMemberResponseDtoRoleEnum_OWNER;
    case 'COLLABORATOR':
      return _$joinedThreadMemberResponseDtoRoleEnum_COLLABORATOR;
    case 'PARTICIPANT':
      return _$joinedThreadMemberResponseDtoRoleEnum_PARTICIPANT;
    case 'unknownDefaultOpenApi':
      return _$joinedThreadMemberResponseDtoRoleEnum_unknownDefaultOpenApi;
    default:
      return _$joinedThreadMemberResponseDtoRoleEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<JoinedThreadMemberResponseDtoRoleEnum>
_$joinedThreadMemberResponseDtoRoleEnumValues =
    BuiltSet<JoinedThreadMemberResponseDtoRoleEnum>(
      const <JoinedThreadMemberResponseDtoRoleEnum>[
        _$joinedThreadMemberResponseDtoRoleEnum_OWNER,
        _$joinedThreadMemberResponseDtoRoleEnum_COLLABORATOR,
        _$joinedThreadMemberResponseDtoRoleEnum_PARTICIPANT,
        _$joinedThreadMemberResponseDtoRoleEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<JoinedThreadMemberResponseDtoRoleEnum>
_$joinedThreadMemberResponseDtoRoleEnumSerializer =
    _$JoinedThreadMemberResponseDtoRoleEnumSerializer();

class _$JoinedThreadMemberResponseDtoRoleEnumSerializer
    implements PrimitiveSerializer<JoinedThreadMemberResponseDtoRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'OWNER': 'OWNER',
    'COLLABORATOR': 'COLLABORATOR',
    'PARTICIPANT': 'PARTICIPANT',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'OWNER': 'OWNER',
    'COLLABORATOR': 'COLLABORATOR',
    'PARTICIPANT': 'PARTICIPANT',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    JoinedThreadMemberResponseDtoRoleEnum,
  ];
  @override
  final String wireName = 'JoinedThreadMemberResponseDtoRoleEnum';

  @override
  Object serialize(
    Serializers serializers,
    JoinedThreadMemberResponseDtoRoleEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  JoinedThreadMemberResponseDtoRoleEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => JoinedThreadMemberResponseDtoRoleEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$JoinedThreadMemberResponseDto extends JoinedThreadMemberResponseDto {
  @override
  final String id;
  @override
  final String threadId;
  @override
  final String userId;
  @override
  final JoinedThreadMemberResponseDtoRoleEnum role;
  @override
  final bool playerMarked;
  @override
  final DateTime joinedAt;
  @override
  final PostAuthorResponseDto user;
  @override
  final JoinedThreadReferenceResponseDto thread;

  factory _$JoinedThreadMemberResponseDto([
    void Function(JoinedThreadMemberResponseDtoBuilder)? updates,
  ]) => (JoinedThreadMemberResponseDtoBuilder()..update(updates))._build();

  _$JoinedThreadMemberResponseDto._({
    required this.id,
    required this.threadId,
    required this.userId,
    required this.role,
    required this.playerMarked,
    required this.joinedAt,
    required this.user,
    required this.thread,
  }) : super._();
  @override
  JoinedThreadMemberResponseDto rebuild(
    void Function(JoinedThreadMemberResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  JoinedThreadMemberResponseDtoBuilder toBuilder() =>
      JoinedThreadMemberResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is JoinedThreadMemberResponseDto &&
        id == other.id &&
        threadId == other.threadId &&
        userId == other.userId &&
        role == other.role &&
        playerMarked == other.playerMarked &&
        joinedAt == other.joinedAt &&
        user == other.user &&
        thread == other.thread;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, threadId.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, playerMarked.hashCode);
    _$hash = $jc(_$hash, joinedAt.hashCode);
    _$hash = $jc(_$hash, user.hashCode);
    _$hash = $jc(_$hash, thread.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'JoinedThreadMemberResponseDto')
          ..add('id', id)
          ..add('threadId', threadId)
          ..add('userId', userId)
          ..add('role', role)
          ..add('playerMarked', playerMarked)
          ..add('joinedAt', joinedAt)
          ..add('user', user)
          ..add('thread', thread))
        .toString();
  }
}

class JoinedThreadMemberResponseDtoBuilder
    implements
        Builder<
          JoinedThreadMemberResponseDto,
          JoinedThreadMemberResponseDtoBuilder
        > {
  _$JoinedThreadMemberResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _threadId;
  String? get threadId => _$this._threadId;
  set threadId(String? threadId) => _$this._threadId = threadId;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  JoinedThreadMemberResponseDtoRoleEnum? _role;
  JoinedThreadMemberResponseDtoRoleEnum? get role => _$this._role;
  set role(JoinedThreadMemberResponseDtoRoleEnum? role) => _$this._role = role;

  bool? _playerMarked;
  bool? get playerMarked => _$this._playerMarked;
  set playerMarked(bool? playerMarked) => _$this._playerMarked = playerMarked;

  DateTime? _joinedAt;
  DateTime? get joinedAt => _$this._joinedAt;
  set joinedAt(DateTime? joinedAt) => _$this._joinedAt = joinedAt;

  PostAuthorResponseDtoBuilder? _user;
  PostAuthorResponseDtoBuilder get user =>
      _$this._user ??= PostAuthorResponseDtoBuilder();
  set user(PostAuthorResponseDtoBuilder? user) => _$this._user = user;

  JoinedThreadReferenceResponseDtoBuilder? _thread;
  JoinedThreadReferenceResponseDtoBuilder get thread =>
      _$this._thread ??= JoinedThreadReferenceResponseDtoBuilder();
  set thread(JoinedThreadReferenceResponseDtoBuilder? thread) =>
      _$this._thread = thread;

  JoinedThreadMemberResponseDtoBuilder() {
    JoinedThreadMemberResponseDto._defaults(this);
  }

  JoinedThreadMemberResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _threadId = $v.threadId;
      _userId = $v.userId;
      _role = $v.role;
      _playerMarked = $v.playerMarked;
      _joinedAt = $v.joinedAt;
      _user = $v.user.toBuilder();
      _thread = $v.thread.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(JoinedThreadMemberResponseDto other) {
    _$v = other as _$JoinedThreadMemberResponseDto;
  }

  @override
  void update(void Function(JoinedThreadMemberResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  JoinedThreadMemberResponseDto build() => _build();

  _$JoinedThreadMemberResponseDto _build() {
    _$JoinedThreadMemberResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$JoinedThreadMemberResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'JoinedThreadMemberResponseDto',
              'id',
            ),
            threadId: BuiltValueNullFieldError.checkNotNull(
              threadId,
              r'JoinedThreadMemberResponseDto',
              'threadId',
            ),
            userId: BuiltValueNullFieldError.checkNotNull(
              userId,
              r'JoinedThreadMemberResponseDto',
              'userId',
            ),
            role: BuiltValueNullFieldError.checkNotNull(
              role,
              r'JoinedThreadMemberResponseDto',
              'role',
            ),
            playerMarked: BuiltValueNullFieldError.checkNotNull(
              playerMarked,
              r'JoinedThreadMemberResponseDto',
              'playerMarked',
            ),
            joinedAt: BuiltValueNullFieldError.checkNotNull(
              joinedAt,
              r'JoinedThreadMemberResponseDto',
              'joinedAt',
            ),
            user: user.build(),
            thread: thread.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'user';
        user.build();
        _$failedField = 'thread';
        thread.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'JoinedThreadMemberResponseDto',
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
