// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'own_bookmark_thread_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OwnBookmarkThreadResponseDtoStatusEnum
_$ownBookmarkThreadResponseDtoStatusEnum_RECRUITING =
    const OwnBookmarkThreadResponseDtoStatusEnum._('RECRUITING');
const OwnBookmarkThreadResponseDtoStatusEnum
_$ownBookmarkThreadResponseDtoStatusEnum_CLOSED =
    const OwnBookmarkThreadResponseDtoStatusEnum._('CLOSED');
const OwnBookmarkThreadResponseDtoStatusEnum
_$ownBookmarkThreadResponseDtoStatusEnum_FINISHED =
    const OwnBookmarkThreadResponseDtoStatusEnum._('FINISHED');
const OwnBookmarkThreadResponseDtoStatusEnum
_$ownBookmarkThreadResponseDtoStatusEnum_unknownDefaultOpenApi =
    const OwnBookmarkThreadResponseDtoStatusEnum._('unknownDefaultOpenApi');

OwnBookmarkThreadResponseDtoStatusEnum
_$ownBookmarkThreadResponseDtoStatusEnumValueOf(String name) {
  switch (name) {
    case 'RECRUITING':
      return _$ownBookmarkThreadResponseDtoStatusEnum_RECRUITING;
    case 'CLOSED':
      return _$ownBookmarkThreadResponseDtoStatusEnum_CLOSED;
    case 'FINISHED':
      return _$ownBookmarkThreadResponseDtoStatusEnum_FINISHED;
    case 'unknownDefaultOpenApi':
      return _$ownBookmarkThreadResponseDtoStatusEnum_unknownDefaultOpenApi;
    default:
      return _$ownBookmarkThreadResponseDtoStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<OwnBookmarkThreadResponseDtoStatusEnum>
_$ownBookmarkThreadResponseDtoStatusEnumValues =
    BuiltSet<OwnBookmarkThreadResponseDtoStatusEnum>(
      const <OwnBookmarkThreadResponseDtoStatusEnum>[
        _$ownBookmarkThreadResponseDtoStatusEnum_RECRUITING,
        _$ownBookmarkThreadResponseDtoStatusEnum_CLOSED,
        _$ownBookmarkThreadResponseDtoStatusEnum_FINISHED,
        _$ownBookmarkThreadResponseDtoStatusEnum_unknownDefaultOpenApi,
      ],
    );

const OwnBookmarkThreadResponseDtoVisibilityEnum
_$ownBookmarkThreadResponseDtoVisibilityEnum_PUBLIC =
    const OwnBookmarkThreadResponseDtoVisibilityEnum._('PUBLIC');
const OwnBookmarkThreadResponseDtoVisibilityEnum
_$ownBookmarkThreadResponseDtoVisibilityEnum_PRIVATE =
    const OwnBookmarkThreadResponseDtoVisibilityEnum._('PRIVATE');
const OwnBookmarkThreadResponseDtoVisibilityEnum
_$ownBookmarkThreadResponseDtoVisibilityEnum_unknownDefaultOpenApi =
    const OwnBookmarkThreadResponseDtoVisibilityEnum._('unknownDefaultOpenApi');

OwnBookmarkThreadResponseDtoVisibilityEnum
_$ownBookmarkThreadResponseDtoVisibilityEnumValueOf(String name) {
  switch (name) {
    case 'PUBLIC':
      return _$ownBookmarkThreadResponseDtoVisibilityEnum_PUBLIC;
    case 'PRIVATE':
      return _$ownBookmarkThreadResponseDtoVisibilityEnum_PRIVATE;
    case 'unknownDefaultOpenApi':
      return _$ownBookmarkThreadResponseDtoVisibilityEnum_unknownDefaultOpenApi;
    default:
      return _$ownBookmarkThreadResponseDtoVisibilityEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<OwnBookmarkThreadResponseDtoVisibilityEnum>
_$ownBookmarkThreadResponseDtoVisibilityEnumValues =
    BuiltSet<OwnBookmarkThreadResponseDtoVisibilityEnum>(
      const <OwnBookmarkThreadResponseDtoVisibilityEnum>[
        _$ownBookmarkThreadResponseDtoVisibilityEnum_PUBLIC,
        _$ownBookmarkThreadResponseDtoVisibilityEnum_PRIVATE,
        _$ownBookmarkThreadResponseDtoVisibilityEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<OwnBookmarkThreadResponseDtoStatusEnum>
_$ownBookmarkThreadResponseDtoStatusEnumSerializer =
    _$OwnBookmarkThreadResponseDtoStatusEnumSerializer();
Serializer<OwnBookmarkThreadResponseDtoVisibilityEnum>
_$ownBookmarkThreadResponseDtoVisibilityEnumSerializer =
    _$OwnBookmarkThreadResponseDtoVisibilityEnumSerializer();

class _$OwnBookmarkThreadResponseDtoStatusEnumSerializer
    implements PrimitiveSerializer<OwnBookmarkThreadResponseDtoStatusEnum> {
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
    OwnBookmarkThreadResponseDtoStatusEnum,
  ];
  @override
  final String wireName = 'OwnBookmarkThreadResponseDtoStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    OwnBookmarkThreadResponseDtoStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  OwnBookmarkThreadResponseDtoStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => OwnBookmarkThreadResponseDtoStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$OwnBookmarkThreadResponseDtoVisibilityEnumSerializer
    implements PrimitiveSerializer<OwnBookmarkThreadResponseDtoVisibilityEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'PUBLIC': 'PUBLIC',
    'PRIVATE': 'PRIVATE',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'PUBLIC': 'PUBLIC',
    'PRIVATE': 'PRIVATE',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    OwnBookmarkThreadResponseDtoVisibilityEnum,
  ];
  @override
  final String wireName = 'OwnBookmarkThreadResponseDtoVisibilityEnum';

  @override
  Object serialize(
    Serializers serializers,
    OwnBookmarkThreadResponseDtoVisibilityEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  OwnBookmarkThreadResponseDtoVisibilityEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => OwnBookmarkThreadResponseDtoVisibilityEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$OwnBookmarkThreadResponseDto extends OwnBookmarkThreadResponseDto {
  @override
  final String id;
  @override
  final String title;
  @override
  final String? category;
  @override
  final OwnBookmarkThreadResponseDtoStatusEnum status;
  @override
  final OwnBookmarkThreadResponseDtoVisibilityEnum visibility;
  @override
  final bool published;
  @override
  final bool pinned;
  @override
  final String tipTotal;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final PostAuthorResponseDto owner;
  @override
  final BookmarkThreadCountResponseDto count;
  @override
  final String? bookmarkId;
  @override
  final String? bookmarkFolderId;

  factory _$OwnBookmarkThreadResponseDto([
    void Function(OwnBookmarkThreadResponseDtoBuilder)? updates,
  ]) => (OwnBookmarkThreadResponseDtoBuilder()..update(updates))._build();

  _$OwnBookmarkThreadResponseDto._({
    required this.id,
    required this.title,
    this.category,
    required this.status,
    required this.visibility,
    required this.published,
    required this.pinned,
    required this.tipTotal,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.owner,
    required this.count,
    this.bookmarkId,
    this.bookmarkFolderId,
  }) : super._();
  @override
  OwnBookmarkThreadResponseDto rebuild(
    void Function(OwnBookmarkThreadResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  OwnBookmarkThreadResponseDtoBuilder toBuilder() =>
      OwnBookmarkThreadResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OwnBookmarkThreadResponseDto &&
        id == other.id &&
        title == other.title &&
        category == other.category &&
        status == other.status &&
        visibility == other.visibility &&
        published == other.published &&
        pinned == other.pinned &&
        tipTotal == other.tipTotal &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        deletedAt == other.deletedAt &&
        owner == other.owner &&
        count == other.count &&
        bookmarkId == other.bookmarkId &&
        bookmarkFolderId == other.bookmarkFolderId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, visibility.hashCode);
    _$hash = $jc(_$hash, published.hashCode);
    _$hash = $jc(_$hash, pinned.hashCode);
    _$hash = $jc(_$hash, tipTotal.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jc(_$hash, owner.hashCode);
    _$hash = $jc(_$hash, count.hashCode);
    _$hash = $jc(_$hash, bookmarkId.hashCode);
    _$hash = $jc(_$hash, bookmarkFolderId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OwnBookmarkThreadResponseDto')
          ..add('id', id)
          ..add('title', title)
          ..add('category', category)
          ..add('status', status)
          ..add('visibility', visibility)
          ..add('published', published)
          ..add('pinned', pinned)
          ..add('tipTotal', tipTotal)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('deletedAt', deletedAt)
          ..add('owner', owner)
          ..add('count', count)
          ..add('bookmarkId', bookmarkId)
          ..add('bookmarkFolderId', bookmarkFolderId))
        .toString();
  }
}

class OwnBookmarkThreadResponseDtoBuilder
    implements
        Builder<
          OwnBookmarkThreadResponseDto,
          OwnBookmarkThreadResponseDtoBuilder
        > {
  _$OwnBookmarkThreadResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _category;
  String? get category => _$this._category;
  set category(String? category) => _$this._category = category;

  OwnBookmarkThreadResponseDtoStatusEnum? _status;
  OwnBookmarkThreadResponseDtoStatusEnum? get status => _$this._status;
  set status(OwnBookmarkThreadResponseDtoStatusEnum? status) =>
      _$this._status = status;

  OwnBookmarkThreadResponseDtoVisibilityEnum? _visibility;
  OwnBookmarkThreadResponseDtoVisibilityEnum? get visibility =>
      _$this._visibility;
  set visibility(OwnBookmarkThreadResponseDtoVisibilityEnum? visibility) =>
      _$this._visibility = visibility;

  bool? _published;
  bool? get published => _$this._published;
  set published(bool? published) => _$this._published = published;

  bool? _pinned;
  bool? get pinned => _$this._pinned;
  set pinned(bool? pinned) => _$this._pinned = pinned;

  String? _tipTotal;
  String? get tipTotal => _$this._tipTotal;
  set tipTotal(String? tipTotal) => _$this._tipTotal = tipTotal;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  PostAuthorResponseDtoBuilder? _owner;
  PostAuthorResponseDtoBuilder get owner =>
      _$this._owner ??= PostAuthorResponseDtoBuilder();
  set owner(PostAuthorResponseDtoBuilder? owner) => _$this._owner = owner;

  BookmarkThreadCountResponseDtoBuilder? _count;
  BookmarkThreadCountResponseDtoBuilder get count =>
      _$this._count ??= BookmarkThreadCountResponseDtoBuilder();
  set count(BookmarkThreadCountResponseDtoBuilder? count) =>
      _$this._count = count;

  String? _bookmarkId;
  String? get bookmarkId => _$this._bookmarkId;
  set bookmarkId(String? bookmarkId) => _$this._bookmarkId = bookmarkId;

  String? _bookmarkFolderId;
  String? get bookmarkFolderId => _$this._bookmarkFolderId;
  set bookmarkFolderId(String? bookmarkFolderId) =>
      _$this._bookmarkFolderId = bookmarkFolderId;

  OwnBookmarkThreadResponseDtoBuilder() {
    OwnBookmarkThreadResponseDto._defaults(this);
  }

  OwnBookmarkThreadResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _category = $v.category;
      _status = $v.status;
      _visibility = $v.visibility;
      _published = $v.published;
      _pinned = $v.pinned;
      _tipTotal = $v.tipTotal;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _deletedAt = $v.deletedAt;
      _owner = $v.owner.toBuilder();
      _count = $v.count.toBuilder();
      _bookmarkId = $v.bookmarkId;
      _bookmarkFolderId = $v.bookmarkFolderId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OwnBookmarkThreadResponseDto other) {
    _$v = other as _$OwnBookmarkThreadResponseDto;
  }

  @override
  void update(void Function(OwnBookmarkThreadResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OwnBookmarkThreadResponseDto build() => _build();

  _$OwnBookmarkThreadResponseDto _build() {
    _$OwnBookmarkThreadResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$OwnBookmarkThreadResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'OwnBookmarkThreadResponseDto',
              'id',
            ),
            title: BuiltValueNullFieldError.checkNotNull(
              title,
              r'OwnBookmarkThreadResponseDto',
              'title',
            ),
            category: category,
            status: BuiltValueNullFieldError.checkNotNull(
              status,
              r'OwnBookmarkThreadResponseDto',
              'status',
            ),
            visibility: BuiltValueNullFieldError.checkNotNull(
              visibility,
              r'OwnBookmarkThreadResponseDto',
              'visibility',
            ),
            published: BuiltValueNullFieldError.checkNotNull(
              published,
              r'OwnBookmarkThreadResponseDto',
              'published',
            ),
            pinned: BuiltValueNullFieldError.checkNotNull(
              pinned,
              r'OwnBookmarkThreadResponseDto',
              'pinned',
            ),
            tipTotal: BuiltValueNullFieldError.checkNotNull(
              tipTotal,
              r'OwnBookmarkThreadResponseDto',
              'tipTotal',
            ),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'OwnBookmarkThreadResponseDto',
              'createdAt',
            ),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt,
              r'OwnBookmarkThreadResponseDto',
              'updatedAt',
            ),
            deletedAt: deletedAt,
            owner: owner.build(),
            count: count.build(),
            bookmarkId: bookmarkId,
            bookmarkFolderId: bookmarkFolderId,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'owner';
        owner.build();
        _$failedField = 'count';
        count.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'OwnBookmarkThreadResponseDto',
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
