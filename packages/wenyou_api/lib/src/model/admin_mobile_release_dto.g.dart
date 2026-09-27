// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_mobile_release_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminMobileReleaseDtoPlatformEnum
_$adminMobileReleaseDtoPlatformEnum_android =
    const AdminMobileReleaseDtoPlatformEnum._('android');
const AdminMobileReleaseDtoPlatformEnum
_$adminMobileReleaseDtoPlatformEnum_unknownDefaultOpenApi =
    const AdminMobileReleaseDtoPlatformEnum._('unknownDefaultOpenApi');

AdminMobileReleaseDtoPlatformEnum _$adminMobileReleaseDtoPlatformEnumValueOf(
  String name,
) {
  switch (name) {
    case 'android':
      return _$adminMobileReleaseDtoPlatformEnum_android;
    case 'unknownDefaultOpenApi':
      return _$adminMobileReleaseDtoPlatformEnum_unknownDefaultOpenApi;
    default:
      return _$adminMobileReleaseDtoPlatformEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminMobileReleaseDtoPlatformEnum>
_$adminMobileReleaseDtoPlatformEnumValues =
    BuiltSet<AdminMobileReleaseDtoPlatformEnum>(
      const <AdminMobileReleaseDtoPlatformEnum>[
        _$adminMobileReleaseDtoPlatformEnum_android,
        _$adminMobileReleaseDtoPlatformEnum_unknownDefaultOpenApi,
      ],
    );

const AdminMobileReleaseDtoStatusEnum _$adminMobileReleaseDtoStatusEnum_DRAFT =
    const AdminMobileReleaseDtoStatusEnum._('DRAFT');
const AdminMobileReleaseDtoStatusEnum _$adminMobileReleaseDtoStatusEnum_READY =
    const AdminMobileReleaseDtoStatusEnum._('READY');
const AdminMobileReleaseDtoStatusEnum
_$adminMobileReleaseDtoStatusEnum_PUBLISHED =
    const AdminMobileReleaseDtoStatusEnum._('PUBLISHED');
const AdminMobileReleaseDtoStatusEnum
_$adminMobileReleaseDtoStatusEnum_unknownDefaultOpenApi =
    const AdminMobileReleaseDtoStatusEnum._('unknownDefaultOpenApi');

AdminMobileReleaseDtoStatusEnum _$adminMobileReleaseDtoStatusEnumValueOf(
  String name,
) {
  switch (name) {
    case 'DRAFT':
      return _$adminMobileReleaseDtoStatusEnum_DRAFT;
    case 'READY':
      return _$adminMobileReleaseDtoStatusEnum_READY;
    case 'PUBLISHED':
      return _$adminMobileReleaseDtoStatusEnum_PUBLISHED;
    case 'unknownDefaultOpenApi':
      return _$adminMobileReleaseDtoStatusEnum_unknownDefaultOpenApi;
    default:
      return _$adminMobileReleaseDtoStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<AdminMobileReleaseDtoStatusEnum>
_$adminMobileReleaseDtoStatusEnumValues =
    BuiltSet<AdminMobileReleaseDtoStatusEnum>(
      const <AdminMobileReleaseDtoStatusEnum>[
        _$adminMobileReleaseDtoStatusEnum_DRAFT,
        _$adminMobileReleaseDtoStatusEnum_READY,
        _$adminMobileReleaseDtoStatusEnum_PUBLISHED,
        _$adminMobileReleaseDtoStatusEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<AdminMobileReleaseDtoPlatformEnum>
_$adminMobileReleaseDtoPlatformEnumSerializer =
    _$AdminMobileReleaseDtoPlatformEnumSerializer();
Serializer<AdminMobileReleaseDtoStatusEnum>
_$adminMobileReleaseDtoStatusEnumSerializer =
    _$AdminMobileReleaseDtoStatusEnumSerializer();

class _$AdminMobileReleaseDtoPlatformEnumSerializer
    implements PrimitiveSerializer<AdminMobileReleaseDtoPlatformEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'android': 'android',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'android': 'android',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[AdminMobileReleaseDtoPlatformEnum];
  @override
  final String wireName = 'AdminMobileReleaseDtoPlatformEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminMobileReleaseDtoPlatformEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminMobileReleaseDtoPlatformEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminMobileReleaseDtoPlatformEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminMobileReleaseDtoStatusEnumSerializer
    implements PrimitiveSerializer<AdminMobileReleaseDtoStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'DRAFT': 'DRAFT',
    'READY': 'READY',
    'PUBLISHED': 'PUBLISHED',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'DRAFT': 'DRAFT',
    'READY': 'READY',
    'PUBLISHED': 'PUBLISHED',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[AdminMobileReleaseDtoStatusEnum];
  @override
  final String wireName = 'AdminMobileReleaseDtoStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminMobileReleaseDtoStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminMobileReleaseDtoStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminMobileReleaseDtoStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminMobileReleaseDto extends AdminMobileReleaseDto {
  @override
  final AdminMobileReleaseDtoPlatformEnum platform;
  @override
  final String versionName;
  @override
  final num buildNumber;
  @override
  final String id;
  @override
  final String summary;
  @override
  final BuiltList<String> items;
  @override
  final num revision;
  @override
  final AdminMobileReleaseDtoStatusEnum status;
  @override
  final bool hasUnconfirmedChanges;
  @override
  final bool publishing;
  @override
  final MobileReleaseSnapshotDto? confirmed;
  @override
  final PublicMobileReleaseDto? published;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$AdminMobileReleaseDto([
    void Function(AdminMobileReleaseDtoBuilder)? updates,
  ]) => (AdminMobileReleaseDtoBuilder()..update(updates))._build();

  _$AdminMobileReleaseDto._({
    required this.platform,
    required this.versionName,
    required this.buildNumber,
    required this.id,
    required this.summary,
    required this.items,
    required this.revision,
    required this.status,
    required this.hasUnconfirmedChanges,
    required this.publishing,
    this.confirmed,
    this.published,
    required this.createdAt,
    required this.updatedAt,
  }) : super._();
  @override
  AdminMobileReleaseDto rebuild(
    void Function(AdminMobileReleaseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminMobileReleaseDtoBuilder toBuilder() =>
      AdminMobileReleaseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminMobileReleaseDto &&
        platform == other.platform &&
        versionName == other.versionName &&
        buildNumber == other.buildNumber &&
        id == other.id &&
        summary == other.summary &&
        items == other.items &&
        revision == other.revision &&
        status == other.status &&
        hasUnconfirmedChanges == other.hasUnconfirmedChanges &&
        publishing == other.publishing &&
        confirmed == other.confirmed &&
        published == other.published &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, versionName.hashCode);
    _$hash = $jc(_$hash, buildNumber.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, summary.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, hasUnconfirmedChanges.hashCode);
    _$hash = $jc(_$hash, publishing.hashCode);
    _$hash = $jc(_$hash, confirmed.hashCode);
    _$hash = $jc(_$hash, published.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminMobileReleaseDto')
          ..add('platform', platform)
          ..add('versionName', versionName)
          ..add('buildNumber', buildNumber)
          ..add('id', id)
          ..add('summary', summary)
          ..add('items', items)
          ..add('revision', revision)
          ..add('status', status)
          ..add('hasUnconfirmedChanges', hasUnconfirmedChanges)
          ..add('publishing', publishing)
          ..add('confirmed', confirmed)
          ..add('published', published)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class AdminMobileReleaseDtoBuilder
    implements Builder<AdminMobileReleaseDto, AdminMobileReleaseDtoBuilder> {
  _$AdminMobileReleaseDto? _$v;

  AdminMobileReleaseDtoPlatformEnum? _platform;
  AdminMobileReleaseDtoPlatformEnum? get platform => _$this._platform;
  set platform(AdminMobileReleaseDtoPlatformEnum? platform) =>
      _$this._platform = platform;

  String? _versionName;
  String? get versionName => _$this._versionName;
  set versionName(String? versionName) => _$this._versionName = versionName;

  num? _buildNumber;
  num? get buildNumber => _$this._buildNumber;
  set buildNumber(num? buildNumber) => _$this._buildNumber = buildNumber;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _summary;
  String? get summary => _$this._summary;
  set summary(String? summary) => _$this._summary = summary;

  ListBuilder<String>? _items;
  ListBuilder<String> get items => _$this._items ??= ListBuilder<String>();
  set items(ListBuilder<String>? items) => _$this._items = items;

  num? _revision;
  num? get revision => _$this._revision;
  set revision(num? revision) => _$this._revision = revision;

  AdminMobileReleaseDtoStatusEnum? _status;
  AdminMobileReleaseDtoStatusEnum? get status => _$this._status;
  set status(AdminMobileReleaseDtoStatusEnum? status) =>
      _$this._status = status;

  bool? _hasUnconfirmedChanges;
  bool? get hasUnconfirmedChanges => _$this._hasUnconfirmedChanges;
  set hasUnconfirmedChanges(bool? hasUnconfirmedChanges) =>
      _$this._hasUnconfirmedChanges = hasUnconfirmedChanges;

  bool? _publishing;
  bool? get publishing => _$this._publishing;
  set publishing(bool? publishing) => _$this._publishing = publishing;

  MobileReleaseSnapshotDtoBuilder? _confirmed;
  MobileReleaseSnapshotDtoBuilder get confirmed =>
      _$this._confirmed ??= MobileReleaseSnapshotDtoBuilder();
  set confirmed(MobileReleaseSnapshotDtoBuilder? confirmed) =>
      _$this._confirmed = confirmed;

  PublicMobileReleaseDtoBuilder? _published;
  PublicMobileReleaseDtoBuilder get published =>
      _$this._published ??= PublicMobileReleaseDtoBuilder();
  set published(PublicMobileReleaseDtoBuilder? published) =>
      _$this._published = published;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  AdminMobileReleaseDtoBuilder() {
    AdminMobileReleaseDto._defaults(this);
  }

  AdminMobileReleaseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _platform = $v.platform;
      _versionName = $v.versionName;
      _buildNumber = $v.buildNumber;
      _id = $v.id;
      _summary = $v.summary;
      _items = $v.items.toBuilder();
      _revision = $v.revision;
      _status = $v.status;
      _hasUnconfirmedChanges = $v.hasUnconfirmedChanges;
      _publishing = $v.publishing;
      _confirmed = $v.confirmed?.toBuilder();
      _published = $v.published?.toBuilder();
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminMobileReleaseDto other) {
    _$v = other as _$AdminMobileReleaseDto;
  }

  @override
  void update(void Function(AdminMobileReleaseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminMobileReleaseDto build() => _build();

  _$AdminMobileReleaseDto _build() {
    _$AdminMobileReleaseDto _$result;
    try {
      _$result =
          _$v ??
          _$AdminMobileReleaseDto._(
            platform: BuiltValueNullFieldError.checkNotNull(
              platform,
              r'AdminMobileReleaseDto',
              'platform',
            ),
            versionName: BuiltValueNullFieldError.checkNotNull(
              versionName,
              r'AdminMobileReleaseDto',
              'versionName',
            ),
            buildNumber: BuiltValueNullFieldError.checkNotNull(
              buildNumber,
              r'AdminMobileReleaseDto',
              'buildNumber',
            ),
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'AdminMobileReleaseDto',
              'id',
            ),
            summary: BuiltValueNullFieldError.checkNotNull(
              summary,
              r'AdminMobileReleaseDto',
              'summary',
            ),
            items: items.build(),
            revision: BuiltValueNullFieldError.checkNotNull(
              revision,
              r'AdminMobileReleaseDto',
              'revision',
            ),
            status: BuiltValueNullFieldError.checkNotNull(
              status,
              r'AdminMobileReleaseDto',
              'status',
            ),
            hasUnconfirmedChanges: BuiltValueNullFieldError.checkNotNull(
              hasUnconfirmedChanges,
              r'AdminMobileReleaseDto',
              'hasUnconfirmedChanges',
            ),
            publishing: BuiltValueNullFieldError.checkNotNull(
              publishing,
              r'AdminMobileReleaseDto',
              'publishing',
            ),
            confirmed: _confirmed?.build(),
            published: _published?.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'AdminMobileReleaseDto',
              'createdAt',
            ),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt,
              r'AdminMobileReleaseDto',
              'updatedAt',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();

        _$failedField = 'confirmed';
        _confirmed?.build();
        _$failedField = 'published';
        _published?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AdminMobileReleaseDto',
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
