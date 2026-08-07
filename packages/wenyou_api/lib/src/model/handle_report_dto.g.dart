// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'handle_report_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const HandleReportDtoStatusEnum _$handleReportDtoStatusEnum_RESOLVED =
    const HandleReportDtoStatusEnum._('RESOLVED');
const HandleReportDtoStatusEnum _$handleReportDtoStatusEnum_DISMISSED =
    const HandleReportDtoStatusEnum._('DISMISSED');
const HandleReportDtoStatusEnum
_$handleReportDtoStatusEnum_unknownDefaultOpenApi =
    const HandleReportDtoStatusEnum._('unknownDefaultOpenApi');

HandleReportDtoStatusEnum _$handleReportDtoStatusEnumValueOf(String name) {
  switch (name) {
    case 'RESOLVED':
      return _$handleReportDtoStatusEnum_RESOLVED;
    case 'DISMISSED':
      return _$handleReportDtoStatusEnum_DISMISSED;
    case 'unknownDefaultOpenApi':
      return _$handleReportDtoStatusEnum_unknownDefaultOpenApi;
    default:
      return _$handleReportDtoStatusEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<HandleReportDtoStatusEnum> _$handleReportDtoStatusEnumValues =
    BuiltSet<HandleReportDtoStatusEnum>(const <HandleReportDtoStatusEnum>[
      _$handleReportDtoStatusEnum_RESOLVED,
      _$handleReportDtoStatusEnum_DISMISSED,
      _$handleReportDtoStatusEnum_unknownDefaultOpenApi,
    ]);

Serializer<HandleReportDtoStatusEnum> _$handleReportDtoStatusEnumSerializer =
    _$HandleReportDtoStatusEnumSerializer();

class _$HandleReportDtoStatusEnumSerializer
    implements PrimitiveSerializer<HandleReportDtoStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'RESOLVED': 'RESOLVED',
    'DISMISSED': 'DISMISSED',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'RESOLVED': 'RESOLVED',
    'DISMISSED': 'DISMISSED',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[HandleReportDtoStatusEnum];
  @override
  final String wireName = 'HandleReportDtoStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    HandleReportDtoStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  HandleReportDtoStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => HandleReportDtoStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$HandleReportDto extends HandleReportDto {
  @override
  final HandleReportDtoStatusEnum status;

  factory _$HandleReportDto([void Function(HandleReportDtoBuilder)? updates]) =>
      (HandleReportDtoBuilder()..update(updates))._build();

  _$HandleReportDto._({required this.status}) : super._();
  @override
  HandleReportDto rebuild(void Function(HandleReportDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  HandleReportDtoBuilder toBuilder() => HandleReportDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is HandleReportDto && status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'HandleReportDto',
    )..add('status', status)).toString();
  }
}

class HandleReportDtoBuilder
    implements Builder<HandleReportDto, HandleReportDtoBuilder> {
  _$HandleReportDto? _$v;

  HandleReportDtoStatusEnum? _status;
  HandleReportDtoStatusEnum? get status => _$this._status;
  set status(HandleReportDtoStatusEnum? status) => _$this._status = status;

  HandleReportDtoBuilder() {
    HandleReportDto._defaults(this);
  }

  HandleReportDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(HandleReportDto other) {
    _$v = other as _$HandleReportDto;
  }

  @override
  void update(void Function(HandleReportDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  HandleReportDto build() => _build();

  _$HandleReportDto _build() {
    final _$result =
        _$v ??
        _$HandleReportDto._(
          status: BuiltValueNullFieldError.checkNotNull(
            status,
            r'HandleReportDto',
            'status',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
