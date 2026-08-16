// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_thread_category_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateThreadCategoryDto extends UpdateThreadCategoryDto {
  @override
  final String? name;
  @override
  final String? description;
  @override
  final String? icon;
  @override
  final num? sortOrder;
  @override
  final bool? isActive;
  @override
  final String? reason;

  factory _$UpdateThreadCategoryDto([
    void Function(UpdateThreadCategoryDtoBuilder)? updates,
  ]) => (UpdateThreadCategoryDtoBuilder()..update(updates))._build();

  _$UpdateThreadCategoryDto._({
    this.name,
    this.description,
    this.icon,
    this.sortOrder,
    this.isActive,
    this.reason,
  }) : super._();
  @override
  UpdateThreadCategoryDto rebuild(
    void Function(UpdateThreadCategoryDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UpdateThreadCategoryDtoBuilder toBuilder() =>
      UpdateThreadCategoryDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateThreadCategoryDto &&
        name == other.name &&
        description == other.description &&
        icon == other.icon &&
        sortOrder == other.sortOrder &&
        isActive == other.isActive &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, icon.hashCode);
    _$hash = $jc(_$hash, sortOrder.hashCode);
    _$hash = $jc(_$hash, isActive.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateThreadCategoryDto')
          ..add('name', name)
          ..add('description', description)
          ..add('icon', icon)
          ..add('sortOrder', sortOrder)
          ..add('isActive', isActive)
          ..add('reason', reason))
        .toString();
  }
}

class UpdateThreadCategoryDtoBuilder
    implements
        Builder<UpdateThreadCategoryDto, UpdateThreadCategoryDtoBuilder> {
  _$UpdateThreadCategoryDto? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  String? _icon;
  String? get icon => _$this._icon;
  set icon(String? icon) => _$this._icon = icon;

  num? _sortOrder;
  num? get sortOrder => _$this._sortOrder;
  set sortOrder(num? sortOrder) => _$this._sortOrder = sortOrder;

  bool? _isActive;
  bool? get isActive => _$this._isActive;
  set isActive(bool? isActive) => _$this._isActive = isActive;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  UpdateThreadCategoryDtoBuilder() {
    UpdateThreadCategoryDto._defaults(this);
  }

  UpdateThreadCategoryDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _description = $v.description;
      _icon = $v.icon;
      _sortOrder = $v.sortOrder;
      _isActive = $v.isActive;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateThreadCategoryDto other) {
    _$v = other as _$UpdateThreadCategoryDto;
  }

  @override
  void update(void Function(UpdateThreadCategoryDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateThreadCategoryDto build() => _build();

  _$UpdateThreadCategoryDto _build() {
    final _$result =
        _$v ??
        _$UpdateThreadCategoryDto._(
          name: name,
          description: description,
          icon: icon,
          sortOrder: sortOrder,
          isActive: isActive,
          reason: reason,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
