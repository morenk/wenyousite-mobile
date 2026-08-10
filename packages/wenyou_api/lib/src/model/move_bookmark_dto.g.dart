// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'move_bookmark_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MoveBookmarkDto extends MoveBookmarkDto {
  @override
  final String folderId;

  factory _$MoveBookmarkDto([void Function(MoveBookmarkDtoBuilder)? updates]) =>
      (MoveBookmarkDtoBuilder()..update(updates))._build();

  _$MoveBookmarkDto._({required this.folderId}) : super._();
  @override
  MoveBookmarkDto rebuild(void Function(MoveBookmarkDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MoveBookmarkDtoBuilder toBuilder() => MoveBookmarkDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MoveBookmarkDto && folderId == other.folderId;
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
      r'MoveBookmarkDto',
    )..add('folderId', folderId)).toString();
  }
}

class MoveBookmarkDtoBuilder
    implements Builder<MoveBookmarkDto, MoveBookmarkDtoBuilder> {
  _$MoveBookmarkDto? _$v;

  String? _folderId;
  String? get folderId => _$this._folderId;
  set folderId(String? folderId) => _$this._folderId = folderId;

  MoveBookmarkDtoBuilder() {
    MoveBookmarkDto._defaults(this);
  }

  MoveBookmarkDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _folderId = $v.folderId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MoveBookmarkDto other) {
    _$v = other as _$MoveBookmarkDto;
  }

  @override
  void update(void Function(MoveBookmarkDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MoveBookmarkDto build() => _build();

  _$MoveBookmarkDto _build() {
    final _$result =
        _$v ??
        _$MoveBookmarkDto._(
          folderId: BuiltValueNullFieldError.checkNotNull(
            folderId,
            r'MoveBookmarkDto',
            'folderId',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
