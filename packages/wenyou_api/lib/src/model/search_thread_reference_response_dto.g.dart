// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_thread_reference_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SearchThreadReferenceResponseDto
    extends SearchThreadReferenceResponseDto {
  @override
  final String id;
  @override
  final String title;

  factory _$SearchThreadReferenceResponseDto([
    void Function(SearchThreadReferenceResponseDtoBuilder)? updates,
  ]) => (SearchThreadReferenceResponseDtoBuilder()..update(updates))._build();

  _$SearchThreadReferenceResponseDto._({required this.id, required this.title})
    : super._();
  @override
  SearchThreadReferenceResponseDto rebuild(
    void Function(SearchThreadReferenceResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SearchThreadReferenceResponseDtoBuilder toBuilder() =>
      SearchThreadReferenceResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SearchThreadReferenceResponseDto &&
        id == other.id &&
        title == other.title;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SearchThreadReferenceResponseDto')
          ..add('id', id)
          ..add('title', title))
        .toString();
  }
}

class SearchThreadReferenceResponseDtoBuilder
    implements
        Builder<
          SearchThreadReferenceResponseDto,
          SearchThreadReferenceResponseDtoBuilder
        > {
  _$SearchThreadReferenceResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  SearchThreadReferenceResponseDtoBuilder() {
    SearchThreadReferenceResponseDto._defaults(this);
  }

  SearchThreadReferenceResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SearchThreadReferenceResponseDto other) {
    _$v = other as _$SearchThreadReferenceResponseDto;
  }

  @override
  void update(void Function(SearchThreadReferenceResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SearchThreadReferenceResponseDto build() => _build();

  _$SearchThreadReferenceResponseDto _build() {
    final _$result =
        _$v ??
        _$SearchThreadReferenceResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'SearchThreadReferenceResponseDto',
            'id',
          ),
          title: BuiltValueNullFieldError.checkNotNull(
            title,
            r'SearchThreadReferenceResponseDto',
            'title',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
