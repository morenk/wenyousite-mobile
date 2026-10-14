// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rp_identity_collection_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RpIdentityCollectionDtoLimitEnum _$rpIdentityCollectionDtoLimitEnum_n10 =
    const RpIdentityCollectionDtoLimitEnum._('n10');
const RpIdentityCollectionDtoLimitEnum
_$rpIdentityCollectionDtoLimitEnum_unknownDefaultOpenApi =
    const RpIdentityCollectionDtoLimitEnum._('unknownDefaultOpenApi');

RpIdentityCollectionDtoLimitEnum _$rpIdentityCollectionDtoLimitEnumValueOf(
  String name,
) {
  switch (name) {
    case 'n10':
      return _$rpIdentityCollectionDtoLimitEnum_n10;
    case 'unknownDefaultOpenApi':
      return _$rpIdentityCollectionDtoLimitEnum_unknownDefaultOpenApi;
    default:
      return _$rpIdentityCollectionDtoLimitEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<RpIdentityCollectionDtoLimitEnum>
_$rpIdentityCollectionDtoLimitEnumValues =
    BuiltSet<RpIdentityCollectionDtoLimitEnum>(
      const <RpIdentityCollectionDtoLimitEnum>[
        _$rpIdentityCollectionDtoLimitEnum_n10,
        _$rpIdentityCollectionDtoLimitEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<RpIdentityCollectionDtoLimitEnum>
_$rpIdentityCollectionDtoLimitEnumSerializer =
    _$RpIdentityCollectionDtoLimitEnumSerializer();

class _$RpIdentityCollectionDtoLimitEnumSerializer
    implements PrimitiveSerializer<RpIdentityCollectionDtoLimitEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'n10': '10',
    'unknownDefaultOpenApi': '11184809',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    '10': 'n10',
    '11184809': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[RpIdentityCollectionDtoLimitEnum];
  @override
  final String wireName = 'RpIdentityCollectionDtoLimitEnum';

  @override
  Object serialize(
    Serializers serializers,
    RpIdentityCollectionDtoLimitEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  RpIdentityCollectionDtoLimitEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => RpIdentityCollectionDtoLimitEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$RpIdentityCollectionDto extends RpIdentityCollectionDto {
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
  final num activeCount;
  @override
  final RpIdentityCollectionDtoLimitEnum limit;
  @override
  final String? compatibilityIdentityId;
  @override
  final String? defaultIdentityId;
  @override
  final BuiltList<RpIdentityStateDto> identities;
  @override
  final ThreadIdentityAccountDto account;

  factory _$RpIdentityCollectionDto([
    void Function(RpIdentityCollectionDtoBuilder)? updates,
  ]) => (RpIdentityCollectionDtoBuilder()..update(updates))._build();

  _$RpIdentityCollectionDto._({
    required this.threadId,
    required this.userId,
    required this.enabled,
    required this.eligible,
    required this.canEdit,
    required this.activeCount,
    required this.limit,
    this.compatibilityIdentityId,
    this.defaultIdentityId,
    required this.identities,
    required this.account,
  }) : super._();
  @override
  RpIdentityCollectionDto rebuild(
    void Function(RpIdentityCollectionDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  RpIdentityCollectionDtoBuilder toBuilder() =>
      RpIdentityCollectionDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RpIdentityCollectionDto &&
        threadId == other.threadId &&
        userId == other.userId &&
        enabled == other.enabled &&
        eligible == other.eligible &&
        canEdit == other.canEdit &&
        activeCount == other.activeCount &&
        limit == other.limit &&
        compatibilityIdentityId == other.compatibilityIdentityId &&
        defaultIdentityId == other.defaultIdentityId &&
        identities == other.identities &&
        account == other.account;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, threadId.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, eligible.hashCode);
    _$hash = $jc(_$hash, canEdit.hashCode);
    _$hash = $jc(_$hash, activeCount.hashCode);
    _$hash = $jc(_$hash, limit.hashCode);
    _$hash = $jc(_$hash, compatibilityIdentityId.hashCode);
    _$hash = $jc(_$hash, defaultIdentityId.hashCode);
    _$hash = $jc(_$hash, identities.hashCode);
    _$hash = $jc(_$hash, account.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RpIdentityCollectionDto')
          ..add('threadId', threadId)
          ..add('userId', userId)
          ..add('enabled', enabled)
          ..add('eligible', eligible)
          ..add('canEdit', canEdit)
          ..add('activeCount', activeCount)
          ..add('limit', limit)
          ..add('compatibilityIdentityId', compatibilityIdentityId)
          ..add('defaultIdentityId', defaultIdentityId)
          ..add('identities', identities)
          ..add('account', account))
        .toString();
  }
}

class RpIdentityCollectionDtoBuilder
    implements
        Builder<RpIdentityCollectionDto, RpIdentityCollectionDtoBuilder> {
  _$RpIdentityCollectionDto? _$v;

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

  num? _activeCount;
  num? get activeCount => _$this._activeCount;
  set activeCount(num? activeCount) => _$this._activeCount = activeCount;

  RpIdentityCollectionDtoLimitEnum? _limit;
  RpIdentityCollectionDtoLimitEnum? get limit => _$this._limit;
  set limit(RpIdentityCollectionDtoLimitEnum? limit) => _$this._limit = limit;

  String? _compatibilityIdentityId;
  String? get compatibilityIdentityId => _$this._compatibilityIdentityId;
  set compatibilityIdentityId(String? compatibilityIdentityId) =>
      _$this._compatibilityIdentityId = compatibilityIdentityId;

  String? _defaultIdentityId;
  String? get defaultIdentityId => _$this._defaultIdentityId;
  set defaultIdentityId(String? defaultIdentityId) =>
      _$this._defaultIdentityId = defaultIdentityId;

  ListBuilder<RpIdentityStateDto>? _identities;
  ListBuilder<RpIdentityStateDto> get identities =>
      _$this._identities ??= ListBuilder<RpIdentityStateDto>();
  set identities(ListBuilder<RpIdentityStateDto>? identities) =>
      _$this._identities = identities;

  ThreadIdentityAccountDtoBuilder? _account;
  ThreadIdentityAccountDtoBuilder get account =>
      _$this._account ??= ThreadIdentityAccountDtoBuilder();
  set account(ThreadIdentityAccountDtoBuilder? account) =>
      _$this._account = account;

  RpIdentityCollectionDtoBuilder() {
    RpIdentityCollectionDto._defaults(this);
  }

  RpIdentityCollectionDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _threadId = $v.threadId;
      _userId = $v.userId;
      _enabled = $v.enabled;
      _eligible = $v.eligible;
      _canEdit = $v.canEdit;
      _activeCount = $v.activeCount;
      _limit = $v.limit;
      _compatibilityIdentityId = $v.compatibilityIdentityId;
      _defaultIdentityId = $v.defaultIdentityId;
      _identities = $v.identities.toBuilder();
      _account = $v.account.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RpIdentityCollectionDto other) {
    _$v = other as _$RpIdentityCollectionDto;
  }

  @override
  void update(void Function(RpIdentityCollectionDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RpIdentityCollectionDto build() => _build();

  _$RpIdentityCollectionDto _build() {
    _$RpIdentityCollectionDto _$result;
    try {
      _$result =
          _$v ??
          _$RpIdentityCollectionDto._(
            threadId: BuiltValueNullFieldError.checkNotNull(
              threadId,
              r'RpIdentityCollectionDto',
              'threadId',
            ),
            userId: BuiltValueNullFieldError.checkNotNull(
              userId,
              r'RpIdentityCollectionDto',
              'userId',
            ),
            enabled: BuiltValueNullFieldError.checkNotNull(
              enabled,
              r'RpIdentityCollectionDto',
              'enabled',
            ),
            eligible: BuiltValueNullFieldError.checkNotNull(
              eligible,
              r'RpIdentityCollectionDto',
              'eligible',
            ),
            canEdit: BuiltValueNullFieldError.checkNotNull(
              canEdit,
              r'RpIdentityCollectionDto',
              'canEdit',
            ),
            activeCount: BuiltValueNullFieldError.checkNotNull(
              activeCount,
              r'RpIdentityCollectionDto',
              'activeCount',
            ),
            limit: BuiltValueNullFieldError.checkNotNull(
              limit,
              r'RpIdentityCollectionDto',
              'limit',
            ),
            compatibilityIdentityId: compatibilityIdentityId,
            defaultIdentityId: defaultIdentityId,
            identities: identities.build(),
            account: account.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'identities';
        identities.build();
        _$failedField = 'account';
        account.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'RpIdentityCollectionDto',
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
