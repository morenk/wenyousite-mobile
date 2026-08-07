// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user_search_item_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminUserSearchItemDtoRoleEnum _$adminUserSearchItemDtoRoleEnum_USER =
    const AdminUserSearchItemDtoRoleEnum._('USER');
const AdminUserSearchItemDtoRoleEnum _$adminUserSearchItemDtoRoleEnum_ADMIN =
    const AdminUserSearchItemDtoRoleEnum._('ADMIN');
const AdminUserSearchItemDtoRoleEnum
_$adminUserSearchItemDtoRoleEnum_SUPER_ADMIN =
    const AdminUserSearchItemDtoRoleEnum._('SUPER_ADMIN');
const AdminUserSearchItemDtoRoleEnum
_$adminUserSearchItemDtoRoleEnum_unknownDefaultOpenApi =
    const AdminUserSearchItemDtoRoleEnum._('unknownDefaultOpenApi');

AdminUserSearchItemDtoRoleEnum _$adminUserSearchItemDtoRoleEnumValueOf(
  String name,
) {
  switch (name) {
    case 'USER':
      return _$adminUserSearchItemDtoRoleEnum_USER;
    case 'ADMIN':
      return _$adminUserSearchItemDtoRoleEnum_ADMIN;
    case 'SUPER_ADMIN':
      return _$adminUserSearchItemDtoRoleEnum_SUPER_ADMIN;
    case 'unknownDefaultOpenApi':
      return _$adminUserSearchItemDtoRoleEnum_unknownDefaultOpenApi;
    default:
      return _$adminUserSearchItemDtoRoleEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminUserSearchItemDtoRoleEnum>
_$adminUserSearchItemDtoRoleEnumValues =
    BuiltSet<AdminUserSearchItemDtoRoleEnum>(
      const <AdminUserSearchItemDtoRoleEnum>[
        _$adminUserSearchItemDtoRoleEnum_USER,
        _$adminUserSearchItemDtoRoleEnum_ADMIN,
        _$adminUserSearchItemDtoRoleEnum_SUPER_ADMIN,
        _$adminUserSearchItemDtoRoleEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminUserSearchItemDtoRoleEnum>
_$adminUserSearchItemDtoRoleEnumSerializer =
    _$AdminUserSearchItemDtoRoleEnumSerializer();

class _$AdminUserSearchItemDtoRoleEnumSerializer
    implements PrimitiveSerializer<AdminUserSearchItemDtoRoleEnum> {
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
  final Iterable<Type> types = const <Type>[AdminUserSearchItemDtoRoleEnum];
  @override
  final String wireName = 'AdminUserSearchItemDtoRoleEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminUserSearchItemDtoRoleEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminUserSearchItemDtoRoleEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminUserSearchItemDtoRoleEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminUserSearchItemDto extends AdminUserSearchItemDto {
  @override
  final String id;
  @override
  final String username;
  @override
  final String email;
  @override
  final AdminUserSearchItemDtoRoleEnum role;
  @override
  final bool emailVerified;
  @override
  final DateTime createdAt;

  factory _$AdminUserSearchItemDto([
    void Function(AdminUserSearchItemDtoBuilder)? updates,
  ]) => (AdminUserSearchItemDtoBuilder()..update(updates))._build();

  _$AdminUserSearchItemDto._({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.emailVerified,
    required this.createdAt,
  }) : super._();
  @override
  AdminUserSearchItemDto rebuild(
    void Function(AdminUserSearchItemDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminUserSearchItemDtoBuilder toBuilder() =>
      AdminUserSearchItemDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminUserSearchItemDto &&
        id == other.id &&
        username == other.username &&
        email == other.email &&
        role == other.role &&
        emailVerified == other.emailVerified &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, emailVerified.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminUserSearchItemDto')
          ..add('id', id)
          ..add('username', username)
          ..add('email', email)
          ..add('role', role)
          ..add('emailVerified', emailVerified)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class AdminUserSearchItemDtoBuilder
    implements Builder<AdminUserSearchItemDto, AdminUserSearchItemDtoBuilder> {
  _$AdminUserSearchItemDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  AdminUserSearchItemDtoRoleEnum? _role;
  AdminUserSearchItemDtoRoleEnum? get role => _$this._role;
  set role(AdminUserSearchItemDtoRoleEnum? role) => _$this._role = role;

  bool? _emailVerified;
  bool? get emailVerified => _$this._emailVerified;
  set emailVerified(bool? emailVerified) =>
      _$this._emailVerified = emailVerified;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  AdminUserSearchItemDtoBuilder() {
    AdminUserSearchItemDto._defaults(this);
  }

  AdminUserSearchItemDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _username = $v.username;
      _email = $v.email;
      _role = $v.role;
      _emailVerified = $v.emailVerified;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminUserSearchItemDto other) {
    _$v = other as _$AdminUserSearchItemDto;
  }

  @override
  void update(void Function(AdminUserSearchItemDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminUserSearchItemDto build() => _build();

  _$AdminUserSearchItemDto _build() {
    final _$result =
        _$v ??
        _$AdminUserSearchItemDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'AdminUserSearchItemDto',
            'id',
          ),
          username: BuiltValueNullFieldError.checkNotNull(
            username,
            r'AdminUserSearchItemDto',
            'username',
          ),
          email: BuiltValueNullFieldError.checkNotNull(
            email,
            r'AdminUserSearchItemDto',
            'email',
          ),
          role: BuiltValueNullFieldError.checkNotNull(
            role,
            r'AdminUserSearchItemDto',
            'role',
          ),
          emailVerified: BuiltValueNullFieldError.checkNotNull(
            emailVerified,
            r'AdminUserSearchItemDto',
            'emailVerified',
          ),
          createdAt: BuiltValueNullFieldError.checkNotNull(
            createdAt,
            r'AdminUserSearchItemDto',
            'createdAt',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
