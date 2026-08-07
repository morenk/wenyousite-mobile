// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_preview_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$InvitePreviewResponseDto extends InvitePreviewResponseDto {
  @override
  final InviteThreadPreviewResponseDto thread;
  @override
  final bool alreadyJoined;

  factory _$InvitePreviewResponseDto([
    void Function(InvitePreviewResponseDtoBuilder)? updates,
  ]) => (InvitePreviewResponseDtoBuilder()..update(updates))._build();

  _$InvitePreviewResponseDto._({
    required this.thread,
    required this.alreadyJoined,
  }) : super._();
  @override
  InvitePreviewResponseDto rebuild(
    void Function(InvitePreviewResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  InvitePreviewResponseDtoBuilder toBuilder() =>
      InvitePreviewResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InvitePreviewResponseDto &&
        thread == other.thread &&
        alreadyJoined == other.alreadyJoined;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, thread.hashCode);
    _$hash = $jc(_$hash, alreadyJoined.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'InvitePreviewResponseDto')
          ..add('thread', thread)
          ..add('alreadyJoined', alreadyJoined))
        .toString();
  }
}

class InvitePreviewResponseDtoBuilder
    implements
        Builder<InvitePreviewResponseDto, InvitePreviewResponseDtoBuilder> {
  _$InvitePreviewResponseDto? _$v;

  InviteThreadPreviewResponseDtoBuilder? _thread;
  InviteThreadPreviewResponseDtoBuilder get thread =>
      _$this._thread ??= InviteThreadPreviewResponseDtoBuilder();
  set thread(InviteThreadPreviewResponseDtoBuilder? thread) =>
      _$this._thread = thread;

  bool? _alreadyJoined;
  bool? get alreadyJoined => _$this._alreadyJoined;
  set alreadyJoined(bool? alreadyJoined) =>
      _$this._alreadyJoined = alreadyJoined;

  InvitePreviewResponseDtoBuilder() {
    InvitePreviewResponseDto._defaults(this);
  }

  InvitePreviewResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _thread = $v.thread.toBuilder();
      _alreadyJoined = $v.alreadyJoined;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(InvitePreviewResponseDto other) {
    _$v = other as _$InvitePreviewResponseDto;
  }

  @override
  void update(void Function(InvitePreviewResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  InvitePreviewResponseDto build() => _build();

  _$InvitePreviewResponseDto _build() {
    _$InvitePreviewResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$InvitePreviewResponseDto._(
            thread: thread.build(),
            alreadyJoined: BuiltValueNullFieldError.checkNotNull(
              alreadyJoined,
              r'InvitePreviewResponseDto',
              'alreadyJoined',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'thread';
        thread.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'InvitePreviewResponseDto',
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
