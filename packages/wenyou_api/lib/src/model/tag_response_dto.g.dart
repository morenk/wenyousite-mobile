// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TagResponseDto extends TagResponseDto {
  @override
  final String id;
  @override
  final String name;
  @override
  final String? color;
  @override
  final String? description;
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

  factory _$TagResponseDto([void Function(TagResponseDtoBuilder)? updates]) =>
      (TagResponseDtoBuilder()..update(updates))._build();

  _$TagResponseDto._({
    required this.id,
    required this.name,
    this.color,
    this.description,
    required this.sortOrder,
    required this.isActive,
    this.mergedIntoId,
    required this.createdAt,
    required this.updatedAt,
  }) : super._();
  @override
  TagResponseDto rebuild(void Function(TagResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TagResponseDtoBuilder toBuilder() => TagResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TagResponseDto &&
        id == other.id &&
        name == other.name &&
        color == other.color &&
        description == other.description &&
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
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, color.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
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
    return (newBuiltValueToStringHelper(r'TagResponseDto')
          ..add('id', id)
          ..add('name', name)
          ..add('color', color)
          ..add('description', description)
          ..add('sortOrder', sortOrder)
          ..add('isActive', isActive)
          ..add('mergedIntoId', mergedIntoId)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class TagResponseDtoBuilder
    implements Builder<TagResponseDto, TagResponseDtoBuilder> {
  _$TagResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

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

  String? _mergedIntoId;
  String? get mergedIntoId => _$this._mergedIntoId;
  set mergedIntoId(String? mergedIntoId) => _$this._mergedIntoId = mergedIntoId;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  TagResponseDtoBuilder() {
    TagResponseDto._defaults(this);
  }

  TagResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _color = $v.color;
      _description = $v.description;
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
  void replace(TagResponseDto other) {
    _$v = other as _$TagResponseDto;
  }

  @override
  void update(void Function(TagResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TagResponseDto build() => _build();

  _$TagResponseDto _build() {
    final _$result =
        _$v ??
        _$TagResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'TagResponseDto',
            'id',
          ),
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'TagResponseDto',
            'name',
          ),
          color: color,
          description: description,
          sortOrder: BuiltValueNullFieldError.checkNotNull(
            sortOrder,
            r'TagResponseDto',
            'sortOrder',
          ),
          isActive: BuiltValueNullFieldError.checkNotNull(
            isActive,
            r'TagResponseDto',
            'isActive',
          ),
          mergedIntoId: mergedIntoId,
          createdAt: BuiltValueNullFieldError.checkNotNull(
            createdAt,
            r'TagResponseDto',
            'createdAt',
          ),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
            updatedAt,
            r'TagResponseDto',
            'updatedAt',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
