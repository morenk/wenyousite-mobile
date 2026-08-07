// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subthread_count_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SubthreadCountResponseDto extends SubthreadCountResponseDto {
  @override
  final num posts;

  factory _$SubthreadCountResponseDto([
    void Function(SubthreadCountResponseDtoBuilder)? updates,
  ]) => (SubthreadCountResponseDtoBuilder()..update(updates))._build();

  _$SubthreadCountResponseDto._({required this.posts}) : super._();
  @override
  SubthreadCountResponseDto rebuild(
    void Function(SubthreadCountResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SubthreadCountResponseDtoBuilder toBuilder() =>
      SubthreadCountResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SubthreadCountResponseDto && posts == other.posts;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, posts.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'SubthreadCountResponseDto',
    )..add('posts', posts)).toString();
  }
}

class SubthreadCountResponseDtoBuilder
    implements
        Builder<SubthreadCountResponseDto, SubthreadCountResponseDtoBuilder> {
  _$SubthreadCountResponseDto? _$v;

  num? _posts;
  num? get posts => _$this._posts;
  set posts(num? posts) => _$this._posts = posts;

  SubthreadCountResponseDtoBuilder() {
    SubthreadCountResponseDto._defaults(this);
  }

  SubthreadCountResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _posts = $v.posts;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SubthreadCountResponseDto other) {
    _$v = other as _$SubthreadCountResponseDto;
  }

  @override
  void update(void Function(SubthreadCountResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SubthreadCountResponseDto build() => _build();

  _$SubthreadCountResponseDto _build() {
    final _$result =
        _$v ??
        _$SubthreadCountResponseDto._(
          posts: BuiltValueNullFieldError.checkNotNull(
            posts,
            r'SubthreadCountResponseDto',
            'posts',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
