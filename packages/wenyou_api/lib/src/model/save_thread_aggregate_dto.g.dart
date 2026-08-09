// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_thread_aggregate_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SaveThreadAggregateDtoStatusEnum
_$saveThreadAggregateDtoStatusEnum_RECRUITING =
    const SaveThreadAggregateDtoStatusEnum._('RECRUITING');
const SaveThreadAggregateDtoStatusEnum
_$saveThreadAggregateDtoStatusEnum_CLOSED =
    const SaveThreadAggregateDtoStatusEnum._('CLOSED');
const SaveThreadAggregateDtoStatusEnum
_$saveThreadAggregateDtoStatusEnum_FINISHED =
    const SaveThreadAggregateDtoStatusEnum._('FINISHED');
const SaveThreadAggregateDtoStatusEnum
_$saveThreadAggregateDtoStatusEnum_unknownDefaultOpenApi =
    const SaveThreadAggregateDtoStatusEnum._('unknownDefaultOpenApi');

SaveThreadAggregateDtoStatusEnum _$saveThreadAggregateDtoStatusEnumValueOf(
  String name,
) {
  switch (name) {
    case 'RECRUITING':
      return _$saveThreadAggregateDtoStatusEnum_RECRUITING;
    case 'CLOSED':
      return _$saveThreadAggregateDtoStatusEnum_CLOSED;
    case 'FINISHED':
      return _$saveThreadAggregateDtoStatusEnum_FINISHED;
    case 'unknownDefaultOpenApi':
      return _$saveThreadAggregateDtoStatusEnum_unknownDefaultOpenApi;
    default:
      return _$saveThreadAggregateDtoStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<SaveThreadAggregateDtoStatusEnum>
_$saveThreadAggregateDtoStatusEnumValues =
    BuiltSet<SaveThreadAggregateDtoStatusEnum>(
      const <SaveThreadAggregateDtoStatusEnum>[
        _$saveThreadAggregateDtoStatusEnum_RECRUITING,
        _$saveThreadAggregateDtoStatusEnum_CLOSED,
        _$saveThreadAggregateDtoStatusEnum_FINISHED,
        _$saveThreadAggregateDtoStatusEnum_unknownDefaultOpenApi,
      ],
    );

const SaveThreadAggregateDtoVisibilityEnum
_$saveThreadAggregateDtoVisibilityEnum_PUBLIC =
    const SaveThreadAggregateDtoVisibilityEnum._('PUBLIC');
const SaveThreadAggregateDtoVisibilityEnum
_$saveThreadAggregateDtoVisibilityEnum_PRIVATE =
    const SaveThreadAggregateDtoVisibilityEnum._('PRIVATE');
const SaveThreadAggregateDtoVisibilityEnum
_$saveThreadAggregateDtoVisibilityEnum_unknownDefaultOpenApi =
    const SaveThreadAggregateDtoVisibilityEnum._('unknownDefaultOpenApi');

SaveThreadAggregateDtoVisibilityEnum
_$saveThreadAggregateDtoVisibilityEnumValueOf(String name) {
  switch (name) {
    case 'PUBLIC':
      return _$saveThreadAggregateDtoVisibilityEnum_PUBLIC;
    case 'PRIVATE':
      return _$saveThreadAggregateDtoVisibilityEnum_PRIVATE;
    case 'unknownDefaultOpenApi':
      return _$saveThreadAggregateDtoVisibilityEnum_unknownDefaultOpenApi;
    default:
      return _$saveThreadAggregateDtoVisibilityEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<SaveThreadAggregateDtoVisibilityEnum>
_$saveThreadAggregateDtoVisibilityEnumValues =
    BuiltSet<SaveThreadAggregateDtoVisibilityEnum>(
      const <SaveThreadAggregateDtoVisibilityEnum>[
        _$saveThreadAggregateDtoVisibilityEnum_PUBLIC,
        _$saveThreadAggregateDtoVisibilityEnum_PRIVATE,
        _$saveThreadAggregateDtoVisibilityEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<SaveThreadAggregateDtoStatusEnum>
_$saveThreadAggregateDtoStatusEnumSerializer =
    _$SaveThreadAggregateDtoStatusEnumSerializer();
Serializer<SaveThreadAggregateDtoVisibilityEnum>
_$saveThreadAggregateDtoVisibilityEnumSerializer =
    _$SaveThreadAggregateDtoVisibilityEnumSerializer();

class _$SaveThreadAggregateDtoStatusEnumSerializer
    implements PrimitiveSerializer<SaveThreadAggregateDtoStatusEnum> {
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
  final Iterable<Type> types = const <Type>[SaveThreadAggregateDtoStatusEnum];
  @override
  final String wireName = 'SaveThreadAggregateDtoStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    SaveThreadAggregateDtoStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SaveThreadAggregateDtoStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SaveThreadAggregateDtoStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$SaveThreadAggregateDtoVisibilityEnumSerializer
    implements PrimitiveSerializer<SaveThreadAggregateDtoVisibilityEnum> {
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
    SaveThreadAggregateDtoVisibilityEnum,
  ];
  @override
  final String wireName = 'SaveThreadAggregateDtoVisibilityEnum';

  @override
  Object serialize(
    Serializers serializers,
    SaveThreadAggregateDtoVisibilityEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SaveThreadAggregateDtoVisibilityEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SaveThreadAggregateDtoVisibilityEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$SaveThreadAggregateDto extends SaveThreadAggregateDto {
  @override
  final String? title;
  @override
  final String? category;
  @override
  final SaveThreadAggregateDtoStatusEnum? status;
  @override
  final SaveThreadAggregateDtoVisibilityEnum? visibility;
  @override
  final bool? published;
  @override
  final num version;
  @override
  final num defaultSubthreadVersion;
  @override
  final num? bodyVersion;
  @override
  final String content;
  @override
  final BuiltList<String> tagNames;

  factory _$SaveThreadAggregateDto([
    void Function(SaveThreadAggregateDtoBuilder)? updates,
  ]) => (SaveThreadAggregateDtoBuilder()..update(updates))._build();

  _$SaveThreadAggregateDto._({
    this.title,
    this.category,
    this.status,
    this.visibility,
    this.published,
    required this.version,
    required this.defaultSubthreadVersion,
    this.bodyVersion,
    required this.content,
    required this.tagNames,
  }) : super._();
  @override
  SaveThreadAggregateDto rebuild(
    void Function(SaveThreadAggregateDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SaveThreadAggregateDtoBuilder toBuilder() =>
      SaveThreadAggregateDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SaveThreadAggregateDto &&
        title == other.title &&
        category == other.category &&
        status == other.status &&
        visibility == other.visibility &&
        published == other.published &&
        version == other.version &&
        defaultSubthreadVersion == other.defaultSubthreadVersion &&
        bodyVersion == other.bodyVersion &&
        content == other.content &&
        tagNames == other.tagNames;
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
    _$hash = $jc(_$hash, defaultSubthreadVersion.hashCode);
    _$hash = $jc(_$hash, bodyVersion.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, tagNames.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SaveThreadAggregateDto')
          ..add('title', title)
          ..add('category', category)
          ..add('status', status)
          ..add('visibility', visibility)
          ..add('published', published)
          ..add('version', version)
          ..add('defaultSubthreadVersion', defaultSubthreadVersion)
          ..add('bodyVersion', bodyVersion)
          ..add('content', content)
          ..add('tagNames', tagNames))
        .toString();
  }
}

class SaveThreadAggregateDtoBuilder
    implements Builder<SaveThreadAggregateDto, SaveThreadAggregateDtoBuilder> {
  _$SaveThreadAggregateDto? _$v;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _category;
  String? get category => _$this._category;
  set category(String? category) => _$this._category = category;

  SaveThreadAggregateDtoStatusEnum? _status;
  SaveThreadAggregateDtoStatusEnum? get status => _$this._status;
  set status(SaveThreadAggregateDtoStatusEnum? status) =>
      _$this._status = status;

  SaveThreadAggregateDtoVisibilityEnum? _visibility;
  SaveThreadAggregateDtoVisibilityEnum? get visibility => _$this._visibility;
  set visibility(SaveThreadAggregateDtoVisibilityEnum? visibility) =>
      _$this._visibility = visibility;

  bool? _published;
  bool? get published => _$this._published;
  set published(bool? published) => _$this._published = published;

  num? _version;
  num? get version => _$this._version;
  set version(num? version) => _$this._version = version;

  num? _defaultSubthreadVersion;
  num? get defaultSubthreadVersion => _$this._defaultSubthreadVersion;
  set defaultSubthreadVersion(num? defaultSubthreadVersion) =>
      _$this._defaultSubthreadVersion = defaultSubthreadVersion;

  num? _bodyVersion;
  num? get bodyVersion => _$this._bodyVersion;
  set bodyVersion(num? bodyVersion) => _$this._bodyVersion = bodyVersion;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  ListBuilder<String>? _tagNames;
  ListBuilder<String> get tagNames =>
      _$this._tagNames ??= ListBuilder<String>();
  set tagNames(ListBuilder<String>? tagNames) => _$this._tagNames = tagNames;

  SaveThreadAggregateDtoBuilder() {
    SaveThreadAggregateDto._defaults(this);
  }

  SaveThreadAggregateDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _title = $v.title;
      _category = $v.category;
      _status = $v.status;
      _visibility = $v.visibility;
      _published = $v.published;
      _version = $v.version;
      _defaultSubthreadVersion = $v.defaultSubthreadVersion;
      _bodyVersion = $v.bodyVersion;
      _content = $v.content;
      _tagNames = $v.tagNames.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SaveThreadAggregateDto other) {
    _$v = other as _$SaveThreadAggregateDto;
  }

  @override
  void update(void Function(SaveThreadAggregateDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SaveThreadAggregateDto build() => _build();

  _$SaveThreadAggregateDto _build() {
    _$SaveThreadAggregateDto _$result;
    try {
      _$result =
          _$v ??
          _$SaveThreadAggregateDto._(
            title: title,
            category: category,
            status: status,
            visibility: visibility,
            published: published,
            version: BuiltValueNullFieldError.checkNotNull(
              version,
              r'SaveThreadAggregateDto',
              'version',
            ),
            defaultSubthreadVersion: BuiltValueNullFieldError.checkNotNull(
              defaultSubthreadVersion,
              r'SaveThreadAggregateDto',
              'defaultSubthreadVersion',
            ),
            bodyVersion: bodyVersion,
            content: BuiltValueNullFieldError.checkNotNull(
              content,
              r'SaveThreadAggregateDto',
              'content',
            ),
            tagNames: tagNames.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'tagNames';
        tagNames.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SaveThreadAggregateDto',
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
