// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_moment_bookmark_folder_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateMomentBookmarkFolderDto extends CreateMomentBookmarkFolderDto {
  @override
  final String name;

  factory _$CreateMomentBookmarkFolderDto([
    void Function(CreateMomentBookmarkFolderDtoBuilder)? updates,
  ]) => (CreateMomentBookmarkFolderDtoBuilder()..update(updates))._build();

  _$CreateMomentBookmarkFolderDto._({required this.name}) : super._();
  @override
  CreateMomentBookmarkFolderDto rebuild(
    void Function(CreateMomentBookmarkFolderDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  CreateMomentBookmarkFolderDtoBuilder toBuilder() =>
      CreateMomentBookmarkFolderDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateMomentBookmarkFolderDto && name == other.name;
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
      r'CreateMomentBookmarkFolderDto',
    )..add('name', name)).toString();
  }
}

class CreateMomentBookmarkFolderDtoBuilder
    implements
        Builder<
          CreateMomentBookmarkFolderDto,
          CreateMomentBookmarkFolderDtoBuilder
        > {
  _$CreateMomentBookmarkFolderDto? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  CreateMomentBookmarkFolderDtoBuilder() {
    CreateMomentBookmarkFolderDto._defaults(this);
  }

  CreateMomentBookmarkFolderDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateMomentBookmarkFolderDto other) {
    _$v = other as _$CreateMomentBookmarkFolderDto;
  }

  @override
  void update(void Function(CreateMomentBookmarkFolderDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateMomentBookmarkFolderDto build() => _build();

  _$CreateMomentBookmarkFolderDto _build() {
    final _$result =
        _$v ??
        _$CreateMomentBookmarkFolderDto._(
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'CreateMomentBookmarkFolderDto',
            'name',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
