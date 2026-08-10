// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_managed_tag_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateManagedTagDto extends UpdateManagedTagDto {
  @override
  final String? name;
  @override
  final String? color;
  @override
  final String? description;
  @override
  final num? sortOrder;
  @override
  final bool? isActive;
  @override
  final String? reason;

  factory _$UpdateManagedTagDto([
    void Function(UpdateManagedTagDtoBuilder)? updates,
  ]) => (UpdateManagedTagDtoBuilder()..update(updates))._build();

  _$UpdateManagedTagDto._({
    this.name,
    this.color,
    this.description,
    this.sortOrder,
    this.isActive,
    this.reason,
  }) : super._();
  @override
  UpdateManagedTagDto rebuild(
    void Function(UpdateManagedTagDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UpdateManagedTagDtoBuilder toBuilder() =>
      UpdateManagedTagDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateManagedTagDto &&
        name == other.name &&
        color == other.color &&
        description == other.description &&
        sortOrder == other.sortOrder &&
        isActive == other.isActive &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, color.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, sortOrder.hashCode);
    _$hash = $jc(_$hash, isActive.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateManagedTagDto')
          ..add('name', name)
          ..add('color', color)
          ..add('description', description)
          ..add('sortOrder', sortOrder)
          ..add('isActive', isActive)
          ..add('reason', reason))
        .toString();
  }
}

class UpdateManagedTagDtoBuilder
    implements Builder<UpdateManagedTagDto, UpdateManagedTagDtoBuilder> {
  _$UpdateManagedTagDto? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _color;
  String? get color => _$this._color;
  set color(String? color) => _$this._color = color;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  num? _sortOrder;
  num? get sortOrder => _$this._sortOrder;
  set sortOrder(num? sortOrder) => _$this._sortOrder = sortOrder;

  bool? _isActive;
  bool? get isActive => _$this._isActive;
  set isActive(bool? isActive) => _$this._isActive = isActive;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  UpdateManagedTagDtoBuilder() {
    UpdateManagedTagDto._defaults(this);
  }

  UpdateManagedTagDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _color = $v.color;
      _description = $v.description;
      _sortOrder = $v.sortOrder;
      _isActive = $v.isActive;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateManagedTagDto other) {
    _$v = other as _$UpdateManagedTagDto;
  }

  @override
  void update(void Function(UpdateManagedTagDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateManagedTagDto build() => _build();

  _$UpdateManagedTagDto _build() {
    final _$result =
        _$v ??
        _$UpdateManagedTagDto._(
          name: name,
          color: color,
          description: description,
          sortOrder: sortOrder,
          isActive: isActive,
          reason: reason,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
