// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_dashboard_category_distribution_item_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminDashboardCategoryDistributionItemDto
    extends AdminDashboardCategoryDistributionItemDto {
  @override
  final String key;
  @override
  final num count;
  @override
  final String name;
  @override
  final bool isActive;

  factory _$AdminDashboardCategoryDistributionItemDto([
    void Function(AdminDashboardCategoryDistributionItemDtoBuilder)? updates,
  ]) => (AdminDashboardCategoryDistributionItemDtoBuilder()..update(updates))
      ._build();

  _$AdminDashboardCategoryDistributionItemDto._({
    required this.key,
    required this.count,
    required this.name,
    required this.isActive,
  }) : super._();
  @override
  AdminDashboardCategoryDistributionItemDto rebuild(
    void Function(AdminDashboardCategoryDistributionItemDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminDashboardCategoryDistributionItemDtoBuilder toBuilder() =>
      AdminDashboardCategoryDistributionItemDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminDashboardCategoryDistributionItemDto &&
        key == other.key &&
        count == other.count &&
        name == other.name &&
        isActive == other.isActive;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, count.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, isActive.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'AdminDashboardCategoryDistributionItemDto',
          )
          ..add('key', key)
          ..add('count', count)
          ..add('name', name)
          ..add('isActive', isActive))
        .toString();
  }
}

class AdminDashboardCategoryDistributionItemDtoBuilder
    implements
        Builder<
          AdminDashboardCategoryDistributionItemDto,
          AdminDashboardCategoryDistributionItemDtoBuilder
        > {
  _$AdminDashboardCategoryDistributionItemDto? _$v;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  num? _count;
  num? get count => _$this._count;
  set count(num? count) => _$this._count = count;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  bool? _isActive;
  bool? get isActive => _$this._isActive;
  set isActive(bool? isActive) => _$this._isActive = isActive;

  AdminDashboardCategoryDistributionItemDtoBuilder() {
    AdminDashboardCategoryDistributionItemDto._defaults(this);
  }

  AdminDashboardCategoryDistributionItemDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _key = $v.key;
      _count = $v.count;
      _name = $v.name;
      _isActive = $v.isActive;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminDashboardCategoryDistributionItemDto other) {
    _$v = other as _$AdminDashboardCategoryDistributionItemDto;
  }

  @override
  void update(
    void Function(AdminDashboardCategoryDistributionItemDtoBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminDashboardCategoryDistributionItemDto build() => _build();

  _$AdminDashboardCategoryDistributionItemDto _build() {
    final _$result =
        _$v ??
        _$AdminDashboardCategoryDistributionItemDto._(
          key: BuiltValueNullFieldError.checkNotNull(
            key,
            r'AdminDashboardCategoryDistributionItemDto',
            'key',
          ),
          count: BuiltValueNullFieldError.checkNotNull(
            count,
            r'AdminDashboardCategoryDistributionItemDto',
            'count',
          ),
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'AdminDashboardCategoryDistributionItemDto',
            'name',
          ),
          isActive: BuiltValueNullFieldError.checkNotNull(
            isActive,
            r'AdminDashboardCategoryDistributionItemDto',
            'isActive',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
