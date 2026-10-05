// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rp_identity_state_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RpIdentityStateDto extends RpIdentityStateDto {
  @override
  final String threadId;
  @override
  final String userId;
  @override
  final bool enabled;
  @override
  final bool eligible;
  @override
  final bool canEdit;
  @override
  final ThreadIdentityProfileDto? identity;
  @override
  final RpIdentityResponseDto? display;
  @override
  final ThreadIdentityAccountDto account;
  @override
  final String? identityToken;
  @override
  final bool canDelete;
  @override
  final String identityId;
  @override
  final bool deleted;
  @override
  final bool compatibilityIdentity;

  factory _$RpIdentityStateDto([
    void Function(RpIdentityStateDtoBuilder)? updates,
  ]) => (RpIdentityStateDtoBuilder()..update(updates))._build();

  _$RpIdentityStateDto._({
    required this.threadId,
    required this.userId,
    required this.enabled,
    required this.eligible,
    required this.canEdit,
    this.identity,
    this.display,
    required this.account,
    this.identityToken,
    required this.canDelete,
    required this.identityId,
    required this.deleted,
    required this.compatibilityIdentity,
  }) : super._();
  @override
  RpIdentityStateDto rebuild(
    void Function(RpIdentityStateDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  RpIdentityStateDtoBuilder toBuilder() =>
      RpIdentityStateDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RpIdentityStateDto &&
        threadId == other.threadId &&
        userId == other.userId &&
        enabled == other.enabled &&
        eligible == other.eligible &&
        canEdit == other.canEdit &&
        identity == other.identity &&
        display == other.display &&
        account == other.account &&
        identityToken == other.identityToken &&
        canDelete == other.canDelete &&
        identityId == other.identityId &&
        deleted == other.deleted &&
        compatibilityIdentity == other.compatibilityIdentity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, threadId.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, eligible.hashCode);
    _$hash = $jc(_$hash, canEdit.hashCode);
    _$hash = $jc(_$hash, identity.hashCode);
    _$hash = $jc(_$hash, display.hashCode);
    _$hash = $jc(_$hash, account.hashCode);
    _$hash = $jc(_$hash, identityToken.hashCode);
    _$hash = $jc(_$hash, canDelete.hashCode);
    _$hash = $jc(_$hash, identityId.hashCode);
    _$hash = $jc(_$hash, deleted.hashCode);
    _$hash = $jc(_$hash, compatibilityIdentity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RpIdentityStateDto')
          ..add('threadId', threadId)
          ..add('userId', userId)
          ..add('enabled', enabled)
          ..add('eligible', eligible)
          ..add('canEdit', canEdit)
          ..add('identity', identity)
          ..add('display', display)
          ..add('account', account)
          ..add('identityToken', identityToken)
          ..add('canDelete', canDelete)
          ..add('identityId', identityId)
          ..add('deleted', deleted)
          ..add('compatibilityIdentity', compatibilityIdentity))
        .toString();
  }
}

class RpIdentityStateDtoBuilder
    implements Builder<RpIdentityStateDto, RpIdentityStateDtoBuilder> {
  _$RpIdentityStateDto? _$v;

  String? _threadId;
  String? get threadId => _$this._threadId;
  set threadId(String? threadId) => _$this._threadId = threadId;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  bool? _eligible;
  bool? get eligible => _$this._eligible;
  set eligible(bool? eligible) => _$this._eligible = eligible;

  bool? _canEdit;
  bool? get canEdit => _$this._canEdit;
  set canEdit(bool? canEdit) => _$this._canEdit = canEdit;

  ThreadIdentityProfileDtoBuilder? _identity;
  ThreadIdentityProfileDtoBuilder get identity =>
      _$this._identity ??= ThreadIdentityProfileDtoBuilder();
  set identity(ThreadIdentityProfileDtoBuilder? identity) =>
      _$this._identity = identity;

  RpIdentityResponseDtoBuilder? _display;
  RpIdentityResponseDtoBuilder get display =>
      _$this._display ??= RpIdentityResponseDtoBuilder();
  set display(RpIdentityResponseDtoBuilder? display) =>
      _$this._display = display;

  ThreadIdentityAccountDtoBuilder? _account;
  ThreadIdentityAccountDtoBuilder get account =>
      _$this._account ??= ThreadIdentityAccountDtoBuilder();
  set account(ThreadIdentityAccountDtoBuilder? account) =>
      _$this._account = account;

  String? _identityToken;
  String? get identityToken => _$this._identityToken;
  set identityToken(String? identityToken) =>
      _$this._identityToken = identityToken;

  bool? _canDelete;
  bool? get canDelete => _$this._canDelete;
  set canDelete(bool? canDelete) => _$this._canDelete = canDelete;

  String? _identityId;
  String? get identityId => _$this._identityId;
  set identityId(String? identityId) => _$this._identityId = identityId;

  bool? _deleted;
  bool? get deleted => _$this._deleted;
  set deleted(bool? deleted) => _$this._deleted = deleted;

  bool? _compatibilityIdentity;
  bool? get compatibilityIdentity => _$this._compatibilityIdentity;
  set compatibilityIdentity(bool? compatibilityIdentity) =>
      _$this._compatibilityIdentity = compatibilityIdentity;

  RpIdentityStateDtoBuilder() {
    RpIdentityStateDto._defaults(this);
  }

  RpIdentityStateDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _threadId = $v.threadId;
      _userId = $v.userId;
      _enabled = $v.enabled;
      _eligible = $v.eligible;
      _canEdit = $v.canEdit;
      _identity = $v.identity?.toBuilder();
      _display = $v.display?.toBuilder();
      _account = $v.account.toBuilder();
      _identityToken = $v.identityToken;
      _canDelete = $v.canDelete;
      _identityId = $v.identityId;
      _deleted = $v.deleted;
      _compatibilityIdentity = $v.compatibilityIdentity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RpIdentityStateDto other) {
    _$v = other as _$RpIdentityStateDto;
  }

  @override
  void update(void Function(RpIdentityStateDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RpIdentityStateDto build() => _build();

  _$RpIdentityStateDto _build() {
    _$RpIdentityStateDto _$result;
    try {
      _$result =
          _$v ??
          _$RpIdentityStateDto._(
            threadId: BuiltValueNullFieldError.checkNotNull(
              threadId,
              r'RpIdentityStateDto',
              'threadId',
            ),
            userId: BuiltValueNullFieldError.checkNotNull(
              userId,
              r'RpIdentityStateDto',
              'userId',
            ),
            enabled: BuiltValueNullFieldError.checkNotNull(
              enabled,
              r'RpIdentityStateDto',
              'enabled',
            ),
            eligible: BuiltValueNullFieldError.checkNotNull(
              eligible,
              r'RpIdentityStateDto',
              'eligible',
            ),
            canEdit: BuiltValueNullFieldError.checkNotNull(
              canEdit,
              r'RpIdentityStateDto',
              'canEdit',
            ),
            identity: _identity?.build(),
            display: _display?.build(),
            account: account.build(),
            identityToken: identityToken,
            canDelete: BuiltValueNullFieldError.checkNotNull(
              canDelete,
              r'RpIdentityStateDto',
              'canDelete',
            ),
            identityId: BuiltValueNullFieldError.checkNotNull(
              identityId,
              r'RpIdentityStateDto',
              'identityId',
            ),
            deleted: BuiltValueNullFieldError.checkNotNull(
              deleted,
              r'RpIdentityStateDto',
              'deleted',
            ),
            compatibilityIdentity: BuiltValueNullFieldError.checkNotNull(
              compatibilityIdentity,
              r'RpIdentityStateDto',
              'compatibilityIdentity',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'identity';
        _identity?.build();
        _$failedField = 'display';
        _display?.build();
        _$failedField = 'account';
        account.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'RpIdentityStateDto',
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
