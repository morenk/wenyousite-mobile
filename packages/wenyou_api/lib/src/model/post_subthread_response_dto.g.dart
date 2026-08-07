// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_subthread_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostSubthreadResponseDto extends PostSubthreadResponseDto {
  @override
  final String id;
  @override
  final String title;

  factory _$PostSubthreadResponseDto([
    void Function(PostSubthreadResponseDtoBuilder)? updates,
  ]) => (PostSubthreadResponseDtoBuilder()..update(updates))._build();

  _$PostSubthreadResponseDto._({required this.id, required this.title})
    : super._();
  @override
  PostSubthreadResponseDto rebuild(
    void Function(PostSubthreadResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  PostSubthreadResponseDtoBuilder toBuilder() =>
      PostSubthreadResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSubthreadResponseDto &&
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
    return (newBuiltValueToStringHelper(r'PostSubthreadResponseDto')
          ..add('id', id)
          ..add('title', title))
        .toString();
  }
}

class PostSubthreadResponseDtoBuilder
    implements
        Builder<PostSubthreadResponseDto, PostSubthreadResponseDtoBuilder> {
  _$PostSubthreadResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  PostSubthreadResponseDtoBuilder() {
    PostSubthreadResponseDto._defaults(this);
  }

  PostSubthreadResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSubthreadResponseDto other) {
    _$v = other as _$PostSubthreadResponseDto;
  }

  @override
  void update(void Function(PostSubthreadResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSubthreadResponseDto build() => _build();

  _$PostSubthreadResponseDto _build() {
    final _$result =
        _$v ??
        _$PostSubthreadResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'PostSubthreadResponseDto',
            'id',
          ),
          title: BuiltValueNullFieldError.checkNotNull(
            title,
            r'PostSubthreadResponseDto',
            'title',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
