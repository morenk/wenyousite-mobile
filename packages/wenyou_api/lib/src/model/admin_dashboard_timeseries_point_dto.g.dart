// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_dashboard_timeseries_point_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminDashboardTimeseriesPointDto
    extends AdminDashboardTimeseriesPointDto {
  @override
  final String date;
  @override
  final num dau;
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

  factory _$AdminDashboardTimeseriesPointDto([
    void Function(AdminDashboardTimeseriesPointDtoBuilder)? updates,
  ]) => (AdminDashboardTimeseriesPointDtoBuilder()..update(updates))._build();

  _$AdminDashboardTimeseriesPointDto._({
    required this.date,
    required this.dau,
    required this.newUsers,
    required this.publishedThreads,
    required this.newPosts,
    required this.reportsReceived,
    required this.reportsHandled,
  }) : super._();
  @override
  AdminDashboardTimeseriesPointDto rebuild(
    void Function(AdminDashboardTimeseriesPointDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminDashboardTimeseriesPointDtoBuilder toBuilder() =>
      AdminDashboardTimeseriesPointDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminDashboardTimeseriesPointDto &&
        date == other.date &&
        dau == other.dau &&
        newUsers == other.newUsers &&
        publishedThreads == other.publishedThreads &&
        newPosts == other.newPosts &&
        reportsReceived == other.reportsReceived &&
        reportsHandled == other.reportsHandled;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, date.hashCode);
    _$hash = $jc(_$hash, dau.hashCode);
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
    return (newBuiltValueToStringHelper(r'AdminDashboardTimeseriesPointDto')
          ..add('date', date)
          ..add('dau', dau)
          ..add('newUsers', newUsers)
          ..add('publishedThreads', publishedThreads)
          ..add('newPosts', newPosts)
          ..add('reportsReceived', reportsReceived)
          ..add('reportsHandled', reportsHandled))
        .toString();
  }
}

class AdminDashboardTimeseriesPointDtoBuilder
    implements
        Builder<
          AdminDashboardTimeseriesPointDto,
          AdminDashboardTimeseriesPointDtoBuilder
        > {
  _$AdminDashboardTimeseriesPointDto? _$v;

  String? _date;
  String? get date => _$this._date;
  set date(String? date) => _$this._date = date;

  num? _dau;
  num? get dau => _$this._dau;
  set dau(num? dau) => _$this._dau = dau;

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

  AdminDashboardTimeseriesPointDtoBuilder() {
    AdminDashboardTimeseriesPointDto._defaults(this);
  }

  AdminDashboardTimeseriesPointDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _date = $v.date;
      _dau = $v.dau;
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
  void replace(AdminDashboardTimeseriesPointDto other) {
    _$v = other as _$AdminDashboardTimeseriesPointDto;
  }

  @override
  void update(void Function(AdminDashboardTimeseriesPointDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminDashboardTimeseriesPointDto build() => _build();

  _$AdminDashboardTimeseriesPointDto _build() {
    final _$result =
        _$v ??
        _$AdminDashboardTimeseriesPointDto._(
          date: BuiltValueNullFieldError.checkNotNull(
            date,
            r'AdminDashboardTimeseriesPointDto',
            'date',
          ),
          dau: BuiltValueNullFieldError.checkNotNull(
            dau,
            r'AdminDashboardTimeseriesPointDto',
            'dau',
          ),
          newUsers: BuiltValueNullFieldError.checkNotNull(
            newUsers,
            r'AdminDashboardTimeseriesPointDto',
            'newUsers',
          ),
          publishedThreads: BuiltValueNullFieldError.checkNotNull(
            publishedThreads,
            r'AdminDashboardTimeseriesPointDto',
            'publishedThreads',
          ),
          newPosts: BuiltValueNullFieldError.checkNotNull(
            newPosts,
            r'AdminDashboardTimeseriesPointDto',
            'newPosts',
          ),
          reportsReceived: BuiltValueNullFieldError.checkNotNull(
            reportsReceived,
            r'AdminDashboardTimeseriesPointDto',
            'reportsReceived',
          ),
          reportsHandled: BuiltValueNullFieldError.checkNotNull(
            reportsHandled,
            r'AdminDashboardTimeseriesPointDto',
            'reportsHandled',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
