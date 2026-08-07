// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_thread_tag_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AddThreadTagDto extends AddThreadTagDto {
  @override
  final String name;

  factory _$AddThreadTagDto([void Function(AddThreadTagDtoBuilder)? updates]) =>
      (AddThreadTagDtoBuilder()..update(updates))._build();

  _$AddThreadTagDto._({required this.name}) : super._();
  @override
  AddThreadTagDto rebuild(void Function(AddThreadTagDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AddThreadTagDtoBuilder toBuilder() => AddThreadTagDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AddThreadTagDto && name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'AddThreadTagDto',
    )..add('name', name)).toString();
  }
}

class AddThreadTagDtoBuilder
    implements Builder<AddThreadTagDto, AddThreadTagDtoBuilder> {
  _$AddThreadTagDto? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  AddThreadTagDtoBuilder() {
    AddThreadTagDto._defaults(this);
  }

  AddThreadTagDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AddThreadTagDto other) {
    _$v = other as _$AddThreadTagDto;
  }

  @override
  void update(void Function(AddThreadTagDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AddThreadTagDto build() => _build();

  _$AddThreadTagDto _build() {
    final _$result =
        _$v ??
        _$AddThreadTagDto._(
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'AddThreadTagDto',
            'name',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
