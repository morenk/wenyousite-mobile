// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rename_bookmark_folder_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RenameBookmarkFolderDto extends RenameBookmarkFolderDto {
  @override
  final String name;

  factory _$RenameBookmarkFolderDto([
    void Function(RenameBookmarkFolderDtoBuilder)? updates,
  ]) => (RenameBookmarkFolderDtoBuilder()..update(updates))._build();

  _$RenameBookmarkFolderDto._({required this.name}) : super._();
  @override
  RenameBookmarkFolderDto rebuild(
    void Function(RenameBookmarkFolderDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  RenameBookmarkFolderDtoBuilder toBuilder() =>
      RenameBookmarkFolderDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RenameBookmarkFolderDto && name == other.name;
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
      r'RenameBookmarkFolderDto',
    )..add('name', name)).toString();
  }
}

class RenameBookmarkFolderDtoBuilder
    implements
        Builder<RenameBookmarkFolderDto, RenameBookmarkFolderDtoBuilder> {
  _$RenameBookmarkFolderDto? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  RenameBookmarkFolderDtoBuilder() {
    RenameBookmarkFolderDto._defaults(this);
  }

  RenameBookmarkFolderDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RenameBookmarkFolderDto other) {
    _$v = other as _$RenameBookmarkFolderDto;
  }

  @override
  void update(void Function(RenameBookmarkFolderDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RenameBookmarkFolderDto build() => _build();

  _$RenameBookmarkFolderDto _build() {
    final _$result =
        _$v ??
        _$RenameBookmarkFolderDto._(
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'RenameBookmarkFolderDto',
            'name',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
