// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_direct_conversation_archive_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SetDirectConversationArchiveDto
    extends SetDirectConversationArchiveDto {
  @override
  final bool archived;

  factory _$SetDirectConversationArchiveDto([
    void Function(SetDirectConversationArchiveDtoBuilder)? updates,
  ]) => (SetDirectConversationArchiveDtoBuilder()..update(updates))._build();

  _$SetDirectConversationArchiveDto._({required this.archived}) : super._();
  @override
  SetDirectConversationArchiveDto rebuild(
    void Function(SetDirectConversationArchiveDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SetDirectConversationArchiveDtoBuilder toBuilder() =>
      SetDirectConversationArchiveDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SetDirectConversationArchiveDto &&
        archived == other.archived;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, archived.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'SetDirectConversationArchiveDto',
    )..add('archived', archived)).toString();
  }
}

class SetDirectConversationArchiveDtoBuilder
    implements
        Builder<
          SetDirectConversationArchiveDto,
          SetDirectConversationArchiveDtoBuilder
        > {
  _$SetDirectConversationArchiveDto? _$v;

  bool? _archived;
  bool? get archived => _$this._archived;
  set archived(bool? archived) => _$this._archived = archived;

  SetDirectConversationArchiveDtoBuilder() {
    SetDirectConversationArchiveDto._defaults(this);
  }

  SetDirectConversationArchiveDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _archived = $v.archived;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SetDirectConversationArchiveDto other) {
    _$v = other as _$SetDirectConversationArchiveDto;
  }

  @override
  void update(void Function(SetDirectConversationArchiveDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SetDirectConversationArchiveDto build() => _build();

  _$SetDirectConversationArchiveDto _build() {
    final _$result =
        _$v ??
        _$SetDirectConversationArchiveDto._(
          archived: BuiltValueNullFieldError.checkNotNull(
            archived,
            r'SetDirectConversationArchiveDto',
            'archived',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
