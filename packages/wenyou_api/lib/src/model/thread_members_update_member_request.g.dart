// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_members_update_member_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ThreadMembersUpdateMemberRequestRoleEnum
_$threadMembersUpdateMemberRequestRoleEnum_COLLABORATOR =
    const ThreadMembersUpdateMemberRequestRoleEnum._('COLLABORATOR');
const ThreadMembersUpdateMemberRequestRoleEnum
_$threadMembersUpdateMemberRequestRoleEnum_PARTICIPANT =
    const ThreadMembersUpdateMemberRequestRoleEnum._('PARTICIPANT');
const ThreadMembersUpdateMemberRequestRoleEnum
_$threadMembersUpdateMemberRequestRoleEnum_unknownDefaultOpenApi =
    const ThreadMembersUpdateMemberRequestRoleEnum._('unknownDefaultOpenApi');

ThreadMembersUpdateMemberRequestRoleEnum
_$threadMembersUpdateMemberRequestRoleEnumValueOf(String name) {
  switch (name) {
    case 'COLLABORATOR':
      return _$threadMembersUpdateMemberRequestRoleEnum_COLLABORATOR;
    case 'PARTICIPANT':
      return _$threadMembersUpdateMemberRequestRoleEnum_PARTICIPANT;
    case 'unknownDefaultOpenApi':
      return _$threadMembersUpdateMemberRequestRoleEnum_unknownDefaultOpenApi;
    default:
      return _$threadMembersUpdateMemberRequestRoleEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadMembersUpdateMemberRequestRoleEnum>
_$threadMembersUpdateMemberRequestRoleEnumValues =
    BuiltSet<ThreadMembersUpdateMemberRequestRoleEnum>(
      const <ThreadMembersUpdateMemberRequestRoleEnum>[
        _$threadMembersUpdateMemberRequestRoleEnum_COLLABORATOR,
        _$threadMembersUpdateMemberRequestRoleEnum_PARTICIPANT,
        _$threadMembersUpdateMemberRequestRoleEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ThreadMembersUpdateMemberRequestRoleEnum>
_$threadMembersUpdateMemberRequestRoleEnumSerializer =
    _$ThreadMembersUpdateMemberRequestRoleEnumSerializer();

class _$ThreadMembersUpdateMemberRequestRoleEnumSerializer
    implements PrimitiveSerializer<ThreadMembersUpdateMemberRequestRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'COLLABORATOR': 'COLLABORATOR',
    'PARTICIPANT': 'PARTICIPANT',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'COLLABORATOR': 'COLLABORATOR',
    'PARTICIPANT': 'PARTICIPANT',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    ThreadMembersUpdateMemberRequestRoleEnum,
  ];
  @override
  final String wireName = 'ThreadMembersUpdateMemberRequestRoleEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadMembersUpdateMemberRequestRoleEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadMembersUpdateMemberRequestRoleEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadMembersUpdateMemberRequestRoleEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadMembersUpdateMemberRequest
    extends ThreadMembersUpdateMemberRequest {
  @override
  final ThreadMembersUpdateMemberRequestRoleEnum? role;
  @override
  final bool? playerMarked;

  factory _$ThreadMembersUpdateMemberRequest([
    void Function(ThreadMembersUpdateMemberRequestBuilder)? updates,
  ]) => (ThreadMembersUpdateMemberRequestBuilder()..update(updates))._build();

  _$ThreadMembersUpdateMemberRequest._({this.role, this.playerMarked})
    : super._();
  @override
  ThreadMembersUpdateMemberRequest rebuild(
    void Function(ThreadMembersUpdateMemberRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadMembersUpdateMemberRequestBuilder toBuilder() =>
      ThreadMembersUpdateMemberRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadMembersUpdateMemberRequest &&
        role == other.role &&
        playerMarked == other.playerMarked;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, playerMarked.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ThreadMembersUpdateMemberRequest')
          ..add('role', role)
          ..add('playerMarked', playerMarked))
        .toString();
  }
}

class ThreadMembersUpdateMemberRequestBuilder
    implements
        Builder<
          ThreadMembersUpdateMemberRequest,
          ThreadMembersUpdateMemberRequestBuilder
        > {
  _$ThreadMembersUpdateMemberRequest? _$v;

  ThreadMembersUpdateMemberRequestRoleEnum? _role;
  ThreadMembersUpdateMemberRequestRoleEnum? get role => _$this._role;
  set role(ThreadMembersUpdateMemberRequestRoleEnum? role) =>
      _$this._role = role;

  bool? _playerMarked;
  bool? get playerMarked => _$this._playerMarked;
  set playerMarked(bool? playerMarked) => _$this._playerMarked = playerMarked;

  ThreadMembersUpdateMemberRequestBuilder() {
    ThreadMembersUpdateMemberRequest._defaults(this);
  }

  ThreadMembersUpdateMemberRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _role = $v.role;
      _playerMarked = $v.playerMarked;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ThreadMembersUpdateMemberRequest other) {
    _$v = other as _$ThreadMembersUpdateMemberRequest;
  }

  @override
  void update(void Function(ThreadMembersUpdateMemberRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadMembersUpdateMemberRequest build() => _build();

  _$ThreadMembersUpdateMemberRequest _build() {
    final _$result =
        _$v ??
        _$ThreadMembersUpdateMemberRequest._(
          role: role,
          playerMarked: playerMarked,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
