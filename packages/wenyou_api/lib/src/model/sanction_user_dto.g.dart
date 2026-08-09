// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sanction_user_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SanctionUserDtoTypeEnum _$sanctionUserDtoTypeEnum_SUSPENSION =
    const SanctionUserDtoTypeEnum._('SUSPENSION');
const SanctionUserDtoTypeEnum _$sanctionUserDtoTypeEnum_BAN =
    const SanctionUserDtoTypeEnum._('BAN');
const SanctionUserDtoTypeEnum _$sanctionUserDtoTypeEnum_unknownDefaultOpenApi =
    const SanctionUserDtoTypeEnum._('unknownDefaultOpenApi');

SanctionUserDtoTypeEnum _$sanctionUserDtoTypeEnumValueOf(String name) {
  switch (name) {
    case 'SUSPENSION':
      return _$sanctionUserDtoTypeEnum_SUSPENSION;
    case 'BAN':
      return _$sanctionUserDtoTypeEnum_BAN;
    case 'unknownDefaultOpenApi':
      return _$sanctionUserDtoTypeEnum_unknownDefaultOpenApi;
    default:
      return _$sanctionUserDtoTypeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<SanctionUserDtoTypeEnum> _$sanctionUserDtoTypeEnumValues =
    BuiltSet<SanctionUserDtoTypeEnum>(const <SanctionUserDtoTypeEnum>[
      _$sanctionUserDtoTypeEnum_SUSPENSION,
      _$sanctionUserDtoTypeEnum_BAN,
      _$sanctionUserDtoTypeEnum_unknownDefaultOpenApi,
    ]);

Serializer<SanctionUserDtoTypeEnum> _$sanctionUserDtoTypeEnumSerializer =
    _$SanctionUserDtoTypeEnumSerializer();

class _$SanctionUserDtoTypeEnumSerializer
    implements PrimitiveSerializer<SanctionUserDtoTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'SUSPENSION': 'SUSPENSION',
    'BAN': 'BAN',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'SUSPENSION': 'SUSPENSION',
    'BAN': 'BAN',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[SanctionUserDtoTypeEnum];
  @override
  final String wireName = 'SanctionUserDtoTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    SanctionUserDtoTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SanctionUserDtoTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SanctionUserDtoTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$SanctionUserDto extends SanctionUserDto {
  @override
  final SanctionUserDtoTypeEnum type;
  @override
  final String reason;
  @override
  final DateTime? endsAt;

  factory _$SanctionUserDto([void Function(SanctionUserDtoBuilder)? updates]) =>
      (SanctionUserDtoBuilder()..update(updates))._build();

  _$SanctionUserDto._({required this.type, required this.reason, this.endsAt})
    : super._();
  @override
  SanctionUserDto rebuild(void Function(SanctionUserDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SanctionUserDtoBuilder toBuilder() => SanctionUserDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SanctionUserDto &&
        type == other.type &&
        reason == other.reason &&
        endsAt == other.endsAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, endsAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SanctionUserDto')
          ..add('type', type)
          ..add('reason', reason)
          ..add('endsAt', endsAt))
        .toString();
  }
}

class SanctionUserDtoBuilder
    implements Builder<SanctionUserDto, SanctionUserDtoBuilder> {
  _$SanctionUserDto? _$v;

  SanctionUserDtoTypeEnum? _type;
  SanctionUserDtoTypeEnum? get type => _$this._type;
  set type(SanctionUserDtoTypeEnum? type) => _$this._type = type;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  DateTime? _endsAt;
  DateTime? get endsAt => _$this._endsAt;
  set endsAt(DateTime? endsAt) => _$this._endsAt = endsAt;

  SanctionUserDtoBuilder() {
    SanctionUserDto._defaults(this);
  }

  SanctionUserDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _reason = $v.reason;
      _endsAt = $v.endsAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SanctionUserDto other) {
    _$v = other as _$SanctionUserDto;
  }

  @override
  void update(void Function(SanctionUserDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SanctionUserDto build() => _build();

  _$SanctionUserDto _build() {
    final _$result =
        _$v ??
        _$SanctionUserDto._(
          type: BuiltValueNullFieldError.checkNotNull(
            type,
            r'SanctionUserDto',
            'type',
          ),
          reason: BuiltValueNullFieldError.checkNotNull(
            reason,
            r'SanctionUserDto',
            'reason',
          ),
          endsAt: endsAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
