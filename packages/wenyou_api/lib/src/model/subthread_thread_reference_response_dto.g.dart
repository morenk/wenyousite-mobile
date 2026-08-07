// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subthread_thread_reference_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SubthreadThreadReferenceResponseDtoVisibilityEnum
_$subthreadThreadReferenceResponseDtoVisibilityEnum_PUBLIC =
    const SubthreadThreadReferenceResponseDtoVisibilityEnum._('PUBLIC');
const SubthreadThreadReferenceResponseDtoVisibilityEnum
_$subthreadThreadReferenceResponseDtoVisibilityEnum_PRIVATE =
    const SubthreadThreadReferenceResponseDtoVisibilityEnum._('PRIVATE');
const SubthreadThreadReferenceResponseDtoVisibilityEnum
_$subthreadThreadReferenceResponseDtoVisibilityEnum_unknownDefaultOpenApi =
    const SubthreadThreadReferenceResponseDtoVisibilityEnum._(
      'unknownDefaultOpenApi',
    );

SubthreadThreadReferenceResponseDtoVisibilityEnum
_$subthreadThreadReferenceResponseDtoVisibilityEnumValueOf(String name) {
  switch (name) {
    case 'PUBLIC':
      return _$subthreadThreadReferenceResponseDtoVisibilityEnum_PUBLIC;
    case 'PRIVATE':
      return _$subthreadThreadReferenceResponseDtoVisibilityEnum_PRIVATE;
    case 'unknownDefaultOpenApi':
      return _$subthreadThreadReferenceResponseDtoVisibilityEnum_unknownDefaultOpenApi;
    default:
      return _$subthreadThreadReferenceResponseDtoVisibilityEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<SubthreadThreadReferenceResponseDtoVisibilityEnum>
_$subthreadThreadReferenceResponseDtoVisibilityEnumValues =
    BuiltSet<SubthreadThreadReferenceResponseDtoVisibilityEnum>(const <
      SubthreadThreadReferenceResponseDtoVisibilityEnum
    >[
      _$subthreadThreadReferenceResponseDtoVisibilityEnum_PUBLIC,
      _$subthreadThreadReferenceResponseDtoVisibilityEnum_PRIVATE,
      _$subthreadThreadReferenceResponseDtoVisibilityEnum_unknownDefaultOpenApi,
    ]);

Serializer<SubthreadThreadReferenceResponseDtoVisibilityEnum>
_$subthreadThreadReferenceResponseDtoVisibilityEnumSerializer =
    _$SubthreadThreadReferenceResponseDtoVisibilityEnumSerializer();

class _$SubthreadThreadReferenceResponseDtoVisibilityEnumSerializer
    implements
        PrimitiveSerializer<SubthreadThreadReferenceResponseDtoVisibilityEnum> {
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
    SubthreadThreadReferenceResponseDtoVisibilityEnum,
  ];
  @override
  final String wireName = 'SubthreadThreadReferenceResponseDtoVisibilityEnum';

  @override
  Object serialize(
    Serializers serializers,
    SubthreadThreadReferenceResponseDtoVisibilityEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SubthreadThreadReferenceResponseDtoVisibilityEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SubthreadThreadReferenceResponseDtoVisibilityEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$SubthreadThreadReferenceResponseDto
    extends SubthreadThreadReferenceResponseDto {
  @override
  final String id;
  @override
  final String? title;
  @override
  final String ownerId;
  @override
  final SubthreadThreadReferenceResponseDtoVisibilityEnum visibility;

  factory _$SubthreadThreadReferenceResponseDto([
    void Function(SubthreadThreadReferenceResponseDtoBuilder)? updates,
  ]) =>
      (SubthreadThreadReferenceResponseDtoBuilder()..update(updates))._build();

  _$SubthreadThreadReferenceResponseDto._({
    required this.id,
    this.title,
    required this.ownerId,
    required this.visibility,
  }) : super._();
  @override
  SubthreadThreadReferenceResponseDto rebuild(
    void Function(SubthreadThreadReferenceResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SubthreadThreadReferenceResponseDtoBuilder toBuilder() =>
      SubthreadThreadReferenceResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SubthreadThreadReferenceResponseDto &&
        id == other.id &&
        title == other.title &&
        ownerId == other.ownerId &&
        visibility == other.visibility;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, ownerId.hashCode);
    _$hash = $jc(_$hash, visibility.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SubthreadThreadReferenceResponseDto')
          ..add('id', id)
          ..add('title', title)
          ..add('ownerId', ownerId)
          ..add('visibility', visibility))
        .toString();
  }
}

class SubthreadThreadReferenceResponseDtoBuilder
    implements
        Builder<
          SubthreadThreadReferenceResponseDto,
          SubthreadThreadReferenceResponseDtoBuilder
        > {
  _$SubthreadThreadReferenceResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _ownerId;
  String? get ownerId => _$this._ownerId;
  set ownerId(String? ownerId) => _$this._ownerId = ownerId;

  SubthreadThreadReferenceResponseDtoVisibilityEnum? _visibility;
  SubthreadThreadReferenceResponseDtoVisibilityEnum? get visibility =>
      _$this._visibility;
  set visibility(
    SubthreadThreadReferenceResponseDtoVisibilityEnum? visibility,
  ) => _$this._visibility = visibility;

  SubthreadThreadReferenceResponseDtoBuilder() {
    SubthreadThreadReferenceResponseDto._defaults(this);
  }

  SubthreadThreadReferenceResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _ownerId = $v.ownerId;
      _visibility = $v.visibility;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SubthreadThreadReferenceResponseDto other) {
    _$v = other as _$SubthreadThreadReferenceResponseDto;
  }

  @override
  void update(
    void Function(SubthreadThreadReferenceResponseDtoBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  SubthreadThreadReferenceResponseDto build() => _build();

  _$SubthreadThreadReferenceResponseDto _build() {
    final _$result =
        _$v ??
        _$SubthreadThreadReferenceResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'SubthreadThreadReferenceResponseDto',
            'id',
          ),
          title: title,
          ownerId: BuiltValueNullFieldError.checkNotNull(
            ownerId,
            r'SubthreadThreadReferenceResponseDto',
            'ownerId',
          ),
          visibility: BuiltValueNullFieldError.checkNotNull(
            visibility,
            r'SubthreadThreadReferenceResponseDto',
            'visibility',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
