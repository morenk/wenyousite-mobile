// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appeal_access_token_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AppealAccessTokenResponseDto extends AppealAccessTokenResponseDto {
  @override
  final String appealToken;
  @override
  final DateTime expiresAt;

  factory _$AppealAccessTokenResponseDto([
    void Function(AppealAccessTokenResponseDtoBuilder)? updates,
  ]) => (AppealAccessTokenResponseDtoBuilder()..update(updates))._build();

  _$AppealAccessTokenResponseDto._({
    required this.appealToken,
    required this.expiresAt,
  }) : super._();
  @override
  AppealAccessTokenResponseDto rebuild(
    void Function(AppealAccessTokenResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AppealAccessTokenResponseDtoBuilder toBuilder() =>
      AppealAccessTokenResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AppealAccessTokenResponseDto &&
        appealToken == other.appealToken &&
        expiresAt == other.expiresAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, appealToken.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AppealAccessTokenResponseDto')
          ..add('appealToken', appealToken)
          ..add('expiresAt', expiresAt))
        .toString();
  }
}

class AppealAccessTokenResponseDtoBuilder
    implements
        Builder<
          AppealAccessTokenResponseDto,
          AppealAccessTokenResponseDtoBuilder
        > {
  _$AppealAccessTokenResponseDto? _$v;

  String? _appealToken;
  String? get appealToken => _$this._appealToken;
  set appealToken(String? appealToken) => _$this._appealToken = appealToken;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  AppealAccessTokenResponseDtoBuilder() {
    AppealAccessTokenResponseDto._defaults(this);
  }

  AppealAccessTokenResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _appealToken = $v.appealToken;
      _expiresAt = $v.expiresAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AppealAccessTokenResponseDto other) {
    _$v = other as _$AppealAccessTokenResponseDto;
  }

  @override
  void update(void Function(AppealAccessTokenResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AppealAccessTokenResponseDto build() => _build();

  _$AppealAccessTokenResponseDto _build() {
    final _$result =
        _$v ??
        _$AppealAccessTokenResponseDto._(
          appealToken: BuiltValueNullFieldError.checkNotNull(
            appealToken,
            r'AppealAccessTokenResponseDto',
            'appealToken',
          ),
          expiresAt: BuiltValueNullFieldError.checkNotNull(
            expiresAt,
            r'AppealAccessTokenResponseDto',
            'expiresAt',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
