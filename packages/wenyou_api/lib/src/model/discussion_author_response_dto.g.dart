// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discussion_author_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DiscussionAuthorResponseDtoRoleEnum
_$discussionAuthorResponseDtoRoleEnum_OWNER =
    const DiscussionAuthorResponseDtoRoleEnum._('OWNER');
const DiscussionAuthorResponseDtoRoleEnum
_$discussionAuthorResponseDtoRoleEnum_COLLABORATOR =
    const DiscussionAuthorResponseDtoRoleEnum._('COLLABORATOR');
const DiscussionAuthorResponseDtoRoleEnum
_$discussionAuthorResponseDtoRoleEnum_PARTICIPANT =
    const DiscussionAuthorResponseDtoRoleEnum._('PARTICIPANT');
const DiscussionAuthorResponseDtoRoleEnum
_$discussionAuthorResponseDtoRoleEnum_unknownDefaultOpenApi =
    const DiscussionAuthorResponseDtoRoleEnum._('unknownDefaultOpenApi');

DiscussionAuthorResponseDtoRoleEnum
_$discussionAuthorResponseDtoRoleEnumValueOf(String name) {
  switch (name) {
    case 'OWNER':
      return _$discussionAuthorResponseDtoRoleEnum_OWNER;
    case 'COLLABORATOR':
      return _$discussionAuthorResponseDtoRoleEnum_COLLABORATOR;
    case 'PARTICIPANT':
      return _$discussionAuthorResponseDtoRoleEnum_PARTICIPANT;
    case 'unknownDefaultOpenApi':
      return _$discussionAuthorResponseDtoRoleEnum_unknownDefaultOpenApi;
    default:
      return _$discussionAuthorResponseDtoRoleEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<DiscussionAuthorResponseDtoRoleEnum>
_$discussionAuthorResponseDtoRoleEnumValues =
    BuiltSet<DiscussionAuthorResponseDtoRoleEnum>(
      const <DiscussionAuthorResponseDtoRoleEnum>[
        _$discussionAuthorResponseDtoRoleEnum_OWNER,
        _$discussionAuthorResponseDtoRoleEnum_COLLABORATOR,
        _$discussionAuthorResponseDtoRoleEnum_PARTICIPANT,
        _$discussionAuthorResponseDtoRoleEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<DiscussionAuthorResponseDtoRoleEnum>
_$discussionAuthorResponseDtoRoleEnumSerializer =
    _$DiscussionAuthorResponseDtoRoleEnumSerializer();

class _$DiscussionAuthorResponseDtoRoleEnumSerializer
    implements PrimitiveSerializer<DiscussionAuthorResponseDtoRoleEnum> {
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
    DiscussionAuthorResponseDtoRoleEnum,
  ];
  @override
  final String wireName = 'DiscussionAuthorResponseDtoRoleEnum';

  @override
  Object serialize(
    Serializers serializers,
    DiscussionAuthorResponseDtoRoleEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  DiscussionAuthorResponseDtoRoleEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DiscussionAuthorResponseDtoRoleEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$DiscussionAuthorResponseDto extends DiscussionAuthorResponseDto {
  @override
  final String id;
  @override
  final String username;
  @override
  final String? avatar;
  @override
  final num level;
  @override
  final DiscussionAuthorResponseDtoRoleEnum role;
  @override
  final bool playerMarked;

  factory _$DiscussionAuthorResponseDto([
    void Function(DiscussionAuthorResponseDtoBuilder)? updates,
  ]) => (DiscussionAuthorResponseDtoBuilder()..update(updates))._build();

  _$DiscussionAuthorResponseDto._({
    required this.id,
    required this.username,
    this.avatar,
    required this.level,
    required this.role,
    required this.playerMarked,
  }) : super._();
  @override
  DiscussionAuthorResponseDto rebuild(
    void Function(DiscussionAuthorResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DiscussionAuthorResponseDtoBuilder toBuilder() =>
      DiscussionAuthorResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DiscussionAuthorResponseDto &&
        id == other.id &&
        username == other.username &&
        avatar == other.avatar &&
        level == other.level &&
        role == other.role &&
        playerMarked == other.playerMarked;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, avatar.hashCode);
    _$hash = $jc(_$hash, level.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, playerMarked.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DiscussionAuthorResponseDto')
          ..add('id', id)
          ..add('username', username)
          ..add('avatar', avatar)
          ..add('level', level)
          ..add('role', role)
          ..add('playerMarked', playerMarked))
        .toString();
  }
}

class DiscussionAuthorResponseDtoBuilder
    implements
        Builder<
          DiscussionAuthorResponseDto,
          DiscussionAuthorResponseDtoBuilder
        > {
  _$DiscussionAuthorResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _avatar;
  String? get avatar => _$this._avatar;
  set avatar(String? avatar) => _$this._avatar = avatar;

  num? _level;
  num? get level => _$this._level;
  set level(num? level) => _$this._level = level;

  DiscussionAuthorResponseDtoRoleEnum? _role;
  DiscussionAuthorResponseDtoRoleEnum? get role => _$this._role;
  set role(DiscussionAuthorResponseDtoRoleEnum? role) => _$this._role = role;

  bool? _playerMarked;
  bool? get playerMarked => _$this._playerMarked;
  set playerMarked(bool? playerMarked) => _$this._playerMarked = playerMarked;

  DiscussionAuthorResponseDtoBuilder() {
    DiscussionAuthorResponseDto._defaults(this);
  }

  DiscussionAuthorResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _username = $v.username;
      _avatar = $v.avatar;
      _level = $v.level;
      _role = $v.role;
      _playerMarked = $v.playerMarked;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DiscussionAuthorResponseDto other) {
    _$v = other as _$DiscussionAuthorResponseDto;
  }

  @override
  void update(void Function(DiscussionAuthorResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DiscussionAuthorResponseDto build() => _build();

  _$DiscussionAuthorResponseDto _build() {
    final _$result =
        _$v ??
        _$DiscussionAuthorResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'DiscussionAuthorResponseDto',
            'id',
          ),
          username: BuiltValueNullFieldError.checkNotNull(
            username,
            r'DiscussionAuthorResponseDto',
            'username',
          ),
          avatar: avatar,
          level: BuiltValueNullFieldError.checkNotNull(
            level,
            r'DiscussionAuthorResponseDto',
            'level',
          ),
          role: BuiltValueNullFieldError.checkNotNull(
            role,
            r'DiscussionAuthorResponseDto',
            'role',
          ),
          playerMarked: BuiltValueNullFieldError.checkNotNull(
            playerMarked,
            r'DiscussionAuthorResponseDto',
            'playerMarked',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
