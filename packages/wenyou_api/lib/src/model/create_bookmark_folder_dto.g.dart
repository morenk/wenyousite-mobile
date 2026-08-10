// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_bookmark_folder_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateBookmarkFolderDto extends CreateBookmarkFolderDto {
  @override
  final String name;

  factory _$CreateBookmarkFolderDto([
    void Function(CreateBookmarkFolderDtoBuilder)? updates,
  ]) => (CreateBookmarkFolderDtoBuilder()..update(updates))._build();

  _$CreateBookmarkFolderDto._({required this.name}) : super._();
  @override
  CreateBookmarkFolderDto rebuild(
    void Function(CreateBookmarkFolderDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  CreateBookmarkFolderDtoBuilder toBuilder() =>
      CreateBookmarkFolderDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateBookmarkFolderDto && name == other.name;
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
      r'CreateBookmarkFolderDto',
    )..add('name', name)).toString();
  }
}

class CreateBookmarkFolderDtoBuilder
    implements
        Builder<CreateBookmarkFolderDto, CreateBookmarkFolderDtoBuilder> {
  _$CreateBookmarkFolderDto? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  CreateBookmarkFolderDtoBuilder() {
    CreateBookmarkFolderDto._defaults(this);
  }

  CreateBookmarkFolderDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateBookmarkFolderDto other) {
    _$v = other as _$CreateBookmarkFolderDto;
  }

  @override
  void update(void Function(CreateBookmarkFolderDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateBookmarkFolderDto build() => _build();

  _$CreateBookmarkFolderDto _build() {
    final _$result =
        _$v ??
        _$CreateBookmarkFolderDto._(
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'CreateBookmarkFolderDto',
            'name',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
