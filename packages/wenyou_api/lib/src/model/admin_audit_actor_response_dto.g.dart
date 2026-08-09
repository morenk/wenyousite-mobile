// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_audit_actor_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminAuditActorResponseDtoRoleEnum
_$adminAuditActorResponseDtoRoleEnum_USER =
    const AdminAuditActorResponseDtoRoleEnum._('USER');
const AdminAuditActorResponseDtoRoleEnum
_$adminAuditActorResponseDtoRoleEnum_ADMIN =
    const AdminAuditActorResponseDtoRoleEnum._('ADMIN');
const AdminAuditActorResponseDtoRoleEnum
_$adminAuditActorResponseDtoRoleEnum_SUPER_ADMIN =
    const AdminAuditActorResponseDtoRoleEnum._('SUPER_ADMIN');
const AdminAuditActorResponseDtoRoleEnum
_$adminAuditActorResponseDtoRoleEnum_unknownDefaultOpenApi =
    const AdminAuditActorResponseDtoRoleEnum._('unknownDefaultOpenApi');

AdminAuditActorResponseDtoRoleEnum _$adminAuditActorResponseDtoRoleEnumValueOf(
  String name,
) {
  switch (name) {
    case 'USER':
      return _$adminAuditActorResponseDtoRoleEnum_USER;
    case 'ADMIN':
      return _$adminAuditActorResponseDtoRoleEnum_ADMIN;
    case 'SUPER_ADMIN':
      return _$adminAuditActorResponseDtoRoleEnum_SUPER_ADMIN;
    case 'unknownDefaultOpenApi':
      return _$adminAuditActorResponseDtoRoleEnum_unknownDefaultOpenApi;
    default:
      return _$adminAuditActorResponseDtoRoleEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminAuditActorResponseDtoRoleEnum>
_$adminAuditActorResponseDtoRoleEnumValues =
    BuiltSet<AdminAuditActorResponseDtoRoleEnum>(
      const <AdminAuditActorResponseDtoRoleEnum>[
        _$adminAuditActorResponseDtoRoleEnum_USER,
        _$adminAuditActorResponseDtoRoleEnum_ADMIN,
        _$adminAuditActorResponseDtoRoleEnum_SUPER_ADMIN,
        _$adminAuditActorResponseDtoRoleEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminAuditActorResponseDtoRoleEnum>
_$adminAuditActorResponseDtoRoleEnumSerializer =
    _$AdminAuditActorResponseDtoRoleEnumSerializer();

class _$AdminAuditActorResponseDtoRoleEnumSerializer
    implements PrimitiveSerializer<AdminAuditActorResponseDtoRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'USER': 'USER',
    'ADMIN': 'ADMIN',
    'SUPER_ADMIN': 'SUPER_ADMIN',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'USER': 'USER',
    'ADMIN': 'ADMIN',
    'SUPER_ADMIN': 'SUPER_ADMIN',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[AdminAuditActorResponseDtoRoleEnum];
  @override
  final String wireName = 'AdminAuditActorResponseDtoRoleEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminAuditActorResponseDtoRoleEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminAuditActorResponseDtoRoleEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminAuditActorResponseDtoRoleEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminAuditActorResponseDto extends AdminAuditActorResponseDto {
  @override
  final String id;
  @override
  final String username;
  @override
  final AdminAuditActorResponseDtoRoleEnum role;

  factory _$AdminAuditActorResponseDto([
    void Function(AdminAuditActorResponseDtoBuilder)? updates,
  ]) => (AdminAuditActorResponseDtoBuilder()..update(updates))._build();

  _$AdminAuditActorResponseDto._({
    required this.id,
    required this.username,
    required this.role,
  }) : super._();
  @override
  AdminAuditActorResponseDto rebuild(
    void Function(AdminAuditActorResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminAuditActorResponseDtoBuilder toBuilder() =>
      AdminAuditActorResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminAuditActorResponseDto &&
        id == other.id &&
        username == other.username &&
        role == other.role;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminAuditActorResponseDto')
          ..add('id', id)
          ..add('username', username)
          ..add('role', role))
        .toString();
  }
}

class AdminAuditActorResponseDtoBuilder
    implements
        Builder<AdminAuditActorResponseDto, AdminAuditActorResponseDtoBuilder> {
  _$AdminAuditActorResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  AdminAuditActorResponseDtoRoleEnum? _role;
  AdminAuditActorResponseDtoRoleEnum? get role => _$this._role;
  set role(AdminAuditActorResponseDtoRoleEnum? role) => _$this._role = role;

  AdminAuditActorResponseDtoBuilder() {
    AdminAuditActorResponseDto._defaults(this);
  }

  AdminAuditActorResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _username = $v.username;
      _role = $v.role;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminAuditActorResponseDto other) {
    _$v = other as _$AdminAuditActorResponseDto;
  }

  @override
  void update(void Function(AdminAuditActorResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminAuditActorResponseDto build() => _build();

  _$AdminAuditActorResponseDto _build() {
    final _$result =
        _$v ??
        _$AdminAuditActorResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'AdminAuditActorResponseDto',
            'id',
          ),
          username: BuiltValueNullFieldError.checkNotNull(
            username,
            r'AdminAuditActorResponseDto',
            'username',
          ),
          role: BuiltValueNullFieldError.checkNotNull(
            role,
            r'AdminAuditActorResponseDto',
            'role',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
