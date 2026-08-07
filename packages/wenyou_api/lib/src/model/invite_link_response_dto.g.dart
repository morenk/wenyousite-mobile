// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_link_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$InviteLinkResponseDto extends InviteLinkResponseDto {
  @override
  final String id;
  @override
  final String threadId;
  @override
  final String token;
  @override
  final DateTime createdAt;

  factory _$InviteLinkResponseDto([
    void Function(InviteLinkResponseDtoBuilder)? updates,
  ]) => (InviteLinkResponseDtoBuilder()..update(updates))._build();

  _$InviteLinkResponseDto._({
    required this.id,
    required this.threadId,
    required this.token,
    required this.createdAt,
  }) : super._();
  @override
  InviteLinkResponseDto rebuild(
    void Function(InviteLinkResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  InviteLinkResponseDtoBuilder toBuilder() =>
      InviteLinkResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InviteLinkResponseDto &&
        id == other.id &&
        threadId == other.threadId &&
        token == other.token &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, threadId.hashCode);
    _$hash = $jc(_$hash, token.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'InviteLinkResponseDto')
          ..add('id', id)
          ..add('threadId', threadId)
          ..add('token', token)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class InviteLinkResponseDtoBuilder
    implements Builder<InviteLinkResponseDto, InviteLinkResponseDtoBuilder> {
  _$InviteLinkResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _threadId;
  String? get threadId => _$this._threadId;
  set threadId(String? threadId) => _$this._threadId = threadId;

  String? _token;
  String? get token => _$this._token;
  set token(String? token) => _$this._token = token;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  InviteLinkResponseDtoBuilder() {
    InviteLinkResponseDto._defaults(this);
  }

  InviteLinkResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _threadId = $v.threadId;
      _token = $v.token;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(InviteLinkResponseDto other) {
    _$v = other as _$InviteLinkResponseDto;
  }

  @override
  void update(void Function(InviteLinkResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  InviteLinkResponseDto build() => _build();

  _$InviteLinkResponseDto _build() {
    final _$result =
        _$v ??
        _$InviteLinkResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'InviteLinkResponseDto',
            'id',
          ),
          threadId: BuiltValueNullFieldError.checkNotNull(
            threadId,
            r'InviteLinkResponseDto',
            'threadId',
          ),
          token: BuiltValueNullFieldError.checkNotNull(
            token,
            r'InviteLinkResponseDto',
            'token',
          ),
          createdAt: BuiltValueNullFieldError.checkNotNull(
            createdAt,
            r'InviteLinkResponseDto',
            'createdAt',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
