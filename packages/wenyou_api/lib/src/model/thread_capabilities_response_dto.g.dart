// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_capabilities_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ThreadCapabilitiesResponseDto extends ThreadCapabilitiesResponseDto {
  @override
  final bool canManageThread;
  @override
  final bool canManageMembers;
  @override
  final bool isOwner;

  factory _$ThreadCapabilitiesResponseDto([
    void Function(ThreadCapabilitiesResponseDtoBuilder)? updates,
  ]) => (ThreadCapabilitiesResponseDtoBuilder()..update(updates))._build();

  _$ThreadCapabilitiesResponseDto._({
    required this.canManageThread,
    required this.canManageMembers,
    required this.isOwner,
  }) : super._();
  @override
  ThreadCapabilitiesResponseDto rebuild(
    void Function(ThreadCapabilitiesResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadCapabilitiesResponseDtoBuilder toBuilder() =>
      ThreadCapabilitiesResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadCapabilitiesResponseDto &&
        canManageThread == other.canManageThread &&
        canManageMembers == other.canManageMembers &&
        isOwner == other.isOwner;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, canManageThread.hashCode);
    _$hash = $jc(_$hash, canManageMembers.hashCode);
    _$hash = $jc(_$hash, isOwner.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ThreadCapabilitiesResponseDto')
          ..add('canManageThread', canManageThread)
          ..add('canManageMembers', canManageMembers)
          ..add('isOwner', isOwner))
        .toString();
  }
}

class ThreadCapabilitiesResponseDtoBuilder
    implements
        Builder<
          ThreadCapabilitiesResponseDto,
          ThreadCapabilitiesResponseDtoBuilder
        > {
  _$ThreadCapabilitiesResponseDto? _$v;

  bool? _canManageThread;
  bool? get canManageThread => _$this._canManageThread;
  set canManageThread(bool? canManageThread) =>
      _$this._canManageThread = canManageThread;

  bool? _canManageMembers;
  bool? get canManageMembers => _$this._canManageMembers;
  set canManageMembers(bool? canManageMembers) =>
      _$this._canManageMembers = canManageMembers;

  bool? _isOwner;
  bool? get isOwner => _$this._isOwner;
  set isOwner(bool? isOwner) => _$this._isOwner = isOwner;

  ThreadCapabilitiesResponseDtoBuilder() {
    ThreadCapabilitiesResponseDto._defaults(this);
  }

  ThreadCapabilitiesResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _canManageThread = $v.canManageThread;
      _canManageMembers = $v.canManageMembers;
      _isOwner = $v.isOwner;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ThreadCapabilitiesResponseDto other) {
    _$v = other as _$ThreadCapabilitiesResponseDto;
  }

  @override
  void update(void Function(ThreadCapabilitiesResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadCapabilitiesResponseDto build() => _build();

  _$ThreadCapabilitiesResponseDto _build() {
    final _$result =
        _$v ??
        _$ThreadCapabilitiesResponseDto._(
          canManageThread: BuiltValueNullFieldError.checkNotNull(
            canManageThread,
            r'ThreadCapabilitiesResponseDto',
            'canManageThread',
          ),
          canManageMembers: BuiltValueNullFieldError.checkNotNull(
            canManageMembers,
            r'ThreadCapabilitiesResponseDto',
            'canManageMembers',
          ),
          isOwner: BuiltValueNullFieldError.checkNotNull(
            isOwner,
            r'ThreadCapabilitiesResponseDto',
            'isOwner',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
