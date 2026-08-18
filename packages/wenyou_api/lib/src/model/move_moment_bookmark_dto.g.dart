// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'move_moment_bookmark_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MoveMomentBookmarkDto extends MoveMomentBookmarkDto {
  @override
  final String folderId;

  factory _$MoveMomentBookmarkDto([
    void Function(MoveMomentBookmarkDtoBuilder)? updates,
  ]) => (MoveMomentBookmarkDtoBuilder()..update(updates))._build();

  _$MoveMomentBookmarkDto._({required this.folderId}) : super._();
  @override
  MoveMomentBookmarkDto rebuild(
    void Function(MoveMomentBookmarkDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MoveMomentBookmarkDtoBuilder toBuilder() =>
      MoveMomentBookmarkDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MoveMomentBookmarkDto && folderId == other.folderId;
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
      r'MoveMomentBookmarkDto',
    )..add('folderId', folderId)).toString();
  }
}

class MoveMomentBookmarkDtoBuilder
    implements Builder<MoveMomentBookmarkDto, MoveMomentBookmarkDtoBuilder> {
  _$MoveMomentBookmarkDto? _$v;

  String? _folderId;
  String? get folderId => _$this._folderId;
  set folderId(String? folderId) => _$this._folderId = folderId;

  MoveMomentBookmarkDtoBuilder() {
    MoveMomentBookmarkDto._defaults(this);
  }

  MoveMomentBookmarkDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _folderId = $v.folderId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MoveMomentBookmarkDto other) {
    _$v = other as _$MoveMomentBookmarkDto;
  }

  @override
  void update(void Function(MoveMomentBookmarkDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MoveMomentBookmarkDto build() => _build();

  _$MoveMomentBookmarkDto _build() {
    final _$result =
        _$v ??
        _$MoveMomentBookmarkDto._(
          folderId: BuiltValueNullFieldError.checkNotNull(
            folderId,
            r'MoveMomentBookmarkDto',
            'folderId',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
