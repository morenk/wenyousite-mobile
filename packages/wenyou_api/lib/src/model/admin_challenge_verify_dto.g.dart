// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_challenge_verify_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminChallengeVerifyDto extends AdminChallengeVerifyDto {
  @override
  final String challengeId;
  @override
  final String code;

  factory _$AdminChallengeVerifyDto([
    void Function(AdminChallengeVerifyDtoBuilder)? updates,
  ]) => (AdminChallengeVerifyDtoBuilder()..update(updates))._build();

  _$AdminChallengeVerifyDto._({required this.challengeId, required this.code})
    : super._();
  @override
  AdminChallengeVerifyDto rebuild(
    void Function(AdminChallengeVerifyDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminChallengeVerifyDtoBuilder toBuilder() =>
      AdminChallengeVerifyDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminChallengeVerifyDto &&
        challengeId == other.challengeId &&
        code == other.code;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, challengeId.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminChallengeVerifyDto')
          ..add('challengeId', challengeId)
          ..add('code', code))
        .toString();
  }
}

class AdminChallengeVerifyDtoBuilder
    implements
        Builder<AdminChallengeVerifyDto, AdminChallengeVerifyDtoBuilder> {
  _$AdminChallengeVerifyDto? _$v;

  String? _challengeId;
  String? get challengeId => _$this._challengeId;
  set challengeId(String? challengeId) => _$this._challengeId = challengeId;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  AdminChallengeVerifyDtoBuilder() {
    AdminChallengeVerifyDto._defaults(this);
  }

  AdminChallengeVerifyDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _challengeId = $v.challengeId;
      _code = $v.code;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminChallengeVerifyDto other) {
    _$v = other as _$AdminChallengeVerifyDto;
  }

  @override
  void update(void Function(AdminChallengeVerifyDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminChallengeVerifyDto build() => _build();

  _$AdminChallengeVerifyDto _build() {
    final _$result =
        _$v ??
        _$AdminChallengeVerifyDto._(
          challengeId: BuiltValueNullFieldError.checkNotNull(
            challengeId,
            r'AdminChallengeVerifyDto',
            'challengeId',
          ),
          code: BuiltValueNullFieldError.checkNotNull(
            code,
            r'AdminChallengeVerifyDto',
            'code',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
