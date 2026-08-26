// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moment_bookmark_folder_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MomentBookmarkFolderResponseDto
    extends MomentBookmarkFolderResponseDto {
  @override
  final String id;
  @override
  final String name;
  @override
  final bool isDefault;
  @override
  final num momentBookmarkCount;
  @override
  final DateTime createdAt;

  factory _$MomentBookmarkFolderResponseDto([
    void Function(MomentBookmarkFolderResponseDtoBuilder)? updates,
  ]) => (MomentBookmarkFolderResponseDtoBuilder()..update(updates))._build();

  _$MomentBookmarkFolderResponseDto._({
    required this.id,
    required this.name,
    required this.isDefault,
    required this.momentBookmarkCount,
    required this.createdAt,
  }) : super._();
  @override
  MomentBookmarkFolderResponseDto rebuild(
    void Function(MomentBookmarkFolderResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MomentBookmarkFolderResponseDtoBuilder toBuilder() =>
      MomentBookmarkFolderResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentBookmarkFolderResponseDto &&
        id == other.id &&
        name == other.name &&
        isDefault == other.isDefault &&
        momentBookmarkCount == other.momentBookmarkCount &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, isDefault.hashCode);
    _$hash = $jc(_$hash, momentBookmarkCount.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MomentBookmarkFolderResponseDto')
          ..add('id', id)
          ..add('name', name)
          ..add('isDefault', isDefault)
          ..add('momentBookmarkCount', momentBookmarkCount)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class MomentBookmarkFolderResponseDtoBuilder
    implements
        Builder<
          MomentBookmarkFolderResponseDto,
          MomentBookmarkFolderResponseDtoBuilder
        > {
  _$MomentBookmarkFolderResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  bool? _isDefault;
  bool? get isDefault => _$this._isDefault;
  set isDefault(bool? isDefault) => _$this._isDefault = isDefault;

  num? _momentBookmarkCount;
  num? get momentBookmarkCount => _$this._momentBookmarkCount;
  set momentBookmarkCount(num? momentBookmarkCount) =>
      _$this._momentBookmarkCount = momentBookmarkCount;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  MomentBookmarkFolderResponseDtoBuilder() {
    MomentBookmarkFolderResponseDto._defaults(this);
  }

  MomentBookmarkFolderResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _isDefault = $v.isDefault;
      _momentBookmarkCount = $v.momentBookmarkCount;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MomentBookmarkFolderResponseDto other) {
    _$v = other as _$MomentBookmarkFolderResponseDto;
  }

  @override
  void update(void Function(MomentBookmarkFolderResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MomentBookmarkFolderResponseDto build() => _build();

  _$MomentBookmarkFolderResponseDto _build() {
    final _$result =
        _$v ??
        _$MomentBookmarkFolderResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'MomentBookmarkFolderResponseDto',
            'id',
          ),
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'MomentBookmarkFolderResponseDto',
            'name',
          ),
          isDefault: BuiltValueNullFieldError.checkNotNull(
            isDefault,
            r'MomentBookmarkFolderResponseDto',
            'isDefault',
          ),
          momentBookmarkCount: BuiltValueNullFieldError.checkNotNull(
            momentBookmarkCount,
            r'MomentBookmarkFolderResponseDto',
            'momentBookmarkCount',
          ),
          createdAt: BuiltValueNullFieldError.checkNotNull(
            createdAt,
            r'MomentBookmarkFolderResponseDto',
            'createdAt',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
