// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_subthread_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CreateSubthreadDtoPostingPolicyEnum
_$createSubthreadDtoPostingPolicyEnum_PARTICIPANTS =
    const CreateSubthreadDtoPostingPolicyEnum._('PARTICIPANTS');
const CreateSubthreadDtoPostingPolicyEnum
_$createSubthreadDtoPostingPolicyEnum_COLLABORATORS =
    const CreateSubthreadDtoPostingPolicyEnum._('COLLABORATORS');
const CreateSubthreadDtoPostingPolicyEnum
_$createSubthreadDtoPostingPolicyEnum_PLAYERS =
    const CreateSubthreadDtoPostingPolicyEnum._('PLAYERS');
const CreateSubthreadDtoPostingPolicyEnum
_$createSubthreadDtoPostingPolicyEnum_unknownDefaultOpenApi =
    const CreateSubthreadDtoPostingPolicyEnum._('unknownDefaultOpenApi');

CreateSubthreadDtoPostingPolicyEnum
_$createSubthreadDtoPostingPolicyEnumValueOf(String name) {
  switch (name) {
    case 'PARTICIPANTS':
      return _$createSubthreadDtoPostingPolicyEnum_PARTICIPANTS;
    case 'COLLABORATORS':
      return _$createSubthreadDtoPostingPolicyEnum_COLLABORATORS;
    case 'PLAYERS':
      return _$createSubthreadDtoPostingPolicyEnum_PLAYERS;
    case 'unknownDefaultOpenApi':
      return _$createSubthreadDtoPostingPolicyEnum_unknownDefaultOpenApi;
    default:
      return _$createSubthreadDtoPostingPolicyEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<CreateSubthreadDtoPostingPolicyEnum>
_$createSubthreadDtoPostingPolicyEnumValues =
    BuiltSet<CreateSubthreadDtoPostingPolicyEnum>(
      const <CreateSubthreadDtoPostingPolicyEnum>[
        _$createSubthreadDtoPostingPolicyEnum_PARTICIPANTS,
        _$createSubthreadDtoPostingPolicyEnum_COLLABORATORS,
        _$createSubthreadDtoPostingPolicyEnum_PLAYERS,
        _$createSubthreadDtoPostingPolicyEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<CreateSubthreadDtoPostingPolicyEnum>
_$createSubthreadDtoPostingPolicyEnumSerializer =
    _$CreateSubthreadDtoPostingPolicyEnumSerializer();

class _$CreateSubthreadDtoPostingPolicyEnumSerializer
    implements PrimitiveSerializer<CreateSubthreadDtoPostingPolicyEnum> {
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
    CreateSubthreadDtoPostingPolicyEnum,
  ];
  @override
  final String wireName = 'CreateSubthreadDtoPostingPolicyEnum';

  @override
  Object serialize(
    Serializers serializers,
    CreateSubthreadDtoPostingPolicyEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  CreateSubthreadDtoPostingPolicyEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => CreateSubthreadDtoPostingPolicyEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$CreateSubthreadDto extends CreateSubthreadDto {
  @override
  final String? clientRequestId;
  @override
  final String title;
  @override
  final String? content;
  @override
  final num? sortOrder;
  @override
  final CreateSubthreadDtoPostingPolicyEnum? postingPolicy;

  factory _$CreateSubthreadDto([
    void Function(CreateSubthreadDtoBuilder)? updates,
  ]) => (CreateSubthreadDtoBuilder()..update(updates))._build();

  _$CreateSubthreadDto._({
    this.clientRequestId,
    required this.title,
    this.content,
    this.sortOrder,
    this.postingPolicy,
  }) : super._();
  @override
  CreateSubthreadDto rebuild(
    void Function(CreateSubthreadDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  CreateSubthreadDtoBuilder toBuilder() =>
      CreateSubthreadDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateSubthreadDto &&
        clientRequestId == other.clientRequestId &&
        title == other.title &&
        content == other.content &&
        sortOrder == other.sortOrder &&
        postingPolicy == other.postingPolicy;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientRequestId.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, sortOrder.hashCode);
    _$hash = $jc(_$hash, postingPolicy.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateSubthreadDto')
          ..add('clientRequestId', clientRequestId)
          ..add('title', title)
          ..add('content', content)
          ..add('sortOrder', sortOrder)
          ..add('postingPolicy', postingPolicy))
        .toString();
  }
}

class CreateSubthreadDtoBuilder
    implements Builder<CreateSubthreadDto, CreateSubthreadDtoBuilder> {
  _$CreateSubthreadDto? _$v;

  String? _clientRequestId;
  String? get clientRequestId => _$this._clientRequestId;
  set clientRequestId(String? clientRequestId) =>
      _$this._clientRequestId = clientRequestId;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  num? _sortOrder;
  num? get sortOrder => _$this._sortOrder;
  set sortOrder(num? sortOrder) => _$this._sortOrder = sortOrder;

  CreateSubthreadDtoPostingPolicyEnum? _postingPolicy;
  CreateSubthreadDtoPostingPolicyEnum? get postingPolicy =>
      _$this._postingPolicy;
  set postingPolicy(CreateSubthreadDtoPostingPolicyEnum? postingPolicy) =>
      _$this._postingPolicy = postingPolicy;

  CreateSubthreadDtoBuilder() {
    CreateSubthreadDto._defaults(this);
  }

  CreateSubthreadDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientRequestId = $v.clientRequestId;
      _title = $v.title;
      _content = $v.content;
      _sortOrder = $v.sortOrder;
      _postingPolicy = $v.postingPolicy;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateSubthreadDto other) {
    _$v = other as _$CreateSubthreadDto;
  }

  @override
  void update(void Function(CreateSubthreadDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateSubthreadDto build() => _build();

  _$CreateSubthreadDto _build() {
    final _$result =
        _$v ??
        _$CreateSubthreadDto._(
          clientRequestId: clientRequestId,
          title: BuiltValueNullFieldError.checkNotNull(
            title,
            r'CreateSubthreadDto',
            'title',
          ),
          content: content,
          sortOrder: sortOrder,
          postingPolicy: postingPolicy,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
