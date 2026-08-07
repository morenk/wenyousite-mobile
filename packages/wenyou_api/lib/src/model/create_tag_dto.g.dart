// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_tag_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateTagDto extends CreateTagDto {
  @override
  final String name;
  @override
  final String? color;

  factory _$CreateTagDto([void Function(CreateTagDtoBuilder)? updates]) =>
      (CreateTagDtoBuilder()..update(updates))._build();

  _$CreateTagDto._({required this.name, this.color}) : super._();
  @override
  CreateTagDto rebuild(void Function(CreateTagDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateTagDtoBuilder toBuilder() => CreateTagDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateTagDto && name == other.name && color == other.color;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, color.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateTagDto')
          ..add('name', name)
          ..add('color', color))
        .toString();
  }
}

class CreateTagDtoBuilder
    implements Builder<CreateTagDto, CreateTagDtoBuilder> {
  _$CreateTagDto? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _color;
  String? get color => _$this._color;
  set color(String? color) => _$this._color = color;

  CreateTagDtoBuilder() {
    CreateTagDto._defaults(this);
  }

  CreateTagDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _color = $v.color;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateTagDto other) {
    _$v = other as _$CreateTagDto;
  }

  @override
  void update(void Function(CreateTagDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateTagDto build() => _build();

  _$CreateTagDto _build() {
    final _$result =
        _$v ??
        _$CreateTagDto._(
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'CreateTagDto',
            'name',
          ),
          color: color,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
