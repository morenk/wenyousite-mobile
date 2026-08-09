// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_dashboard_overview_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminDashboardOverviewResponseDto
    extends AdminDashboardOverviewResponseDto {
  @override
  final AdminDashboardRangeResponseDto range;
  @override
  final AdminDashboardActivityMetricsDto activity;
  @override
  final AdminDashboardPeriodMetricsDto current;
  @override
  final AdminDashboardPeriodMetricsDto previous;
  @override
  final AdminDashboardSnapshotDto snapshot;

  factory _$AdminDashboardOverviewResponseDto([
    void Function(AdminDashboardOverviewResponseDtoBuilder)? updates,
  ]) => (AdminDashboardOverviewResponseDtoBuilder()..update(updates))._build();

  _$AdminDashboardOverviewResponseDto._({
    required this.range,
    required this.activity,
    required this.current,
    required this.previous,
    required this.snapshot,
  }) : super._();
  @override
  AdminDashboardOverviewResponseDto rebuild(
    void Function(AdminDashboardOverviewResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminDashboardOverviewResponseDtoBuilder toBuilder() =>
      AdminDashboardOverviewResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminDashboardOverviewResponseDto &&
        range == other.range &&
        activity == other.activity &&
        current == other.current &&
        previous == other.previous &&
        snapshot == other.snapshot;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, range.hashCode);
    _$hash = $jc(_$hash, activity.hashCode);
    _$hash = $jc(_$hash, current.hashCode);
    _$hash = $jc(_$hash, previous.hashCode);
    _$hash = $jc(_$hash, snapshot.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminDashboardOverviewResponseDto')
          ..add('range', range)
          ..add('activity', activity)
          ..add('current', current)
          ..add('previous', previous)
          ..add('snapshot', snapshot))
        .toString();
  }
}

class AdminDashboardOverviewResponseDtoBuilder
    implements
        Builder<
          AdminDashboardOverviewResponseDto,
          AdminDashboardOverviewResponseDtoBuilder
        > {
  _$AdminDashboardOverviewResponseDto? _$v;

  AdminDashboardRangeResponseDtoBuilder? _range;
  AdminDashboardRangeResponseDtoBuilder get range =>
      _$this._range ??= AdminDashboardRangeResponseDtoBuilder();
  set range(AdminDashboardRangeResponseDtoBuilder? range) =>
      _$this._range = range;

  AdminDashboardActivityMetricsDtoBuilder? _activity;
  AdminDashboardActivityMetricsDtoBuilder get activity =>
      _$this._activity ??= AdminDashboardActivityMetricsDtoBuilder();
  set activity(AdminDashboardActivityMetricsDtoBuilder? activity) =>
      _$this._activity = activity;

  AdminDashboardPeriodMetricsDtoBuilder? _current;
  AdminDashboardPeriodMetricsDtoBuilder get current =>
      _$this._current ??= AdminDashboardPeriodMetricsDtoBuilder();
  set current(AdminDashboardPeriodMetricsDtoBuilder? current) =>
      _$this._current = current;

  AdminDashboardPeriodMetricsDtoBuilder? _previous;
  AdminDashboardPeriodMetricsDtoBuilder get previous =>
      _$this._previous ??= AdminDashboardPeriodMetricsDtoBuilder();
  set previous(AdminDashboardPeriodMetricsDtoBuilder? previous) =>
      _$this._previous = previous;

  AdminDashboardSnapshotDtoBuilder? _snapshot;
  AdminDashboardSnapshotDtoBuilder get snapshot =>
      _$this._snapshot ??= AdminDashboardSnapshotDtoBuilder();
  set snapshot(AdminDashboardSnapshotDtoBuilder? snapshot) =>
      _$this._snapshot = snapshot;

  AdminDashboardOverviewResponseDtoBuilder() {
    AdminDashboardOverviewResponseDto._defaults(this);
  }

  AdminDashboardOverviewResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _range = $v.range.toBuilder();
      _activity = $v.activity.toBuilder();
      _current = $v.current.toBuilder();
      _previous = $v.previous.toBuilder();
      _snapshot = $v.snapshot.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminDashboardOverviewResponseDto other) {
    _$v = other as _$AdminDashboardOverviewResponseDto;
  }

  @override
  void update(
    void Function(AdminDashboardOverviewResponseDtoBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminDashboardOverviewResponseDto build() => _build();

  _$AdminDashboardOverviewResponseDto _build() {
    _$AdminDashboardOverviewResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$AdminDashboardOverviewResponseDto._(
            range: range.build(),
            activity: activity.build(),
            current: current.build(),
            previous: previous.build(),
            snapshot: snapshot.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'range';
        range.build();
        _$failedField = 'activity';
        activity.build();
        _$failedField = 'current';
        current.build();
        _$failedField = 'previous';
        previous.build();
        _$failedField = 'snapshot';
        snapshot.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AdminDashboardOverviewResponseDto',
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
