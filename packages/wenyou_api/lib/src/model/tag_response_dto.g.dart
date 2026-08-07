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
  final DateTime createdAt;

  factory _$TagResponseDto([void Function(TagResponseDtoBuilder)? updates]) =>
      (TagResponseDtoBuilder()..update(updates))._build();

  _$TagResponseDto._({
    required this.id,
    required this.name,
    this.color,
    required this.createdAt,
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
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, color.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TagResponseDto')
          ..add('id', id)
          ..add('name', name)
          ..add('color', color)
          ..add('createdAt', createdAt))
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

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  TagResponseDtoBuilder() {
    TagResponseDto._defaults(this);
  }

  TagResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _color = $v.color;
      _createdAt = $v.createdAt;
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
          createdAt: BuiltValueNullFieldError.checkNotNull(
            createdAt,
            r'TagResponseDto',
            'createdAt',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
