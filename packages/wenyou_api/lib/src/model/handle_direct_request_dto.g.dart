// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'handle_direct_request_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const HandleDirectRequestDtoActionEnum
_$handleDirectRequestDtoActionEnum_ACCEPT =
    const HandleDirectRequestDtoActionEnum._('ACCEPT');
const HandleDirectRequestDtoActionEnum
_$handleDirectRequestDtoActionEnum_DECLINE =
    const HandleDirectRequestDtoActionEnum._('DECLINE');
const HandleDirectRequestDtoActionEnum
_$handleDirectRequestDtoActionEnum_unknownDefaultOpenApi =
    const HandleDirectRequestDtoActionEnum._('unknownDefaultOpenApi');

HandleDirectRequestDtoActionEnum _$handleDirectRequestDtoActionEnumValueOf(
  String name,
) {
  switch (name) {
    case 'ACCEPT':
      return _$handleDirectRequestDtoActionEnum_ACCEPT;
    case 'DECLINE':
      return _$handleDirectRequestDtoActionEnum_DECLINE;
    case 'unknownDefaultOpenApi':
      return _$handleDirectRequestDtoActionEnum_unknownDefaultOpenApi;
    default:
      return _$handleDirectRequestDtoActionEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<HandleDirectRequestDtoActionEnum>
_$handleDirectRequestDtoActionEnumValues =
    BuiltSet<HandleDirectRequestDtoActionEnum>(
      const <HandleDirectRequestDtoActionEnum>[
        _$handleDirectRequestDtoActionEnum_ACCEPT,
        _$handleDirectRequestDtoActionEnum_DECLINE,
        _$handleDirectRequestDtoActionEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<HandleDirectRequestDtoActionEnum>
_$handleDirectRequestDtoActionEnumSerializer =
    _$HandleDirectRequestDtoActionEnumSerializer();

class _$HandleDirectRequestDtoActionEnumSerializer
    implements PrimitiveSerializer<HandleDirectRequestDtoActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ACCEPT': 'ACCEPT',
    'DECLINE': 'DECLINE',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ACCEPT': 'ACCEPT',
    'DECLINE': 'DECLINE',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[HandleDirectRequestDtoActionEnum];
  @override
  final String wireName = 'HandleDirectRequestDtoActionEnum';

  @override
  Object serialize(
    Serializers serializers,
    HandleDirectRequestDtoActionEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  HandleDirectRequestDtoActionEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => HandleDirectRequestDtoActionEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$HandleDirectRequestDto extends HandleDirectRequestDto {
  @override
  final HandleDirectRequestDtoActionEnum action;

  factory _$HandleDirectRequestDto([
    void Function(HandleDirectRequestDtoBuilder)? updates,
  ]) => (HandleDirectRequestDtoBuilder()..update(updates))._build();

  _$HandleDirectRequestDto._({required this.action}) : super._();
  @override
  HandleDirectRequestDto rebuild(
    void Function(HandleDirectRequestDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  HandleDirectRequestDtoBuilder toBuilder() =>
      HandleDirectRequestDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is HandleDirectRequestDto && action == other.action;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'HandleDirectRequestDto',
    )..add('action', action)).toString();
  }
}

class HandleDirectRequestDtoBuilder
    implements Builder<HandleDirectRequestDto, HandleDirectRequestDtoBuilder> {
  _$HandleDirectRequestDto? _$v;

  HandleDirectRequestDtoActionEnum? _action;
  HandleDirectRequestDtoActionEnum? get action => _$this._action;
  set action(HandleDirectRequestDtoActionEnum? action) =>
      _$this._action = action;

  HandleDirectRequestDtoBuilder() {
    HandleDirectRequestDto._defaults(this);
  }

  HandleDirectRequestDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _action = $v.action;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(HandleDirectRequestDto other) {
    _$v = other as _$HandleDirectRequestDto;
  }

  @override
  void update(void Function(HandleDirectRequestDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  HandleDirectRequestDto build() => _build();

  _$HandleDirectRequestDto _build() {
    final _$result =
        _$v ??
        _$HandleDirectRequestDto._(
          action: BuiltValueNullFieldError.checkNotNull(
            action,
            r'HandleDirectRequestDto',
            'action',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
