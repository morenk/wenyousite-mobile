// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user_detail_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminUserDetailResponseDtoRoleEnum
_$adminUserDetailResponseDtoRoleEnum_USER =
    const AdminUserDetailResponseDtoRoleEnum._('USER');
const AdminUserDetailResponseDtoRoleEnum
_$adminUserDetailResponseDtoRoleEnum_ADMIN =
    const AdminUserDetailResponseDtoRoleEnum._('ADMIN');
const AdminUserDetailResponseDtoRoleEnum
_$adminUserDetailResponseDtoRoleEnum_SUPER_ADMIN =
    const AdminUserDetailResponseDtoRoleEnum._('SUPER_ADMIN');
const AdminUserDetailResponseDtoRoleEnum
_$adminUserDetailResponseDtoRoleEnum_unknownDefaultOpenApi =
    const AdminUserDetailResponseDtoRoleEnum._('unknownDefaultOpenApi');

AdminUserDetailResponseDtoRoleEnum _$adminUserDetailResponseDtoRoleEnumValueOf(
  String name,
) {
  switch (name) {
    case 'USER':
      return _$adminUserDetailResponseDtoRoleEnum_USER;
    case 'ADMIN':
      return _$adminUserDetailResponseDtoRoleEnum_ADMIN;
    case 'SUPER_ADMIN':
      return _$adminUserDetailResponseDtoRoleEnum_SUPER_ADMIN;
    case 'unknownDefaultOpenApi':
      return _$adminUserDetailResponseDtoRoleEnum_unknownDefaultOpenApi;
    default:
      return _$adminUserDetailResponseDtoRoleEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminUserDetailResponseDtoRoleEnum>
_$adminUserDetailResponseDtoRoleEnumValues =
    BuiltSet<AdminUserDetailResponseDtoRoleEnum>(
      const <AdminUserDetailResponseDtoRoleEnum>[
        _$adminUserDetailResponseDtoRoleEnum_USER,
        _$adminUserDetailResponseDtoRoleEnum_ADMIN,
        _$adminUserDetailResponseDtoRoleEnum_SUPER_ADMIN,
        _$adminUserDetailResponseDtoRoleEnum_unknownDefaultOpenApi,
      ],
    );

const AdminUserDetailResponseDtoModerationStatusEnum
_$adminUserDetailResponseDtoModerationStatusEnum_ACTIVE =
    const AdminUserDetailResponseDtoModerationStatusEnum._('ACTIVE');
const AdminUserDetailResponseDtoModerationStatusEnum
_$adminUserDetailResponseDtoModerationStatusEnum_SUSPENDED =
    const AdminUserDetailResponseDtoModerationStatusEnum._('SUSPENDED');
const AdminUserDetailResponseDtoModerationStatusEnum
_$adminUserDetailResponseDtoModerationStatusEnum_BANNED =
    const AdminUserDetailResponseDtoModerationStatusEnum._('BANNED');
const AdminUserDetailResponseDtoModerationStatusEnum
_$adminUserDetailResponseDtoModerationStatusEnum_unknownDefaultOpenApi =
    const AdminUserDetailResponseDtoModerationStatusEnum._(
      'unknownDefaultOpenApi',
    );

AdminUserDetailResponseDtoModerationStatusEnum
_$adminUserDetailResponseDtoModerationStatusEnumValueOf(String name) {
  switch (name) {
    case 'ACTIVE':
      return _$adminUserDetailResponseDtoModerationStatusEnum_ACTIVE;
    case 'SUSPENDED':
      return _$adminUserDetailResponseDtoModerationStatusEnum_SUSPENDED;
    case 'BANNED':
      return _$adminUserDetailResponseDtoModerationStatusEnum_BANNED;
    case 'unknownDefaultOpenApi':
      return _$adminUserDetailResponseDtoModerationStatusEnum_unknownDefaultOpenApi;
    default:
      return _$adminUserDetailResponseDtoModerationStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminUserDetailResponseDtoModerationStatusEnum>
_$adminUserDetailResponseDtoModerationStatusEnumValues =
    BuiltSet<AdminUserDetailResponseDtoModerationStatusEnum>(
      const <AdminUserDetailResponseDtoModerationStatusEnum>[
        _$adminUserDetailResponseDtoModerationStatusEnum_ACTIVE,
        _$adminUserDetailResponseDtoModerationStatusEnum_SUSPENDED,
        _$adminUserDetailResponseDtoModerationStatusEnum_BANNED,
        _$adminUserDetailResponseDtoModerationStatusEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminUserDetailResponseDtoRoleEnum>
_$adminUserDetailResponseDtoRoleEnumSerializer =
    _$AdminUserDetailResponseDtoRoleEnumSerializer();
Serializer<AdminUserDetailResponseDtoModerationStatusEnum>
_$adminUserDetailResponseDtoModerationStatusEnumSerializer =
    _$AdminUserDetailResponseDtoModerationStatusEnumSerializer();

class _$AdminUserDetailResponseDtoRoleEnumSerializer
    implements PrimitiveSerializer<AdminUserDetailResponseDtoRoleEnum> {
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
  final Iterable<Type> types = const <Type>[AdminUserDetailResponseDtoRoleEnum];
  @override
  final String wireName = 'AdminUserDetailResponseDtoRoleEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminUserDetailResponseDtoRoleEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminUserDetailResponseDtoRoleEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminUserDetailResponseDtoRoleEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminUserDetailResponseDtoModerationStatusEnumSerializer
    implements
        PrimitiveSerializer<AdminUserDetailResponseDtoModerationStatusEnum> {
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
    AdminUserDetailResponseDtoModerationStatusEnum,
  ];
  @override
  final String wireName = 'AdminUserDetailResponseDtoModerationStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminUserDetailResponseDtoModerationStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminUserDetailResponseDtoModerationStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminUserDetailResponseDtoModerationStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminUserDetailResponseDto extends AdminUserDetailResponseDto {
  @override
  final String id;
  @override
  final String email;
  @override
  final String username;
  @override
  final AdminUserDetailResponseDtoRoleEnum role;
  @override
  final AdminUserDetailResponseDtoModerationStatusEnum moderationStatus;
  @override
  final AdminUserSanctionResponseDto? currentSanction;
  @override
  final DateTime createdAt;
  @override
  final String? bio;
  @override
  final num level;
  @override
  final Date? lastActiveDate;
  @override
  final AdminUserContentCountsDto contentCounts;

  factory _$AdminUserDetailResponseDto([
    void Function(AdminUserDetailResponseDtoBuilder)? updates,
  ]) => (AdminUserDetailResponseDtoBuilder()..update(updates))._build();

  _$AdminUserDetailResponseDto._({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
    required this.moderationStatus,
    this.currentSanction,
    required this.createdAt,
    this.bio,
    required this.level,
    this.lastActiveDate,
    required this.contentCounts,
  }) : super._();
  @override
  AdminUserDetailResponseDto rebuild(
    void Function(AdminUserDetailResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminUserDetailResponseDtoBuilder toBuilder() =>
      AdminUserDetailResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminUserDetailResponseDto &&
        id == other.id &&
        email == other.email &&
        username == other.username &&
        role == other.role &&
        moderationStatus == other.moderationStatus &&
        currentSanction == other.currentSanction &&
        createdAt == other.createdAt &&
        bio == other.bio &&
        level == other.level &&
        lastActiveDate == other.lastActiveDate &&
        contentCounts == other.contentCounts;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, moderationStatus.hashCode);
    _$hash = $jc(_$hash, currentSanction.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, bio.hashCode);
    _$hash = $jc(_$hash, level.hashCode);
    _$hash = $jc(_$hash, lastActiveDate.hashCode);
    _$hash = $jc(_$hash, contentCounts.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminUserDetailResponseDto')
          ..add('id', id)
          ..add('email', email)
          ..add('username', username)
          ..add('role', role)
          ..add('moderationStatus', moderationStatus)
          ..add('currentSanction', currentSanction)
          ..add('createdAt', createdAt)
          ..add('bio', bio)
          ..add('level', level)
          ..add('lastActiveDate', lastActiveDate)
          ..add('contentCounts', contentCounts))
        .toString();
  }
}

class AdminUserDetailResponseDtoBuilder
    implements
        Builder<AdminUserDetailResponseDto, AdminUserDetailResponseDtoBuilder> {
  _$AdminUserDetailResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  AdminUserDetailResponseDtoRoleEnum? _role;
  AdminUserDetailResponseDtoRoleEnum? get role => _$this._role;
  set role(AdminUserDetailResponseDtoRoleEnum? role) => _$this._role = role;

  AdminUserDetailResponseDtoModerationStatusEnum? _moderationStatus;
  AdminUserDetailResponseDtoModerationStatusEnum? get moderationStatus =>
      _$this._moderationStatus;
  set moderationStatus(
    AdminUserDetailResponseDtoModerationStatusEnum? moderationStatus,
  ) => _$this._moderationStatus = moderationStatus;

  AdminUserSanctionResponseDtoBuilder? _currentSanction;
  AdminUserSanctionResponseDtoBuilder get currentSanction =>
      _$this._currentSanction ??= AdminUserSanctionResponseDtoBuilder();
  set currentSanction(AdminUserSanctionResponseDtoBuilder? currentSanction) =>
      _$this._currentSanction = currentSanction;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _bio;
  String? get bio => _$this._bio;
  set bio(String? bio) => _$this._bio = bio;

  num? _level;
  num? get level => _$this._level;
  set level(num? level) => _$this._level = level;

  Date? _lastActiveDate;
  Date? get lastActiveDate => _$this._lastActiveDate;
  set lastActiveDate(Date? lastActiveDate) =>
      _$this._lastActiveDate = lastActiveDate;

  AdminUserContentCountsDtoBuilder? _contentCounts;
  AdminUserContentCountsDtoBuilder get contentCounts =>
      _$this._contentCounts ??= AdminUserContentCountsDtoBuilder();
  set contentCounts(AdminUserContentCountsDtoBuilder? contentCounts) =>
      _$this._contentCounts = contentCounts;

  AdminUserDetailResponseDtoBuilder() {
    AdminUserDetailResponseDto._defaults(this);
  }

  AdminUserDetailResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _email = $v.email;
      _username = $v.username;
      _role = $v.role;
      _moderationStatus = $v.moderationStatus;
      _currentSanction = $v.currentSanction?.toBuilder();
      _createdAt = $v.createdAt;
      _bio = $v.bio;
      _level = $v.level;
      _lastActiveDate = $v.lastActiveDate;
      _contentCounts = $v.contentCounts.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminUserDetailResponseDto other) {
    _$v = other as _$AdminUserDetailResponseDto;
  }

  @override
  void update(void Function(AdminUserDetailResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminUserDetailResponseDto build() => _build();

  _$AdminUserDetailResponseDto _build() {
    _$AdminUserDetailResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$AdminUserDetailResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'AdminUserDetailResponseDto',
              'id',
            ),
            email: BuiltValueNullFieldError.checkNotNull(
              email,
              r'AdminUserDetailResponseDto',
              'email',
            ),
            username: BuiltValueNullFieldError.checkNotNull(
              username,
              r'AdminUserDetailResponseDto',
              'username',
            ),
            role: BuiltValueNullFieldError.checkNotNull(
              role,
              r'AdminUserDetailResponseDto',
              'role',
            ),
            moderationStatus: BuiltValueNullFieldError.checkNotNull(
              moderationStatus,
              r'AdminUserDetailResponseDto',
              'moderationStatus',
            ),
            currentSanction: _currentSanction?.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'AdminUserDetailResponseDto',
              'createdAt',
            ),
            bio: bio,
            level: BuiltValueNullFieldError.checkNotNull(
              level,
              r'AdminUserDetailResponseDto',
              'level',
            ),
            lastActiveDate: lastActiveDate,
            contentCounts: contentCounts.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'currentSanction';
        _currentSanction?.build();

        _$failedField = 'contentCounts';
        contentCounts.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AdminUserDetailResponseDto',
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
