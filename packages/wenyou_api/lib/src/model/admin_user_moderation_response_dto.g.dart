// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user_moderation_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminUserModerationResponseDtoRoleEnum
_$adminUserModerationResponseDtoRoleEnum_USER =
    const AdminUserModerationResponseDtoRoleEnum._('USER');
const AdminUserModerationResponseDtoRoleEnum
_$adminUserModerationResponseDtoRoleEnum_ADMIN =
    const AdminUserModerationResponseDtoRoleEnum._('ADMIN');
const AdminUserModerationResponseDtoRoleEnum
_$adminUserModerationResponseDtoRoleEnum_SUPER_ADMIN =
    const AdminUserModerationResponseDtoRoleEnum._('SUPER_ADMIN');
const AdminUserModerationResponseDtoRoleEnum
_$adminUserModerationResponseDtoRoleEnum_unknownDefaultOpenApi =
    const AdminUserModerationResponseDtoRoleEnum._('unknownDefaultOpenApi');

AdminUserModerationResponseDtoRoleEnum
_$adminUserModerationResponseDtoRoleEnumValueOf(String name) {
  switch (name) {
    case 'USER':
      return _$adminUserModerationResponseDtoRoleEnum_USER;
    case 'ADMIN':
      return _$adminUserModerationResponseDtoRoleEnum_ADMIN;
    case 'SUPER_ADMIN':
      return _$adminUserModerationResponseDtoRoleEnum_SUPER_ADMIN;
    case 'unknownDefaultOpenApi':
      return _$adminUserModerationResponseDtoRoleEnum_unknownDefaultOpenApi;
    default:
      return _$adminUserModerationResponseDtoRoleEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminUserModerationResponseDtoRoleEnum>
_$adminUserModerationResponseDtoRoleEnumValues =
    BuiltSet<AdminUserModerationResponseDtoRoleEnum>(
      const <AdminUserModerationResponseDtoRoleEnum>[
        _$adminUserModerationResponseDtoRoleEnum_USER,
        _$adminUserModerationResponseDtoRoleEnum_ADMIN,
        _$adminUserModerationResponseDtoRoleEnum_SUPER_ADMIN,
        _$adminUserModerationResponseDtoRoleEnum_unknownDefaultOpenApi,
      ],
    );

const AdminUserModerationResponseDtoModerationStatusEnum
_$adminUserModerationResponseDtoModerationStatusEnum_ACTIVE =
    const AdminUserModerationResponseDtoModerationStatusEnum._('ACTIVE');
const AdminUserModerationResponseDtoModerationStatusEnum
_$adminUserModerationResponseDtoModerationStatusEnum_SUSPENDED =
    const AdminUserModerationResponseDtoModerationStatusEnum._('SUSPENDED');
const AdminUserModerationResponseDtoModerationStatusEnum
_$adminUserModerationResponseDtoModerationStatusEnum_BANNED =
    const AdminUserModerationResponseDtoModerationStatusEnum._('BANNED');
const AdminUserModerationResponseDtoModerationStatusEnum
_$adminUserModerationResponseDtoModerationStatusEnum_unknownDefaultOpenApi =
    const AdminUserModerationResponseDtoModerationStatusEnum._(
      'unknownDefaultOpenApi',
    );

AdminUserModerationResponseDtoModerationStatusEnum
_$adminUserModerationResponseDtoModerationStatusEnumValueOf(String name) {
  switch (name) {
    case 'ACTIVE':
      return _$adminUserModerationResponseDtoModerationStatusEnum_ACTIVE;
    case 'SUSPENDED':
      return _$adminUserModerationResponseDtoModerationStatusEnum_SUSPENDED;
    case 'BANNED':
      return _$adminUserModerationResponseDtoModerationStatusEnum_BANNED;
    case 'unknownDefaultOpenApi':
      return _$adminUserModerationResponseDtoModerationStatusEnum_unknownDefaultOpenApi;
    default:
      return _$adminUserModerationResponseDtoModerationStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminUserModerationResponseDtoModerationStatusEnum>
_$adminUserModerationResponseDtoModerationStatusEnumValues =
    BuiltSet<AdminUserModerationResponseDtoModerationStatusEnum>(const <
      AdminUserModerationResponseDtoModerationStatusEnum
    >[
      _$adminUserModerationResponseDtoModerationStatusEnum_ACTIVE,
      _$adminUserModerationResponseDtoModerationStatusEnum_SUSPENDED,
      _$adminUserModerationResponseDtoModerationStatusEnum_BANNED,
      _$adminUserModerationResponseDtoModerationStatusEnum_unknownDefaultOpenApi,
    ]);

Serializer<AdminUserModerationResponseDtoRoleEnum>
_$adminUserModerationResponseDtoRoleEnumSerializer =
    _$AdminUserModerationResponseDtoRoleEnumSerializer();
Serializer<AdminUserModerationResponseDtoModerationStatusEnum>
_$adminUserModerationResponseDtoModerationStatusEnumSerializer =
    _$AdminUserModerationResponseDtoModerationStatusEnumSerializer();

class _$AdminUserModerationResponseDtoRoleEnumSerializer
    implements PrimitiveSerializer<AdminUserModerationResponseDtoRoleEnum> {
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
  final Iterable<Type> types = const <Type>[
    AdminUserModerationResponseDtoRoleEnum,
  ];
  @override
  final String wireName = 'AdminUserModerationResponseDtoRoleEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminUserModerationResponseDtoRoleEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminUserModerationResponseDtoRoleEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminUserModerationResponseDtoRoleEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminUserModerationResponseDtoModerationStatusEnumSerializer
    implements
        PrimitiveSerializer<
          AdminUserModerationResponseDtoModerationStatusEnum
        > {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ACTIVE': 'ACTIVE',
    'SUSPENDED': 'SUSPENDED',
    'BANNED': 'BANNED',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ACTIVE': 'ACTIVE',
    'SUSPENDED': 'SUSPENDED',
    'BANNED': 'BANNED',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    AdminUserModerationResponseDtoModerationStatusEnum,
  ];
  @override
  final String wireName = 'AdminUserModerationResponseDtoModerationStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminUserModerationResponseDtoModerationStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminUserModerationResponseDtoModerationStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminUserModerationResponseDtoModerationStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminUserModerationResponseDto extends AdminUserModerationResponseDto {
  @override
  final String id;
  @override
  final String email;
  @override
  final String username;
  @override
  final AdminUserModerationResponseDtoRoleEnum role;
  @override
  final bool emailVerified;
  @override
  final AdminUserModerationResponseDtoModerationStatusEnum moderationStatus;
  @override
  final AdminUserSanctionResponseDto? currentSanction;
  @override
  final DateTime createdAt;

  factory _$AdminUserModerationResponseDto([
    void Function(AdminUserModerationResponseDtoBuilder)? updates,
  ]) => (AdminUserModerationResponseDtoBuilder()..update(updates))._build();

  _$AdminUserModerationResponseDto._({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
    required this.emailVerified,
    required this.moderationStatus,
    this.currentSanction,
    required this.createdAt,
  }) : super._();
  @override
  AdminUserModerationResponseDto rebuild(
    void Function(AdminUserModerationResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminUserModerationResponseDtoBuilder toBuilder() =>
      AdminUserModerationResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminUserModerationResponseDto &&
        id == other.id &&
        email == other.email &&
        username == other.username &&
        role == other.role &&
        emailVerified == other.emailVerified &&
        moderationStatus == other.moderationStatus &&
        currentSanction == other.currentSanction &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, emailVerified.hashCode);
    _$hash = $jc(_$hash, moderationStatus.hashCode);
    _$hash = $jc(_$hash, currentSanction.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminUserModerationResponseDto')
          ..add('id', id)
          ..add('email', email)
          ..add('username', username)
          ..add('role', role)
          ..add('emailVerified', emailVerified)
          ..add('moderationStatus', moderationStatus)
          ..add('currentSanction', currentSanction)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class AdminUserModerationResponseDtoBuilder
    implements
        Builder<
          AdminUserModerationResponseDto,
          AdminUserModerationResponseDtoBuilder
        > {
  _$AdminUserModerationResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  AdminUserModerationResponseDtoRoleEnum? _role;
  AdminUserModerationResponseDtoRoleEnum? get role => _$this._role;
  set role(AdminUserModerationResponseDtoRoleEnum? role) => _$this._role = role;

  bool? _emailVerified;
  bool? get emailVerified => _$this._emailVerified;
  set emailVerified(bool? emailVerified) =>
      _$this._emailVerified = emailVerified;

  AdminUserModerationResponseDtoModerationStatusEnum? _moderationStatus;
  AdminUserModerationResponseDtoModerationStatusEnum? get moderationStatus =>
      _$this._moderationStatus;
  set moderationStatus(
    AdminUserModerationResponseDtoModerationStatusEnum? moderationStatus,
  ) => _$this._moderationStatus = moderationStatus;

  AdminUserSanctionResponseDtoBuilder? _currentSanction;
  AdminUserSanctionResponseDtoBuilder get currentSanction =>
      _$this._currentSanction ??= AdminUserSanctionResponseDtoBuilder();
  set currentSanction(AdminUserSanctionResponseDtoBuilder? currentSanction) =>
      _$this._currentSanction = currentSanction;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  AdminUserModerationResponseDtoBuilder() {
    AdminUserModerationResponseDto._defaults(this);
  }

  AdminUserModerationResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _email = $v.email;
      _username = $v.username;
      _role = $v.role;
      _emailVerified = $v.emailVerified;
      _moderationStatus = $v.moderationStatus;
      _currentSanction = $v.currentSanction?.toBuilder();
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminUserModerationResponseDto other) {
    _$v = other as _$AdminUserModerationResponseDto;
  }

  @override
  void update(void Function(AdminUserModerationResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminUserModerationResponseDto build() => _build();

  _$AdminUserModerationResponseDto _build() {
    _$AdminUserModerationResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$AdminUserModerationResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'AdminUserModerationResponseDto',
              'id',
            ),
            email: BuiltValueNullFieldError.checkNotNull(
              email,
              r'AdminUserModerationResponseDto',
              'email',
            ),
            username: BuiltValueNullFieldError.checkNotNull(
              username,
              r'AdminUserModerationResponseDto',
              'username',
            ),
            role: BuiltValueNullFieldError.checkNotNull(
              role,
              r'AdminUserModerationResponseDto',
              'role',
            ),
            emailVerified: BuiltValueNullFieldError.checkNotNull(
              emailVerified,
              r'AdminUserModerationResponseDto',
              'emailVerified',
            ),
            moderationStatus: BuiltValueNullFieldError.checkNotNull(
              moderationStatus,
              r'AdminUserModerationResponseDto',
              'moderationStatus',
            ),
            currentSanction: _currentSanction?.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'AdminUserModerationResponseDto',
              'createdAt',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'currentSanction';
        _currentSanction?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AdminUserModerationResponseDto',
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
