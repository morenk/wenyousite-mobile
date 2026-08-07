// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_subthread_reference_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SearchSubthreadReferenceResponseDto
    extends SearchSubthreadReferenceResponseDto {
  @override
  final String id;
  @override
  final String title;

  factory _$SearchSubthreadReferenceResponseDto([
    void Function(SearchSubthreadReferenceResponseDtoBuilder)? updates,
  ]) =>
      (SearchSubthreadReferenceResponseDtoBuilder()..update(updates))._build();

  _$SearchSubthreadReferenceResponseDto._({
    required this.id,
    required this.title,
  }) : super._();
  @override
  SearchSubthreadReferenceResponseDto rebuild(
    void Function(SearchSubthreadReferenceResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SearchSubthreadReferenceResponseDtoBuilder toBuilder() =>
      SearchSubthreadReferenceResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SearchSubthreadReferenceResponseDto &&
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
    return (newBuiltValueToStringHelper(r'SearchSubthreadReferenceResponseDto')
          ..add('id', id)
          ..add('title', title))
        .toString();
  }
}

class SearchSubthreadReferenceResponseDtoBuilder
    implements
        Builder<
          SearchSubthreadReferenceResponseDto,
          SearchSubthreadReferenceResponseDtoBuilder
        > {
  _$SearchSubthreadReferenceResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  SearchSubthreadReferenceResponseDtoBuilder() {
    SearchSubthreadReferenceResponseDto._defaults(this);
  }

  SearchSubthreadReferenceResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SearchSubthreadReferenceResponseDto other) {
    _$v = other as _$SearchSubthreadReferenceResponseDto;
  }

  @override
  void update(
    void Function(SearchSubthreadReferenceResponseDtoBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  SearchSubthreadReferenceResponseDto build() => _build();

  _$SearchSubthreadReferenceResponseDto _build() {
    final _$result =
        _$v ??
        _$SearchSubthreadReferenceResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'SearchSubthreadReferenceResponseDto',
            'id',
          ),
          title: BuiltValueNullFieldError.checkNotNull(
            title,
            r'SearchSubthreadReferenceResponseDto',
            'title',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
