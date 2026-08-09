// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_dashboard_timeseries_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminDashboardTimeseriesResponseDto
    extends AdminDashboardTimeseriesResponseDto {
  @override
  final AdminDashboardRangeResponseDto range;
  @override
  final BuiltList<AdminDashboardTimeseriesPointDto> items;

  factory _$AdminDashboardTimeseriesResponseDto([
    void Function(AdminDashboardTimeseriesResponseDtoBuilder)? updates,
  ]) =>
      (AdminDashboardTimeseriesResponseDtoBuilder()..update(updates))._build();

  _$AdminDashboardTimeseriesResponseDto._({
    required this.range,
    required this.items,
  }) : super._();
  @override
  AdminDashboardTimeseriesResponseDto rebuild(
    void Function(AdminDashboardTimeseriesResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminDashboardTimeseriesResponseDtoBuilder toBuilder() =>
      AdminDashboardTimeseriesResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminDashboardTimeseriesResponseDto &&
        range == other.range &&
        items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, range.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminDashboardTimeseriesResponseDto')
          ..add('range', range)
          ..add('items', items))
        .toString();
  }
}

class AdminDashboardTimeseriesResponseDtoBuilder
    implements
        Builder<
          AdminDashboardTimeseriesResponseDto,
          AdminDashboardTimeseriesResponseDtoBuilder
        > {
  _$AdminDashboardTimeseriesResponseDto? _$v;

  AdminDashboardRangeResponseDtoBuilder? _range;
  AdminDashboardRangeResponseDtoBuilder get range =>
      _$this._range ??= AdminDashboardRangeResponseDtoBuilder();
  set range(AdminDashboardRangeResponseDtoBuilder? range) =>
      _$this._range = range;

  ListBuilder<AdminDashboardTimeseriesPointDto>? _items;
  ListBuilder<AdminDashboardTimeseriesPointDto> get items =>
      _$this._items ??= ListBuilder<AdminDashboardTimeseriesPointDto>();
  set items(ListBuilder<AdminDashboardTimeseriesPointDto>? items) =>
      _$this._items = items;

  AdminDashboardTimeseriesResponseDtoBuilder() {
    AdminDashboardTimeseriesResponseDto._defaults(this);
  }

  AdminDashboardTimeseriesResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _range = $v.range.toBuilder();
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminDashboardTimeseriesResponseDto other) {
    _$v = other as _$AdminDashboardTimeseriesResponseDto;
  }

  @override
  void update(
    void Function(AdminDashboardTimeseriesResponseDtoBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminDashboardTimeseriesResponseDto build() => _build();

  _$AdminDashboardTimeseriesResponseDto _build() {
    _$AdminDashboardTimeseriesResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$AdminDashboardTimeseriesResponseDto._(
            range: range.build(),
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'range';
        range.build();
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AdminDashboardTimeseriesResponseDto',
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
