// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_session_info_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminSessionInfoDto extends AdminSessionInfoDto {
  @override
  final String id;
  @override
  final DateTime expiresAt;
  @override
  final num idleMinutes;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? lastActiveAt;
  @override
  final DateTime? elevatedUntil;

  factory _$AdminSessionInfoDto([
    void Function(AdminSessionInfoDtoBuilder)? updates,
  ]) => (AdminSessionInfoDtoBuilder()..update(updates))._build();

  _$AdminSessionInfoDto._({
    required this.id,
    required this.expiresAt,
    required this.idleMinutes,
    this.createdAt,
    this.lastActiveAt,
    this.elevatedUntil,
  }) : super._();
  @override
  AdminSessionInfoDto rebuild(
    void Function(AdminSessionInfoDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminSessionInfoDtoBuilder toBuilder() =>
      AdminSessionInfoDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminSessionInfoDto &&
        id == other.id &&
        expiresAt == other.expiresAt &&
        idleMinutes == other.idleMinutes &&
        createdAt == other.createdAt &&
        lastActiveAt == other.lastActiveAt &&
        elevatedUntil == other.elevatedUntil;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, idleMinutes.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, lastActiveAt.hashCode);
    _$hash = $jc(_$hash, elevatedUntil.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminSessionInfoDto')
          ..add('id', id)
          ..add('expiresAt', expiresAt)
          ..add('idleMinutes', idleMinutes)
          ..add('createdAt', createdAt)
          ..add('lastActiveAt', lastActiveAt)
          ..add('elevatedUntil', elevatedUntil))
        .toString();
  }
}

class AdminSessionInfoDtoBuilder
    implements Builder<AdminSessionInfoDto, AdminSessionInfoDtoBuilder> {
  _$AdminSessionInfoDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  num? _idleMinutes;
  num? get idleMinutes => _$this._idleMinutes;
  set idleMinutes(num? idleMinutes) => _$this._idleMinutes = idleMinutes;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _lastActiveAt;
  DateTime? get lastActiveAt => _$this._lastActiveAt;
  set lastActiveAt(DateTime? lastActiveAt) =>
      _$this._lastActiveAt = lastActiveAt;

  DateTime? _elevatedUntil;
  DateTime? get elevatedUntil => _$this._elevatedUntil;
  set elevatedUntil(DateTime? elevatedUntil) =>
      _$this._elevatedUntil = elevatedUntil;

  AdminSessionInfoDtoBuilder() {
    AdminSessionInfoDto._defaults(this);
  }

  AdminSessionInfoDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _expiresAt = $v.expiresAt;
      _idleMinutes = $v.idleMinutes;
      _createdAt = $v.createdAt;
      _lastActiveAt = $v.lastActiveAt;
      _elevatedUntil = $v.elevatedUntil;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminSessionInfoDto other) {
    _$v = other as _$AdminSessionInfoDto;
  }

  @override
  void update(void Function(AdminSessionInfoDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminSessionInfoDto build() => _build();

  _$AdminSessionInfoDto _build() {
    final _$result =
        _$v ??
        _$AdminSessionInfoDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'AdminSessionInfoDto',
            'id',
          ),
          expiresAt: BuiltValueNullFieldError.checkNotNull(
            expiresAt,
            r'AdminSessionInfoDto',
            'expiresAt',
          ),
          idleMinutes: BuiltValueNullFieldError.checkNotNull(
            idleMinutes,
            r'AdminSessionInfoDto',
            'idleMinutes',
          ),
          createdAt: createdAt,
          lastActiveAt: lastActiveAt,
          elevatedUntil: elevatedUntil,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
