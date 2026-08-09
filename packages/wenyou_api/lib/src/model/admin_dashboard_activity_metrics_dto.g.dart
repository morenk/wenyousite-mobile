// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_dashboard_activity_metrics_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminDashboardActivityMetricsDto
    extends AdminDashboardActivityMetricsDto {
  @override
  final num dau;
  @override
  final num wau;
  @override
  final num mau;

  factory _$AdminDashboardActivityMetricsDto([
    void Function(AdminDashboardActivityMetricsDtoBuilder)? updates,
  ]) => (AdminDashboardActivityMetricsDtoBuilder()..update(updates))._build();

  _$AdminDashboardActivityMetricsDto._({
    required this.dau,
    required this.wau,
    required this.mau,
  }) : super._();
  @override
  AdminDashboardActivityMetricsDto rebuild(
    void Function(AdminDashboardActivityMetricsDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminDashboardActivityMetricsDtoBuilder toBuilder() =>
      AdminDashboardActivityMetricsDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminDashboardActivityMetricsDto &&
        dau == other.dau &&
        wau == other.wau &&
        mau == other.mau;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, dau.hashCode);
    _$hash = $jc(_$hash, wau.hashCode);
    _$hash = $jc(_$hash, mau.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminDashboardActivityMetricsDto')
          ..add('dau', dau)
          ..add('wau', wau)
          ..add('mau', mau))
        .toString();
  }
}

class AdminDashboardActivityMetricsDtoBuilder
    implements
        Builder<
          AdminDashboardActivityMetricsDto,
          AdminDashboardActivityMetricsDtoBuilder
        > {
  _$AdminDashboardActivityMetricsDto? _$v;

  num? _dau;
  num? get dau => _$this._dau;
  set dau(num? dau) => _$this._dau = dau;

  num? _wau;
  num? get wau => _$this._wau;
  set wau(num? wau) => _$this._wau = wau;

  num? _mau;
  num? get mau => _$this._mau;
  set mau(num? mau) => _$this._mau = mau;

  AdminDashboardActivityMetricsDtoBuilder() {
    AdminDashboardActivityMetricsDto._defaults(this);
  }

  AdminDashboardActivityMetricsDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _dau = $v.dau;
      _wau = $v.wau;
      _mau = $v.mau;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminDashboardActivityMetricsDto other) {
    _$v = other as _$AdminDashboardActivityMetricsDto;
  }

  @override
  void update(void Function(AdminDashboardActivityMetricsDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminDashboardActivityMetricsDto build() => _build();

  _$AdminDashboardActivityMetricsDto _build() {
    final _$result =
        _$v ??
        _$AdminDashboardActivityMetricsDto._(
          dau: BuiltValueNullFieldError.checkNotNull(
            dau,
            r'AdminDashboardActivityMetricsDto',
            'dau',
          ),
          wau: BuiltValueNullFieldError.checkNotNull(
            wau,
            r'AdminDashboardActivityMetricsDto',
            'wau',
          ),
          mau: BuiltValueNullFieldError.checkNotNull(
            mau,
            r'AdminDashboardActivityMetricsDto',
            'mau',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
