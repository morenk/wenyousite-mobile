// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_thread_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SearchThreadResponseDtoCategoryEnum
_$searchThreadResponseDtoCategoryEnum_DEDUCTION =
    const SearchThreadResponseDtoCategoryEnum._('DEDUCTION');
const SearchThreadResponseDtoCategoryEnum
_$searchThreadResponseDtoCategoryEnum_NATION =
    const SearchThreadResponseDtoCategoryEnum._('NATION');
const SearchThreadResponseDtoCategoryEnum
_$searchThreadResponseDtoCategoryEnum_RPG =
    const SearchThreadResponseDtoCategoryEnum._('RPG');
const SearchThreadResponseDtoCategoryEnum
_$searchThreadResponseDtoCategoryEnum_unknownDefaultOpenApi =
    const SearchThreadResponseDtoCategoryEnum._('unknownDefaultOpenApi');

SearchThreadResponseDtoCategoryEnum
_$searchThreadResponseDtoCategoryEnumValueOf(String name) {
  switch (name) {
    case 'DEDUCTION':
      return _$searchThreadResponseDtoCategoryEnum_DEDUCTION;
    case 'NATION':
      return _$searchThreadResponseDtoCategoryEnum_NATION;
    case 'RPG':
      return _$searchThreadResponseDtoCategoryEnum_RPG;
    case 'unknownDefaultOpenApi':
      return _$searchThreadResponseDtoCategoryEnum_unknownDefaultOpenApi;
    default:
      return _$searchThreadResponseDtoCategoryEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<SearchThreadResponseDtoCategoryEnum>
_$searchThreadResponseDtoCategoryEnumValues =
    BuiltSet<SearchThreadResponseDtoCategoryEnum>(
      const <SearchThreadResponseDtoCategoryEnum>[
        _$searchThreadResponseDtoCategoryEnum_DEDUCTION,
        _$searchThreadResponseDtoCategoryEnum_NATION,
        _$searchThreadResponseDtoCategoryEnum_RPG,
        _$searchThreadResponseDtoCategoryEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<SearchThreadResponseDtoCategoryEnum>
_$searchThreadResponseDtoCategoryEnumSerializer =
    _$SearchThreadResponseDtoCategoryEnumSerializer();

class _$SearchThreadResponseDtoCategoryEnumSerializer
    implements PrimitiveSerializer<SearchThreadResponseDtoCategoryEnum> {
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
  final Iterable<Type> types = const <Type>[
    SearchThreadResponseDtoCategoryEnum,
  ];
  @override
  final String wireName = 'SearchThreadResponseDtoCategoryEnum';

  @override
  Object serialize(
    Serializers serializers,
    SearchThreadResponseDtoCategoryEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SearchThreadResponseDtoCategoryEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SearchThreadResponseDtoCategoryEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$SearchThreadResponseDto extends SearchThreadResponseDto {
  @override
  final String id;
  @override
  final String title;
  @override
  final SearchThreadResponseDtoCategoryEnum category;
  @override
  final DateTime createdAt;
  @override
  final SearchThreadOwnerResponseDto owner;
  @override
  final SearchThreadCountResponseDto count;

  factory _$SearchThreadResponseDto([
    void Function(SearchThreadResponseDtoBuilder)? updates,
  ]) => (SearchThreadResponseDtoBuilder()..update(updates))._build();

  _$SearchThreadResponseDto._({
    required this.id,
    required this.title,
    required this.category,
    required this.createdAt,
    required this.owner,
    required this.count,
  }) : super._();
  @override
  SearchThreadResponseDto rebuild(
    void Function(SearchThreadResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SearchThreadResponseDtoBuilder toBuilder() =>
      SearchThreadResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SearchThreadResponseDto &&
        id == other.id &&
        title == other.title &&
        category == other.category &&
        createdAt == other.createdAt &&
        owner == other.owner &&
        count == other.count;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, owner.hashCode);
    _$hash = $jc(_$hash, count.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SearchThreadResponseDto')
          ..add('id', id)
          ..add('title', title)
          ..add('category', category)
          ..add('createdAt', createdAt)
          ..add('owner', owner)
          ..add('count', count))
        .toString();
  }
}

class SearchThreadResponseDtoBuilder
    implements
        Builder<SearchThreadResponseDto, SearchThreadResponseDtoBuilder> {
  _$SearchThreadResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  SearchThreadResponseDtoCategoryEnum? _category;
  SearchThreadResponseDtoCategoryEnum? get category => _$this._category;
  set category(SearchThreadResponseDtoCategoryEnum? category) =>
      _$this._category = category;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  SearchThreadOwnerResponseDtoBuilder? _owner;
  SearchThreadOwnerResponseDtoBuilder get owner =>
      _$this._owner ??= SearchThreadOwnerResponseDtoBuilder();
  set owner(SearchThreadOwnerResponseDtoBuilder? owner) =>
      _$this._owner = owner;

  SearchThreadCountResponseDtoBuilder? _count;
  SearchThreadCountResponseDtoBuilder get count =>
      _$this._count ??= SearchThreadCountResponseDtoBuilder();
  set count(SearchThreadCountResponseDtoBuilder? count) =>
      _$this._count = count;

  SearchThreadResponseDtoBuilder() {
    SearchThreadResponseDto._defaults(this);
  }

  SearchThreadResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _category = $v.category;
      _createdAt = $v.createdAt;
      _owner = $v.owner.toBuilder();
      _count = $v.count.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SearchThreadResponseDto other) {
    _$v = other as _$SearchThreadResponseDto;
  }

  @override
  void update(void Function(SearchThreadResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SearchThreadResponseDto build() => _build();

  _$SearchThreadResponseDto _build() {
    _$SearchThreadResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$SearchThreadResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'SearchThreadResponseDto',
              'id',
            ),
            title: BuiltValueNullFieldError.checkNotNull(
              title,
              r'SearchThreadResponseDto',
              'title',
            ),
            category: BuiltValueNullFieldError.checkNotNull(
              category,
              r'SearchThreadResponseDto',
              'category',
            ),
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'SearchThreadResponseDto',
              'createdAt',
            ),
            owner: owner.build(),
            count: count.build(),
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
          r'SearchThreadResponseDto',
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
