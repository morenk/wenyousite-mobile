// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_dashboard_snapshot_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminDashboardSnapshotDto extends AdminDashboardSnapshotDto {
  @override
  final num totalUsers;
  @override
  final num pendingReports;
  @override
  final num activeSuspensions;
  @override
  final num activeBans;

  factory _$AdminDashboardSnapshotDto([
    void Function(AdminDashboardSnapshotDtoBuilder)? updates,
  ]) => (AdminDashboardSnapshotDtoBuilder()..update(updates))._build();

  _$AdminDashboardSnapshotDto._({
    required this.totalUsers,
    required this.pendingReports,
    required this.activeSuspensions,
    required this.activeBans,
  }) : super._();
  @override
  AdminDashboardSnapshotDto rebuild(
    void Function(AdminDashboardSnapshotDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminDashboardSnapshotDtoBuilder toBuilder() =>
      AdminDashboardSnapshotDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminDashboardSnapshotDto &&
        totalUsers == other.totalUsers &&
        pendingReports == other.pendingReports &&
        activeSuspensions == other.activeSuspensions &&
        activeBans == other.activeBans;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, totalUsers.hashCode);
    _$hash = $jc(_$hash, pendingReports.hashCode);
    _$hash = $jc(_$hash, activeSuspensions.hashCode);
    _$hash = $jc(_$hash, activeBans.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminDashboardSnapshotDto')
          ..add('totalUsers', totalUsers)
          ..add('pendingReports', pendingReports)
          ..add('activeSuspensions', activeSuspensions)
          ..add('activeBans', activeBans))
        .toString();
  }
}

class AdminDashboardSnapshotDtoBuilder
    implements
        Builder<AdminDashboardSnapshotDto, AdminDashboardSnapshotDtoBuilder> {
  _$AdminDashboardSnapshotDto? _$v;

  num? _totalUsers;
  num? get totalUsers => _$this._totalUsers;
  set totalUsers(num? totalUsers) => _$this._totalUsers = totalUsers;

  num? _pendingReports;
  num? get pendingReports => _$this._pendingReports;
  set pendingReports(num? pendingReports) =>
      _$this._pendingReports = pendingReports;

  num? _activeSuspensions;
  num? get activeSuspensions => _$this._activeSuspensions;
  set activeSuspensions(num? activeSuspensions) =>
      _$this._activeSuspensions = activeSuspensions;

  num? _activeBans;
  num? get activeBans => _$this._activeBans;
  set activeBans(num? activeBans) => _$this._activeBans = activeBans;

  AdminDashboardSnapshotDtoBuilder() {
    AdminDashboardSnapshotDto._defaults(this);
  }

  AdminDashboardSnapshotDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _totalUsers = $v.totalUsers;
      _pendingReports = $v.pendingReports;
      _activeSuspensions = $v.activeSuspensions;
      _activeBans = $v.activeBans;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminDashboardSnapshotDto other) {
    _$v = other as _$AdminDashboardSnapshotDto;
  }

  @override
  void update(void Function(AdminDashboardSnapshotDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminDashboardSnapshotDto build() => _build();

  _$AdminDashboardSnapshotDto _build() {
    final _$result =
        _$v ??
        _$AdminDashboardSnapshotDto._(
          totalUsers: BuiltValueNullFieldError.checkNotNull(
            totalUsers,
            r'AdminDashboardSnapshotDto',
            'totalUsers',
          ),
          pendingReports: BuiltValueNullFieldError.checkNotNull(
            pendingReports,
            r'AdminDashboardSnapshotDto',
            'pendingReports',
          ),
          activeSuspensions: BuiltValueNullFieldError.checkNotNull(
            activeSuspensions,
            r'AdminDashboardSnapshotDto',
            'activeSuspensions',
          ),
          activeBans: BuiltValueNullFieldError.checkNotNull(
            activeBans,
            r'AdminDashboardSnapshotDto',
            'activeBans',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
