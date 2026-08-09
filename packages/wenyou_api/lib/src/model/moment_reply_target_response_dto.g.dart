// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moment_reply_target_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MomentReplyTargetResponseDto extends MomentReplyTargetResponseDto {
  @override
  final String id;
  @override
  final PostAuthorResponseDto author;

  factory _$MomentReplyTargetResponseDto([
    void Function(MomentReplyTargetResponseDtoBuilder)? updates,
  ]) => (MomentReplyTargetResponseDtoBuilder()..update(updates))._build();

  _$MomentReplyTargetResponseDto._({required this.id, required this.author})
    : super._();
  @override
  MomentReplyTargetResponseDto rebuild(
    void Function(MomentReplyTargetResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MomentReplyTargetResponseDtoBuilder toBuilder() =>
      MomentReplyTargetResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentReplyTargetResponseDto &&
        id == other.id &&
        author == other.author;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, author.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MomentReplyTargetResponseDto')
          ..add('id', id)
          ..add('author', author))
        .toString();
  }
}

class MomentReplyTargetResponseDtoBuilder
    implements
        Builder<
          MomentReplyTargetResponseDto,
          MomentReplyTargetResponseDtoBuilder
        > {
  _$MomentReplyTargetResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  PostAuthorResponseDtoBuilder? _author;
  PostAuthorResponseDtoBuilder get author =>
      _$this._author ??= PostAuthorResponseDtoBuilder();
  set author(PostAuthorResponseDtoBuilder? author) => _$this._author = author;

  MomentReplyTargetResponseDtoBuilder() {
    MomentReplyTargetResponseDto._defaults(this);
  }

  MomentReplyTargetResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _author = $v.author.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MomentReplyTargetResponseDto other) {
    _$v = other as _$MomentReplyTargetResponseDto;
  }

  @override
  void update(void Function(MomentReplyTargetResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MomentReplyTargetResponseDto build() => _build();

  _$MomentReplyTargetResponseDto _build() {
    _$MomentReplyTargetResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$MomentReplyTargetResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'MomentReplyTargetResponseDto',
              'id',
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
          r'MomentReplyTargetResponseDto',
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
