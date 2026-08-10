// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_challenge_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminChallengeResponseDto extends AdminChallengeResponseDto {
  @override
  final String challengeId;
  @override
  final num expiresIn;

  factory _$AdminChallengeResponseDto([
    void Function(AdminChallengeResponseDtoBuilder)? updates,
  ]) => (AdminChallengeResponseDtoBuilder()..update(updates))._build();

  _$AdminChallengeResponseDto._({
    required this.challengeId,
    required this.expiresIn,
  }) : super._();
  @override
  AdminChallengeResponseDto rebuild(
    void Function(AdminChallengeResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminChallengeResponseDtoBuilder toBuilder() =>
      AdminChallengeResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminChallengeResponseDto &&
        challengeId == other.challengeId &&
        expiresIn == other.expiresIn;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, challengeId.hashCode);
    _$hash = $jc(_$hash, expiresIn.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminChallengeResponseDto')
          ..add('challengeId', challengeId)
          ..add('expiresIn', expiresIn))
        .toString();
  }
}

class AdminChallengeResponseDtoBuilder
    implements
        Builder<AdminChallengeResponseDto, AdminChallengeResponseDtoBuilder> {
  _$AdminChallengeResponseDto? _$v;

  String? _challengeId;
  String? get challengeId => _$this._challengeId;
  set challengeId(String? challengeId) => _$this._challengeId = challengeId;

  num? _expiresIn;
  num? get expiresIn => _$this._expiresIn;
  set expiresIn(num? expiresIn) => _$this._expiresIn = expiresIn;

  AdminChallengeResponseDtoBuilder() {
    AdminChallengeResponseDto._defaults(this);
  }

  AdminChallengeResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _challengeId = $v.challengeId;
      _expiresIn = $v.expiresIn;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminChallengeResponseDto other) {
    _$v = other as _$AdminChallengeResponseDto;
  }

  @override
  void update(void Function(AdminChallengeResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminChallengeResponseDto build() => _build();

  _$AdminChallengeResponseDto _build() {
    final _$result =
        _$v ??
        _$AdminChallengeResponseDto._(
          challengeId: BuiltValueNullFieldError.checkNotNull(
            challengeId,
            r'AdminChallengeResponseDto',
            'challengeId',
          ),
          expiresIn: BuiltValueNullFieldError.checkNotNull(
            expiresIn,
            r'AdminChallengeResponseDto',
            'expiresIn',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
