// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_dashboard_period_metrics_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminDashboardPeriodMetricsDto extends AdminDashboardPeriodMetricsDto {
  @override
  final num activeUsers;
  @override
  final num newUsers;
  @override
  final num publishedThreads;
  @override
  final num newPosts;
  @override
  final num reportsReceived;
  @override
  final num reportsHandled;

  factory _$AdminDashboardPeriodMetricsDto([
    void Function(AdminDashboardPeriodMetricsDtoBuilder)? updates,
  ]) => (AdminDashboardPeriodMetricsDtoBuilder()..update(updates))._build();

  _$AdminDashboardPeriodMetricsDto._({
    required this.activeUsers,
    required this.newUsers,
    required this.publishedThreads,
    required this.newPosts,
    required this.reportsReceived,
    required this.reportsHandled,
  }) : super._();
  @override
  AdminDashboardPeriodMetricsDto rebuild(
    void Function(AdminDashboardPeriodMetricsDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminDashboardPeriodMetricsDtoBuilder toBuilder() =>
      AdminDashboardPeriodMetricsDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminDashboardPeriodMetricsDto &&
        activeUsers == other.activeUsers &&
        newUsers == other.newUsers &&
        publishedThreads == other.publishedThreads &&
        newPosts == other.newPosts &&
        reportsReceived == other.reportsReceived &&
        reportsHandled == other.reportsHandled;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, activeUsers.hashCode);
    _$hash = $jc(_$hash, newUsers.hashCode);
    _$hash = $jc(_$hash, publishedThreads.hashCode);
    _$hash = $jc(_$hash, newPosts.hashCode);
    _$hash = $jc(_$hash, reportsReceived.hashCode);
    _$hash = $jc(_$hash, reportsHandled.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminDashboardPeriodMetricsDto')
          ..add('activeUsers', activeUsers)
          ..add('newUsers', newUsers)
          ..add('publishedThreads', publishedThreads)
          ..add('newPosts', newPosts)
          ..add('reportsReceived', reportsReceived)
          ..add('reportsHandled', reportsHandled))
        .toString();
  }
}

class AdminDashboardPeriodMetricsDtoBuilder
    implements
        Builder<
          AdminDashboardPeriodMetricsDto,
          AdminDashboardPeriodMetricsDtoBuilder
        > {
  _$AdminDashboardPeriodMetricsDto? _$v;

  num? _activeUsers;
  num? get activeUsers => _$this._activeUsers;
  set activeUsers(num? activeUsers) => _$this._activeUsers = activeUsers;

  num? _newUsers;
  num? get newUsers => _$this._newUsers;
  set newUsers(num? newUsers) => _$this._newUsers = newUsers;

  num? _publishedThreads;
  num? get publishedThreads => _$this._publishedThreads;
  set publishedThreads(num? publishedThreads) =>
      _$this._publishedThreads = publishedThreads;

  num? _newPosts;
  num? get newPosts => _$this._newPosts;
  set newPosts(num? newPosts) => _$this._newPosts = newPosts;

  num? _reportsReceived;
  num? get reportsReceived => _$this._reportsReceived;
  set reportsReceived(num? reportsReceived) =>
      _$this._reportsReceived = reportsReceived;

  num? _reportsHandled;
  num? get reportsHandled => _$this._reportsHandled;
  set reportsHandled(num? reportsHandled) =>
      _$this._reportsHandled = reportsHandled;

  AdminDashboardPeriodMetricsDtoBuilder() {
    AdminDashboardPeriodMetricsDto._defaults(this);
  }

  AdminDashboardPeriodMetricsDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _activeUsers = $v.activeUsers;
      _newUsers = $v.newUsers;
      _publishedThreads = $v.publishedThreads;
      _newPosts = $v.newPosts;
      _reportsReceived = $v.reportsReceived;
      _reportsHandled = $v.reportsHandled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminDashboardPeriodMetricsDto other) {
    _$v = other as _$AdminDashboardPeriodMetricsDto;
  }

  @override
  void update(void Function(AdminDashboardPeriodMetricsDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminDashboardPeriodMetricsDto build() => _build();

  _$AdminDashboardPeriodMetricsDto _build() {
    final _$result =
        _$v ??
        _$AdminDashboardPeriodMetricsDto._(
          activeUsers: BuiltValueNullFieldError.checkNotNull(
            activeUsers,
            r'AdminDashboardPeriodMetricsDto',
            'activeUsers',
          ),
          newUsers: BuiltValueNullFieldError.checkNotNull(
            newUsers,
            r'AdminDashboardPeriodMetricsDto',
            'newUsers',
          ),
          publishedThreads: BuiltValueNullFieldError.checkNotNull(
            publishedThreads,
            r'AdminDashboardPeriodMetricsDto',
            'publishedThreads',
          ),
          newPosts: BuiltValueNullFieldError.checkNotNull(
            newPosts,
            r'AdminDashboardPeriodMetricsDto',
            'newPosts',
          ),
          reportsReceived: BuiltValueNullFieldError.checkNotNull(
            reportsReceived,
            r'AdminDashboardPeriodMetricsDto',
            'reportsReceived',
          ),
          reportsHandled: BuiltValueNullFieldError.checkNotNull(
            reportsHandled,
            r'AdminDashboardPeriodMetricsDto',
            'reportsHandled',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
