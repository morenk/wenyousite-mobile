// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_thread_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SubscriptionThreadResponseDto extends SubscriptionThreadResponseDto {
  @override
  final String id;
  @override
  final String title;
  @override
  final String? category;
  @override
  final ThreadCategoryInfoDto? categoryInfo;

  factory _$SubscriptionThreadResponseDto([
    void Function(SubscriptionThreadResponseDtoBuilder)? updates,
  ]) => (SubscriptionThreadResponseDtoBuilder()..update(updates))._build();

  _$SubscriptionThreadResponseDto._({
    required this.id,
    required this.title,
    this.category,
    this.categoryInfo,
  }) : super._();
  @override
  SubscriptionThreadResponseDto rebuild(
    void Function(SubscriptionThreadResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SubscriptionThreadResponseDtoBuilder toBuilder() =>
      SubscriptionThreadResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SubscriptionThreadResponseDto &&
        id == other.id &&
        title == other.title &&
        category == other.category &&
        categoryInfo == other.categoryInfo;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, categoryInfo.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SubscriptionThreadResponseDto')
          ..add('id', id)
          ..add('title', title)
          ..add('category', category)
          ..add('categoryInfo', categoryInfo))
        .toString();
  }
}

class SubscriptionThreadResponseDtoBuilder
    implements
        Builder<
          SubscriptionThreadResponseDto,
          SubscriptionThreadResponseDtoBuilder
        > {
  _$SubscriptionThreadResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _category;
  String? get category => _$this._category;
  set category(String? category) => _$this._category = category;

  ThreadCategoryInfoDtoBuilder? _categoryInfo;
  ThreadCategoryInfoDtoBuilder get categoryInfo =>
      _$this._categoryInfo ??= ThreadCategoryInfoDtoBuilder();
  set categoryInfo(ThreadCategoryInfoDtoBuilder? categoryInfo) =>
      _$this._categoryInfo = categoryInfo;

  SubscriptionThreadResponseDtoBuilder() {
    SubscriptionThreadResponseDto._defaults(this);
  }

  SubscriptionThreadResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _category = $v.category;
      _categoryInfo = $v.categoryInfo?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SubscriptionThreadResponseDto other) {
    _$v = other as _$SubscriptionThreadResponseDto;
  }

  @override
  void update(void Function(SubscriptionThreadResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SubscriptionThreadResponseDto build() => _build();

  _$SubscriptionThreadResponseDto _build() {
    _$SubscriptionThreadResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$SubscriptionThreadResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'SubscriptionThreadResponseDto',
              'id',
            ),
            title: BuiltValueNullFieldError.checkNotNull(
              title,
              r'SubscriptionThreadResponseDto',
              'title',
            ),
            category: category,
            categoryInfo: _categoryInfo?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'categoryInfo';
        _categoryInfo?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SubscriptionThreadResponseDto',
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
