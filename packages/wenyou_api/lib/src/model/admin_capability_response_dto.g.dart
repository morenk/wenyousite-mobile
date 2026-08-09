// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_capability_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminCapabilityResponseDtoRoleEnum
_$adminCapabilityResponseDtoRoleEnum_ADMIN =
    const AdminCapabilityResponseDtoRoleEnum._('ADMIN');
const AdminCapabilityResponseDtoRoleEnum
_$adminCapabilityResponseDtoRoleEnum_SUPER_ADMIN =
    const AdminCapabilityResponseDtoRoleEnum._('SUPER_ADMIN');
const AdminCapabilityResponseDtoRoleEnum
_$adminCapabilityResponseDtoRoleEnum_unknownDefaultOpenApi =
    const AdminCapabilityResponseDtoRoleEnum._('unknownDefaultOpenApi');

AdminCapabilityResponseDtoRoleEnum _$adminCapabilityResponseDtoRoleEnumValueOf(
  String name,
) {
  switch (name) {
    case 'ADMIN':
      return _$adminCapabilityResponseDtoRoleEnum_ADMIN;
    case 'SUPER_ADMIN':
      return _$adminCapabilityResponseDtoRoleEnum_SUPER_ADMIN;
    case 'unknownDefaultOpenApi':
      return _$adminCapabilityResponseDtoRoleEnum_unknownDefaultOpenApi;
    default:
      return _$adminCapabilityResponseDtoRoleEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminCapabilityResponseDtoRoleEnum>
_$adminCapabilityResponseDtoRoleEnumValues =
    BuiltSet<AdminCapabilityResponseDtoRoleEnum>(
      const <AdminCapabilityResponseDtoRoleEnum>[
        _$adminCapabilityResponseDtoRoleEnum_ADMIN,
        _$adminCapabilityResponseDtoRoleEnum_SUPER_ADMIN,
        _$adminCapabilityResponseDtoRoleEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminCapabilityResponseDtoRoleEnum>
_$adminCapabilityResponseDtoRoleEnumSerializer =
    _$AdminCapabilityResponseDtoRoleEnumSerializer();

class _$AdminCapabilityResponseDtoRoleEnumSerializer
    implements PrimitiveSerializer<AdminCapabilityResponseDtoRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ADMIN': 'ADMIN',
    'SUPER_ADMIN': 'SUPER_ADMIN',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ADMIN': 'ADMIN',
    'SUPER_ADMIN': 'SUPER_ADMIN',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[AdminCapabilityResponseDtoRoleEnum];
  @override
  final String wireName = 'AdminCapabilityResponseDtoRoleEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminCapabilityResponseDtoRoleEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminCapabilityResponseDtoRoleEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminCapabilityResponseDtoRoleEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminCapabilityResponseDto extends AdminCapabilityResponseDto {
  @override
  final AdminCapabilityResponseDtoRoleEnum role;
  @override
  final BuiltList<String> capabilities;

  factory _$AdminCapabilityResponseDto([
    void Function(AdminCapabilityResponseDtoBuilder)? updates,
  ]) => (AdminCapabilityResponseDtoBuilder()..update(updates))._build();

  _$AdminCapabilityResponseDto._({
    required this.role,
    required this.capabilities,
  }) : super._();
  @override
  AdminCapabilityResponseDto rebuild(
    void Function(AdminCapabilityResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminCapabilityResponseDtoBuilder toBuilder() =>
      AdminCapabilityResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminCapabilityResponseDto &&
        role == other.role &&
        capabilities == other.capabilities;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, capabilities.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminCapabilityResponseDto')
          ..add('role', role)
          ..add('capabilities', capabilities))
        .toString();
  }
}

class AdminCapabilityResponseDtoBuilder
    implements
        Builder<AdminCapabilityResponseDto, AdminCapabilityResponseDtoBuilder> {
  _$AdminCapabilityResponseDto? _$v;

  AdminCapabilityResponseDtoRoleEnum? _role;
  AdminCapabilityResponseDtoRoleEnum? get role => _$this._role;
  set role(AdminCapabilityResponseDtoRoleEnum? role) => _$this._role = role;

  ListBuilder<String>? _capabilities;
  ListBuilder<String> get capabilities =>
      _$this._capabilities ??= ListBuilder<String>();
  set capabilities(ListBuilder<String>? capabilities) =>
      _$this._capabilities = capabilities;

  AdminCapabilityResponseDtoBuilder() {
    AdminCapabilityResponseDto._defaults(this);
  }

  AdminCapabilityResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _role = $v.role;
      _capabilities = $v.capabilities.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminCapabilityResponseDto other) {
    _$v = other as _$AdminCapabilityResponseDto;
  }

  @override
  void update(void Function(AdminCapabilityResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminCapabilityResponseDto build() => _build();

  _$AdminCapabilityResponseDto _build() {
    _$AdminCapabilityResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$AdminCapabilityResponseDto._(
            role: BuiltValueNullFieldError.checkNotNull(
              role,
              r'AdminCapabilityResponseDto',
              'role',
            ),
            capabilities: capabilities.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'capabilities';
        capabilities.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AdminCapabilityResponseDto',
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
