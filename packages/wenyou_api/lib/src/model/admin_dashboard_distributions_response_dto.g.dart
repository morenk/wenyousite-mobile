// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_dashboard_distributions_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminDashboardDistributionsResponseDto
    extends AdminDashboardDistributionsResponseDto {
  @override
  final BuiltList<AdminDashboardDistributionItemDto> usersByRole;
  @override
  final BuiltList<AdminDashboardDistributionItemDto> reportsByStatus;
  @override
  final BuiltList<AdminDashboardDistributionItemDto> reportsByReason;
  @override
  final BuiltList<AdminDashboardDistributionItemDto> threadsByCategory;
  @override
  final BuiltList<AdminDashboardDistributionItemDto> activeSanctionsByType;

  factory _$AdminDashboardDistributionsResponseDto([
    void Function(AdminDashboardDistributionsResponseDtoBuilder)? updates,
  ]) => (AdminDashboardDistributionsResponseDtoBuilder()..update(updates))
      ._build();

  _$AdminDashboardDistributionsResponseDto._({
    required this.usersByRole,
    required this.reportsByStatus,
    required this.reportsByReason,
    required this.threadsByCategory,
    required this.activeSanctionsByType,
  }) : super._();
  @override
  AdminDashboardDistributionsResponseDto rebuild(
    void Function(AdminDashboardDistributionsResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminDashboardDistributionsResponseDtoBuilder toBuilder() =>
      AdminDashboardDistributionsResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminDashboardDistributionsResponseDto &&
        usersByRole == other.usersByRole &&
        reportsByStatus == other.reportsByStatus &&
        reportsByReason == other.reportsByReason &&
        threadsByCategory == other.threadsByCategory &&
        activeSanctionsByType == other.activeSanctionsByType;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, usersByRole.hashCode);
    _$hash = $jc(_$hash, reportsByStatus.hashCode);
    _$hash = $jc(_$hash, reportsByReason.hashCode);
    _$hash = $jc(_$hash, threadsByCategory.hashCode);
    _$hash = $jc(_$hash, activeSanctionsByType.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'AdminDashboardDistributionsResponseDto',
          )
          ..add('usersByRole', usersByRole)
          ..add('reportsByStatus', reportsByStatus)
          ..add('reportsByReason', reportsByReason)
          ..add('threadsByCategory', threadsByCategory)
          ..add('activeSanctionsByType', activeSanctionsByType))
        .toString();
  }
}

class AdminDashboardDistributionsResponseDtoBuilder
    implements
        Builder<
          AdminDashboardDistributionsResponseDto,
          AdminDashboardDistributionsResponseDtoBuilder
        > {
  _$AdminDashboardDistributionsResponseDto? _$v;

  ListBuilder<AdminDashboardDistributionItemDto>? _usersByRole;
  ListBuilder<AdminDashboardDistributionItemDto> get usersByRole =>
      _$this._usersByRole ??= ListBuilder<AdminDashboardDistributionItemDto>();
  set usersByRole(
    ListBuilder<AdminDashboardDistributionItemDto>? usersByRole,
  ) => _$this._usersByRole = usersByRole;

  ListBuilder<AdminDashboardDistributionItemDto>? _reportsByStatus;
  ListBuilder<AdminDashboardDistributionItemDto> get reportsByStatus =>
      _$this._reportsByStatus ??=
          ListBuilder<AdminDashboardDistributionItemDto>();
  set reportsByStatus(
    ListBuilder<AdminDashboardDistributionItemDto>? reportsByStatus,
  ) => _$this._reportsByStatus = reportsByStatus;

  ListBuilder<AdminDashboardDistributionItemDto>? _reportsByReason;
  ListBuilder<AdminDashboardDistributionItemDto> get reportsByReason =>
      _$this._reportsByReason ??=
          ListBuilder<AdminDashboardDistributionItemDto>();
  set reportsByReason(
    ListBuilder<AdminDashboardDistributionItemDto>? reportsByReason,
  ) => _$this._reportsByReason = reportsByReason;

  ListBuilder<AdminDashboardDistributionItemDto>? _threadsByCategory;
  ListBuilder<AdminDashboardDistributionItemDto> get threadsByCategory =>
      _$this._threadsByCategory ??=
          ListBuilder<AdminDashboardDistributionItemDto>();
  set threadsByCategory(
    ListBuilder<AdminDashboardDistributionItemDto>? threadsByCategory,
  ) => _$this._threadsByCategory = threadsByCategory;

  ListBuilder<AdminDashboardDistributionItemDto>? _activeSanctionsByType;
  ListBuilder<AdminDashboardDistributionItemDto> get activeSanctionsByType =>
      _$this._activeSanctionsByType ??=
          ListBuilder<AdminDashboardDistributionItemDto>();
  set activeSanctionsByType(
    ListBuilder<AdminDashboardDistributionItemDto>? activeSanctionsByType,
  ) => _$this._activeSanctionsByType = activeSanctionsByType;

  AdminDashboardDistributionsResponseDtoBuilder() {
    AdminDashboardDistributionsResponseDto._defaults(this);
  }

  AdminDashboardDistributionsResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _usersByRole = $v.usersByRole.toBuilder();
      _reportsByStatus = $v.reportsByStatus.toBuilder();
      _reportsByReason = $v.reportsByReason.toBuilder();
      _threadsByCategory = $v.threadsByCategory.toBuilder();
      _activeSanctionsByType = $v.activeSanctionsByType.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminDashboardDistributionsResponseDto other) {
    _$v = other as _$AdminDashboardDistributionsResponseDto;
  }

  @override
  void update(
    void Function(AdminDashboardDistributionsResponseDtoBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminDashboardDistributionsResponseDto build() => _build();

  _$AdminDashboardDistributionsResponseDto _build() {
    _$AdminDashboardDistributionsResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$AdminDashboardDistributionsResponseDto._(
            usersByRole: usersByRole.build(),
            reportsByStatus: reportsByStatus.build(),
            reportsByReason: reportsByReason.build(),
            threadsByCategory: threadsByCategory.build(),
            activeSanctionsByType: activeSanctionsByType.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'usersByRole';
        usersByRole.build();
        _$failedField = 'reportsByStatus';
        reportsByStatus.build();
        _$failedField = 'reportsByReason';
        reportsByReason.build();
        _$failedField = 'threadsByCategory';
        threadsByCategory.build();
        _$failedField = 'activeSanctionsByType';
        activeSanctionsByType.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AdminDashboardDistributionsResponseDto',
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
