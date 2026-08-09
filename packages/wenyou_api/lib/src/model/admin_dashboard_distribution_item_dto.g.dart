// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_dashboard_distribution_item_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminDashboardDistributionItemDto
    extends AdminDashboardDistributionItemDto {
  @override
  final String key;
  @override
  final num count;

  factory _$AdminDashboardDistributionItemDto([
    void Function(AdminDashboardDistributionItemDtoBuilder)? updates,
  ]) => (AdminDashboardDistributionItemDtoBuilder()..update(updates))._build();

  _$AdminDashboardDistributionItemDto._({
    required this.key,
    required this.count,
  }) : super._();
  @override
  AdminDashboardDistributionItemDto rebuild(
    void Function(AdminDashboardDistributionItemDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminDashboardDistributionItemDtoBuilder toBuilder() =>
      AdminDashboardDistributionItemDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminDashboardDistributionItemDto &&
        key == other.key &&
        count == other.count;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, count.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminDashboardDistributionItemDto')
          ..add('key', key)
          ..add('count', count))
        .toString();
  }
}

class AdminDashboardDistributionItemDtoBuilder
    implements
        Builder<
          AdminDashboardDistributionItemDto,
          AdminDashboardDistributionItemDtoBuilder
        > {
  _$AdminDashboardDistributionItemDto? _$v;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  num? _count;
  num? get count => _$this._count;
  set count(num? count) => _$this._count = count;

  AdminDashboardDistributionItemDtoBuilder() {
    AdminDashboardDistributionItemDto._defaults(this);
  }

  AdminDashboardDistributionItemDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _key = $v.key;
      _count = $v.count;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminDashboardDistributionItemDto other) {
    _$v = other as _$AdminDashboardDistributionItemDto;
  }

  @override
  void update(
    void Function(AdminDashboardDistributionItemDtoBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminDashboardDistributionItemDto build() => _build();

  _$AdminDashboardDistributionItemDto _build() {
    final _$result =
        _$v ??
        _$AdminDashboardDistributionItemDto._(
          key: BuiltValueNullFieldError.checkNotNull(
            key,
            r'AdminDashboardDistributionItemDto',
            'key',
          ),
          count: BuiltValueNullFieldError.checkNotNull(
            count,
            r'AdminDashboardDistributionItemDto',
            'count',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
