// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moment_comment_context_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MomentCommentContextResponseDto
    extends MomentCommentContextResponseDto {
  @override
  final MomentCommentResponseDto root;
  @override
  final MomentCommentResponseDto target;
  @override
  final num replyCount;

  factory _$MomentCommentContextResponseDto([
    void Function(MomentCommentContextResponseDtoBuilder)? updates,
  ]) => (MomentCommentContextResponseDtoBuilder()..update(updates))._build();

  _$MomentCommentContextResponseDto._({
    required this.root,
    required this.target,
    required this.replyCount,
  }) : super._();
  @override
  MomentCommentContextResponseDto rebuild(
    void Function(MomentCommentContextResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MomentCommentContextResponseDtoBuilder toBuilder() =>
      MomentCommentContextResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentCommentContextResponseDto &&
        root == other.root &&
        target == other.target &&
        replyCount == other.replyCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, root.hashCode);
    _$hash = $jc(_$hash, target.hashCode);
    _$hash = $jc(_$hash, replyCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MomentCommentContextResponseDto')
          ..add('root', root)
          ..add('target', target)
          ..add('replyCount', replyCount))
        .toString();
  }
}

class MomentCommentContextResponseDtoBuilder
    implements
        Builder<
          MomentCommentContextResponseDto,
          MomentCommentContextResponseDtoBuilder
        > {
  _$MomentCommentContextResponseDto? _$v;

  MomentCommentResponseDtoBuilder? _root;
  MomentCommentResponseDtoBuilder get root =>
      _$this._root ??= MomentCommentResponseDtoBuilder();
  set root(MomentCommentResponseDtoBuilder? root) => _$this._root = root;

  MomentCommentResponseDtoBuilder? _target;
  MomentCommentResponseDtoBuilder get target =>
      _$this._target ??= MomentCommentResponseDtoBuilder();
  set target(MomentCommentResponseDtoBuilder? target) =>
      _$this._target = target;

  num? _replyCount;
  num? get replyCount => _$this._replyCount;
  set replyCount(num? replyCount) => _$this._replyCount = replyCount;

  MomentCommentContextResponseDtoBuilder() {
    MomentCommentContextResponseDto._defaults(this);
  }

  MomentCommentContextResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _root = $v.root.toBuilder();
      _target = $v.target.toBuilder();
      _replyCount = $v.replyCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MomentCommentContextResponseDto other) {
    _$v = other as _$MomentCommentContextResponseDto;
  }

  @override
  void update(void Function(MomentCommentContextResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MomentCommentContextResponseDto build() => _build();

  _$MomentCommentContextResponseDto _build() {
    _$MomentCommentContextResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$MomentCommentContextResponseDto._(
            root: root.build(),
            target: target.build(),
            replyCount: BuiltValueNullFieldError.checkNotNull(
              replyCount,
              r'MomentCommentContextResponseDto',
              'replyCount',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'root';
        root.build();
        _$failedField = 'target';
        target.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'MomentCommentContextResponseDto',
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
