// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_thread_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostThreadResponseDto extends PostThreadResponseDto {
  @override
  final String id;
  @override
  final String title;

  factory _$PostThreadResponseDto([
    void Function(PostThreadResponseDtoBuilder)? updates,
  ]) => (PostThreadResponseDtoBuilder()..update(updates))._build();

  _$PostThreadResponseDto._({required this.id, required this.title})
    : super._();
  @override
  PostThreadResponseDto rebuild(
    void Function(PostThreadResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  PostThreadResponseDtoBuilder toBuilder() =>
      PostThreadResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostThreadResponseDto &&
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
    return (newBuiltValueToStringHelper(r'PostThreadResponseDto')
          ..add('id', id)
          ..add('title', title))
        .toString();
  }
}

class PostThreadResponseDtoBuilder
    implements Builder<PostThreadResponseDto, PostThreadResponseDtoBuilder> {
  _$PostThreadResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  PostThreadResponseDtoBuilder() {
    PostThreadResponseDto._defaults(this);
  }

  PostThreadResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostThreadResponseDto other) {
    _$v = other as _$PostThreadResponseDto;
  }

  @override
  void update(void Function(PostThreadResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostThreadResponseDto build() => _build();

  _$PostThreadResponseDto _build() {
    final _$result =
        _$v ??
        _$PostThreadResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'PostThreadResponseDto',
            'id',
          ),
          title: BuiltValueNullFieldError.checkNotNull(
            title,
            r'PostThreadResponseDto',
            'title',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
