// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_content_taxonomy_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateContentTaxonomyDto extends UpdateContentTaxonomyDto {
  @override
  final num version;
  @override
  final String reason;
  @override
  final String? category;
  @override
  final BuiltList<String>? tagIds;

  factory _$UpdateContentTaxonomyDto([
    void Function(UpdateContentTaxonomyDtoBuilder)? updates,
  ]) => (UpdateContentTaxonomyDtoBuilder()..update(updates))._build();

  _$UpdateContentTaxonomyDto._({
    required this.version,
    required this.reason,
    this.category,
    this.tagIds,
  }) : super._();
  @override
  UpdateContentTaxonomyDto rebuild(
    void Function(UpdateContentTaxonomyDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UpdateContentTaxonomyDtoBuilder toBuilder() =>
      UpdateContentTaxonomyDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateContentTaxonomyDto &&
        version == other.version &&
        reason == other.reason &&
        category == other.category &&
        tagIds == other.tagIds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, tagIds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateContentTaxonomyDto')
          ..add('version', version)
          ..add('reason', reason)
          ..add('category', category)
          ..add('tagIds', tagIds))
        .toString();
  }
}

class UpdateContentTaxonomyDtoBuilder
    implements
        Builder<UpdateContentTaxonomyDto, UpdateContentTaxonomyDtoBuilder> {
  _$UpdateContentTaxonomyDto? _$v;

  num? _version;
  num? get version => _$this._version;
  set version(num? version) => _$this._version = version;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  String? _category;
  String? get category => _$this._category;
  set category(String? category) => _$this._category = category;

  ListBuilder<String>? _tagIds;
  ListBuilder<String> get tagIds => _$this._tagIds ??= ListBuilder<String>();
  set tagIds(ListBuilder<String>? tagIds) => _$this._tagIds = tagIds;

  UpdateContentTaxonomyDtoBuilder() {
    UpdateContentTaxonomyDto._defaults(this);
  }

  UpdateContentTaxonomyDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _version = $v.version;
      _reason = $v.reason;
      _category = $v.category;
      _tagIds = $v.tagIds?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateContentTaxonomyDto other) {
    _$v = other as _$UpdateContentTaxonomyDto;
  }

  @override
  void update(void Function(UpdateContentTaxonomyDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateContentTaxonomyDto build() => _build();

  _$UpdateContentTaxonomyDto _build() {
    _$UpdateContentTaxonomyDto _$result;
    try {
      _$result =
          _$v ??
          _$UpdateContentTaxonomyDto._(
            version: BuiltValueNullFieldError.checkNotNull(
              version,
              r'UpdateContentTaxonomyDto',
              'version',
            ),
            reason: BuiltValueNullFieldError.checkNotNull(
              reason,
              r'UpdateContentTaxonomyDto',
              'reason',
            ),
            category: category,
            tagIds: _tagIds?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'tagIds';
        _tagIds?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'UpdateContentTaxonomyDto',
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
