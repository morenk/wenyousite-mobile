// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mention_candidate_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MentionCandidateDtoRelationEnum
_$mentionCandidateDtoRelationEnum_FOLLOWING =
    const MentionCandidateDtoRelationEnum._('FOLLOWING');
const MentionCandidateDtoRelationEnum _$mentionCandidateDtoRelationEnum_PLAYER =
    const MentionCandidateDtoRelationEnum._('PLAYER');
const MentionCandidateDtoRelationEnum _$mentionCandidateDtoRelationEnum_OWNER =
    const MentionCandidateDtoRelationEnum._('OWNER');
const MentionCandidateDtoRelationEnum
_$mentionCandidateDtoRelationEnum_COLLABORATOR =
    const MentionCandidateDtoRelationEnum._('COLLABORATOR');
const MentionCandidateDtoRelationEnum
_$mentionCandidateDtoRelationEnum_unknownDefaultOpenApi =
    const MentionCandidateDtoRelationEnum._('unknownDefaultOpenApi');

MentionCandidateDtoRelationEnum _$mentionCandidateDtoRelationEnumValueOf(
  String name,
) {
  switch (name) {
    case 'FOLLOWING':
      return _$mentionCandidateDtoRelationEnum_FOLLOWING;
    case 'PLAYER':
      return _$mentionCandidateDtoRelationEnum_PLAYER;
    case 'OWNER':
      return _$mentionCandidateDtoRelationEnum_OWNER;
    case 'COLLABORATOR':
      return _$mentionCandidateDtoRelationEnum_COLLABORATOR;
    case 'unknownDefaultOpenApi':
      return _$mentionCandidateDtoRelationEnum_unknownDefaultOpenApi;
    default:
      return _$mentionCandidateDtoRelationEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<MentionCandidateDtoRelationEnum>
_$mentionCandidateDtoRelationEnumValues =
    BuiltSet<MentionCandidateDtoRelationEnum>(
      const <MentionCandidateDtoRelationEnum>[
        _$mentionCandidateDtoRelationEnum_FOLLOWING,
        _$mentionCandidateDtoRelationEnum_PLAYER,
        _$mentionCandidateDtoRelationEnum_OWNER,
        _$mentionCandidateDtoRelationEnum_COLLABORATOR,
        _$mentionCandidateDtoRelationEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<MentionCandidateDtoRelationEnum>
_$mentionCandidateDtoRelationEnumSerializer =
    _$MentionCandidateDtoRelationEnumSerializer();

class _$MentionCandidateDtoRelationEnumSerializer
    implements PrimitiveSerializer<MentionCandidateDtoRelationEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'FOLLOWING': 'FOLLOWING',
    'PLAYER': 'PLAYER',
    'OWNER': 'OWNER',
    'COLLABORATOR': 'COLLABORATOR',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'FOLLOWING': 'FOLLOWING',
    'PLAYER': 'PLAYER',
    'OWNER': 'OWNER',
    'COLLABORATOR': 'COLLABORATOR',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[MentionCandidateDtoRelationEnum];
  @override
  final String wireName = 'MentionCandidateDtoRelationEnum';

  @override
  Object serialize(
    Serializers serializers,
    MentionCandidateDtoRelationEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MentionCandidateDtoRelationEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MentionCandidateDtoRelationEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MentionCandidateDto extends MentionCandidateDto {
  @override
  final String? candidateKey;
  @override
  final String? targetIdentityId;
  @override
  final String? mentionLabel;
  @override
  final String? mentionHref;
  @override
  final RpIdentityResponseDto? rpIdentity;
  @override
  final MediaDisplayResponseDto? avatarDisplay;
  @override
  final String id;
  @override
  final String username;
  @override
  final String? avatar;
  @override
  final MentionCandidateDtoRelationEnum relation;

  factory _$MentionCandidateDto([
    void Function(MentionCandidateDtoBuilder)? updates,
  ]) => (MentionCandidateDtoBuilder()..update(updates))._build();

  _$MentionCandidateDto._({
    this.candidateKey,
    this.targetIdentityId,
    this.mentionLabel,
    this.mentionHref,
    this.rpIdentity,
    this.avatarDisplay,
    required this.id,
    required this.username,
    this.avatar,
    required this.relation,
  }) : super._();
  @override
  MentionCandidateDto rebuild(
    void Function(MentionCandidateDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  MentionCandidateDtoBuilder toBuilder() =>
      MentionCandidateDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MentionCandidateDto &&
        candidateKey == other.candidateKey &&
        targetIdentityId == other.targetIdentityId &&
        mentionLabel == other.mentionLabel &&
        mentionHref == other.mentionHref &&
        rpIdentity == other.rpIdentity &&
        avatarDisplay == other.avatarDisplay &&
        id == other.id &&
        username == other.username &&
        avatar == other.avatar &&
        relation == other.relation;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, candidateKey.hashCode);
    _$hash = $jc(_$hash, targetIdentityId.hashCode);
    _$hash = $jc(_$hash, mentionLabel.hashCode);
    _$hash = $jc(_$hash, mentionHref.hashCode);
    _$hash = $jc(_$hash, rpIdentity.hashCode);
    _$hash = $jc(_$hash, avatarDisplay.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, avatar.hashCode);
    _$hash = $jc(_$hash, relation.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MentionCandidateDto')
          ..add('candidateKey', candidateKey)
          ..add('targetIdentityId', targetIdentityId)
          ..add('mentionLabel', mentionLabel)
          ..add('mentionHref', mentionHref)
          ..add('rpIdentity', rpIdentity)
          ..add('avatarDisplay', avatarDisplay)
          ..add('id', id)
          ..add('username', username)
          ..add('avatar', avatar)
          ..add('relation', relation))
        .toString();
  }
}

class MentionCandidateDtoBuilder
    implements Builder<MentionCandidateDto, MentionCandidateDtoBuilder> {
  _$MentionCandidateDto? _$v;

  String? _candidateKey;
  String? get candidateKey => _$this._candidateKey;
  set candidateKey(String? candidateKey) => _$this._candidateKey = candidateKey;

  String? _targetIdentityId;
  String? get targetIdentityId => _$this._targetIdentityId;
  set targetIdentityId(String? targetIdentityId) =>
      _$this._targetIdentityId = targetIdentityId;

  String? _mentionLabel;
  String? get mentionLabel => _$this._mentionLabel;
  set mentionLabel(String? mentionLabel) => _$this._mentionLabel = mentionLabel;

  String? _mentionHref;
  String? get mentionHref => _$this._mentionHref;
  set mentionHref(String? mentionHref) => _$this._mentionHref = mentionHref;

  RpIdentityResponseDtoBuilder? _rpIdentity;
  RpIdentityResponseDtoBuilder get rpIdentity =>
      _$this._rpIdentity ??= RpIdentityResponseDtoBuilder();
  set rpIdentity(RpIdentityResponseDtoBuilder? rpIdentity) =>
      _$this._rpIdentity = rpIdentity;

  MediaDisplayResponseDtoBuilder? _avatarDisplay;
  MediaDisplayResponseDtoBuilder get avatarDisplay =>
      _$this._avatarDisplay ??= MediaDisplayResponseDtoBuilder();
  set avatarDisplay(MediaDisplayResponseDtoBuilder? avatarDisplay) =>
      _$this._avatarDisplay = avatarDisplay;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _avatar;
  String? get avatar => _$this._avatar;
  set avatar(String? avatar) => _$this._avatar = avatar;

  MentionCandidateDtoRelationEnum? _relation;
  MentionCandidateDtoRelationEnum? get relation => _$this._relation;
  set relation(MentionCandidateDtoRelationEnum? relation) =>
      _$this._relation = relation;

  MentionCandidateDtoBuilder() {
    MentionCandidateDto._defaults(this);
  }

  MentionCandidateDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _candidateKey = $v.candidateKey;
      _targetIdentityId = $v.targetIdentityId;
      _mentionLabel = $v.mentionLabel;
      _mentionHref = $v.mentionHref;
      _rpIdentity = $v.rpIdentity?.toBuilder();
      _avatarDisplay = $v.avatarDisplay?.toBuilder();
      _id = $v.id;
      _username = $v.username;
      _avatar = $v.avatar;
      _relation = $v.relation;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MentionCandidateDto other) {
    _$v = other as _$MentionCandidateDto;
  }

  @override
  void update(void Function(MentionCandidateDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MentionCandidateDto build() => _build();

  _$MentionCandidateDto _build() {
    _$MentionCandidateDto _$result;
    try {
      _$result =
          _$v ??
          _$MentionCandidateDto._(
            candidateKey: candidateKey,
            targetIdentityId: targetIdentityId,
            mentionLabel: mentionLabel,
            mentionHref: mentionHref,
            rpIdentity: _rpIdentity?.build(),
            avatarDisplay: _avatarDisplay?.build(),
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'MentionCandidateDto',
              'id',
            ),
            username: BuiltValueNullFieldError.checkNotNull(
              username,
              r'MentionCandidateDto',
              'username',
            ),
            avatar: avatar,
            relation: BuiltValueNullFieldError.checkNotNull(
              relation,
              r'MentionCandidateDto',
              'relation',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'rpIdentity';
        _rpIdentity?.build();
        _$failedField = 'avatarDisplay';
        _avatarDisplay?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'MentionCandidateDto',
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
