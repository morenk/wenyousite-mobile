// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_moment_bookmark_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateMomentBookmarkDto extends CreateMomentBookmarkDto {
  @override
  final String? folderId;

  factory _$CreateMomentBookmarkDto([
    void Function(CreateMomentBookmarkDtoBuilder)? updates,
  ]) => (CreateMomentBookmarkDtoBuilder()..update(updates))._build();

  _$CreateMomentBookmarkDto._({this.folderId}) : super._();
  @override
  CreateMomentBookmarkDto rebuild(
    void Function(CreateMomentBookmarkDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  CreateMomentBookmarkDtoBuilder toBuilder() =>
      CreateMomentBookmarkDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateMomentBookmarkDto && folderId == other.folderId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, folderId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'CreateMomentBookmarkDto',
    )..add('folderId', folderId)).toString();
  }
}

class CreateMomentBookmarkDtoBuilder
    implements
        Builder<CreateMomentBookmarkDto, CreateMomentBookmarkDtoBuilder> {
  _$CreateMomentBookmarkDto? _$v;

  String? _folderId;
  String? get folderId => _$this._folderId;
  set folderId(String? folderId) => _$this._folderId = folderId;

  CreateMomentBookmarkDtoBuilder() {
    CreateMomentBookmarkDto._defaults(this);
  }

  CreateMomentBookmarkDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _folderId = $v.folderId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateMomentBookmarkDto other) {
    _$v = other as _$CreateMomentBookmarkDto;
  }

  @override
  void update(void Function(CreateMomentBookmarkDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateMomentBookmarkDto build() => _build();

  _$CreateMomentBookmarkDto _build() {
    final _$result = _$v ?? _$CreateMomentBookmarkDto._(folderId: folderId);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
