// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_thread_category_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateThreadCategoryDto extends CreateThreadCategoryDto {
  @override
  final String slug;
  @override
  final String name;
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

  factory _$CreateThreadCategoryDto([
    void Function(CreateThreadCategoryDtoBuilder)? updates,
  ]) => (CreateThreadCategoryDtoBuilder()..update(updates))._build();

  _$CreateThreadCategoryDto._({
    required this.slug,
    required this.name,
    this.description,
    this.icon,
    this.sortOrder,
    this.isActive,
    this.reason,
  }) : super._();
  @override
  CreateThreadCategoryDto rebuild(
    void Function(CreateThreadCategoryDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  CreateThreadCategoryDtoBuilder toBuilder() =>
      CreateThreadCategoryDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateThreadCategoryDto &&
        slug == other.slug &&
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
    _$hash = $jc(_$hash, slug.hashCode);
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
    return (newBuiltValueToStringHelper(r'CreateThreadCategoryDto')
          ..add('slug', slug)
          ..add('name', name)
          ..add('description', description)
          ..add('icon', icon)
          ..add('sortOrder', sortOrder)
          ..add('isActive', isActive)
          ..add('reason', reason))
        .toString();
  }
}

class CreateThreadCategoryDtoBuilder
    implements
        Builder<CreateThreadCategoryDto, CreateThreadCategoryDtoBuilder> {
  _$CreateThreadCategoryDto? _$v;

  String? _slug;
  String? get slug => _$this._slug;
  set slug(String? slug) => _$this._slug = slug;

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

  CreateThreadCategoryDtoBuilder() {
    CreateThreadCategoryDto._defaults(this);
  }

  CreateThreadCategoryDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _slug = $v.slug;
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
  void replace(CreateThreadCategoryDto other) {
    _$v = other as _$CreateThreadCategoryDto;
  }

  @override
  void update(void Function(CreateThreadCategoryDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateThreadCategoryDto build() => _build();

  _$CreateThreadCategoryDto _build() {
    final _$result =
        _$v ??
        _$CreateThreadCategoryDto._(
          slug: BuiltValueNullFieldError.checkNotNull(
            slug,
            r'CreateThreadCategoryDto',
            'slug',
          ),
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'CreateThreadCategoryDto',
            'name',
          ),
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
