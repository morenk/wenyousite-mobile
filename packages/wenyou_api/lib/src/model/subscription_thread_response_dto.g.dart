// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_thread_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SubscriptionThreadResponseDtoCategoryEnum
_$subscriptionThreadResponseDtoCategoryEnum_DEDUCTION =
    const SubscriptionThreadResponseDtoCategoryEnum._('DEDUCTION');
const SubscriptionThreadResponseDtoCategoryEnum
_$subscriptionThreadResponseDtoCategoryEnum_NATION =
    const SubscriptionThreadResponseDtoCategoryEnum._('NATION');
const SubscriptionThreadResponseDtoCategoryEnum
_$subscriptionThreadResponseDtoCategoryEnum_RPG =
    const SubscriptionThreadResponseDtoCategoryEnum._('RPG');
const SubscriptionThreadResponseDtoCategoryEnum
_$subscriptionThreadResponseDtoCategoryEnum_unknownDefaultOpenApi =
    const SubscriptionThreadResponseDtoCategoryEnum._('unknownDefaultOpenApi');

SubscriptionThreadResponseDtoCategoryEnum
_$subscriptionThreadResponseDtoCategoryEnumValueOf(String name) {
  switch (name) {
    case 'DEDUCTION':
      return _$subscriptionThreadResponseDtoCategoryEnum_DEDUCTION;
    case 'NATION':
      return _$subscriptionThreadResponseDtoCategoryEnum_NATION;
    case 'RPG':
      return _$subscriptionThreadResponseDtoCategoryEnum_RPG;
    case 'unknownDefaultOpenApi':
      return _$subscriptionThreadResponseDtoCategoryEnum_unknownDefaultOpenApi;
    default:
      return _$subscriptionThreadResponseDtoCategoryEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<SubscriptionThreadResponseDtoCategoryEnum>
_$subscriptionThreadResponseDtoCategoryEnumValues =
    BuiltSet<SubscriptionThreadResponseDtoCategoryEnum>(
      const <SubscriptionThreadResponseDtoCategoryEnum>[
        _$subscriptionThreadResponseDtoCategoryEnum_DEDUCTION,
        _$subscriptionThreadResponseDtoCategoryEnum_NATION,
        _$subscriptionThreadResponseDtoCategoryEnum_RPG,
        _$subscriptionThreadResponseDtoCategoryEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<SubscriptionThreadResponseDtoCategoryEnum>
_$subscriptionThreadResponseDtoCategoryEnumSerializer =
    _$SubscriptionThreadResponseDtoCategoryEnumSerializer();

class _$SubscriptionThreadResponseDtoCategoryEnumSerializer
    implements PrimitiveSerializer<SubscriptionThreadResponseDtoCategoryEnum> {
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
    SubscriptionThreadResponseDtoCategoryEnum,
  ];
  @override
  final String wireName = 'SubscriptionThreadResponseDtoCategoryEnum';

  @override
  Object serialize(
    Serializers serializers,
    SubscriptionThreadResponseDtoCategoryEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SubscriptionThreadResponseDtoCategoryEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SubscriptionThreadResponseDtoCategoryEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$SubscriptionThreadResponseDto extends SubscriptionThreadResponseDto {
  @override
  final String id;
  @override
  final String title;
  @override
  final SubscriptionThreadResponseDtoCategoryEnum category;

  factory _$SubscriptionThreadResponseDto([
    void Function(SubscriptionThreadResponseDtoBuilder)? updates,
  ]) => (SubscriptionThreadResponseDtoBuilder()..update(updates))._build();

  _$SubscriptionThreadResponseDto._({
    required this.id,
    required this.title,
    required this.category,
  }) : super._();
  @override
  SubscriptionThreadResponseDto rebuild(
    void Function(SubscriptionThreadResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SubscriptionThreadResponseDtoBuilder toBuilder() =>
      SubscriptionThreadResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SubscriptionThreadResponseDto &&
        id == other.id &&
        title == other.title &&
        category == other.category;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SubscriptionThreadResponseDto')
          ..add('id', id)
          ..add('title', title)
          ..add('category', category))
        .toString();
  }
}

class SubscriptionThreadResponseDtoBuilder
    implements
        Builder<
          SubscriptionThreadResponseDto,
          SubscriptionThreadResponseDtoBuilder
        > {
  _$SubscriptionThreadResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  SubscriptionThreadResponseDtoCategoryEnum? _category;
  SubscriptionThreadResponseDtoCategoryEnum? get category => _$this._category;
  set category(SubscriptionThreadResponseDtoCategoryEnum? category) =>
      _$this._category = category;

  SubscriptionThreadResponseDtoBuilder() {
    SubscriptionThreadResponseDto._defaults(this);
  }

  SubscriptionThreadResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _category = $v.category;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SubscriptionThreadResponseDto other) {
    _$v = other as _$SubscriptionThreadResponseDto;
  }

  @override
  void update(void Function(SubscriptionThreadResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SubscriptionThreadResponseDto build() => _build();

  _$SubscriptionThreadResponseDto _build() {
    final _$result =
        _$v ??
        _$SubscriptionThreadResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'SubscriptionThreadResponseDto',
            'id',
          ),
          title: BuiltValueNullFieldError.checkNotNull(
            title,
            r'SubscriptionThreadResponseDto',
            'title',
          ),
          category: BuiltValueNullFieldError.checkNotNull(
            category,
            r'SubscriptionThreadResponseDto',
            'category',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
