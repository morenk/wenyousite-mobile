// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_thread_preview_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const InviteThreadPreviewResponseDtoStatusEnum
_$inviteThreadPreviewResponseDtoStatusEnum_RECRUITING =
    const InviteThreadPreviewResponseDtoStatusEnum._('RECRUITING');
const InviteThreadPreviewResponseDtoStatusEnum
_$inviteThreadPreviewResponseDtoStatusEnum_CLOSED =
    const InviteThreadPreviewResponseDtoStatusEnum._('CLOSED');
const InviteThreadPreviewResponseDtoStatusEnum
_$inviteThreadPreviewResponseDtoStatusEnum_FINISHED =
    const InviteThreadPreviewResponseDtoStatusEnum._('FINISHED');
const InviteThreadPreviewResponseDtoStatusEnum
_$inviteThreadPreviewResponseDtoStatusEnum_unknownDefaultOpenApi =
    const InviteThreadPreviewResponseDtoStatusEnum._('unknownDefaultOpenApi');

InviteThreadPreviewResponseDtoStatusEnum
_$inviteThreadPreviewResponseDtoStatusEnumValueOf(String name) {
  switch (name) {
    case 'RECRUITING':
      return _$inviteThreadPreviewResponseDtoStatusEnum_RECRUITING;
    case 'CLOSED':
      return _$inviteThreadPreviewResponseDtoStatusEnum_CLOSED;
    case 'FINISHED':
      return _$inviteThreadPreviewResponseDtoStatusEnum_FINISHED;
    case 'unknownDefaultOpenApi':
      return _$inviteThreadPreviewResponseDtoStatusEnum_unknownDefaultOpenApi;
    default:
      return _$inviteThreadPreviewResponseDtoStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<InviteThreadPreviewResponseDtoStatusEnum>
_$inviteThreadPreviewResponseDtoStatusEnumValues =
    BuiltSet<InviteThreadPreviewResponseDtoStatusEnum>(
      const <InviteThreadPreviewResponseDtoStatusEnum>[
        _$inviteThreadPreviewResponseDtoStatusEnum_RECRUITING,
        _$inviteThreadPreviewResponseDtoStatusEnum_CLOSED,
        _$inviteThreadPreviewResponseDtoStatusEnum_FINISHED,
        _$inviteThreadPreviewResponseDtoStatusEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<InviteThreadPreviewResponseDtoStatusEnum>
_$inviteThreadPreviewResponseDtoStatusEnumSerializer =
    _$InviteThreadPreviewResponseDtoStatusEnumSerializer();

class _$InviteThreadPreviewResponseDtoStatusEnumSerializer
    implements PrimitiveSerializer<InviteThreadPreviewResponseDtoStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'RECRUITING': 'RECRUITING',
    'CLOSED': 'CLOSED',
    'FINISHED': 'FINISHED',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'RECRUITING': 'RECRUITING',
    'CLOSED': 'CLOSED',
    'FINISHED': 'FINISHED',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    InviteThreadPreviewResponseDtoStatusEnum,
  ];
  @override
  final String wireName = 'InviteThreadPreviewResponseDtoStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    InviteThreadPreviewResponseDtoStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  InviteThreadPreviewResponseDtoStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => InviteThreadPreviewResponseDtoStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$InviteThreadPreviewResponseDto extends InviteThreadPreviewResponseDto {
  @override
  final String id;
  @override
  final String title;
  @override
  final String? category;
  @override
  final ThreadCategoryInfoDto? categoryInfo;
  @override
  final InviteThreadPreviewResponseDtoStatusEnum status;
  @override
  final InviteOwnerResponseDto owner;
  @override
  final num memberCount;
  @override
  final DateTime createdAt;

  factory _$InviteThreadPreviewResponseDto([
    void Function(InviteThreadPreviewResponseDtoBuilder)? updates,
  ]) => (InviteThreadPreviewResponseDtoBuilder()..update(updates))._build();

  _$InviteThreadPreviewResponseDto._({
    required this.id,
    required this.title,
    this.category,
    this.categoryInfo,
    required this.status,
    required this.owner,
    required this.memberCount,
    required this.createdAt,
  }) : super._();
  @override
  InviteThreadPreviewResponseDto rebuild(
    void Function(InviteThreadPreviewResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  InviteThreadPreviewResponseDtoBuilder toBuilder() =>
      InviteThreadPreviewResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InviteThreadPreviewResponseDto &&
        id == other.id &&
        title == other.title &&
        category == other.category &&
        categoryInfo == other.categoryInfo &&
        status == other.status &&
        owner == other.owner &&
        memberCount == other.memberCount &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, categoryInfo.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, owner.hashCode);
    _$hash = $jc(_$hash, memberCount.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'InviteThreadPreviewResponseDto')
          ..add('id', id)
          ..add('title', title)
          ..add('category', category)
          ..add('categoryInfo', categoryInfo)
          ..add('status', status)
          ..add('owner', owner)
          ..add('memberCount', memberCount)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class InviteThreadPreviewResponseDtoBuilder
    implements
        Builder<
          InviteThreadPreviewResponseDto,
          InviteThreadPreviewResponseDtoBuilder
        > {
  _$InviteThreadPreviewResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _category;
  String? get category => _$this._category;
  set category(String? category) => _$this._category = category;

  ThreadCategoryInfoDtoBuilder? _categoryInfo;
  ThreadCategoryInfoDtoBuilder get categoryInfo =>
      _$this._categoryInfo ??= ThreadCategoryInfoDtoBuilder();
  set categoryInfo(ThreadCategoryInfoDtoBuilder? categoryInfo) =>
      _$this._categoryInfo = categoryInfo;

  InviteThreadPreviewResponseDtoStatusEnum? _status;
  InviteThreadPreviewResponseDtoStatusEnum? get status => _$this._status;
  set status(InviteThreadPreviewResponseDtoStatusEnum? status) =>
      _$this._status = status;

  InviteOwnerResponseDtoBuilder? _owner;
  InviteOwnerResponseDtoBuilder get owner =>
      _$this._owner ??= InviteOwnerResponseDtoBuilder();
  set owner(InviteOwnerResponseDtoBuilder? owner) => _$this._owner = owner;

  num? _memberCount;
  num? get memberCount => _$this._memberCount;
  set memberCount(num? memberCount) => _$this._memberCount = memberCount;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  InviteThreadPreviewResponseDtoBuilder() {
    InviteThreadPreviewResponseDto._defaults(this);
  }

  InviteThreadPreviewResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _category = $v.category;
      _categoryInfo = $v.categoryInfo?.toBuilder();
      _status = $v.status;
      _owner = $v.owner.toBuilder();
      _memberCount = $v.memberCount;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(InviteThreadPreviewResponseDto other) {
    _$v = other as _$InviteThreadPreviewResponseDto;
  }

  @override
  void update(void Function(InviteThreadPreviewResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  InviteThreadPreviewResponseDto build() => _build();

  _$InviteThreadPreviewResponseDto _build() {
    _$InviteThreadPreviewResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$InviteThreadPreviewResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'InviteThreadPreviewResponseDto',
              'id',
            ),
            title: BuiltValueNullFieldError.checkNotNull(
              title,
              r'InviteThreadPreviewResponseDto',
              'title',
            ),
            category: category,
            categoryInfo: _categoryInfo?.build(),
            status: BuiltValueNullFieldError.checkNotNull(
              status,
              r'InviteThreadPreviewResponseDto',
              'status',
            ),
            owner: owner.build(),
            memberCount: BuiltValueNullFieldError.checkNotNull(
              memberCount,
              r'InviteThreadPreviewResponseDto',
              'memberCount',
            ),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'InviteThreadPreviewResponseDto',
              'createdAt',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'categoryInfo';
        _categoryInfo?.build();

        _$failedField = 'owner';
        owner.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'InviteThreadPreviewResponseDto',
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
