// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_audience_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const NotificationAudienceDtoRolesEnum _$notificationAudienceDtoRolesEnum_USER =
    const NotificationAudienceDtoRolesEnum._('USER');
const NotificationAudienceDtoRolesEnum
_$notificationAudienceDtoRolesEnum_ADMIN =
    const NotificationAudienceDtoRolesEnum._('ADMIN');
const NotificationAudienceDtoRolesEnum
_$notificationAudienceDtoRolesEnum_SUPER_ADMIN =
    const NotificationAudienceDtoRolesEnum._('SUPER_ADMIN');
const NotificationAudienceDtoRolesEnum
_$notificationAudienceDtoRolesEnum_unknownDefaultOpenApi =
    const NotificationAudienceDtoRolesEnum._('unknownDefaultOpenApi');

NotificationAudienceDtoRolesEnum _$notificationAudienceDtoRolesEnumValueOf(
  String name,
) {
  switch (name) {
    case 'USER':
      return _$notificationAudienceDtoRolesEnum_USER;
    case 'ADMIN':
      return _$notificationAudienceDtoRolesEnum_ADMIN;
    case 'SUPER_ADMIN':
      return _$notificationAudienceDtoRolesEnum_SUPER_ADMIN;
    case 'unknownDefaultOpenApi':
      return _$notificationAudienceDtoRolesEnum_unknownDefaultOpenApi;
    default:
      return _$notificationAudienceDtoRolesEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<NotificationAudienceDtoRolesEnum>
_$notificationAudienceDtoRolesEnumValues =
    BuiltSet<NotificationAudienceDtoRolesEnum>(
      const <NotificationAudienceDtoRolesEnum>[
        _$notificationAudienceDtoRolesEnum_USER,
        _$notificationAudienceDtoRolesEnum_ADMIN,
        _$notificationAudienceDtoRolesEnum_SUPER_ADMIN,
        _$notificationAudienceDtoRolesEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<NotificationAudienceDtoRolesEnum>
_$notificationAudienceDtoRolesEnumSerializer =
    _$NotificationAudienceDtoRolesEnumSerializer();

class _$NotificationAudienceDtoRolesEnumSerializer
    implements PrimitiveSerializer<NotificationAudienceDtoRolesEnum> {
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
  final Iterable<Type> types = const <Type>[NotificationAudienceDtoRolesEnum];
  @override
  final String wireName = 'NotificationAudienceDtoRolesEnum';

  @override
  Object serialize(
    Serializers serializers,
    NotificationAudienceDtoRolesEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  NotificationAudienceDtoRolesEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => NotificationAudienceDtoRolesEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$NotificationAudienceDto extends NotificationAudienceDto {
  @override
  final BuiltList<NotificationAudienceDtoRolesEnum>? roles;

  factory _$NotificationAudienceDto([
    void Function(NotificationAudienceDtoBuilder)? updates,
  ]) => (NotificationAudienceDtoBuilder()..update(updates))._build();

  _$NotificationAudienceDto._({this.roles}) : super._();
  @override
  NotificationAudienceDto rebuild(
    void Function(NotificationAudienceDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  NotificationAudienceDtoBuilder toBuilder() =>
      NotificationAudienceDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationAudienceDto && roles == other.roles;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, roles.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'NotificationAudienceDto',
    )..add('roles', roles)).toString();
  }
}

class NotificationAudienceDtoBuilder
    implements
        Builder<NotificationAudienceDto, NotificationAudienceDtoBuilder> {
  _$NotificationAudienceDto? _$v;

  ListBuilder<NotificationAudienceDtoRolesEnum>? _roles;
  ListBuilder<NotificationAudienceDtoRolesEnum> get roles =>
      _$this._roles ??= ListBuilder<NotificationAudienceDtoRolesEnum>();
  set roles(ListBuilder<NotificationAudienceDtoRolesEnum>? roles) =>
      _$this._roles = roles;

  NotificationAudienceDtoBuilder() {
    NotificationAudienceDto._defaults(this);
  }

  NotificationAudienceDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _roles = $v.roles?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotificationAudienceDto other) {
    _$v = other as _$NotificationAudienceDto;
  }

  @override
  void update(void Function(NotificationAudienceDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationAudienceDto build() => _build();

  _$NotificationAudienceDto _build() {
    _$NotificationAudienceDto _$result;
    try {
      _$result = _$v ?? _$NotificationAudienceDto._(roles: _roles?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'roles';
        _roles?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'NotificationAudienceDto',
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
