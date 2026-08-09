// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_admin_role_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UpdateAdminRoleDtoRoleEnum _$updateAdminRoleDtoRoleEnum_USER =
    const UpdateAdminRoleDtoRoleEnum._('USER');
const UpdateAdminRoleDtoRoleEnum _$updateAdminRoleDtoRoleEnum_ADMIN =
    const UpdateAdminRoleDtoRoleEnum._('ADMIN');
const UpdateAdminRoleDtoRoleEnum
_$updateAdminRoleDtoRoleEnum_unknownDefaultOpenApi =
    const UpdateAdminRoleDtoRoleEnum._('unknownDefaultOpenApi');

UpdateAdminRoleDtoRoleEnum _$updateAdminRoleDtoRoleEnumValueOf(String name) {
  switch (name) {
    case 'USER':
      return _$updateAdminRoleDtoRoleEnum_USER;
    case 'ADMIN':
      return _$updateAdminRoleDtoRoleEnum_ADMIN;
    case 'unknownDefaultOpenApi':
      return _$updateAdminRoleDtoRoleEnum_unknownDefaultOpenApi;
    default:
      return _$updateAdminRoleDtoRoleEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UpdateAdminRoleDtoRoleEnum> _$updateAdminRoleDtoRoleEnumValues =
    BuiltSet<UpdateAdminRoleDtoRoleEnum>(const <UpdateAdminRoleDtoRoleEnum>[
      _$updateAdminRoleDtoRoleEnum_USER,
      _$updateAdminRoleDtoRoleEnum_ADMIN,
      _$updateAdminRoleDtoRoleEnum_unknownDefaultOpenApi,
    ]);

Serializer<UpdateAdminRoleDtoRoleEnum> _$updateAdminRoleDtoRoleEnumSerializer =
    _$UpdateAdminRoleDtoRoleEnumSerializer();

class _$UpdateAdminRoleDtoRoleEnumSerializer
    implements PrimitiveSerializer<UpdateAdminRoleDtoRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'USER': 'USER',
    'ADMIN': 'ADMIN',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'USER': 'USER',
    'ADMIN': 'ADMIN',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[UpdateAdminRoleDtoRoleEnum];
  @override
  final String wireName = 'UpdateAdminRoleDtoRoleEnum';

  @override
  Object serialize(
    Serializers serializers,
    UpdateAdminRoleDtoRoleEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UpdateAdminRoleDtoRoleEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UpdateAdminRoleDtoRoleEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UpdateAdminRoleDto extends UpdateAdminRoleDto {
  @override
  final UpdateAdminRoleDtoRoleEnum role;
  @override
  final String reason;

  factory _$UpdateAdminRoleDto([
    void Function(UpdateAdminRoleDtoBuilder)? updates,
  ]) => (UpdateAdminRoleDtoBuilder()..update(updates))._build();

  _$UpdateAdminRoleDto._({required this.role, required this.reason})
    : super._();
  @override
  UpdateAdminRoleDto rebuild(
    void Function(UpdateAdminRoleDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UpdateAdminRoleDtoBuilder toBuilder() =>
      UpdateAdminRoleDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateAdminRoleDto &&
        role == other.role &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateAdminRoleDto')
          ..add('role', role)
          ..add('reason', reason))
        .toString();
  }
}

class UpdateAdminRoleDtoBuilder
    implements Builder<UpdateAdminRoleDto, UpdateAdminRoleDtoBuilder> {
  _$UpdateAdminRoleDto? _$v;

  UpdateAdminRoleDtoRoleEnum? _role;
  UpdateAdminRoleDtoRoleEnum? get role => _$this._role;
  set role(UpdateAdminRoleDtoRoleEnum? role) => _$this._role = role;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  UpdateAdminRoleDtoBuilder() {
    UpdateAdminRoleDto._defaults(this);
  }

  UpdateAdminRoleDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _role = $v.role;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateAdminRoleDto other) {
    _$v = other as _$UpdateAdminRoleDto;
  }

  @override
  void update(void Function(UpdateAdminRoleDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateAdminRoleDto build() => _build();

  _$UpdateAdminRoleDto _build() {
    final _$result =
        _$v ??
        _$UpdateAdminRoleDto._(
          role: BuiltValueNullFieldError.checkNotNull(
            role,
            r'UpdateAdminRoleDto',
            'role',
          ),
          reason: BuiltValueNullFieldError.checkNotNull(
            reason,
            r'UpdateAdminRoleDto',
            'reason',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
