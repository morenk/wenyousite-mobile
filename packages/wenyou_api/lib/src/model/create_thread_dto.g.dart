// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_thread_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CreateThreadDtoVisibilityEnum _$createThreadDtoVisibilityEnum_PUBLIC =
    const CreateThreadDtoVisibilityEnum._('PUBLIC');
const CreateThreadDtoVisibilityEnum _$createThreadDtoVisibilityEnum_PRIVATE =
    const CreateThreadDtoVisibilityEnum._('PRIVATE');
const CreateThreadDtoVisibilityEnum
_$createThreadDtoVisibilityEnum_unknownDefaultOpenApi =
    const CreateThreadDtoVisibilityEnum._('unknownDefaultOpenApi');

CreateThreadDtoVisibilityEnum _$createThreadDtoVisibilityEnumValueOf(
  String name,
) {
  switch (name) {
    case 'PUBLIC':
      return _$createThreadDtoVisibilityEnum_PUBLIC;
    case 'PRIVATE':
      return _$createThreadDtoVisibilityEnum_PRIVATE;
    case 'unknownDefaultOpenApi':
      return _$createThreadDtoVisibilityEnum_unknownDefaultOpenApi;
    default:
      return _$createThreadDtoVisibilityEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<CreateThreadDtoVisibilityEnum>
_$createThreadDtoVisibilityEnumValues = BuiltSet<CreateThreadDtoVisibilityEnum>(
  const <CreateThreadDtoVisibilityEnum>[
    _$createThreadDtoVisibilityEnum_PUBLIC,
    _$createThreadDtoVisibilityEnum_PRIVATE,
    _$createThreadDtoVisibilityEnum_unknownDefaultOpenApi,
  ],
);

Serializer<CreateThreadDtoVisibilityEnum>
_$createThreadDtoVisibilityEnumSerializer =
    _$CreateThreadDtoVisibilityEnumSerializer();

class _$CreateThreadDtoVisibilityEnumSerializer
    implements PrimitiveSerializer<CreateThreadDtoVisibilityEnum> {
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
  final Iterable<Type> types = const <Type>[CreateThreadDtoVisibilityEnum];
  @override
  final String wireName = 'CreateThreadDtoVisibilityEnum';

  @override
  Object serialize(
    Serializers serializers,
    CreateThreadDtoVisibilityEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  CreateThreadDtoVisibilityEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => CreateThreadDtoVisibilityEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$CreateThreadDto extends CreateThreadDto {
  @override
  final String? clientRequestId;
  @override
  final String? title;
  @override
  final String? category;
  @override
  final String? content;
  @override
  final String? subthreadTitle;
  @override
  final BuiltList<String>? tagNames;
  @override
  final CreateThreadDtoVisibilityEnum? visibility;

  factory _$CreateThreadDto([void Function(CreateThreadDtoBuilder)? updates]) =>
      (CreateThreadDtoBuilder()..update(updates))._build();

  _$CreateThreadDto._({
    this.clientRequestId,
    this.title,
    this.category,
    this.content,
    this.subthreadTitle,
    this.tagNames,
    this.visibility,
  }) : super._();
  @override
  CreateThreadDto rebuild(void Function(CreateThreadDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateThreadDtoBuilder toBuilder() => CreateThreadDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateThreadDto &&
        clientRequestId == other.clientRequestId &&
        title == other.title &&
        category == other.category &&
        content == other.content &&
        subthreadTitle == other.subthreadTitle &&
        tagNames == other.tagNames &&
        visibility == other.visibility;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientRequestId.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, subthreadTitle.hashCode);
    _$hash = $jc(_$hash, tagNames.hashCode);
    _$hash = $jc(_$hash, visibility.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateThreadDto')
          ..add('clientRequestId', clientRequestId)
          ..add('title', title)
          ..add('category', category)
          ..add('content', content)
          ..add('subthreadTitle', subthreadTitle)
          ..add('tagNames', tagNames)
          ..add('visibility', visibility))
        .toString();
  }
}

class CreateThreadDtoBuilder
    implements Builder<CreateThreadDto, CreateThreadDtoBuilder> {
  _$CreateThreadDto? _$v;

  String? _clientRequestId;
  String? get clientRequestId => _$this._clientRequestId;
  set clientRequestId(String? clientRequestId) =>
      _$this._clientRequestId = clientRequestId;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _category;
  String? get category => _$this._category;
  set category(String? category) => _$this._category = category;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  String? _subthreadTitle;
  String? get subthreadTitle => _$this._subthreadTitle;
  set subthreadTitle(String? subthreadTitle) =>
      _$this._subthreadTitle = subthreadTitle;

  ListBuilder<String>? _tagNames;
  ListBuilder<String> get tagNames =>
      _$this._tagNames ??= ListBuilder<String>();
  set tagNames(ListBuilder<String>? tagNames) => _$this._tagNames = tagNames;

  CreateThreadDtoVisibilityEnum? _visibility;
  CreateThreadDtoVisibilityEnum? get visibility => _$this._visibility;
  set visibility(CreateThreadDtoVisibilityEnum? visibility) =>
      _$this._visibility = visibility;

  CreateThreadDtoBuilder() {
    CreateThreadDto._defaults(this);
  }

  CreateThreadDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientRequestId = $v.clientRequestId;
      _title = $v.title;
      _category = $v.category;
      _content = $v.content;
      _subthreadTitle = $v.subthreadTitle;
      _tagNames = $v.tagNames?.toBuilder();
      _visibility = $v.visibility;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateThreadDto other) {
    _$v = other as _$CreateThreadDto;
  }

  @override
  void update(void Function(CreateThreadDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateThreadDto build() => _build();

  _$CreateThreadDto _build() {
    _$CreateThreadDto _$result;
    try {
      _$result =
          _$v ??
          _$CreateThreadDto._(
            clientRequestId: clientRequestId,
            title: title,
            category: category,
            content: content,
            subthreadTitle: subthreadTitle,
            tagNames: _tagNames?.build(),
            visibility: visibility,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'tagNames';
        _tagNames?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'CreateThreadDto',
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
