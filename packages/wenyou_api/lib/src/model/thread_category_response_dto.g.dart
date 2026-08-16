// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_category_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ThreadCategoryResponseDto extends ThreadCategoryResponseDto {
  @override
  final String id;
  @override
  final String slug;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String? icon;
  @override
  final num sortOrder;
  @override
  final bool isActive;
  @override
  final String? mergedIntoId;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$ThreadCategoryResponseDto([
    void Function(ThreadCategoryResponseDtoBuilder)? updates,
  ]) => (ThreadCategoryResponseDtoBuilder()..update(updates))._build();

  _$ThreadCategoryResponseDto._({
    required this.id,
    required this.slug,
    required this.name,
    this.description,
    this.icon,
    required this.sortOrder,
    required this.isActive,
    this.mergedIntoId,
    required this.createdAt,
    required this.updatedAt,
  }) : super._();
  @override
  ThreadCategoryResponseDto rebuild(
    void Function(ThreadCategoryResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadCategoryResponseDtoBuilder toBuilder() =>
      ThreadCategoryResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadCategoryResponseDto &&
        id == other.id &&
        slug == other.slug &&
        name == other.name &&
        description == other.description &&
        icon == other.icon &&
        sortOrder == other.sortOrder &&
        isActive == other.isActive &&
        mergedIntoId == other.mergedIntoId &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, slug.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, icon.hashCode);
    _$hash = $jc(_$hash, sortOrder.hashCode);
    _$hash = $jc(_$hash, isActive.hashCode);
    _$hash = $jc(_$hash, mergedIntoId.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ThreadCategoryResponseDto')
          ..add('id', id)
          ..add('slug', slug)
          ..add('name', name)
          ..add('description', description)
          ..add('icon', icon)
          ..add('sortOrder', sortOrder)
          ..add('isActive', isActive)
          ..add('mergedIntoId', mergedIntoId)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class ThreadCategoryResponseDtoBuilder
    implements
        Builder<ThreadCategoryResponseDto, ThreadCategoryResponseDtoBuilder> {
  _$ThreadCategoryResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

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

  String? _mergedIntoId;
  String? get mergedIntoId => _$this._mergedIntoId;
  set mergedIntoId(String? mergedIntoId) => _$this._mergedIntoId = mergedIntoId;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  ThreadCategoryResponseDtoBuilder() {
    ThreadCategoryResponseDto._defaults(this);
  }

  ThreadCategoryResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _slug = $v.slug;
      _name = $v.name;
      _description = $v.description;
      _icon = $v.icon;
      _sortOrder = $v.sortOrder;
      _isActive = $v.isActive;
      _mergedIntoId = $v.mergedIntoId;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ThreadCategoryResponseDto other) {
    _$v = other as _$ThreadCategoryResponseDto;
  }

  @override
  void update(void Function(ThreadCategoryResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadCategoryResponseDto build() => _build();

  _$ThreadCategoryResponseDto _build() {
    final _$result =
        _$v ??
        _$ThreadCategoryResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'ThreadCategoryResponseDto',
            'id',
          ),
          slug: BuiltValueNullFieldError.checkNotNull(
            slug,
            r'ThreadCategoryResponseDto',
            'slug',
          ),
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'ThreadCategoryResponseDto',
            'name',
          ),
          description: description,
          icon: icon,
          sortOrder: BuiltValueNullFieldError.checkNotNull(
            sortOrder,
            r'ThreadCategoryResponseDto',
            'sortOrder',
          ),
          isActive: BuiltValueNullFieldError.checkNotNull(
            isActive,
            r'ThreadCategoryResponseDto',
            'isActive',
          ),
          mergedIntoId: mergedIntoId,
          createdAt: BuiltValueNullFieldError.checkNotNull(
            createdAt,
            r'ThreadCategoryResponseDto',
            'createdAt',
          ),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
            updatedAt,
            r'ThreadCategoryResponseDto',
            'updatedAt',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
