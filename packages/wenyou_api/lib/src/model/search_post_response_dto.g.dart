// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_post_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SearchPostResponseDtoKindEnum _$searchPostResponseDtoKindEnum_BODY =
    const SearchPostResponseDtoKindEnum._('BODY');
const SearchPostResponseDtoKindEnum _$searchPostResponseDtoKindEnum_FLOOR =
    const SearchPostResponseDtoKindEnum._('FLOOR');
const SearchPostResponseDtoKindEnum
_$searchPostResponseDtoKindEnum_unknownDefaultOpenApi =
    const SearchPostResponseDtoKindEnum._('unknownDefaultOpenApi');

SearchPostResponseDtoKindEnum _$searchPostResponseDtoKindEnumValueOf(
  String name,
) {
  switch (name) {
    case 'BODY':
      return _$searchPostResponseDtoKindEnum_BODY;
    case 'FLOOR':
      return _$searchPostResponseDtoKindEnum_FLOOR;
    case 'unknownDefaultOpenApi':
      return _$searchPostResponseDtoKindEnum_unknownDefaultOpenApi;
    default:
      return _$searchPostResponseDtoKindEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<SearchPostResponseDtoKindEnum>
_$searchPostResponseDtoKindEnumValues = BuiltSet<SearchPostResponseDtoKindEnum>(
  const <SearchPostResponseDtoKindEnum>[
    _$searchPostResponseDtoKindEnum_BODY,
    _$searchPostResponseDtoKindEnum_FLOOR,
    _$searchPostResponseDtoKindEnum_unknownDefaultOpenApi,
  ],
);

Serializer<SearchPostResponseDtoKindEnum>
_$searchPostResponseDtoKindEnumSerializer =
    _$SearchPostResponseDtoKindEnumSerializer();

class _$SearchPostResponseDtoKindEnumSerializer
    implements PrimitiveSerializer<SearchPostResponseDtoKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'BODY': 'BODY',
    'FLOOR': 'FLOOR',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'BODY': 'BODY',
    'FLOOR': 'FLOOR',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[SearchPostResponseDtoKindEnum];
  @override
  final String wireName = 'SearchPostResponseDtoKindEnum';

  @override
  Object serialize(
    Serializers serializers,
    SearchPostResponseDtoKindEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SearchPostResponseDtoKindEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SearchPostResponseDtoKindEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$SearchPostResponseDto extends SearchPostResponseDto {
  @override
  final SearchPostResponseDtoKindEnum kind;
  @override
  final String id;
  @override
  final num? floorNumber;
  @override
  final String? parentPostId;
  @override
  final String content;
  @override
  final DateTime createdAt;
  @override
  final SearchAuthorResponseDto author;
  @override
  final SearchThreadReferenceResponseDto thread;
  @override
  final SearchSubthreadReferenceResponseDto subthread;

  factory _$SearchPostResponseDto([
    void Function(SearchPostResponseDtoBuilder)? updates,
  ]) => (SearchPostResponseDtoBuilder()..update(updates))._build();

  _$SearchPostResponseDto._({
    required this.kind,
    required this.id,
    this.floorNumber,
    this.parentPostId,
    required this.content,
    required this.createdAt,
    required this.author,
    required this.thread,
    required this.subthread,
  }) : super._();
  @override
  SearchPostResponseDto rebuild(
    void Function(SearchPostResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SearchPostResponseDtoBuilder toBuilder() =>
      SearchPostResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SearchPostResponseDto &&
        kind == other.kind &&
        id == other.id &&
        floorNumber == other.floorNumber &&
        parentPostId == other.parentPostId &&
        content == other.content &&
        createdAt == other.createdAt &&
        author == other.author &&
        thread == other.thread &&
        subthread == other.subthread;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, floorNumber.hashCode);
    _$hash = $jc(_$hash, parentPostId.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, author.hashCode);
    _$hash = $jc(_$hash, thread.hashCode);
    _$hash = $jc(_$hash, subthread.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SearchPostResponseDto')
          ..add('kind', kind)
          ..add('id', id)
          ..add('floorNumber', floorNumber)
          ..add('parentPostId', parentPostId)
          ..add('content', content)
          ..add('createdAt', createdAt)
          ..add('author', author)
          ..add('thread', thread)
          ..add('subthread', subthread))
        .toString();
  }
}

class SearchPostResponseDtoBuilder
    implements Builder<SearchPostResponseDto, SearchPostResponseDtoBuilder> {
  _$SearchPostResponseDto? _$v;

  SearchPostResponseDtoKindEnum? _kind;
  SearchPostResponseDtoKindEnum? get kind => _$this._kind;
  set kind(SearchPostResponseDtoKindEnum? kind) => _$this._kind = kind;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  num? _floorNumber;
  num? get floorNumber => _$this._floorNumber;
  set floorNumber(num? floorNumber) => _$this._floorNumber = floorNumber;

  String? _parentPostId;
  String? get parentPostId => _$this._parentPostId;
  set parentPostId(String? parentPostId) => _$this._parentPostId = parentPostId;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  SearchAuthorResponseDtoBuilder? _author;
  SearchAuthorResponseDtoBuilder get author =>
      _$this._author ??= SearchAuthorResponseDtoBuilder();
  set author(SearchAuthorResponseDtoBuilder? author) => _$this._author = author;

  SearchThreadReferenceResponseDtoBuilder? _thread;
  SearchThreadReferenceResponseDtoBuilder get thread =>
      _$this._thread ??= SearchThreadReferenceResponseDtoBuilder();
  set thread(SearchThreadReferenceResponseDtoBuilder? thread) =>
      _$this._thread = thread;

  SearchSubthreadReferenceResponseDtoBuilder? _subthread;
  SearchSubthreadReferenceResponseDtoBuilder get subthread =>
      _$this._subthread ??= SearchSubthreadReferenceResponseDtoBuilder();
  set subthread(SearchSubthreadReferenceResponseDtoBuilder? subthread) =>
      _$this._subthread = subthread;

  SearchPostResponseDtoBuilder() {
    SearchPostResponseDto._defaults(this);
  }

  SearchPostResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _id = $v.id;
      _floorNumber = $v.floorNumber;
      _parentPostId = $v.parentPostId;
      _content = $v.content;
      _createdAt = $v.createdAt;
      _author = $v.author.toBuilder();
      _thread = $v.thread.toBuilder();
      _subthread = $v.subthread.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SearchPostResponseDto other) {
    _$v = other as _$SearchPostResponseDto;
  }

  @override
  void update(void Function(SearchPostResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SearchPostResponseDto build() => _build();

  _$SearchPostResponseDto _build() {
    _$SearchPostResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$SearchPostResponseDto._(
            kind: BuiltValueNullFieldError.checkNotNull(
              kind,
              r'SearchPostResponseDto',
              'kind',
            ),
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'SearchPostResponseDto',
              'id',
            ),
            floorNumber: floorNumber,
            parentPostId: parentPostId,
            content: BuiltValueNullFieldError.checkNotNull(
              content,
              r'SearchPostResponseDto',
              'content',
            ),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'SearchPostResponseDto',
              'createdAt',
            ),
            author: author.build(),
            thread: thread.build(),
            subthread: subthread.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'author';
        author.build();
        _$failedField = 'thread';
        thread.build();
        _$failedField = 'subthread';
        subthread.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SearchPostResponseDto',
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
