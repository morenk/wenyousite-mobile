// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_default_subthread_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DraftDefaultSubthreadResponseDto
    extends DraftDefaultSubthreadResponseDto {
  @override
  final String id;
  @override
  final String title;

  factory _$DraftDefaultSubthreadResponseDto([
    void Function(DraftDefaultSubthreadResponseDtoBuilder)? updates,
  ]) => (DraftDefaultSubthreadResponseDtoBuilder()..update(updates))._build();

  _$DraftDefaultSubthreadResponseDto._({required this.id, required this.title})
    : super._();
  @override
  DraftDefaultSubthreadResponseDto rebuild(
    void Function(DraftDefaultSubthreadResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DraftDefaultSubthreadResponseDtoBuilder toBuilder() =>
      DraftDefaultSubthreadResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DraftDefaultSubthreadResponseDto &&
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
    return (newBuiltValueToStringHelper(r'DraftDefaultSubthreadResponseDto')
          ..add('id', id)
          ..add('title', title))
        .toString();
  }
}

class DraftDefaultSubthreadResponseDtoBuilder
    implements
        Builder<
          DraftDefaultSubthreadResponseDto,
          DraftDefaultSubthreadResponseDtoBuilder
        > {
  _$DraftDefaultSubthreadResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  DraftDefaultSubthreadResponseDtoBuilder() {
    DraftDefaultSubthreadResponseDto._defaults(this);
  }

  DraftDefaultSubthreadResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DraftDefaultSubthreadResponseDto other) {
    _$v = other as _$DraftDefaultSubthreadResponseDto;
  }

  @override
  void update(void Function(DraftDefaultSubthreadResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DraftDefaultSubthreadResponseDto build() => _build();

  _$DraftDefaultSubthreadResponseDto _build() {
    final _$result =
        _$v ??
        _$DraftDefaultSubthreadResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'DraftDefaultSubthreadResponseDto',
            'id',
          ),
          title: BuiltValueNullFieldError.checkNotNull(
            title,
            r'DraftDefaultSubthreadResponseDto',
            'title',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
