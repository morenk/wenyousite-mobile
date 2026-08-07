// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_thread_count_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DraftThreadCountResponseDto extends DraftThreadCountResponseDto {
  @override
  final num subthreads;
  @override
  final num posts;

  factory _$DraftThreadCountResponseDto([
    void Function(DraftThreadCountResponseDtoBuilder)? updates,
  ]) => (DraftThreadCountResponseDtoBuilder()..update(updates))._build();

  _$DraftThreadCountResponseDto._({
    required this.subthreads,
    required this.posts,
  }) : super._();
  @override
  DraftThreadCountResponseDto rebuild(
    void Function(DraftThreadCountResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DraftThreadCountResponseDtoBuilder toBuilder() =>
      DraftThreadCountResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DraftThreadCountResponseDto &&
        subthreads == other.subthreads &&
        posts == other.posts;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, subthreads.hashCode);
    _$hash = $jc(_$hash, posts.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DraftThreadCountResponseDto')
          ..add('subthreads', subthreads)
          ..add('posts', posts))
        .toString();
  }
}

class DraftThreadCountResponseDtoBuilder
    implements
        Builder<
          DraftThreadCountResponseDto,
          DraftThreadCountResponseDtoBuilder
        > {
  _$DraftThreadCountResponseDto? _$v;

  num? _subthreads;
  num? get subthreads => _$this._subthreads;
  set subthreads(num? subthreads) => _$this._subthreads = subthreads;

  num? _posts;
  num? get posts => _$this._posts;
  set posts(num? posts) => _$this._posts = posts;

  DraftThreadCountResponseDtoBuilder() {
    DraftThreadCountResponseDto._defaults(this);
  }

  DraftThreadCountResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _subthreads = $v.subthreads;
      _posts = $v.posts;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DraftThreadCountResponseDto other) {
    _$v = other as _$DraftThreadCountResponseDto;
  }

  @override
  void update(void Function(DraftThreadCountResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DraftThreadCountResponseDto build() => _build();

  _$DraftThreadCountResponseDto _build() {
    final _$result =
        _$v ??
        _$DraftThreadCountResponseDto._(
          subthreads: BuiltValueNullFieldError.checkNotNull(
            subthreads,
            r'DraftThreadCountResponseDto',
            'subthreads',
          ),
          posts: BuiltValueNullFieldError.checkNotNull(
            posts,
            r'DraftThreadCountResponseDto',
            'posts',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
