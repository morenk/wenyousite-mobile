// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_moment_comment_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NotificationMomentCommentResponseDto
    extends NotificationMomentCommentResponseDto {
  @override
  final String id;
  @override
  final String? parentCommentId;
  @override
  final DateTime? deletedAt;

  factory _$NotificationMomentCommentResponseDto([
    void Function(NotificationMomentCommentResponseDtoBuilder)? updates,
  ]) =>
      (NotificationMomentCommentResponseDtoBuilder()..update(updates))._build();

  _$NotificationMomentCommentResponseDto._({
    required this.id,
    this.parentCommentId,
    this.deletedAt,
  }) : super._();
  @override
  NotificationMomentCommentResponseDto rebuild(
    void Function(NotificationMomentCommentResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  NotificationMomentCommentResponseDtoBuilder toBuilder() =>
      NotificationMomentCommentResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationMomentCommentResponseDto &&
        id == other.id &&
        parentCommentId == other.parentCommentId &&
        deletedAt == other.deletedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, parentCommentId.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NotificationMomentCommentResponseDto')
          ..add('id', id)
          ..add('parentCommentId', parentCommentId)
          ..add('deletedAt', deletedAt))
        .toString();
  }
}

class NotificationMomentCommentResponseDtoBuilder
    implements
        Builder<
          NotificationMomentCommentResponseDto,
          NotificationMomentCommentResponseDtoBuilder
        > {
  _$NotificationMomentCommentResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _parentCommentId;
  String? get parentCommentId => _$this._parentCommentId;
  set parentCommentId(String? parentCommentId) =>
      _$this._parentCommentId = parentCommentId;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  NotificationMomentCommentResponseDtoBuilder() {
    NotificationMomentCommentResponseDto._defaults(this);
  }

  NotificationMomentCommentResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _parentCommentId = $v.parentCommentId;
      _deletedAt = $v.deletedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotificationMomentCommentResponseDto other) {
    _$v = other as _$NotificationMomentCommentResponseDto;
  }

  @override
  void update(
    void Function(NotificationMomentCommentResponseDtoBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  NotificationMomentCommentResponseDto build() => _build();

  _$NotificationMomentCommentResponseDto _build() {
    final _$result =
        _$v ??
        _$NotificationMomentCommentResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'NotificationMomentCommentResponseDto',
            'id',
          ),
          parentCommentId: parentCommentId,
          deletedAt: deletedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
