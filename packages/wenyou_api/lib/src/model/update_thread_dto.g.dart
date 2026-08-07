// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_thread_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UpdateThreadDtoCategoryEnum _$updateThreadDtoCategoryEnum_DEDUCTION =
    const UpdateThreadDtoCategoryEnum._('DEDUCTION');
const UpdateThreadDtoCategoryEnum _$updateThreadDtoCategoryEnum_NATION =
    const UpdateThreadDtoCategoryEnum._('NATION');
const UpdateThreadDtoCategoryEnum _$updateThreadDtoCategoryEnum_RPG =
    const UpdateThreadDtoCategoryEnum._('RPG');
const UpdateThreadDtoCategoryEnum
_$updateThreadDtoCategoryEnum_unknownDefaultOpenApi =
    const UpdateThreadDtoCategoryEnum._('unknownDefaultOpenApi');

UpdateThreadDtoCategoryEnum _$updateThreadDtoCategoryEnumValueOf(String name) {
  switch (name) {
    case 'DEDUCTION':
      return _$updateThreadDtoCategoryEnum_DEDUCTION;
    case 'NATION':
      return _$updateThreadDtoCategoryEnum_NATION;
    case 'RPG':
      return _$updateThreadDtoCategoryEnum_RPG;
    case 'unknownDefaultOpenApi':
      return _$updateThreadDtoCategoryEnum_unknownDefaultOpenApi;
    default:
      return _$updateThreadDtoCategoryEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UpdateThreadDtoCategoryEnum>
_$updateThreadDtoCategoryEnumValues =
    BuiltSet<UpdateThreadDtoCategoryEnum>(const <UpdateThreadDtoCategoryEnum>[
      _$updateThreadDtoCategoryEnum_DEDUCTION,
      _$updateThreadDtoCategoryEnum_NATION,
      _$updateThreadDtoCategoryEnum_RPG,
      _$updateThreadDtoCategoryEnum_unknownDefaultOpenApi,
    ]);

const UpdateThreadDtoStatusEnum _$updateThreadDtoStatusEnum_RECRUITING =
    const UpdateThreadDtoStatusEnum._('RECRUITING');
const UpdateThreadDtoStatusEnum _$updateThreadDtoStatusEnum_CLOSED =
    const UpdateThreadDtoStatusEnum._('CLOSED');
const UpdateThreadDtoStatusEnum _$updateThreadDtoStatusEnum_FINISHED =
    const UpdateThreadDtoStatusEnum._('FINISHED');
const UpdateThreadDtoStatusEnum
_$updateThreadDtoStatusEnum_unknownDefaultOpenApi =
    const UpdateThreadDtoStatusEnum._('unknownDefaultOpenApi');

UpdateThreadDtoStatusEnum _$updateThreadDtoStatusEnumValueOf(String name) {
  switch (name) {
    case 'RECRUITING':
      return _$updateThreadDtoStatusEnum_RECRUITING;
    case 'CLOSED':
      return _$updateThreadDtoStatusEnum_CLOSED;
    case 'FINISHED':
      return _$updateThreadDtoStatusEnum_FINISHED;
    case 'unknownDefaultOpenApi':
      return _$updateThreadDtoStatusEnum_unknownDefaultOpenApi;
    default:
      return _$updateThreadDtoStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UpdateThreadDtoStatusEnum> _$updateThreadDtoStatusEnumValues =
    BuiltSet<UpdateThreadDtoStatusEnum>(const <UpdateThreadDtoStatusEnum>[
      _$updateThreadDtoStatusEnum_RECRUITING,
      _$updateThreadDtoStatusEnum_CLOSED,
      _$updateThreadDtoStatusEnum_FINISHED,
      _$updateThreadDtoStatusEnum_unknownDefaultOpenApi,
    ]);

const UpdateThreadDtoVisibilityEnum _$updateThreadDtoVisibilityEnum_PUBLIC =
    const UpdateThreadDtoVisibilityEnum._('PUBLIC');
const UpdateThreadDtoVisibilityEnum _$updateThreadDtoVisibilityEnum_PRIVATE =
    const UpdateThreadDtoVisibilityEnum._('PRIVATE');
const UpdateThreadDtoVisibilityEnum
_$updateThreadDtoVisibilityEnum_unknownDefaultOpenApi =
    const UpdateThreadDtoVisibilityEnum._('unknownDefaultOpenApi');

UpdateThreadDtoVisibilityEnum _$updateThreadDtoVisibilityEnumValueOf(
  String name,
) {
  switch (name) {
    case 'PUBLIC':
      return _$updateThreadDtoVisibilityEnum_PUBLIC;
    case 'PRIVATE':
      return _$updateThreadDtoVisibilityEnum_PRIVATE;
    case 'unknownDefaultOpenApi':
      return _$updateThreadDtoVisibilityEnum_unknownDefaultOpenApi;
    default:
      return _$updateThreadDtoVisibilityEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<UpdateThreadDtoVisibilityEnum>
_$updateThreadDtoVisibilityEnumValues = BuiltSet<UpdateThreadDtoVisibilityEnum>(
  const <UpdateThreadDtoVisibilityEnum>[
    _$updateThreadDtoVisibilityEnum_PUBLIC,
    _$updateThreadDtoVisibilityEnum_PRIVATE,
    _$updateThreadDtoVisibilityEnum_unknownDefaultOpenApi,
  ],
);

Serializer<UpdateThreadDtoCategoryEnum>
_$updateThreadDtoCategoryEnumSerializer =
    _$UpdateThreadDtoCategoryEnumSerializer();
Serializer<UpdateThreadDtoStatusEnum> _$updateThreadDtoStatusEnumSerializer =
    _$UpdateThreadDtoStatusEnumSerializer();
Serializer<UpdateThreadDtoVisibilityEnum>
_$updateThreadDtoVisibilityEnumSerializer =
    _$UpdateThreadDtoVisibilityEnumSerializer();

class _$UpdateThreadDtoCategoryEnumSerializer
    implements PrimitiveSerializer<UpdateThreadDtoCategoryEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'DEDUCTION': 'DEDUCTION',
    'NATION': 'NATION',
    'RPG': 'RPG',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'DEDUCTION': 'DEDUCTION',
    'NATION': 'NATION',
    'RPG': 'RPG',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[UpdateThreadDtoCategoryEnum];
  @override
  final String wireName = 'UpdateThreadDtoCategoryEnum';

  @override
  Object serialize(
    Serializers serializers,
    UpdateThreadDtoCategoryEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UpdateThreadDtoCategoryEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UpdateThreadDtoCategoryEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UpdateThreadDtoStatusEnumSerializer
    implements PrimitiveSerializer<UpdateThreadDtoStatusEnum> {
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
  final Iterable<Type> types = const <Type>[UpdateThreadDtoStatusEnum];
  @override
  final String wireName = 'UpdateThreadDtoStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    UpdateThreadDtoStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UpdateThreadDtoStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UpdateThreadDtoStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UpdateThreadDtoVisibilityEnumSerializer
    implements PrimitiveSerializer<UpdateThreadDtoVisibilityEnum> {
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
  final Iterable<Type> types = const <Type>[UpdateThreadDtoVisibilityEnum];
  @override
  final String wireName = 'UpdateThreadDtoVisibilityEnum';

  @override
  Object serialize(
    Serializers serializers,
    UpdateThreadDtoVisibilityEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UpdateThreadDtoVisibilityEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UpdateThreadDtoVisibilityEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$UpdateThreadDto extends UpdateThreadDto {
  @override
  final String? title;
  @override
  final UpdateThreadDtoCategoryEnum? category;
  @override
  final UpdateThreadDtoStatusEnum? status;
  @override
  final UpdateThreadDtoVisibilityEnum? visibility;
  @override
  final bool? published;
  @override
  final num version;

  factory _$UpdateThreadDto([void Function(UpdateThreadDtoBuilder)? updates]) =>
      (UpdateThreadDtoBuilder()..update(updates))._build();

  _$UpdateThreadDto._({
    this.title,
    this.category,
    this.status,
    this.visibility,
    this.published,
    required this.version,
  }) : super._();
  @override
  UpdateThreadDto rebuild(void Function(UpdateThreadDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdateThreadDtoBuilder toBuilder() => UpdateThreadDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateThreadDto &&
        title == other.title &&
        category == other.category &&
        status == other.status &&
        visibility == other.visibility &&
        published == other.published &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, visibility.hashCode);
    _$hash = $jc(_$hash, published.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateThreadDto')
          ..add('title', title)
          ..add('category', category)
          ..add('status', status)
          ..add('visibility', visibility)
          ..add('published', published)
          ..add('version', version))
        .toString();
  }
}

class UpdateThreadDtoBuilder
    implements Builder<UpdateThreadDto, UpdateThreadDtoBuilder> {
  _$UpdateThreadDto? _$v;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  UpdateThreadDtoCategoryEnum? _category;
  UpdateThreadDtoCategoryEnum? get category => _$this._category;
  set category(UpdateThreadDtoCategoryEnum? category) =>
      _$this._category = category;

  UpdateThreadDtoStatusEnum? _status;
  UpdateThreadDtoStatusEnum? get status => _$this._status;
  set status(UpdateThreadDtoStatusEnum? status) => _$this._status = status;

  UpdateThreadDtoVisibilityEnum? _visibility;
  UpdateThreadDtoVisibilityEnum? get visibility => _$this._visibility;
  set visibility(UpdateThreadDtoVisibilityEnum? visibility) =>
      _$this._visibility = visibility;

  bool? _published;
  bool? get published => _$this._published;
  set published(bool? published) => _$this._published = published;

  num? _version;
  num? get version => _$this._version;
  set version(num? version) => _$this._version = version;

  UpdateThreadDtoBuilder() {
    UpdateThreadDto._defaults(this);
  }

  UpdateThreadDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _title = $v.title;
      _category = $v.category;
      _status = $v.status;
      _visibility = $v.visibility;
      _published = $v.published;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateThreadDto other) {
    _$v = other as _$UpdateThreadDto;
  }

  @override
  void update(void Function(UpdateThreadDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateThreadDto build() => _build();

  _$UpdateThreadDto _build() {
    final _$result =
        _$v ??
        _$UpdateThreadDto._(
          title: title,
          category: category,
          status: status,
          visibility: visibility,
          published: published,
          version: BuiltValueNullFieldError.checkNotNull(
            version,
            r'UpdateThreadDto',
            'version',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
