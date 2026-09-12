// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_bookmark_folder_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DeleteBookmarkFolderResponseDto
    extends DeleteBookmarkFolderResponseDto {
  @override
  final String deletedFolderId;
  @override
  final String destinationFolderId;

  factory _$DeleteBookmarkFolderResponseDto([
    void Function(DeleteBookmarkFolderResponseDtoBuilder)? updates,
  ]) => (DeleteBookmarkFolderResponseDtoBuilder()..update(updates))._build();

  _$DeleteBookmarkFolderResponseDto._({
    required this.deletedFolderId,
    required this.destinationFolderId,
  }) : super._();
  @override
  DeleteBookmarkFolderResponseDto rebuild(
    void Function(DeleteBookmarkFolderResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DeleteBookmarkFolderResponseDtoBuilder toBuilder() =>
      DeleteBookmarkFolderResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeleteBookmarkFolderResponseDto &&
        deletedFolderId == other.deletedFolderId &&
        destinationFolderId == other.destinationFolderId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, deletedFolderId.hashCode);
    _$hash = $jc(_$hash, destinationFolderId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DeleteBookmarkFolderResponseDto')
          ..add('deletedFolderId', deletedFolderId)
          ..add('destinationFolderId', destinationFolderId))
        .toString();
  }
}

class DeleteBookmarkFolderResponseDtoBuilder
    implements
        Builder<
          DeleteBookmarkFolderResponseDto,
          DeleteBookmarkFolderResponseDtoBuilder
        > {
  _$DeleteBookmarkFolderResponseDto? _$v;

  String? _deletedFolderId;
  String? get deletedFolderId => _$this._deletedFolderId;
  set deletedFolderId(String? deletedFolderId) =>
      _$this._deletedFolderId = deletedFolderId;

  String? _destinationFolderId;
  String? get destinationFolderId => _$this._destinationFolderId;
  set destinationFolderId(String? destinationFolderId) =>
      _$this._destinationFolderId = destinationFolderId;

  DeleteBookmarkFolderResponseDtoBuilder() {
    DeleteBookmarkFolderResponseDto._defaults(this);
  }

  DeleteBookmarkFolderResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _deletedFolderId = $v.deletedFolderId;
      _destinationFolderId = $v.destinationFolderId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeleteBookmarkFolderResponseDto other) {
    _$v = other as _$DeleteBookmarkFolderResponseDto;
  }

  @override
  void update(void Function(DeleteBookmarkFolderResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeleteBookmarkFolderResponseDto build() => _build();

  _$DeleteBookmarkFolderResponseDto _build() {
    final _$result =
        _$v ??
        _$DeleteBookmarkFolderResponseDto._(
          deletedFolderId: BuiltValueNullFieldError.checkNotNull(
            deletedFolderId,
            r'DeleteBookmarkFolderResponseDto',
            'deletedFolderId',
          ),
          destinationFolderId: BuiltValueNullFieldError.checkNotNull(
            destinationFolderId,
            r'DeleteBookmarkFolderResponseDto',
            'destinationFolderId',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
