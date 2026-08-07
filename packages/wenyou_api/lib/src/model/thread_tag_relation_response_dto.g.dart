// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_tag_relation_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ThreadTagRelationResponseDto extends ThreadTagRelationResponseDto {
  @override
  final String id;
  @override
  final String threadId;
  @override
  final String tagId;
  @override
  final ThreadTagResponseDto tag;

  factory _$ThreadTagRelationResponseDto([
    void Function(ThreadTagRelationResponseDtoBuilder)? updates,
  ]) => (ThreadTagRelationResponseDtoBuilder()..update(updates))._build();

  _$ThreadTagRelationResponseDto._({
    required this.id,
    required this.threadId,
    required this.tagId,
    required this.tag,
  }) : super._();
  @override
  ThreadTagRelationResponseDto rebuild(
    void Function(ThreadTagRelationResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadTagRelationResponseDtoBuilder toBuilder() =>
      ThreadTagRelationResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadTagRelationResponseDto &&
        id == other.id &&
        threadId == other.threadId &&
        tagId == other.tagId &&
        tag == other.tag;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, threadId.hashCode);
    _$hash = $jc(_$hash, tagId.hashCode);
    _$hash = $jc(_$hash, tag.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ThreadTagRelationResponseDto')
          ..add('id', id)
          ..add('threadId', threadId)
          ..add('tagId', tagId)
          ..add('tag', tag))
        .toString();
  }
}

class ThreadTagRelationResponseDtoBuilder
    implements
        Builder<
          ThreadTagRelationResponseDto,
          ThreadTagRelationResponseDtoBuilder
        > {
  _$ThreadTagRelationResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _threadId;
  String? get threadId => _$this._threadId;
  set threadId(String? threadId) => _$this._threadId = threadId;

  String? _tagId;
  String? get tagId => _$this._tagId;
  set tagId(String? tagId) => _$this._tagId = tagId;

  ThreadTagResponseDtoBuilder? _tag;
  ThreadTagResponseDtoBuilder get tag =>
      _$this._tag ??= ThreadTagResponseDtoBuilder();
  set tag(ThreadTagResponseDtoBuilder? tag) => _$this._tag = tag;

  ThreadTagRelationResponseDtoBuilder() {
    ThreadTagRelationResponseDto._defaults(this);
  }

  ThreadTagRelationResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _threadId = $v.threadId;
      _tagId = $v.tagId;
      _tag = $v.tag.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ThreadTagRelationResponseDto other) {
    _$v = other as _$ThreadTagRelationResponseDto;
  }

  @override
  void update(void Function(ThreadTagRelationResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadTagRelationResponseDto build() => _build();

  _$ThreadTagRelationResponseDto _build() {
    _$ThreadTagRelationResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$ThreadTagRelationResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'ThreadTagRelationResponseDto',
              'id',
            ),
            threadId: BuiltValueNullFieldError.checkNotNull(
              threadId,
              r'ThreadTagRelationResponseDto',
              'threadId',
            ),
            tagId: BuiltValueNullFieldError.checkNotNull(
              tagId,
              r'ThreadTagRelationResponseDto',
              'tagId',
            ),
            tag: tag.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'tag';
        tag.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'ThreadTagRelationResponseDto',
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
