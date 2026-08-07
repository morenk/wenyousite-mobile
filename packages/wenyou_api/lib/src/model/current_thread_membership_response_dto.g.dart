// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_thread_membership_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CurrentThreadMembershipResponseDtoRoleEnum
_$currentThreadMembershipResponseDtoRoleEnum_OWNER =
    const CurrentThreadMembershipResponseDtoRoleEnum._('OWNER');
const CurrentThreadMembershipResponseDtoRoleEnum
_$currentThreadMembershipResponseDtoRoleEnum_COLLABORATOR =
    const CurrentThreadMembershipResponseDtoRoleEnum._('COLLABORATOR');
const CurrentThreadMembershipResponseDtoRoleEnum
_$currentThreadMembershipResponseDtoRoleEnum_PARTICIPANT =
    const CurrentThreadMembershipResponseDtoRoleEnum._('PARTICIPANT');
const CurrentThreadMembershipResponseDtoRoleEnum
_$currentThreadMembershipResponseDtoRoleEnum_unknownDefaultOpenApi =
    const CurrentThreadMembershipResponseDtoRoleEnum._('unknownDefaultOpenApi');

CurrentThreadMembershipResponseDtoRoleEnum
_$currentThreadMembershipResponseDtoRoleEnumValueOf(String name) {
  switch (name) {
    case 'OWNER':
      return _$currentThreadMembershipResponseDtoRoleEnum_OWNER;
    case 'COLLABORATOR':
      return _$currentThreadMembershipResponseDtoRoleEnum_COLLABORATOR;
    case 'PARTICIPANT':
      return _$currentThreadMembershipResponseDtoRoleEnum_PARTICIPANT;
    case 'unknownDefaultOpenApi':
      return _$currentThreadMembershipResponseDtoRoleEnum_unknownDefaultOpenApi;
    default:
      return _$currentThreadMembershipResponseDtoRoleEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<CurrentThreadMembershipResponseDtoRoleEnum>
_$currentThreadMembershipResponseDtoRoleEnumValues =
    BuiltSet<CurrentThreadMembershipResponseDtoRoleEnum>(
      const <CurrentThreadMembershipResponseDtoRoleEnum>[
        _$currentThreadMembershipResponseDtoRoleEnum_OWNER,
        _$currentThreadMembershipResponseDtoRoleEnum_COLLABORATOR,
        _$currentThreadMembershipResponseDtoRoleEnum_PARTICIPANT,
        _$currentThreadMembershipResponseDtoRoleEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<CurrentThreadMembershipResponseDtoRoleEnum>
_$currentThreadMembershipResponseDtoRoleEnumSerializer =
    _$CurrentThreadMembershipResponseDtoRoleEnumSerializer();

class _$CurrentThreadMembershipResponseDtoRoleEnumSerializer
    implements PrimitiveSerializer<CurrentThreadMembershipResponseDtoRoleEnum> {
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
    CurrentThreadMembershipResponseDtoRoleEnum,
  ];
  @override
  final String wireName = 'CurrentThreadMembershipResponseDtoRoleEnum';

  @override
  Object serialize(
    Serializers serializers,
    CurrentThreadMembershipResponseDtoRoleEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  CurrentThreadMembershipResponseDtoRoleEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => CurrentThreadMembershipResponseDtoRoleEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$CurrentThreadMembershipResponseDto
    extends CurrentThreadMembershipResponseDto {
  @override
  final String id;
  @override
  final String userId;
  @override
  final CurrentThreadMembershipResponseDtoRoleEnum role;
  @override
  final bool playerMarked;

  factory _$CurrentThreadMembershipResponseDto([
    void Function(CurrentThreadMembershipResponseDtoBuilder)? updates,
  ]) => (CurrentThreadMembershipResponseDtoBuilder()..update(updates))._build();

  _$CurrentThreadMembershipResponseDto._({
    required this.id,
    required this.userId,
    required this.role,
    required this.playerMarked,
  }) : super._();
  @override
  CurrentThreadMembershipResponseDto rebuild(
    void Function(CurrentThreadMembershipResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  CurrentThreadMembershipResponseDtoBuilder toBuilder() =>
      CurrentThreadMembershipResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CurrentThreadMembershipResponseDto &&
        id == other.id &&
        userId == other.userId &&
        role == other.role &&
        playerMarked == other.playerMarked;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, playerMarked.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CurrentThreadMembershipResponseDto')
          ..add('id', id)
          ..add('userId', userId)
          ..add('role', role)
          ..add('playerMarked', playerMarked))
        .toString();
  }
}

class CurrentThreadMembershipResponseDtoBuilder
    implements
        Builder<
          CurrentThreadMembershipResponseDto,
          CurrentThreadMembershipResponseDtoBuilder
        > {
  _$CurrentThreadMembershipResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  CurrentThreadMembershipResponseDtoRoleEnum? _role;
  CurrentThreadMembershipResponseDtoRoleEnum? get role => _$this._role;
  set role(CurrentThreadMembershipResponseDtoRoleEnum? role) =>
      _$this._role = role;

  bool? _playerMarked;
  bool? get playerMarked => _$this._playerMarked;
  set playerMarked(bool? playerMarked) => _$this._playerMarked = playerMarked;

  CurrentThreadMembershipResponseDtoBuilder() {
    CurrentThreadMembershipResponseDto._defaults(this);
  }

  CurrentThreadMembershipResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _userId = $v.userId;
      _role = $v.role;
      _playerMarked = $v.playerMarked;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CurrentThreadMembershipResponseDto other) {
    _$v = other as _$CurrentThreadMembershipResponseDto;
  }

  @override
  void update(
    void Function(CurrentThreadMembershipResponseDtoBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  CurrentThreadMembershipResponseDto build() => _build();

  _$CurrentThreadMembershipResponseDto _build() {
    final _$result =
        _$v ??
        _$CurrentThreadMembershipResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'CurrentThreadMembershipResponseDto',
            'id',
          ),
          userId: BuiltValueNullFieldError.checkNotNull(
            userId,
            r'CurrentThreadMembershipResponseDto',
            'userId',
          ),
          role: BuiltValueNullFieldError.checkNotNull(
            role,
            r'CurrentThreadMembershipResponseDto',
            'role',
          ),
          playerMarked: BuiltValueNullFieldError.checkNotNull(
            playerMarked,
            r'CurrentThreadMembershipResponseDto',
            'playerMarked',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
