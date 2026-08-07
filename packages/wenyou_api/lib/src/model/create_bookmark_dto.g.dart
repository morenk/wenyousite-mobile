// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_bookmark_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateBookmarkDto extends CreateBookmarkDto {
  @override
  final String threadId;

  factory _$CreateBookmarkDto([
    void Function(CreateBookmarkDtoBuilder)? updates,
  ]) => (CreateBookmarkDtoBuilder()..update(updates))._build();

  _$CreateBookmarkDto._({required this.threadId}) : super._();
  @override
  CreateBookmarkDto rebuild(void Function(CreateBookmarkDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateBookmarkDtoBuilder toBuilder() =>
      CreateBookmarkDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateBookmarkDto && threadId == other.threadId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, threadId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'CreateBookmarkDto',
    )..add('threadId', threadId)).toString();
  }
}

class CreateBookmarkDtoBuilder
    implements Builder<CreateBookmarkDto, CreateBookmarkDtoBuilder> {
  _$CreateBookmarkDto? _$v;

  String? _threadId;
  String? get threadId => _$this._threadId;
  set threadId(String? threadId) => _$this._threadId = threadId;

  CreateBookmarkDtoBuilder() {
    CreateBookmarkDto._defaults(this);
  }

  CreateBookmarkDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _threadId = $v.threadId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateBookmarkDto other) {
    _$v = other as _$CreateBookmarkDto;
  }

  @override
  void update(void Function(CreateBookmarkDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateBookmarkDto build() => _build();

  _$CreateBookmarkDto _build() {
    final _$result =
        _$v ??
        _$CreateBookmarkDto._(
          threadId: BuiltValueNullFieldError.checkNotNull(
            threadId,
            r'CreateBookmarkDto',
            'threadId',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
