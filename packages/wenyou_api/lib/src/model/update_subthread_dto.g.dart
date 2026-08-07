// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_subthread_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UpdateSubthreadDtoPostingPolicyEnum
_$updateSubthreadDtoPostingPolicyEnum_PARTICIPANTS =
    const UpdateSubthreadDtoPostingPolicyEnum._('PARTICIPANTS');
const UpdateSubthreadDtoPostingPolicyEnum
_$updateSubthreadDtoPostingPolicyEnum_COLLABORATORS =
    const UpdateSubthreadDtoPostingPolicyEnum._('COLLABORATORS');
const UpdateSubthreadDtoPostingPolicyEnum
_$updateSubthreadDtoPostingPolicyEnum_PLAYERS =
    const UpdateSubthreadDtoPostingPolicyEnum._('PLAYERS');
const UpdateSubthreadDtoPostingPolicyEnum
_$updateSubthreadDtoPostingPolicyEnum_unknownDefaultOpenApi =
    const UpdateSubthreadDtoPostingPolicyEnum._('unknownDefaultOpenApi');

UpdateSubthreadDtoPostingPolicyEnum
_$updateSubthreadDtoPostingPolicyEnumValueOf(String name) {
  switch (name) {
    case 'PARTICIPANTS':
      return _$updateSubthreadDtoPostingPolicyEnum_PARTICIPANTS;
    case 'COLLABORATORS':
      return _$updateSubthreadDtoPostingPolicyEnum_COLLABORATORS;
    case 'PLAYERS':
      return _$updateSubthreadDtoPostingPolicyEnum_PLAYERS;
    case 'unknownDefaultOpenApi':
      return _$updateSubthreadDtoPostingPolicyEnum_unknownDefaultOpenApi;
    default:
      return _$updateSubthreadDtoPostingPolicyEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UpdateSubthreadDtoPostingPolicyEnum>
_$updateSubthreadDtoPostingPolicyEnumValues =
    BuiltSet<UpdateSubthreadDtoPostingPolicyEnum>(
      const <UpdateSubthreadDtoPostingPolicyEnum>[
        _$updateSubthreadDtoPostingPolicyEnum_PARTICIPANTS,
        _$updateSubthreadDtoPostingPolicyEnum_COLLABORATORS,
        _$updateSubthreadDtoPostingPolicyEnum_PLAYERS,
        _$updateSubthreadDtoPostingPolicyEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<UpdateSubthreadDtoPostingPolicyEnum>
_$updateSubthreadDtoPostingPolicyEnumSerializer =
    _$UpdateSubthreadDtoPostingPolicyEnumSerializer();

class _$UpdateSubthreadDtoPostingPolicyEnumSerializer
    implements PrimitiveSerializer<UpdateSubthreadDtoPostingPolicyEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'PARTICIPANTS': 'PARTICIPANTS',
    'COLLABORATORS': 'COLLABORATORS',
    'PLAYERS': 'PLAYERS',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'PARTICIPANTS': 'PARTICIPANTS',
    'COLLABORATORS': 'COLLABORATORS',
    'PLAYERS': 'PLAYERS',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    UpdateSubthreadDtoPostingPolicyEnum,
  ];
  @override
  final String wireName = 'UpdateSubthreadDtoPostingPolicyEnum';

  @override
  Object serialize(
    Serializers serializers,
    UpdateSubthreadDtoPostingPolicyEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UpdateSubthreadDtoPostingPolicyEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UpdateSubthreadDtoPostingPolicyEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UpdateSubthreadDto extends UpdateSubthreadDto {
  @override
  final String? title;
  @override
  final num? sortOrder;
  @override
  final UpdateSubthreadDtoPostingPolicyEnum? postingPolicy;
  @override
  final num version;

  factory _$UpdateSubthreadDto([
    void Function(UpdateSubthreadDtoBuilder)? updates,
  ]) => (UpdateSubthreadDtoBuilder()..update(updates))._build();

  _$UpdateSubthreadDto._({
    this.title,
    this.sortOrder,
    this.postingPolicy,
    required this.version,
  }) : super._();
  @override
  UpdateSubthreadDto rebuild(
    void Function(UpdateSubthreadDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UpdateSubthreadDtoBuilder toBuilder() =>
      UpdateSubthreadDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateSubthreadDto &&
        title == other.title &&
        sortOrder == other.sortOrder &&
        postingPolicy == other.postingPolicy &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, sortOrder.hashCode);
    _$hash = $jc(_$hash, postingPolicy.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateSubthreadDto')
          ..add('title', title)
          ..add('sortOrder', sortOrder)
          ..add('postingPolicy', postingPolicy)
          ..add('version', version))
        .toString();
  }
}

class UpdateSubthreadDtoBuilder
    implements Builder<UpdateSubthreadDto, UpdateSubthreadDtoBuilder> {
  _$UpdateSubthreadDto? _$v;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  num? _sortOrder;
  num? get sortOrder => _$this._sortOrder;
  set sortOrder(num? sortOrder) => _$this._sortOrder = sortOrder;

  UpdateSubthreadDtoPostingPolicyEnum? _postingPolicy;
  UpdateSubthreadDtoPostingPolicyEnum? get postingPolicy =>
      _$this._postingPolicy;
  set postingPolicy(UpdateSubthreadDtoPostingPolicyEnum? postingPolicy) =>
      _$this._postingPolicy = postingPolicy;

  num? _version;
  num? get version => _$this._version;
  set version(num? version) => _$this._version = version;

  UpdateSubthreadDtoBuilder() {
    UpdateSubthreadDto._defaults(this);
  }

  UpdateSubthreadDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _title = $v.title;
      _sortOrder = $v.sortOrder;
      _postingPolicy = $v.postingPolicy;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateSubthreadDto other) {
    _$v = other as _$UpdateSubthreadDto;
  }

  @override
  void update(void Function(UpdateSubthreadDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateSubthreadDto build() => _build();

  _$UpdateSubthreadDto _build() {
    final _$result =
        _$v ??
        _$UpdateSubthreadDto._(
          title: title,
          sortOrder: sortOrder,
          postingPolicy: postingPolicy,
          version: BuiltValueNullFieldError.checkNotNull(
            version,
            r'UpdateSubthreadDto',
            'version',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
