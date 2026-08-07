// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_condition_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UserConditionDtoRoleEnum _$userConditionDtoRoleEnum_USER =
    const UserConditionDtoRoleEnum._('USER');
const UserConditionDtoRoleEnum _$userConditionDtoRoleEnum_ADMIN =
    const UserConditionDtoRoleEnum._('ADMIN');
const UserConditionDtoRoleEnum _$userConditionDtoRoleEnum_SUPER_ADMIN =
    const UserConditionDtoRoleEnum._('SUPER_ADMIN');
const UserConditionDtoRoleEnum
_$userConditionDtoRoleEnum_unknownDefaultOpenApi =
    const UserConditionDtoRoleEnum._('unknownDefaultOpenApi');

UserConditionDtoRoleEnum _$userConditionDtoRoleEnumValueOf(String name) {
  switch (name) {
    case 'USER':
      return _$userConditionDtoRoleEnum_USER;
    case 'ADMIN':
      return _$userConditionDtoRoleEnum_ADMIN;
    case 'SUPER_ADMIN':
      return _$userConditionDtoRoleEnum_SUPER_ADMIN;
    case 'unknownDefaultOpenApi':
      return _$userConditionDtoRoleEnum_unknownDefaultOpenApi;
    default:
      return _$userConditionDtoRoleEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UserConditionDtoRoleEnum> _$userConditionDtoRoleEnumValues =
    BuiltSet<UserConditionDtoRoleEnum>(const <UserConditionDtoRoleEnum>[
      _$userConditionDtoRoleEnum_USER,
      _$userConditionDtoRoleEnum_ADMIN,
      _$userConditionDtoRoleEnum_SUPER_ADMIN,
      _$userConditionDtoRoleEnum_unknownDefaultOpenApi,
    ]);

Serializer<UserConditionDtoRoleEnum> _$userConditionDtoRoleEnumSerializer =
    _$UserConditionDtoRoleEnumSerializer();

class _$UserConditionDtoRoleEnumSerializer
    implements PrimitiveSerializer<UserConditionDtoRoleEnum> {
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
  final Iterable<Type> types = const <Type>[UserConditionDtoRoleEnum];
  @override
  final String wireName = 'UserConditionDtoRoleEnum';

  @override
  Object serialize(
    Serializers serializers,
    UserConditionDtoRoleEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UserConditionDtoRoleEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UserConditionDtoRoleEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UserConditionDto extends UserConditionDto {
  @override
  final BuiltList<UserConditionDtoRoleEnum>? role;
  @override
  final bool? emailVerified;
  @override
  final String? createdAfter;
  @override
  final String? createdBefore;

  factory _$UserConditionDto([
    void Function(UserConditionDtoBuilder)? updates,
  ]) => (UserConditionDtoBuilder()..update(updates))._build();

  _$UserConditionDto._({
    this.role,
    this.emailVerified,
    this.createdAfter,
    this.createdBefore,
  }) : super._();
  @override
  UserConditionDto rebuild(void Function(UserConditionDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserConditionDtoBuilder toBuilder() =>
      UserConditionDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserConditionDto &&
        role == other.role &&
        emailVerified == other.emailVerified &&
        createdAfter == other.createdAfter &&
        createdBefore == other.createdBefore;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, emailVerified.hashCode);
    _$hash = $jc(_$hash, createdAfter.hashCode);
    _$hash = $jc(_$hash, createdBefore.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserConditionDto')
          ..add('role', role)
          ..add('emailVerified', emailVerified)
          ..add('createdAfter', createdAfter)
          ..add('createdBefore', createdBefore))
        .toString();
  }
}

class UserConditionDtoBuilder
    implements Builder<UserConditionDto, UserConditionDtoBuilder> {
  _$UserConditionDto? _$v;

  ListBuilder<UserConditionDtoRoleEnum>? _role;
  ListBuilder<UserConditionDtoRoleEnum> get role =>
      _$this._role ??= ListBuilder<UserConditionDtoRoleEnum>();
  set role(ListBuilder<UserConditionDtoRoleEnum>? role) => _$this._role = role;

  bool? _emailVerified;
  bool? get emailVerified => _$this._emailVerified;
  set emailVerified(bool? emailVerified) =>
      _$this._emailVerified = emailVerified;

  String? _createdAfter;
  String? get createdAfter => _$this._createdAfter;
  set createdAfter(String? createdAfter) => _$this._createdAfter = createdAfter;

  String? _createdBefore;
  String? get createdBefore => _$this._createdBefore;
  set createdBefore(String? createdBefore) =>
      _$this._createdBefore = createdBefore;

  UserConditionDtoBuilder() {
    UserConditionDto._defaults(this);
  }

  UserConditionDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _role = $v.role?.toBuilder();
      _emailVerified = $v.emailVerified;
      _createdAfter = $v.createdAfter;
      _createdBefore = $v.createdBefore;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserConditionDto other) {
    _$v = other as _$UserConditionDto;
  }

  @override
  void update(void Function(UserConditionDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserConditionDto build() => _build();

  _$UserConditionDto _build() {
    _$UserConditionDto _$result;
    try {
      _$result =
          _$v ??
          _$UserConditionDto._(
            role: _role?.build(),
            emailVerified: emailVerified,
            createdAfter: createdAfter,
            createdBefore: createdBefore,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'role';
        _role?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'UserConditionDto',
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
