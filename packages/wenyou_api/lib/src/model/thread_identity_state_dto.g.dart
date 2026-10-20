// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_identity_state_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ThreadIdentityStateDtoProfilePostStatusEnum
_$threadIdentityStateDtoProfilePostStatusEnum_NONE =
    const ThreadIdentityStateDtoProfilePostStatusEnum._('NONE');
const ThreadIdentityStateDtoProfilePostStatusEnum
_$threadIdentityStateDtoProfilePostStatusEnum_AVAILABLE =
    const ThreadIdentityStateDtoProfilePostStatusEnum._('AVAILABLE');
const ThreadIdentityStateDtoProfilePostStatusEnum
_$threadIdentityStateDtoProfilePostStatusEnum_UNAVAILABLE =
    const ThreadIdentityStateDtoProfilePostStatusEnum._('UNAVAILABLE');
const ThreadIdentityStateDtoProfilePostStatusEnum
_$threadIdentityStateDtoProfilePostStatusEnum_unknownDefaultOpenApi =
    const ThreadIdentityStateDtoProfilePostStatusEnum._(
      'unknownDefaultOpenApi',
    );

ThreadIdentityStateDtoProfilePostStatusEnum
_$threadIdentityStateDtoProfilePostStatusEnumValueOf(String name) {
  switch (name) {
    case 'NONE':
      return _$threadIdentityStateDtoProfilePostStatusEnum_NONE;
    case 'AVAILABLE':
      return _$threadIdentityStateDtoProfilePostStatusEnum_AVAILABLE;
    case 'UNAVAILABLE':
      return _$threadIdentityStateDtoProfilePostStatusEnum_UNAVAILABLE;
    case 'unknownDefaultOpenApi':
      return _$threadIdentityStateDtoProfilePostStatusEnum_unknownDefaultOpenApi;
    default:
      return _$threadIdentityStateDtoProfilePostStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ThreadIdentityStateDtoProfilePostStatusEnum>
_$threadIdentityStateDtoProfilePostStatusEnumValues =
    BuiltSet<ThreadIdentityStateDtoProfilePostStatusEnum>(
      const <ThreadIdentityStateDtoProfilePostStatusEnum>[
        _$threadIdentityStateDtoProfilePostStatusEnum_NONE,
        _$threadIdentityStateDtoProfilePostStatusEnum_AVAILABLE,
        _$threadIdentityStateDtoProfilePostStatusEnum_UNAVAILABLE,
        _$threadIdentityStateDtoProfilePostStatusEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ThreadIdentityStateDtoProfilePostStatusEnum>
_$threadIdentityStateDtoProfilePostStatusEnumSerializer =
    _$ThreadIdentityStateDtoProfilePostStatusEnumSerializer();

class _$ThreadIdentityStateDtoProfilePostStatusEnumSerializer
    implements
        PrimitiveSerializer<ThreadIdentityStateDtoProfilePostStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'NONE': 'NONE',
    'AVAILABLE': 'AVAILABLE',
    'UNAVAILABLE': 'UNAVAILABLE',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'NONE': 'NONE',
    'AVAILABLE': 'AVAILABLE',
    'UNAVAILABLE': 'UNAVAILABLE',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    ThreadIdentityStateDtoProfilePostStatusEnum,
  ];
  @override
  final String wireName = 'ThreadIdentityStateDtoProfilePostStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    ThreadIdentityStateDtoProfilePostStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ThreadIdentityStateDtoProfilePostStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ThreadIdentityStateDtoProfilePostStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ThreadIdentityStateDto extends ThreadIdentityStateDto {
  @override
  final ThreadIdentityStateDtoProfilePostStatusEnum? profilePostStatus;
  @override
  final String? profilePostId;
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

  factory _$ThreadIdentityStateDto([
    void Function(ThreadIdentityStateDtoBuilder)? updates,
  ]) => (ThreadIdentityStateDtoBuilder()..update(updates))._build();

  _$ThreadIdentityStateDto._({
    this.profilePostStatus,
    this.profilePostId,
    required this.threadId,
    required this.userId,
    required this.enabled,
    required this.eligible,
    required this.canEdit,
    this.identity,
    this.display,
    required this.account,
    this.identityToken,
  }) : super._();
  @override
  ThreadIdentityStateDto rebuild(
    void Function(ThreadIdentityStateDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ThreadIdentityStateDtoBuilder toBuilder() =>
      ThreadIdentityStateDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreadIdentityStateDto &&
        profilePostStatus == other.profilePostStatus &&
        profilePostId == other.profilePostId &&
        threadId == other.threadId &&
        userId == other.userId &&
        enabled == other.enabled &&
        eligible == other.eligible &&
        canEdit == other.canEdit &&
        identity == other.identity &&
        display == other.display &&
        account == other.account &&
        identityToken == other.identityToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, profilePostStatus.hashCode);
    _$hash = $jc(_$hash, profilePostId.hashCode);
    _$hash = $jc(_$hash, threadId.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, eligible.hashCode);
    _$hash = $jc(_$hash, canEdit.hashCode);
    _$hash = $jc(_$hash, identity.hashCode);
    _$hash = $jc(_$hash, display.hashCode);
    _$hash = $jc(_$hash, account.hashCode);
    _$hash = $jc(_$hash, identityToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ThreadIdentityStateDto')
          ..add('profilePostStatus', profilePostStatus)
          ..add('profilePostId', profilePostId)
          ..add('threadId', threadId)
          ..add('userId', userId)
          ..add('enabled', enabled)
          ..add('eligible', eligible)
          ..add('canEdit', canEdit)
          ..add('identity', identity)
          ..add('display', display)
          ..add('account', account)
          ..add('identityToken', identityToken))
        .toString();
  }
}

class ThreadIdentityStateDtoBuilder
    implements Builder<ThreadIdentityStateDto, ThreadIdentityStateDtoBuilder> {
  _$ThreadIdentityStateDto? _$v;

  ThreadIdentityStateDtoProfilePostStatusEnum? _profilePostStatus;
  ThreadIdentityStateDtoProfilePostStatusEnum? get profilePostStatus =>
      _$this._profilePostStatus;
  set profilePostStatus(
    ThreadIdentityStateDtoProfilePostStatusEnum? profilePostStatus,
  ) => _$this._profilePostStatus = profilePostStatus;

  String? _profilePostId;
  String? get profilePostId => _$this._profilePostId;
  set profilePostId(String? profilePostId) =>
      _$this._profilePostId = profilePostId;

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

  ThreadIdentityStateDtoBuilder() {
    ThreadIdentityStateDto._defaults(this);
  }

  ThreadIdentityStateDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _profilePostStatus = $v.profilePostStatus;
      _profilePostId = $v.profilePostId;
      _threadId = $v.threadId;
      _userId = $v.userId;
      _enabled = $v.enabled;
      _eligible = $v.eligible;
      _canEdit = $v.canEdit;
      _identity = $v.identity?.toBuilder();
      _display = $v.display?.toBuilder();
      _account = $v.account.toBuilder();
      _identityToken = $v.identityToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ThreadIdentityStateDto other) {
    _$v = other as _$ThreadIdentityStateDto;
  }

  @override
  void update(void Function(ThreadIdentityStateDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreadIdentityStateDto build() => _build();

  _$ThreadIdentityStateDto _build() {
    _$ThreadIdentityStateDto _$result;
    try {
      _$result =
          _$v ??
          _$ThreadIdentityStateDto._(
            profilePostStatus: profilePostStatus,
            profilePostId: profilePostId,
            threadId: BuiltValueNullFieldError.checkNotNull(
              threadId,
              r'ThreadIdentityStateDto',
              'threadId',
            ),
            userId: BuiltValueNullFieldError.checkNotNull(
              userId,
              r'ThreadIdentityStateDto',
              'userId',
            ),
            enabled: BuiltValueNullFieldError.checkNotNull(
              enabled,
              r'ThreadIdentityStateDto',
              'enabled',
            ),
            eligible: BuiltValueNullFieldError.checkNotNull(
              eligible,
              r'ThreadIdentityStateDto',
              'eligible',
            ),
            canEdit: BuiltValueNullFieldError.checkNotNull(
              canEdit,
              r'ThreadIdentityStateDto',
              'canEdit',
            ),
            identity: _identity?.build(),
            display: _display?.build(),
            account: account.build(),
            identityToken: identityToken,
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
          r'ThreadIdentityStateDto',
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
