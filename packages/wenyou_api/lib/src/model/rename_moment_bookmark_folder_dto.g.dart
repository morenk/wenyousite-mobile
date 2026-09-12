// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rename_moment_bookmark_folder_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RenameMomentBookmarkFolderDto extends RenameMomentBookmarkFolderDto {
  @override
  final String name;

  factory _$RenameMomentBookmarkFolderDto([
    void Function(RenameMomentBookmarkFolderDtoBuilder)? updates,
  ]) => (RenameMomentBookmarkFolderDtoBuilder()..update(updates))._build();

  _$RenameMomentBookmarkFolderDto._({required this.name}) : super._();
  @override
  RenameMomentBookmarkFolderDto rebuild(
    void Function(RenameMomentBookmarkFolderDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  RenameMomentBookmarkFolderDtoBuilder toBuilder() =>
      RenameMomentBookmarkFolderDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RenameMomentBookmarkFolderDto && name == other.name;
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
      r'RenameMomentBookmarkFolderDto',
    )..add('name', name)).toString();
  }
}

class RenameMomentBookmarkFolderDtoBuilder
    implements
        Builder<
          RenameMomentBookmarkFolderDto,
          RenameMomentBookmarkFolderDtoBuilder
        > {
  _$RenameMomentBookmarkFolderDto? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  RenameMomentBookmarkFolderDtoBuilder() {
    RenameMomentBookmarkFolderDto._defaults(this);
  }

  RenameMomentBookmarkFolderDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RenameMomentBookmarkFolderDto other) {
    _$v = other as _$RenameMomentBookmarkFolderDto;
  }

  @override
  void update(void Function(RenameMomentBookmarkFolderDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RenameMomentBookmarkFolderDto build() => _build();

  _$RenameMomentBookmarkFolderDto _build() {
    final _$result =
        _$v ??
        _$RenameMomentBookmarkFolderDto._(
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'RenameMomentBookmarkFolderDto',
            'name',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
