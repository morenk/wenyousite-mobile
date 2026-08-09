// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user_sanction_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminUserSanctionResponseDtoTypeEnum
_$adminUserSanctionResponseDtoTypeEnum_SUSPENSION =
    const AdminUserSanctionResponseDtoTypeEnum._('SUSPENSION');
const AdminUserSanctionResponseDtoTypeEnum
_$adminUserSanctionResponseDtoTypeEnum_BAN =
    const AdminUserSanctionResponseDtoTypeEnum._('BAN');
const AdminUserSanctionResponseDtoTypeEnum
_$adminUserSanctionResponseDtoTypeEnum_unknownDefaultOpenApi =
    const AdminUserSanctionResponseDtoTypeEnum._('unknownDefaultOpenApi');

AdminUserSanctionResponseDtoTypeEnum
_$adminUserSanctionResponseDtoTypeEnumValueOf(String name) {
  switch (name) {
    case 'SUSPENSION':
      return _$adminUserSanctionResponseDtoTypeEnum_SUSPENSION;
    case 'BAN':
      return _$adminUserSanctionResponseDtoTypeEnum_BAN;
    case 'unknownDefaultOpenApi':
      return _$adminUserSanctionResponseDtoTypeEnum_unknownDefaultOpenApi;
    default:
      return _$adminUserSanctionResponseDtoTypeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminUserSanctionResponseDtoTypeEnum>
_$adminUserSanctionResponseDtoTypeEnumValues =
    BuiltSet<AdminUserSanctionResponseDtoTypeEnum>(
      const <AdminUserSanctionResponseDtoTypeEnum>[
        _$adminUserSanctionResponseDtoTypeEnum_SUSPENSION,
        _$adminUserSanctionResponseDtoTypeEnum_BAN,
        _$adminUserSanctionResponseDtoTypeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminUserSanctionResponseDtoTypeEnum>
_$adminUserSanctionResponseDtoTypeEnumSerializer =
    _$AdminUserSanctionResponseDtoTypeEnumSerializer();

class _$AdminUserSanctionResponseDtoTypeEnumSerializer
    implements PrimitiveSerializer<AdminUserSanctionResponseDtoTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'SUSPENSION': 'SUSPENSION',
    'BAN': 'BAN',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'SUSPENSION': 'SUSPENSION',
    'BAN': 'BAN',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    AdminUserSanctionResponseDtoTypeEnum,
  ];
  @override
  final String wireName = 'AdminUserSanctionResponseDtoTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminUserSanctionResponseDtoTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminUserSanctionResponseDtoTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminUserSanctionResponseDtoTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminUserSanctionResponseDto extends AdminUserSanctionResponseDto {
  @override
  final String id;
  @override
  final AdminUserSanctionResponseDtoTypeEnum type;
  @override
  final String reason;
  @override
  final DateTime startsAt;
  @override
  final DateTime? endsAt;
  @override
  final String? reportId;

  factory _$AdminUserSanctionResponseDto([
    void Function(AdminUserSanctionResponseDtoBuilder)? updates,
  ]) => (AdminUserSanctionResponseDtoBuilder()..update(updates))._build();

  _$AdminUserSanctionResponseDto._({
    required this.id,
    required this.type,
    required this.reason,
    required this.startsAt,
    this.endsAt,
    this.reportId,
  }) : super._();
  @override
  AdminUserSanctionResponseDto rebuild(
    void Function(AdminUserSanctionResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminUserSanctionResponseDtoBuilder toBuilder() =>
      AdminUserSanctionResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminUserSanctionResponseDto &&
        id == other.id &&
        type == other.type &&
        reason == other.reason &&
        startsAt == other.startsAt &&
        endsAt == other.endsAt &&
        reportId == other.reportId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, startsAt.hashCode);
    _$hash = $jc(_$hash, endsAt.hashCode);
    _$hash = $jc(_$hash, reportId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminUserSanctionResponseDto')
          ..add('id', id)
          ..add('type', type)
          ..add('reason', reason)
          ..add('startsAt', startsAt)
          ..add('endsAt', endsAt)
          ..add('reportId', reportId))
        .toString();
  }
}

class AdminUserSanctionResponseDtoBuilder
    implements
        Builder<
          AdminUserSanctionResponseDto,
          AdminUserSanctionResponseDtoBuilder
        > {
  _$AdminUserSanctionResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  AdminUserSanctionResponseDtoTypeEnum? _type;
  AdminUserSanctionResponseDtoTypeEnum? get type => _$this._type;
  set type(AdminUserSanctionResponseDtoTypeEnum? type) => _$this._type = type;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  DateTime? _startsAt;
  DateTime? get startsAt => _$this._startsAt;
  set startsAt(DateTime? startsAt) => _$this._startsAt = startsAt;

  DateTime? _endsAt;
  DateTime? get endsAt => _$this._endsAt;
  set endsAt(DateTime? endsAt) => _$this._endsAt = endsAt;

  String? _reportId;
  String? get reportId => _$this._reportId;
  set reportId(String? reportId) => _$this._reportId = reportId;

  AdminUserSanctionResponseDtoBuilder() {
    AdminUserSanctionResponseDto._defaults(this);
  }

  AdminUserSanctionResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _type = $v.type;
      _reason = $v.reason;
      _startsAt = $v.startsAt;
      _endsAt = $v.endsAt;
      _reportId = $v.reportId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminUserSanctionResponseDto other) {
    _$v = other as _$AdminUserSanctionResponseDto;
  }

  @override
  void update(void Function(AdminUserSanctionResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminUserSanctionResponseDto build() => _build();

  _$AdminUserSanctionResponseDto _build() {
    final _$result =
        _$v ??
        _$AdminUserSanctionResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'AdminUserSanctionResponseDto',
            'id',
          ),
          type: BuiltValueNullFieldError.checkNotNull(
            type,
            r'AdminUserSanctionResponseDto',
            'type',
          ),
          reason: BuiltValueNullFieldError.checkNotNull(
            reason,
            r'AdminUserSanctionResponseDto',
            'reason',
          ),
          startsAt: BuiltValueNullFieldError.checkNotNull(
            startsAt,
            r'AdminUserSanctionResponseDto',
            'startsAt',
          ),
          endsAt: endsAt,
          reportId: reportId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
