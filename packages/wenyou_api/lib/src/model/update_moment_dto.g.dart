// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_moment_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateMomentDto extends UpdateMomentDto {
  @override
  final String? title;
  @override
  final String? content;
  @override
  final BuiltList<String>? mediaIds;
  @override
  final String? coverMediaId;
  @override
  final num version;

  factory _$UpdateMomentDto([void Function(UpdateMomentDtoBuilder)? updates]) =>
      (UpdateMomentDtoBuilder()..update(updates))._build();

  _$UpdateMomentDto._({
    this.title,
    this.content,
    this.mediaIds,
    this.coverMediaId,
    required this.version,
  }) : super._();
  @override
  UpdateMomentDto rebuild(void Function(UpdateMomentDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdateMomentDtoBuilder toBuilder() => UpdateMomentDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateMomentDto &&
        title == other.title &&
        content == other.content &&
        mediaIds == other.mediaIds &&
        coverMediaId == other.coverMediaId &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, mediaIds.hashCode);
    _$hash = $jc(_$hash, coverMediaId.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateMomentDto')
          ..add('title', title)
          ..add('content', content)
          ..add('mediaIds', mediaIds)
          ..add('coverMediaId', coverMediaId)
          ..add('version', version))
        .toString();
  }
}

class UpdateMomentDtoBuilder
    implements Builder<UpdateMomentDto, UpdateMomentDtoBuilder> {
  _$UpdateMomentDto? _$v;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  ListBuilder<String>? _mediaIds;
  ListBuilder<String> get mediaIds =>
      _$this._mediaIds ??= ListBuilder<String>();
  set mediaIds(ListBuilder<String>? mediaIds) => _$this._mediaIds = mediaIds;

  String? _coverMediaId;
  String? get coverMediaId => _$this._coverMediaId;
  set coverMediaId(String? coverMediaId) => _$this._coverMediaId = coverMediaId;

  num? _version;
  num? get version => _$this._version;
  set version(num? version) => _$this._version = version;

  UpdateMomentDtoBuilder() {
    UpdateMomentDto._defaults(this);
  }

  UpdateMomentDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _title = $v.title;
      _content = $v.content;
      _mediaIds = $v.mediaIds?.toBuilder();
      _coverMediaId = $v.coverMediaId;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateMomentDto other) {
    _$v = other as _$UpdateMomentDto;
  }

  @override
  void update(void Function(UpdateMomentDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateMomentDto build() => _build();

  _$UpdateMomentDto _build() {
    _$UpdateMomentDto _$result;
    try {
      _$result =
          _$v ??
          _$UpdateMomentDto._(
            title: title,
            content: content,
            mediaIds: _mediaIds?.build(),
            coverMediaId: coverMediaId,
            version: BuiltValueNullFieldError.checkNotNull(
              version,
              r'UpdateMomentDto',
              'version',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'mediaIds';
        _mediaIds?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'UpdateMomentDto',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
