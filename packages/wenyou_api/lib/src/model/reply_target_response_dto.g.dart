// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reply_target_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReplyTargetResponseDto extends ReplyTargetResponseDto {
  @override
  final String id;
  @override
  final String authorId;
  @override
  final PostAuthorResponseDto author;

  factory _$ReplyTargetResponseDto([
    void Function(ReplyTargetResponseDtoBuilder)? updates,
  ]) => (ReplyTargetResponseDtoBuilder()..update(updates))._build();

  _$ReplyTargetResponseDto._({
    required this.id,
    required this.authorId,
    required this.author,
  }) : super._();
  @override
  ReplyTargetResponseDto rebuild(
    void Function(ReplyTargetResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ReplyTargetResponseDtoBuilder toBuilder() =>
      ReplyTargetResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReplyTargetResponseDto &&
        id == other.id &&
        authorId == other.authorId &&
        author == other.author;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, authorId.hashCode);
    _$hash = $jc(_$hash, author.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReplyTargetResponseDto')
          ..add('id', id)
          ..add('authorId', authorId)
          ..add('author', author))
        .toString();
  }
}

class ReplyTargetResponseDtoBuilder
    implements Builder<ReplyTargetResponseDto, ReplyTargetResponseDtoBuilder> {
  _$ReplyTargetResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _authorId;
  String? get authorId => _$this._authorId;
  set authorId(String? authorId) => _$this._authorId = authorId;

  PostAuthorResponseDtoBuilder? _author;
  PostAuthorResponseDtoBuilder get author =>
      _$this._author ??= PostAuthorResponseDtoBuilder();
  set author(PostAuthorResponseDtoBuilder? author) => _$this._author = author;

  ReplyTargetResponseDtoBuilder() {
    ReplyTargetResponseDto._defaults(this);
  }

  ReplyTargetResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _authorId = $v.authorId;
      _author = $v.author.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReplyTargetResponseDto other) {
    _$v = other as _$ReplyTargetResponseDto;
  }

  @override
  void update(void Function(ReplyTargetResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReplyTargetResponseDto build() => _build();

  _$ReplyTargetResponseDto _build() {
    _$ReplyTargetResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$ReplyTargetResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'ReplyTargetResponseDto',
              'id',
            ),
            authorId: BuiltValueNullFieldError.checkNotNull(
              authorId,
              r'ReplyTargetResponseDto',
              'authorId',
            ),
            author: author.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'author';
        author.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'ReplyTargetResponseDto',
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
