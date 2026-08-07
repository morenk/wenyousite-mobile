// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_count_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostCountResponseDto extends PostCountResponseDto {
  @override
  final num replies;

  factory _$PostCountResponseDto([
    void Function(PostCountResponseDtoBuilder)? updates,
  ]) => (PostCountResponseDtoBuilder()..update(updates))._build();

  _$PostCountResponseDto._({required this.replies}) : super._();
  @override
  PostCountResponseDto rebuild(
    void Function(PostCountResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  PostCountResponseDtoBuilder toBuilder() =>
      PostCountResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostCountResponseDto && replies == other.replies;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, replies.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'PostCountResponseDto',
    )..add('replies', replies)).toString();
  }
}

class PostCountResponseDtoBuilder
    implements Builder<PostCountResponseDto, PostCountResponseDtoBuilder> {
  _$PostCountResponseDto? _$v;

  num? _replies;
  num? get replies => _$this._replies;
  set replies(num? replies) => _$this._replies = replies;

  PostCountResponseDtoBuilder() {
    PostCountResponseDto._defaults(this);
  }

  PostCountResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _replies = $v.replies;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostCountResponseDto other) {
    _$v = other as _$PostCountResponseDto;
  }

  @override
  void update(void Function(PostCountResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostCountResponseDto build() => _build();

  _$PostCountResponseDto _build() {
    final _$result =
        _$v ??
        _$PostCountResponseDto._(
          replies: BuiltValueNullFieldError.checkNotNull(
            replies,
            r'PostCountResponseDto',
            'replies',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
