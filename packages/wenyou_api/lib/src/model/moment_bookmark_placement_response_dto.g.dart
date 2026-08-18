// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moment_bookmark_placement_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MomentBookmarkPlacementResponseDto
    extends MomentBookmarkPlacementResponseDto {
  @override
  final String momentId;
  @override
  final String folderId;

  factory _$MomentBookmarkPlacementResponseDto([
    void Function(MomentBookmarkPlacementResponseDtoBuilder)? updates,
  ]) => (MomentBookmarkPlacementResponseDtoBuilder()..update(updates))._build();

  _$MomentBookmarkPlacementResponseDto._({
    required this.momentId,
    required this.folderId,
  }) : super._();
  @override
  MomentBookmarkPlacementResponseDto rebuild(
    void Function(MomentBookmarkPlacementResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MomentBookmarkPlacementResponseDtoBuilder toBuilder() =>
      MomentBookmarkPlacementResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentBookmarkPlacementResponseDto &&
        momentId == other.momentId &&
        folderId == other.folderId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, momentId.hashCode);
    _$hash = $jc(_$hash, folderId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MomentBookmarkPlacementResponseDto')
          ..add('momentId', momentId)
          ..add('folderId', folderId))
        .toString();
  }
}

class MomentBookmarkPlacementResponseDtoBuilder
    implements
        Builder<
          MomentBookmarkPlacementResponseDto,
          MomentBookmarkPlacementResponseDtoBuilder
        > {
  _$MomentBookmarkPlacementResponseDto? _$v;

  String? _momentId;
  String? get momentId => _$this._momentId;
  set momentId(String? momentId) => _$this._momentId = momentId;

  String? _folderId;
  String? get folderId => _$this._folderId;
  set folderId(String? folderId) => _$this._folderId = folderId;

  MomentBookmarkPlacementResponseDtoBuilder() {
    MomentBookmarkPlacementResponseDto._defaults(this);
  }

  MomentBookmarkPlacementResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _momentId = $v.momentId;
      _folderId = $v.folderId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MomentBookmarkPlacementResponseDto other) {
    _$v = other as _$MomentBookmarkPlacementResponseDto;
  }

  @override
  void update(
    void Function(MomentBookmarkPlacementResponseDtoBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  MomentBookmarkPlacementResponseDto build() => _build();

  _$MomentBookmarkPlacementResponseDto _build() {
    final _$result =
        _$v ??
        _$MomentBookmarkPlacementResponseDto._(
          momentId: BuiltValueNullFieldError.checkNotNull(
            momentId,
            r'MomentBookmarkPlacementResponseDto',
            'momentId',
          ),
          folderId: BuiltValueNullFieldError.checkNotNull(
            folderId,
            r'MomentBookmarkPlacementResponseDto',
            'folderId',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
