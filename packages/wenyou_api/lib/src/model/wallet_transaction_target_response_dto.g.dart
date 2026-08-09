// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_transaction_target_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const WalletTransactionTargetResponseDtoTypeEnum
_$walletTransactionTargetResponseDtoTypeEnum_THREAD =
    const WalletTransactionTargetResponseDtoTypeEnum._('THREAD');
const WalletTransactionTargetResponseDtoTypeEnum
_$walletTransactionTargetResponseDtoTypeEnum_USER =
    const WalletTransactionTargetResponseDtoTypeEnum._('USER');
const WalletTransactionTargetResponseDtoTypeEnum
_$walletTransactionTargetResponseDtoTypeEnum_MOMENT =
    const WalletTransactionTargetResponseDtoTypeEnum._('MOMENT');
const WalletTransactionTargetResponseDtoTypeEnum
_$walletTransactionTargetResponseDtoTypeEnum_NONE =
    const WalletTransactionTargetResponseDtoTypeEnum._('NONE');
const WalletTransactionTargetResponseDtoTypeEnum
_$walletTransactionTargetResponseDtoTypeEnum_unknownDefaultOpenApi =
    const WalletTransactionTargetResponseDtoTypeEnum._('unknownDefaultOpenApi');

WalletTransactionTargetResponseDtoTypeEnum
_$walletTransactionTargetResponseDtoTypeEnumValueOf(String name) {
  switch (name) {
    case 'THREAD':
      return _$walletTransactionTargetResponseDtoTypeEnum_THREAD;
    case 'USER':
      return _$walletTransactionTargetResponseDtoTypeEnum_USER;
    case 'MOMENT':
      return _$walletTransactionTargetResponseDtoTypeEnum_MOMENT;
    case 'NONE':
      return _$walletTransactionTargetResponseDtoTypeEnum_NONE;
    case 'unknownDefaultOpenApi':
      return _$walletTransactionTargetResponseDtoTypeEnum_unknownDefaultOpenApi;
    default:
      return _$walletTransactionTargetResponseDtoTypeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<WalletTransactionTargetResponseDtoTypeEnum>
_$walletTransactionTargetResponseDtoTypeEnumValues =
    BuiltSet<WalletTransactionTargetResponseDtoTypeEnum>(
      const <WalletTransactionTargetResponseDtoTypeEnum>[
        _$walletTransactionTargetResponseDtoTypeEnum_THREAD,
        _$walletTransactionTargetResponseDtoTypeEnum_USER,
        _$walletTransactionTargetResponseDtoTypeEnum_MOMENT,
        _$walletTransactionTargetResponseDtoTypeEnum_NONE,
        _$walletTransactionTargetResponseDtoTypeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<WalletTransactionTargetResponseDtoTypeEnum>
_$walletTransactionTargetResponseDtoTypeEnumSerializer =
    _$WalletTransactionTargetResponseDtoTypeEnumSerializer();

class _$WalletTransactionTargetResponseDtoTypeEnumSerializer
    implements PrimitiveSerializer<WalletTransactionTargetResponseDtoTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'THREAD': 'THREAD',
    'USER': 'USER',
    'MOMENT': 'MOMENT',
    'NONE': 'NONE',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'THREAD': 'THREAD',
    'USER': 'USER',
    'MOMENT': 'MOMENT',
    'NONE': 'NONE',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    WalletTransactionTargetResponseDtoTypeEnum,
  ];
  @override
  final String wireName = 'WalletTransactionTargetResponseDtoTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    WalletTransactionTargetResponseDtoTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  WalletTransactionTargetResponseDtoTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => WalletTransactionTargetResponseDtoTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$WalletTransactionTargetResponseDto
    extends WalletTransactionTargetResponseDto {
  @override
  final WalletTransactionTargetResponseDtoTypeEnum type;
  @override
  final String? id;
  @override
  final String? title;

  factory _$WalletTransactionTargetResponseDto([
    void Function(WalletTransactionTargetResponseDtoBuilder)? updates,
  ]) => (WalletTransactionTargetResponseDtoBuilder()..update(updates))._build();

  _$WalletTransactionTargetResponseDto._({
    required this.type,
    this.id,
    this.title,
  }) : super._();
  @override
  WalletTransactionTargetResponseDto rebuild(
    void Function(WalletTransactionTargetResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  WalletTransactionTargetResponseDtoBuilder toBuilder() =>
      WalletTransactionTargetResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WalletTransactionTargetResponseDto &&
        type == other.type &&
        id == other.id &&
        title == other.title;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WalletTransactionTargetResponseDto')
          ..add('type', type)
          ..add('id', id)
          ..add('title', title))
        .toString();
  }
}

class WalletTransactionTargetResponseDtoBuilder
    implements
        Builder<
          WalletTransactionTargetResponseDto,
          WalletTransactionTargetResponseDtoBuilder
        > {
  _$WalletTransactionTargetResponseDto? _$v;

  WalletTransactionTargetResponseDtoTypeEnum? _type;
  WalletTransactionTargetResponseDtoTypeEnum? get type => _$this._type;
  set type(WalletTransactionTargetResponseDtoTypeEnum? type) =>
      _$this._type = type;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  WalletTransactionTargetResponseDtoBuilder() {
    WalletTransactionTargetResponseDto._defaults(this);
  }

  WalletTransactionTargetResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _id = $v.id;
      _title = $v.title;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WalletTransactionTargetResponseDto other) {
    _$v = other as _$WalletTransactionTargetResponseDto;
  }

  @override
  void update(
    void Function(WalletTransactionTargetResponseDtoBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  WalletTransactionTargetResponseDto build() => _build();

  _$WalletTransactionTargetResponseDto _build() {
    final _$result =
        _$v ??
        _$WalletTransactionTargetResponseDto._(
          type: BuiltValueNullFieldError.checkNotNull(
            type,
            r'WalletTransactionTargetResponseDto',
            'type',
          ),
          id: id,
          title: title,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
