// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_user_summary_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ReportUserSummaryDtoRoleEnum _$reportUserSummaryDtoRoleEnum_USER =
    const ReportUserSummaryDtoRoleEnum._('USER');
const ReportUserSummaryDtoRoleEnum _$reportUserSummaryDtoRoleEnum_ADMIN =
    const ReportUserSummaryDtoRoleEnum._('ADMIN');
const ReportUserSummaryDtoRoleEnum _$reportUserSummaryDtoRoleEnum_SUPER_ADMIN =
    const ReportUserSummaryDtoRoleEnum._('SUPER_ADMIN');
const ReportUserSummaryDtoRoleEnum
_$reportUserSummaryDtoRoleEnum_unknownDefaultOpenApi =
    const ReportUserSummaryDtoRoleEnum._('unknownDefaultOpenApi');

ReportUserSummaryDtoRoleEnum _$reportUserSummaryDtoRoleEnumValueOf(
  String name,
) {
  switch (name) {
    case 'USER':
      return _$reportUserSummaryDtoRoleEnum_USER;
    case 'ADMIN':
      return _$reportUserSummaryDtoRoleEnum_ADMIN;
    case 'SUPER_ADMIN':
      return _$reportUserSummaryDtoRoleEnum_SUPER_ADMIN;
    case 'unknownDefaultOpenApi':
      return _$reportUserSummaryDtoRoleEnum_unknownDefaultOpenApi;
    default:
      return _$reportUserSummaryDtoRoleEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ReportUserSummaryDtoRoleEnum>
_$reportUserSummaryDtoRoleEnumValues =
    BuiltSet<ReportUserSummaryDtoRoleEnum>(const <ReportUserSummaryDtoRoleEnum>[
      _$reportUserSummaryDtoRoleEnum_USER,
      _$reportUserSummaryDtoRoleEnum_ADMIN,
      _$reportUserSummaryDtoRoleEnum_SUPER_ADMIN,
      _$reportUserSummaryDtoRoleEnum_unknownDefaultOpenApi,
    ]);

Serializer<ReportUserSummaryDtoRoleEnum>
_$reportUserSummaryDtoRoleEnumSerializer =
    _$ReportUserSummaryDtoRoleEnumSerializer();

class _$ReportUserSummaryDtoRoleEnumSerializer
    implements PrimitiveSerializer<ReportUserSummaryDtoRoleEnum> {
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
  final Iterable<Type> types = const <Type>[ReportUserSummaryDtoRoleEnum];
  @override
  final String wireName = 'ReportUserSummaryDtoRoleEnum';

  @override
  Object serialize(
    Serializers serializers,
    ReportUserSummaryDtoRoleEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ReportUserSummaryDtoRoleEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ReportUserSummaryDtoRoleEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ReportUserSummaryDto extends ReportUserSummaryDto {
  @override
  final String id;
  @override
  final String username;
  @override
  final ReportUserSummaryDtoRoleEnum role;

  factory _$ReportUserSummaryDto([
    void Function(ReportUserSummaryDtoBuilder)? updates,
  ]) => (ReportUserSummaryDtoBuilder()..update(updates))._build();

  _$ReportUserSummaryDto._({
    required this.id,
    required this.username,
    required this.role,
  }) : super._();
  @override
  ReportUserSummaryDto rebuild(
    void Function(ReportUserSummaryDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ReportUserSummaryDtoBuilder toBuilder() =>
      ReportUserSummaryDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReportUserSummaryDto &&
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
    return (newBuiltValueToStringHelper(r'ReportUserSummaryDto')
          ..add('id', id)
          ..add('username', username)
          ..add('role', role))
        .toString();
  }
}

class ReportUserSummaryDtoBuilder
    implements Builder<ReportUserSummaryDto, ReportUserSummaryDtoBuilder> {
  _$ReportUserSummaryDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  ReportUserSummaryDtoRoleEnum? _role;
  ReportUserSummaryDtoRoleEnum? get role => _$this._role;
  set role(ReportUserSummaryDtoRoleEnum? role) => _$this._role = role;

  ReportUserSummaryDtoBuilder() {
    ReportUserSummaryDto._defaults(this);
  }

  ReportUserSummaryDtoBuilder get _$this {
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
  void replace(ReportUserSummaryDto other) {
    _$v = other as _$ReportUserSummaryDto;
  }

  @override
  void update(void Function(ReportUserSummaryDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReportUserSummaryDto build() => _build();

  _$ReportUserSummaryDto _build() {
    final _$result =
        _$v ??
        _$ReportUserSummaryDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'ReportUserSummaryDto',
            'id',
          ),
          username: BuiltValueNullFieldError.checkNotNull(
            username,
            r'ReportUserSummaryDto',
            'username',
          ),
          role: BuiltValueNullFieldError.checkNotNull(
            role,
            r'ReportUserSummaryDto',
            'role',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
