// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_category_info_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ThreadCategoryInfoDto extends ThreadCategoryInfoDto {
  @override
  final String slug;
  @override
  final String name;
  @override
  final bool isActive;

  factory _$ThreadCategoryInfoDto([
    void Function(ThreadCategoryInfoDtoBuilder)? updates,
  ]) => (ThreadCategoryInfoDtoBuilder()..update(updates))._build();

  _$ThreadCategoryInfoDto._({
    required this.slug,
    required this.name,
    required this.isActive,
  }) : super._();
  @override
  ThreadCategoryInfoDto rebuild(
    void Function(ThreadCategoryInfoDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadCategoryInfoDtoBuilder toBuilder() =>
      ThreadCategoryInfoDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadCategoryInfoDto &&
        slug == other.slug &&
        name == other.name &&
        isActive == other.isActive;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, slug.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, isActive.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ThreadCategoryInfoDto')
          ..add('slug', slug)
          ..add('name', name)
          ..add('isActive', isActive))
        .toString();
  }
}

class ThreadCategoryInfoDtoBuilder
    implements Builder<ThreadCategoryInfoDto, ThreadCategoryInfoDtoBuilder> {
  _$ThreadCategoryInfoDto? _$v;

  String? _slug;
  String? get slug => _$this._slug;
  set slug(String? slug) => _$this._slug = slug;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  bool? _isActive;
  bool? get isActive => _$this._isActive;
  set isActive(bool? isActive) => _$this._isActive = isActive;

  ThreadCategoryInfoDtoBuilder() {
    ThreadCategoryInfoDto._defaults(this);
  }

  ThreadCategoryInfoDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _slug = $v.slug;
      _name = $v.name;
      _isActive = $v.isActive;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ThreadCategoryInfoDto other) {
    _$v = other as _$ThreadCategoryInfoDto;
  }

  @override
  void update(void Function(ThreadCategoryInfoDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadCategoryInfoDto build() => _build();

  _$ThreadCategoryInfoDto _build() {
    final _$result =
        _$v ??
        _$ThreadCategoryInfoDto._(
          slug: BuiltValueNullFieldError.checkNotNull(
            slug,
            r'ThreadCategoryInfoDto',
            'slug',
          ),
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'ThreadCategoryInfoDto',
            'name',
          ),
          isActive: BuiltValueNullFieldError.checkNotNull(
            isActive,
            r'ThreadCategoryInfoDto',
            'isActive',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
