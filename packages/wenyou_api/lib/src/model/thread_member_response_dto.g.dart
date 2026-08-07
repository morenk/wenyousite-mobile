// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_member_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ThreadMemberResponseDtoRoleEnum _$threadMemberResponseDtoRoleEnum_OWNER =
    const ThreadMemberResponseDtoRoleEnum._('OWNER');
const ThreadMemberResponseDtoRoleEnum
_$threadMemberResponseDtoRoleEnum_COLLABORATOR =
    const ThreadMemberResponseDtoRoleEnum._('COLLABORATOR');
const ThreadMemberResponseDtoRoleEnum
_$threadMemberResponseDtoRoleEnum_PARTICIPANT =
    const ThreadMemberResponseDtoRoleEnum._('PARTICIPANT');
const ThreadMemberResponseDtoRoleEnum
_$threadMemberResponseDtoRoleEnum_unknownDefaultOpenApi =
    const ThreadMemberResponseDtoRoleEnum._('unknownDefaultOpenApi');

ThreadMemberResponseDtoRoleEnum _$threadMemberResponseDtoRoleEnumValueOf(
  String name,
) {
  switch (name) {
    case 'OWNER':
      return _$threadMemberResponseDtoRoleEnum_OWNER;
    case 'COLLABORATOR':
      return _$threadMemberResponseDtoRoleEnum_COLLABORATOR;
    case 'PARTICIPANT':
      return _$threadMemberResponseDtoRoleEnum_PARTICIPANT;
    case 'unknownDefaultOpenApi':
      return _$threadMemberResponseDtoRoleEnum_unknownDefaultOpenApi;
    default:
      return _$threadMemberResponseDtoRoleEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadMemberResponseDtoRoleEnum>
_$threadMemberResponseDtoRoleEnumValues =
    BuiltSet<ThreadMemberResponseDtoRoleEnum>(
      const <ThreadMemberResponseDtoRoleEnum>[
        _$threadMemberResponseDtoRoleEnum_OWNER,
        _$threadMemberResponseDtoRoleEnum_COLLABORATOR,
        _$threadMemberResponseDtoRoleEnum_PARTICIPANT,
        _$threadMemberResponseDtoRoleEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ThreadMemberResponseDtoRoleEnum>
_$threadMemberResponseDtoRoleEnumSerializer =
    _$ThreadMemberResponseDtoRoleEnumSerializer();

class _$ThreadMemberResponseDtoRoleEnumSerializer
    implements PrimitiveSerializer<ThreadMemberResponseDtoRoleEnum> {
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
  final Iterable<Type> types = const <Type>[ThreadMemberResponseDtoRoleEnum];
  @override
  final String wireName = 'ThreadMemberResponseDtoRoleEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadMemberResponseDtoRoleEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadMemberResponseDtoRoleEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadMemberResponseDtoRoleEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadMemberResponseDto extends ThreadMemberResponseDto {
  @override
  final String id;
  @override
  final String threadId;
  @override
  final String userId;
  @override
  final ThreadMemberResponseDtoRoleEnum role;
  @override
  final bool playerMarked;
  @override
  final DateTime joinedAt;
  @override
  final PostAuthorResponseDto user;

  factory _$ThreadMemberResponseDto([
    void Function(ThreadMemberResponseDtoBuilder)? updates,
  ]) => (ThreadMemberResponseDtoBuilder()..update(updates))._build();

  _$ThreadMemberResponseDto._({
    required this.id,
    required this.threadId,
    required this.userId,
    required this.role,
    required this.playerMarked,
    required this.joinedAt,
    required this.user,
  }) : super._();
  @override
  ThreadMemberResponseDto rebuild(
    void Function(ThreadMemberResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadMemberResponseDtoBuilder toBuilder() =>
      ThreadMemberResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadMemberResponseDto &&
        id == other.id &&
        threadId == other.threadId &&
        userId == other.userId &&
        role == other.role &&
        playerMarked == other.playerMarked &&
        joinedAt == other.joinedAt &&
        user == other.user;
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
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ThreadMemberResponseDto')
          ..add('id', id)
          ..add('threadId', threadId)
          ..add('userId', userId)
          ..add('role', role)
          ..add('playerMarked', playerMarked)
          ..add('joinedAt', joinedAt)
          ..add('user', user))
        .toString();
  }
}

class ThreadMemberResponseDtoBuilder
    implements
        Builder<ThreadMemberResponseDto, ThreadMemberResponseDtoBuilder> {
  _$ThreadMemberResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _threadId;
  String? get threadId => _$this._threadId;
  set threadId(String? threadId) => _$this._threadId = threadId;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  ThreadMemberResponseDtoRoleEnum? _role;
  ThreadMemberResponseDtoRoleEnum? get role => _$this._role;
  set role(ThreadMemberResponseDtoRoleEnum? role) => _$this._role = role;

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

  ThreadMemberResponseDtoBuilder() {
    ThreadMemberResponseDto._defaults(this);
  }

  ThreadMemberResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _threadId = $v.threadId;
      _userId = $v.userId;
      _role = $v.role;
      _playerMarked = $v.playerMarked;
      _joinedAt = $v.joinedAt;
      _user = $v.user.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ThreadMemberResponseDto other) {
    _$v = other as _$ThreadMemberResponseDto;
  }

  @override
  void update(void Function(ThreadMemberResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadMemberResponseDto build() => _build();

  _$ThreadMemberResponseDto _build() {
    _$ThreadMemberResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$ThreadMemberResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'ThreadMemberResponseDto',
              'id',
            ),
            threadId: BuiltValueNullFieldError.checkNotNull(
              threadId,
              r'ThreadMemberResponseDto',
              'threadId',
            ),
            userId: BuiltValueNullFieldError.checkNotNull(
              userId,
              r'ThreadMemberResponseDto',
              'userId',
            ),
            role: BuiltValueNullFieldError.checkNotNull(
              role,
              r'ThreadMemberResponseDto',
              'role',
            ),
            playerMarked: BuiltValueNullFieldError.checkNotNull(
              playerMarked,
              r'ThreadMemberResponseDto',
              'playerMarked',
            ),
            joinedAt: BuiltValueNullFieldError.checkNotNull(
              joinedAt,
              r'ThreadMemberResponseDto',
              'joinedAt',
            ),
            user: user.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'user';
        user.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'ThreadMemberResponseDto',
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
